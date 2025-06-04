import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:freaking/screens/cart_screen.dart';
import 'package:freaking/screens/product_details_screen.dart';
import '../components/custom_button.dart';
import '../components/custom_containers.dart';
import '../components/custom_navigator.dart';
import '../components/custom_text_field.dart';
import '../components/custom_text_style.dart';
import 'package:freaking/colors/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../components/filter_panel.dart';
import '../widgets/category_products_widget.dart';
import '../widgets/featured_products_widget.dart';
import '../model/product.dart';
import '../routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Pantalla principal de la aplicación.
///
/// Esta clase contiene la interfaz de la pantalla que se muestra después de que el usuario haya iniciado sesión correctamente.
/// En esta pantalla aparecen las listas de productos organizados en categorías y que pueden
/// ser buscados mediante una barra de búsqueda.
/// Desde el perfil se permite al usuario ver y actualizar su nombre, cerrar sesión y solicitar la eliminación de su cuenta.
///
/// También incluye un diálogo de confirmación para salir de la aplicación.
///
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Variable constante que representa el valor del rango de precio por defecto.
  static const _defaultPriceRange = RangeValues(0, 1000);

 /// Variables que guardarán el rango de precio y las listas de categorías y subcategorías seleccionadas.
  RangeValues priceRange = RangeValues(0, 1000);

  /// Lista que almacena los categorías padre seleccionadas en el filtro.
  List<String> selectedParentCategories = [];

  /// Lista que almacena los subcategorías seleccionadas en el filtro.
  List<String> selectedSubCategories = [];

  /// Controlador para el campo de texto del nombre de usuario.
  final TextEditingController userNameController = TextEditingController();

  /// Controlador para el campo de texto de la barra de búsqueda.
  late TextEditingController filterController;

  /// Lista que almacena los productos.
  late List<Product> productList;

  /// Mapa ID de categoría → nombre
  Map<String, String> categoryNamesById = {};

  /// Lista que almacena los productos filtrados por la barra de búsqueda.
  late List<Product> searchList;

  /// Texto ingresado en la barra de búsqueda para filtrar productos.
  String searchText = "";

  /// Booleano que controla el estado para verificar si la aplicación puede cerrarse.
  bool _canPop = false;

  /// Método que recibe y aplica los filtros seleccionados en el panel de filtros.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Comprueba si el usuario tenía texto escrito en la barra de búsqueda antes de aplicar filtros.
  /// 2. Actualiza el estado local con el nuevo rango de precios y las categorías/subcategorías seleccionadas.
  /// 3. Si había texto en la búsqueda, lo borra y limpia el controlador (`filterController`).
  /// 4. Llama a `_search` pasándole el texto (vacío o no) para refrescar la lista de productos mostrados.
  ///
  /// @param filters Mapa que contiene:
  ///   - 'priceRange': RangeValues con el rango de precios seleccionado.
  ///   - 'selectedParentCategories': List<String> de IDs de categorías padre seleccionadas.
  ///   - 'selectedSubcategories': List<String> de IDs de subcategorías seleccionadas.
  void _applyFilters(Map<String, dynamic> filters) {
    /// Variable que comprueba el texto en la barra de búsqueda.
    final currentSearchText = searchText.isNotEmpty;
    
    setState(() {
      /// Se aplican los filtros del panel
      priceRange = filters['priceRange'] ?? priceRange;
      selectedParentCategories = List<String>.from(filters['selectedParentCategories'] ?? []);
      selectedSubCategories = List<String>.from(filters['selectedSubCategories'] ?? []);

      /// Si ya había texto, se resetea el campo de búsqueda
      if (currentSearchText) {
        searchText = '';
        filterController.clear();
      }
    });

    /// Vuelve a filtrar la lista (con searchText vacío)
    _search(searchText);
  }


  /// Método para filtrar la lista de productos según texto de búsqueda, rango de precio y categorías.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Convierte la consulta recogida del campo de la barra de búsqueda a minúsculas.
  /// 2. Recorre cada producto en `productList` y evalúa:
  ///    a) `nameMatch`: si el nombre de algún producto coincide con la query.
  ///    b) `categoryNameMatch`: si alguno de los nombres de sus categorías contiene la query.
  ///    c) `priceMatch`: si el precio está dentro de `priceRange`.
  ///    d) `categoryFilterMatch`: si cumple los filtros de categorías/subcategorías seleccionadas
  ///       (o siempre `true` si no hay filtros activos).
  /// 3. Incluye el producto en `searchList` solo si todas las condiciones necesarias se cumplen.
  /// 4. Llama a `setState` para actualizar la UI con los resultados filtrados.
  ///
  /// @param query Texto ingresado por el usuario en la barra de búsqueda.
  void _search(String query) {
    final searchQuery = query.toLowerCase();
    setState(() {
      searchList = productList.where((product) {
        /// Nombre del producto
        final nameMatch = product.name.toLowerCase().contains(searchQuery);
        /// Nombre de la categoría
        final categoryNameMatch = product.categories.any((categoryId) {
          final categoryName = categoryNamesById[categoryId]?.toLowerCase() ?? '';
          return categoryName.contains(searchQuery);
        });
        /// Rango de precio
        final priceMatch = product.price >= priceRange.start && product.price <= priceRange.end;
        /// Filtro de selección
        final categoryFilterMatch = (selectedSubCategories.isEmpty && selectedParentCategories.isEmpty)
            ? true
            : product.categories.any((cid) =>
            selectedSubCategories.contains(cid)
            || selectedParentCategories.contains(cid));
        return (nameMatch || categoryNameMatch) && priceMatch && categoryFilterMatch;
      }).toList();
    });
  }

  /// Método para mostrar el panel de filtros y gestionar el foco del teclado.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Desenfoca cualquier campo de texto activo para ocultar el teclado antes de abrir el panel de filtros.
  /// 2. Abre un `ModalBottomSheet` que contiene el `FilterPanel`, pasando los filtros actuales:
  ///    - `priceRange`
  ///    - `selectedParentCategories`
  ///    - `selectedSubCategories`
  /// 3. Define un callback `onFiltersApplied` que recibirá la nueva configuración de filtros.
  /// 4. Usa `.whenComplete` para volver a desenfocar al cerrar el modal por cualquier motivo
  ///    (botón de cruz, tap fuera o back button), evitando que el teclado reaparezca.
  ///
  /// @see FilterPanel
  void _openFilterPanel() {
    /// Desenfoque de cualquier campo activo para ocultar el teclado.
    FocusScope.of(context).unfocus();
    /// Apertura del modal de filtros con el estado actual.
    showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => FilterPanel(
        initialFilters: {
          'priceRange': priceRange,
          'selectedParentCategories': selectedParentCategories,
          'selectedSubCategories': selectedSubCategories,
        },
        onFiltersApplied: _applyFilters,
      ),
    /// Callback que se ejecuta al cerrar el modal por cualquier vía.
    ).whenComplete(() {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }




  /// Método para cargar el nombre de usuario almacenado localmente.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Obtiene una instancia de `SharedPreferences`.
  /// 2. Recupera el valor asociado a la clave `'name'`, devolviendo `''` si no existe.
  /// 3. Actualiza el `TextEditingController` (`userNameController`) con el nombre recuperado,
  ///    provocando que la UI muestre el nombre correcto.
  ///
  /// @see SharedPreferences
  Future<void> _loadUserName() async {
    /// Instancia de SharedPreferences.
    final prefs = await SharedPreferences.getInstance();

    /// Lectura del nombre de usuario, tien un valor por defecto si no existe.
    final userName = prefs.getString('name') ?? '';

    /// Actualización del controlador de texto para reflejar el nombre en la UI.
    setState(() {
      userNameController.text = userName;
    });
  }


  /// Método para restablecer los filtros del panel a su estado inicial.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Restaura `priceRange` al valor por defecto (`_defaultPriceRange`).
  /// 2. Vacía las listas de `selectedParentCategories` y `selectedSubCategories`.
  /// 3. Vuelve a ejecutar la búsqueda con el texto actual (`searchText`) para refrescar la lista de productos.
  ///
  /// @see _defaultPriceRange
  /// @see _search
  void _clearPanelFilters() {
    setState(() {
      /// Se restablece el rango de precio al valor por defecto.
      priceRange = _defaultPriceRange;
      /// Se limpian las categorías seleccionadas.
      selectedParentCategories.clear();
      selectedSubCategories.clear();
    });
      /// Se refresca la búsqueda con el texto actual.
    _search(searchText);
  }

  /// Inicializa el estado del widget y lanza las cargas iniciales.
  ///
  /// Este método realiza las siguientes tareas en orden:
  /// 1. Llama a `super.initState()` para la inicialización base.
  /// 2. Inicializa el `TextEditingController` para la barra de búsqueda (`filterController`).
  /// 3. Inicializa `productList` y `searchList` como listas vacías.
  /// 4. Invoca al método `_fetchData()` para obtener los productos en tiempo real desde Firestore.
  /// 5. Invoca al método `_loadUserName()` para cargar el nombre del usuario desde SharedPreferences.
  /// 6. Invoca al método`_loadCategories()` para cargar el mapa de nombres de categorías desde Firestore.
  @override
  void initState() {
    /// Llama al método initState para inicializar el estado del widget.
    super.initState();

    /// Inicialización del controlador de texto para la barra de búsqueda.
    filterController = TextEditingController();

    /// Inicialización de las listas de productos y búsqueda como listas vacías.
    productList = [];
    searchList = [];

    /// Llamada al método _fetchData() para obtener los datos de los productos desde la base de datos.
    _fetchData();

    /// Llamada al método _loadUserName() para cargar el nombre de usuario almacenado en SharedPreferences.
    _loadUserName();

    /// Llamada al método _loadCategories() para cargar el nombre de usuario almacenado en SharedPreferences.
    _loadCategories();
  }

    /// Método que carga y mantiene actualizada la lista de productos desde Firestore.
    ///
    /// Este método realiza las siguientes tareas:
    /// 1. Se conecta en tiempo real a la colección `products` de Firestore.
    /// 2. Cuando se producen cambios (añadidos, modificados o eliminados), recibe un `snapshot`.
    /// 3. Se comprueba si hay documentos en el snapshot de la colección:
    ///    - Si hay:
    ///      a) Se imprime en consola la cantidad de documentos recibidos.
    ///      b) Se convierte cada `DocumentSnapshot` en un objeto `Product` con `Product.fromFirestore`.
    ///      c) Se actualiza `productList` y se clona esa lista en `searchList` para las búsquedas.
    ///      d) Se imprime en consola el total de productos cargados.
    ///    - Si no hay documentos, se imprime un mensaje indicando que la colección está vacía.
    /// 4. Se capturan errores de conexión o permisos y los imprime en consola.
    ///
    /// @see Product.fromFirestore
    /// @see productList
    /// @see searchList
   _fetchData() {
    /// Se escuchan los cambios en la colección 'products' de Firestore.
    FirebaseFirestore.instance.collection('products').snapshots().listen((snapshot) {

      /// Verificación que comprueba si hay documentos en la colección.
      if (snapshot.docs.isNotEmpty) {
        print('Documentos obtenidos de Firestore: ${snapshot.docs.length}');

        setState(() {
          /// Conversión de los documentos de Firestore en objetos de tipo Product.
          productList = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

          /// Copiado de la lista de productos para su uso en la búsqueda.
          searchList = List.from(productList);
        });

        print('Número de productos obtenidos: ${productList.length}');
      } else {
        print('No se encontraron documentos en Firestore.');

      }
    }, onError: (error) {
      /// Manejo de errores en caso de que falle la obtención de datos.
      print('Error al obtener los productos: $error');
    });
  }

  /// Método para cargar los nombres de todas las categorías desde Firestore.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Obtiene un snapshot de todos los documentos en la colección `categories`.
  /// 2. Transforma cada documento en una entrada de mapa `ID → nombre`.
  /// 3. Actualiza el estado local (`categoryNamesById`) mediante `setState`.
  ///
  /// Al finalizar, `categoryNamesById` contendrá los nombres de categoría accesibles por su ID.
  ///
  /// @see categoryNamesById
  Future<void> _loadCategories() async {
    /// Consulta de todos los documentos de 'categories'.
    final snap = await FirebaseFirestore.instance.collection('categories').get();
    /// Actualiza el estado añadiendo las categorías actuales de la base de datos al Mapa "categoryNamesById".
    setState(() {
      categoryNamesById = {
        for (var doc in snap.docs)
          doc.id: (doc.data())['name'] as String
      };
    });
  }


  /// Método que guarda el nombre de usuario proporcionado en almacenamiento local.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Obtiene una instancia de `SharedPreferences` para acceder al almacenamiento persistente.
  /// 2. Almacena el valor `newName` bajo la clave `'name'` mediante `setString`.
  ///
  /// @param newName El nombre de usuario que se desea guardar.
  /// @see SharedPreferences
  Future<void> saveNameToPreferences(String newName) async {

    /// Obtención de una instancia de SharedPreferences para acceder a los datos almacenados.
    final prefs = await SharedPreferences.getInstance();

    /// Guardado del nuevo nombre bajo la clave 'name'.
    await prefs.setString('name', newName);
  }

  /// Método que limpia los datos del usuario almacenados localmente.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Obtiene una instancia de `SharedPreferences` para acceder al almacenamiento persistente.
  /// 2. Elimina todos los datos guardados con `prefs.clear()`.
  /// 3. Restablece la bandera `"onboarding"` a `true` para que el usuario pueda volver a ver de nuevo las pantallas de introducción
  ///    la próxima vez que se inicie la aplicación.
  ///
  /// @see SharedPreferences
  Future<void> clearUserData() async {
    /// Se obtiene una instancia de SharedPreferences para acceder a los datos almacenados del usuario.
    final prefs = await SharedPreferences.getInstance();

    /// Se eliminan todos los datos almacenados en SharedPreferences.
    await prefs.clear();

    /// Se restablece el valor de "onboarding" a `true` para indicar que el usuario debe volver a ver las pantallas
    /// de introducción si elimina la aplicación.
    await prefs.setBool("onboarding", true);
  }


  /// Método para cerrar la sesión del usuario y limpiar datos locales.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Cierra la sesión actual en Firebase Authentication.
  /// 2. Borra todos los datos del usuario almacenados en `SharedPreferences` mediante `clearUserData()`.
  /// 3. Navega a la pantalla de login, eliminando el stack de navegación para impedir volver atrás.
  ///
  /// @param context Contexto de Flutter necesario para la navegación.
  /// @see FirebaseAuth.instance.signOut()
  /// @see clearUserData()
  /// @see CustomNavigator.instantNavigationPushNamedAndRemoveUntil
  Future<void> logout(BuildContext context) async {
    try {
      /// Cierre de sesión de Firebase Auth.
      await FirebaseAuth.instance.signOut();

      /// Limpieza de los datos de SharedPreferences.
      await clearUserData();

      /// Redirección del usuario a la pantalla de login y limpieza historial.
      CustomNavigator.instantNavigationPushNamedAndRemoveUntil(context, AppRoutes.loginScreen);

      /// Manejo de errores al intentar cerrar sesión.
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  /// Método para recuperar datos del cliente almacenados localmente.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Obtiene una instancia de `SharedPreferences` para acceder al almacenamiento persistente.
  /// 2. Lee el valor de `'stripeCustomerId'`, que contiene el ID de cliente en Stripe.
  /// 3. Lee el valor de `'name'`, que contiene el nombre del usuario.
  /// 4. Devuelve un `Map<String, String?>` con ambas claves y sus valores correspondientes.
  ///
  /// @return Mapa con:
  ///   - `'stripeCustomerId'`: ID de cliente de Stripe, o `null` si no existe.
  ///   - `'name'`: nombre del usuario, o `null` si no existe.
  /// @see SharedPreferences
  Future<Map<String, String?>> getCustomerData() async {
    /// Obtención de una instancia de SharedPreferences para acceder a los datos almacenados localmente.
    final prefs = await SharedPreferences.getInstance();

    /// Recuperación del identificador de cliente de Stripe almacenado en SharedPreferences.
    String? stripeCustomerId = prefs.getString('stripeCustomerId');

    /// Recuperación del nombre del usuario almacenado en SharedPreferences.
    String? name = prefs.getString('name');

    /// Retorno de un mapa con los valores obtenidos.
    return {
      'stripeCustomerId': stripeCustomerId,
      'name': name,
    };
  }

  /// Método para actualizar el nombre del cliente en Firebase y Stripe con el uso de una Cloud Function.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Recupera el `stripeCustomerId` y el nombre actual del usuario desde SharedPreferences.
  /// 2. Verifica que `stripeCustomerId` exista; si no, registra un error y detiene la operación.
  /// 3. Actualiza el nombre en SharedPreferences mediante `saveNameToPreferences(newName)`.
  /// 4. Construye y envía una solicitud POST a la Cloud Function `updateCustomerName` con:
  ///    - `customerId`: el ID de cliente de Stripe.
  ///    - `newName`: el nuevo nombre proporcionado.
  /// 5. Comprueba el código de estado de la respuesta:
  ///    - Si es 200, actualiza el controlador de texto `userNameController` y registra el éxito.
  ///    - Si no, imprime el código y el cuerpo de error.
  /// 6. Captura y registra excepciones en caso de fallo de la petición HTTP.
  ///
  /// @param newName El nuevo nombre que se asignará al cliente en Stripe y Firebase.
  /// @see getCustomerData()
  /// @see saveNameToPreferences()
  Future<void> updateCustomerNameInFirebase(String newName) async {
    /// Obtención del customerId y nombre de usuario con el método getCustomerData().
    final data = await getCustomerData();

    /// Obtención del `stripeCustomerId` del mapa de datos recuperado desde SharedPreferences.
    String? stripeCustomerId = data['stripeCustomerId'];


    /// Verificación que comprueba si el stripeCustomerId está disponible.
    if (stripeCustomerId == null) {
      print('stripeCustomerId no está disponible en SharedPreferences');
      return;
    }

    /// Actualización del nombre en SharedPreferences con el método saveNameToPreferences(newName).
    await saveNameToPreferences(newName);

    try {
      /// Definición de la URL de la función en Firebase Cloud Functions.
      final url = Uri.parse(
          'https://europe-west3-freaking-76982.cloudfunctions.net/updateCustomerName');

      /// Construcción del cuerpo de la solicitud POST con el customerId y newName.
      final body = jsonEncode({
        'customerId': stripeCustomerId,
        'newName': newName,
      });

      /// Realización de la solicitud POST a la función de Firebase.
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      /// Verificación que comprueba si la solicitud fue exitosa.
      if (response.statusCode == 200) {
        print('Nombre actualizado correctamente en Firebase y Stripe');

        /// Actualización del controlador del campo de texto con el nuevo nombre.
        setState(() {
          userNameController.text = newName;
        });

      } else {
        print('Error al actualizar el nombre: ${response.statusCode}');
        print('Detalles del error: ${response.body}');
      }
    } catch (e) {
      /// Manejo de errores en caso de fallo en la solicitud HTTP.
      print('Error en la solicitud: $e');
    }
  }


  /// Método para verificar si el usuario tiene pedidos pendientes.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Obtiene el `userId` del usuario actualmente autenticado en Firebase Auth.
  /// 2. Consulta en Firestore la subcolección `userOrderRecord` de dicho usuario,
  ///    filtrando por pedidos cuyo campo `orderState` no sea `"received"`.
  /// 3. Determina si existen documentos en el snapshot (es decir, pedidos pendientes).
  /// 4. Imprime en consola el estado y devuelve `true` si hay pedidos pendientes, o `false` en caso contrario.
  /// 5. Captura y maneja excepciones, devolviendo `false` si ocurre algún error.
  ///
  /// @return `true` si el usuario tiene pedidos pendientes; `false` en caso contrario o de error.
  Future<bool> checkPendingOrders() async {
    try {
      /// Obtención del userId del usuario autenticado en Firebase Auth.
      final userId = FirebaseAuth.instance.currentUser!.uid;

      /// Consulta en Firestore de los pedidos del usuario con estado diferente a "received".
      final userOrderSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('userOrderRecord')
          .where('orderState', isNotEqualTo: 'received')
          .get();

      /// Retorna `true` si hay pedidos pendientes, de lo contrario `false`.
      final hasPendingOrders = userOrderSnapshot.docs.isNotEmpty;

      if (hasPendingOrders) {
        print("Existen pedidos pendientes.");
        return true;
      } else {
        print("No hay pedidos pendientes.");
        return false;
      }
    } catch (e) {
      print("Error al verificar pedidos pendientes: $e");
      return false;
    }
  }


  /// Método para solicitar la eliminación de la cuenta del usuario.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Recupera el `stripeCustomerId` y el nombre de usuario almacenados en SharedPreferences.
  /// 2. Obtiene el token de autenticación (`idToken`) del usuario actual de Firebase Auth.
  /// 3. Lanza una petición POST a la Cloud Function `requestAccountDeletion`, enviando:
  ///    - `stripeCustomerId` en el cuerpo.
  ///    - `Authorization: Bearer <idToken>` en la cabecera.
  /// 4. Procesa la respuesta:
  ///    - Si `statusCode == 200` y `responseData['success'] == true`:
  ///      a) Imprime el mensaje de éxito.
  ///      b) Actualiza el campo `accountState` del usuario en Firestore a `"disabled"`.
  ///      c) Redirige al usuario a la pantalla de registro eliminando el historial de navegación.
  ///    - Si hay error en la respuesta o en la petición, imprime los detalles y muestra una notificación de error.
  /// 5. Captura excepciones durante el proceso y muestra la notificación de error correspondiente.
  ///
  /// @param context Contexto de Flutter necesario para navegación y notificaciones.
  /// @see getCustomerData()
  /// @see FirebaseAuth.instance.currentUser
  /// @see CustomNavigator.instantNavigationPushNamedAndRemoveUntil
  Future<void> requestAccountDeletion(BuildContext context) async {
    try {
      /// Obtención del customerId y nombre de usuario con el método getCustomerData().
      final data = await getCustomerData();

      /// Obtención del `stripeCustomerId` del mapa de datos recuperado desde SharedPreferences.
      String? stripeCustomerId = data['stripeCustomerId'];

      /// Obtención del token de autenticación del usuario actual.
      final user = FirebaseAuth.instance.currentUser;

      /// Obtención del token de autenticación (idToken) del usuario actual de Firebase.
      final idToken = await user?.getIdToken();

      /// Verificación que comprueba si idToken es null.
      if (idToken == null) {
        throw Exception("No se pudo obtener el token de autenticación.");
      }

      /// URL de la función a la Cloud Function que maneja la eliminación de cuentas.
      final url = Uri.parse(
          'https://europe-west3-freaking-76982.cloudfunctions.net/requestAccountDeletion');

      /// Cuerpo de la solicitud con los datos requeridos.
      final body = jsonEncode({'stripeCustomerId': stripeCustomerId});

      /// Realización de la solicitud POST a la función de Firebase.
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken', // Token de autenticación.
        },
        body: body,
      );

      /// Manejo de la respuesta de Firebase.
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          print(responseData['message']);

          /// Actualización del estado de la cuenta en Firestore a "disabled".
          final userDocRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
          await userDocRef.update({'accountState': 'disabled'});
          print('El estado de la cuenta se actualizó a "disabled".');

          /// Redirección del usuario a la pantalla de registro.
          CustomNavigator.instantNavigationPushNamedAndRemoveUntil(
              context, AppRoutes.registerScreen);
        } else {
          print('Error al solicitar la eliminación: ${responseData['message']}');
          showAccountDeletionErrorNotification(context);
        }
      } else {
        print('Error en la llamada a Firebase: ${response.statusCode}');
        print('Detalles del error: ${response.body}');
        showAccountDeletionErrorNotification(context);
      }
    } catch (e) {
      print("Error al solicitar la eliminación de la cuenta: $e");
      showAccountDeletionErrorNotification(context);
    }
  }


  /// Método para mostrar una alerta de error al intentar eliminar la cuenta.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Construye y muestra un `AlertDialog` modal con:
  ///    - Título que informa de pedidos en curso.
  ///    - Mensaje recomendando esperar a la finalización de los pedidos.
  ///    - Un botón “Aceptar” que cierra el diálogo.
  /// 2. Utiliza los estilos definidos en `dialogTheme` y los colores del tema actual.
  ///
  /// @param context Contexto de Flutter necesario para mostrar el diálogo.
  /// @see ThemeData.dialogTheme
  void showAccountDeletionErrorNotification(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text("Hemos detectado algún pedido en curso en su cuenta.",
                style: Theme.of(context).dialogTheme.titleTextStyle),
            backgroundColor: Theme.of(context).colorScheme.surface,
            content: Text(
              "Le recomendamos no eliminar su cuenta hasta que sus pedidos se hayan completado para evitar posibles problemas y seguir tener un seguimiento de estos.",
              style: Theme.of(context).dialogTheme.contentTextStyle,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Aceptar",
                  style: Theme.of(context).dialogTheme.contentTextStyle,
                ),
              ),
            ],
          ),
    );
  }

  /// Método para mostrar un diálogo de confirmación antes de salir de la aplicación.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Muestra un `AlertDialog` modal que pregunta al usuario si desea salir de la aplicación.
  ///    - `barrierDismissible: false` impide cerrar el diálogo tocando fuera.
  ///    - Título y contenido usan los estilos definidos en `dialogTheme`.
  ///    - Botones de acción: “Cancelar” (devuelve `false`) y “Salir” (devuelve `true`).
  /// 2. Espera la respuesta del usuario:
  ///    - Si devuelve `true`, marca `_canPop = true` en el estado y cierra la app con `SystemNavigator.pop()`.
  ///    - Si devuelve `false` o `null`, simplemente cierra el diálogo y la app continúa abierta.
  ///
  /// @param context Contexto de Flutter necesario para mostrar el diálogo y navegar.
  /// @see SystemNavigator.pop()
  Future<void> _showExitDialog(BuildContext context) async {
    bool? exitApp = await showDialog(
      context: context,
      /// Permite que el diálogo no se cierre si se toca fuera de este.
      barrierDismissible: false,
      builder: (context) =>
          AlertDialog(
            title: Text('¿Quieres salir de la aplicación?',
                style: Theme.of(context).dialogTheme.titleTextStyle),
            content: Text('Presiona "Salir" para cerrar la aplicación.',
                style: Theme.of(context).dialogTheme.contentTextStyle),
            actions: [
              TextButton(
                /// Botón “Cancelar”: cierra el diálogo con valor false.
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancelar',
                    style: Theme.of(context).dialogTheme.contentTextStyle),
              ),
              /// Botón “Salir”: cierra el diálogo con valor true.
              CustomButton.customElevatedButtonWithText(
                onPressed: () => Navigator.of(context).pop(true),
                text: 'Salir',
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).colorScheme.primary,
                customTextStyle: CustomTextStyle.whiteSemiBold14WithShadow,
              ),
            ],
          ),
    );
    /// Si el usuario confirmó, actualiza el estado y cierra la aplicación.
    if (exitApp ?? false) {
      setState(() {
        _canPop = true;
      });
      /// Cerrar la aplicación.
      SystemNavigator.pop();
    }
  }

    /// Widget que construye la interfaz de la pantalla principal de la aplicación.
    ///
    /// El widget encargado de la interfaz de la pantalla, realiza las siguientes tareas:
    /// 1. Genera una lista de los productos que estén destacados filtrando los productos con `featured == true`.
    /// 2. Agrupa todos los productos filtrados (`searchList`) en un mapa `productsByCategory`
    ///    donde la clave es el ID de categoría y el valor es la lista de productos de esa categoría.
    /// 3. Envuelve la pantalla en un `PopScope` para gestionar el botón “atrás”:
    ///    - Usa `_canPop` para permitir o impedir el cierre de la app.
    ///    - Llama a `_showExitDialog` para mostrar un diálogo de confirmación antes de salir de la aplicación.
    /// 4. Dentro del `Scaffold`, organiza el conjunto en un `Stack` para superponer:
    ///    a) Encabezado decorativo con `CustomContainer().header(context)`.
    ///    b) Título principal centrado (“FREAKING”).
    ///    c) Botón de perfil (abre diálogo de usuario).
    ///    d) Fila de filtro + barra de búsqueda:
    ///       - Botón de filtros que abre `_openFilterPanel()`.
    ///       - `CustomTextField` con lógica de 'onChanged' y 'onSubmitted' para buscar.
    ///    e) `Divider` con color dinámico.
    ///    f) `ListView` de contenido principal:
    ///       1) `FeaturedProductsWidget` si hay productos destacados.
    ///       2) Por cada entrada de `productsByCategory`, un `CategoryProductsWidget`.
    ///    g) Botón de cesta en la esquina superior derecha.
    ///
    /// Al final, todos los elementos están posicionados con `Positioned` para un layout exacto.
    ///
    @override
    Widget build(BuildContext context) {
      /// Generación de lista de productos destacados, filtrados según el atributo `featured`.
      List<Product> featuredProducts = productList.where((product) => product.featured).toList();
      print('Número de productos destacados: ${featuredProducts.length}');

      /// Declaración de un mapa para organizar los productos según su categoría.
      Map<String, List<Product>> productsByCategory = {};

      /// Se recorre la lista de productos filtrados (searchList) y los agrupa por categoría.
      for (var product in searchList) {
        for (var category in product.categories) {
          /// Si la categoría no existe en el mapa, la inicializa con una lista vacía.
          productsByCategory.putIfAbsent(category, () => []);

          /// Agrega el producto a la categoría correspondiente.
          productsByCategory[category]!.add(product);
        }
      }

      return PopScope(

        /// Uso del booleano _canPop si la aplicación puede cerrarse con la navegación hacia atrás.
        canPop: _canPop,

        /// Manejador de eventos de navegación que se ejecuta cuando el usuario intenta salir de la aplicación.
        onPopInvokedWithResult: (didPop, result) async {
          /// Si la acción de "pop" ya ocurrió, no se realiza otra acción.
          if (didPop) {
            return;
          }

          /// Muestra del diálogo de confirmación.
          await _showExitDialog(context);
        },

        child: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [

                    /// Contenedor con forma ovalada que actua como decoración para el título de encabezado de cada pantalla.
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: CustomContainer().header(context),
                    ),

                    /// Título principal de la aplicación, alineado en el centro.
                    Positioned(
                      top: 45,
                      left: 0,
                      right: 0,
                      child: Text(
                        "FREAKING",
                        style: CustomTextStyle.whiteSemiBold30,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    /// Botón circular que abre el diálogo del perfil del usuario.
                    Positioned(
                      top: 40,
                      left: 14,
                      child: CustomButton.customCircularElevatedButtonWithIcon(
                        onPressed: () {
                          /// Llamada del metodo que muestra el diálogo del perfil de usuario.
                          showUserProfileDialog(
                            context,
                            userNameController,
                          );
                        },
                        icon: SvgPicture.asset('assets/svg/icon/Person.svg'),
                        backgroundColor: AppColors.purple3,
                        size: 70,
                      ),
                    ),
                    /// Botón circular para acceder a la cesta.
                    Positioned(
                      top: 40,
                      right: 14,
                      child: CustomButton.customCircularElevatedButtonWithIcon(
                        onPressed: () {
                          CustomNavigator.sharedAxisNavigationPush(context: context, page: CartScreen());
                        },
                        icon: SvgPicture.asset('assets/svg/icon/Shopping.svg'),
                        backgroundColor: AppColors.purple3,
                        size: 70,
                      ),
                    ),

                    /// Contenedor que incluye el botón de filtro y la barra de búsqueda.
                    Positioned(
                      top: 130,
                      left: 14,
                      right: 14,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          /// Botón de filtro para aplicar filtros personalizados a la lista de productos.
                          CustomButton.CustomRoundedSquareElevatedButtonWithIcon(
                            onPressed: () {
                              _openFilterPanel();
                            },
                            icon: SvgPicture.asset('assets/svg/icon/Filter.svg'),
                            backgroundColor: AppColors.purple3,
                            size: 60,
                          ),
                          const SizedBox(width: 10),

                          /// Campo de texto de búsqueda con diseño personalizado.
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25.0),
                                color: AppColors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    offset: const Offset(0, 4),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: CustomTextField.filterField(
                                controller: filterController,

                                /// Estilo de texto dinámico basado en el tema.
                                customTextStyle: CustomTextStyle.dynamicColorSemiBold14WithShadowFilterHT(context),

                                /// Configuración del color del cursor según el tema.
                                cursorColor: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[850]!.withOpacity(0.50)
                                    : Colors.white.withOpacity(0.50),

                                /// Configuración de los colores y bordes del campo de búsqueda.
                                fillColor: Theme.of(context).colorScheme.tertiary,
                                borderColor: Colors.transparent,
                                focusedBorderColor: Colors.transparent,
                                enabledBorderColor: Colors.transparent,
                                borderWidth: 3.0,
                                focusedBorderWidth: 5.0,
                                enabledBorderWidth: 3.0,
                                contentVerticalPadding: 8.0,
                                contentHorizontalPadding: 16.0,

                                /// Texto de ayuda en el campo de búsqueda.
                                hintText: 'Busca por nombre o categoría',

                                /// Estilo del texto de ayuda basado en el tema actual.
                                hintStyle: Theme.of(context).brightness == Brightness.dark
                                    ? CustomTextStyle.whiteOpacity50SemiBold14WithShadow // Tema oscuro
                                    : CustomTextStyle.greyOpacity50SemiBold14WithShadow, // Tema claro

                                /// Icono de la lupa dentro del campo de búsqueda.
                                prefixIcon: SvgPicture.asset('assets/svg/icon/Magnifier.svg'),
                                onIconTap: () {

                                },
                                /// Función que se ejecuta cuando el usuario envía el texto en la barra de búsqueda
                                /// (por ejemplo, al presionar "Enter" en el teclado).
                                onFieldSubmitted: _search,

                                /// Función que se ejecuta cada vez que el usuario escribe o modifica el texto en la barra de búsqueda.
                                /// Permite actualizar la lista de productos en tiempo real mientras se escribe.
                                onChanged: (val) {
                                  /// si es el primer carácter y había algún filtro activo, se resetea.
                                  if (val.length == 1 &&
                                      (selectedParentCategories.isNotEmpty ||
                                          selectedSubCategories.isNotEmpty ||
                                          priceRange != _defaultPriceRange)
                                  ) {
                                    _clearPanelFilters();
                                  }
                                  searchText = val;
                                  _search(val);
                                },

                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    /// Línea divisoria
                    Positioned(
                        top: 196,
                        left: 0,
                        right: 0,
                        child: Divider(
                            thickness: 3,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.purple3
                                : AppColors.green)
                    ),
                    /// Sección principal que muestra la lista de productos en la pantalla.
                    Positioned(
                      top: 206,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: ListView(
                        children: [
                          /// Sección de productos destacados.Si hay productos marcados como destacados,
                          /// se muestra el widget FeaturedProductsWidget al que se le pasa la lista
                          /// de productos destacados para la generación de la card de cada producto.
                          if (featuredProducts.isNotEmpty)
                            FeaturedProductsWidget(
                              products: featuredProducts,
                              onProductTap: (product) {
                                // Construye la lista formateada ["id: nombre", ...]
                                final idCategoryName = product.categories.map((id) {
                                  final name = categoryNamesById[id] ?? 'desconocida';
                                  return '$id: $name';
                                }).join(', ');
                                print('➡️ Producto clicado ➡️ '
                                    'ID=${product.id}, '
                                    'Nombre=${product.name}, '
                                    'Precio=${product.price}€, '
                                    'Categorías=[$idCategoryName]');
                                CustomNavigator.instantNavigationPush(
                                  context,
                                  ProductDetailsScreen(product: product),
                                );
                              },
                            ),
                          /// Sección de productos organizados por categoría.
                          Column(
                            children: productsByCategory.entries.map((entry) {
                              /// Identificador único de la categoría.
                              String categoryId = entry.key;

                              /// Obtención de la referencia del documento de la categoría en Firestore.
                              DocumentReference categoryRef = FirebaseFirestore.instance.collection('categories').doc(categoryId);

                              /// Widget que muestra los productos agrupados por categoría.
                              return CategoryProductsWidget(
                                categoryRef: categoryRef,
                                products: entry.value,
                                onProductTap: (product) {
                                  // Construye la lista formateada ["id: nombre", ...]
                                  final idCategoryName = product.categories.map((id) {
                                    final name = categoryNamesById[id] ?? 'desconocida';
                                    return '$id: $name';
                                  }).join(', ');
                                  print('➡️ Producto clicado ➡️ '
                                      'ID=${product.id}, '
                                      'Nombre=${product.name}, '
                                      'Precio=${product.price}€, '
                                      'Categorías=[$idCategoryName]');
                                  CustomNavigator.instantNavigationPush(
                                    context,
                                    ProductDetailsScreen(product: product),
                                  );
                                },
                              );
                              /// Conversión de los elementos en una lista de widgets.
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

  /// Diálogo emergente que muestra el perfil del usuario y permite:
  /// 1. Modificar el nombre de usuario.
  /// 2. Guardar los cambios tanto en SharedPreferences como en Firebase/Stripe.
  /// 3. Cerrar sesión con confirmación.
  /// 4. Solicitar eliminación de la cuenta con confirmación.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Muestra un `AlertDialog` con:
  ///    - Un campo de texto para editar el nombre (controlado por `userNameController`).
  ///    - Botones para guardar cambios, cerrar sesión y eliminar la cuenta.
  ///    - Un botón “Cerrar” para descartar el diálogo.
  /// 2. Al pulsar “Guardar modificaciones”:
  ///    a) Guarda el nuevo nombre localmente (`saveNameToPreferences`).
  ///    b) Envía la actualización a Firebase/Stripe (`updateCustomerNameInFirebase`).
  ///    c) Muestra un `SnackBar` de confirmación.
  /// 3. Al pulsar “Cerrar sesión”, lanza `showLogoutDialog`.
  /// 4. Al pulsar “Eliminar cuenta”, lanza `showDeleteAccountDialog`.
  ///
  /// @param context Contexto de Flutter para mostrar el diálogo y navegar.
  /// @param userNameController Controlador que contiene y actualiza el texto del nombre de usuario.
  Future<void> showUserProfileDialog(BuildContext context, TextEditingController userNameController) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Perfil de usuario"),
          titleTextStyle: Theme.of(context).dialogTheme.titleTextStyle,
          elevation: 24.0,
          backgroundColor: Theme.of(context).colorScheme.surface,  // Color de fondo.

          /// Contenido principal del diálogo.
          content: Container(
            width: 300.0,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    "Modificar nombre de usuario",
                    style: Theme.of(context).dialogTheme.contentTextStyle,
                  ),
                  const SizedBox(height: 10),
                  /// Campo de texto para modificar el nombre de usuario.
                  CustomTextField.customField(
                    controller: userNameController,  // Controlador del campo de texto.
                    customTextStyle: Theme.of(context).dialogTheme.contentTextStyle!,
                    cursorColor: Theme.of(context).colorScheme.primary,
                    fillColor: AppColors.purple1,  // Color de fondo del campo.
                    borderColor: Theme.of(context).colorScheme.primary,  // Color del borde.
                    focusedBorderColor: Theme.of(context).colorScheme.primary,
                    enabledBorderColor: Theme.of(context).colorScheme.primary,
                    borderWidth: 3.0,
                    focusedBorderWidth: 5.0,
                    enabledBorderWidth: 3.0,
                    contentVerticalPadding: 8.0,
                    contentHorizontalPadding: 16.0,
                  ),
                  const SizedBox(height: 10),

                  /// Botón para guardar los cambios del nombre de usuario.
                  CustomButton.customElevatedButtonWithText(
                    onPressed: () async {
                      /// Llamada del método saveNameToPreferences para guardar el nombre modificado.
                      await saveNameToPreferences(userNameController.text);
                      /// Llamada del método updateCustomerNameInFirebase para guardar y actua
                      await updateCustomerNameInFirebase(userNameController.text);
                    },
                    text: 'Guardar modificaciones',
                    foregroundColor: AppColors.white,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    customTextStyle: CustomTextStyle.whiteSemiBold14WithShadow,
                  ),

                  const SizedBox(height: 10),

                  /// Botón para cerrar sesión.
                  CustomButton.customElevatedButtonWithText(
                    onPressed: () {
                      /// LLamada a la función que muestra el diálogo de confirmación para cerrar sesión.
                      showLogoutDialog(context);
                    },
                    text: 'Cerrar sesión',
                    foregroundColor: AppColors.white,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    customTextStyle: CustomTextStyle.whiteSemiBold14WithShadow,
                  ),

                  const SizedBox(height: 10),

                  /// Botón para eliminar la cuenta.
                  CustomButton.customElevatedButtonWithText(
                    onPressed: () {
                      /// Llamada a la función que muestra el diálogo de confirmación para eliminar la cuenta.
                      showDeleteAccountDialog(context);
                    },
                    text: 'Eliminar cuenta',
                    foregroundColor: AppColors.white,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    customTextStyle: CustomTextStyle.whiteSemiBold14WithShadow,
                  ),
                ],
              ),
            ),
          ),

          /// Botón de cierre del diálogo.
          actions: <Widget>[
            TextButton(
              child: Text("Cerrar", style: Theme.of(context).dialogTheme.contentTextStyle),
              onPressed: () {
                Navigator.of(context).pop();  // Cierra el diálogo.
              },
            ),
          ],
        );
      },
    );
  }


  /// Diálogo de confirmación para cerrar sesión del usuario.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Muestra un `AlertDialog` modal con:
  ///    - Título “Cierre de sesión”.
  ///    - Mensaje advirtiendo que se está a punto de cerrar la sesión.
  ///    - Botón “Cancelar” que simplemente cierra el diálogo.
  ///    - Botón “Aceptar” que procede a cerrar sesión.
  /// 2. Al pulsar “Aceptar”:
  ///    a) Llama a `logout(context)` para realizar el cierre de sesión.
  ///    b) Muestra un `SnackBar` confirmando que la sesión se cerró correctamente.
  /// 3. Gestiona el diálogo sin estilos de barrera personalizada (se cierra al tocar fuera).
  ///
  /// @param context Contexto de Flutter necesario para mostrar el diálogo y navegación.
  /// @see logout()
  Future<void> showLogoutDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          /// Título del cuadro de diálogo.
          title: Text("Cierre de sesión"),
          elevation: 24.0,
          backgroundColor: Theme.of(context).colorScheme.surface,

          /// Mensaje de advertencia para el usuario.
          content: Text(
            "Está a punto de cerrar la sesión de la cuenta actual. ¿Desea continuar?",
            style: Theme.of(context).dialogTheme.contentTextStyle,
          ),

          actions: <Widget>[
            /// Botón para cancelar la acción y cerrar el diálogo.
            TextButton(
              child: Text(
                "Cancelar",
                style: Theme.of(context).dialogTheme.contentTextStyle,
              ),
              onPressed: () {
                /// Cierra el diálogo sin cerrar sesión.
                Navigator.of(context).pop();
              },
            ),

            /// Botón para confirmar el cierre de sesión.
            CustomButton.customElevatedButtonWithText(
              onPressed: () async {
                /// Llamada de la función de cierre de sesión.
                await logout(context);
              },
              text: 'Aceptar',
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).colorScheme.primary,
              customTextStyle: CustomTextStyle.whiteSemiBold14WithShadow,
            ),
          ],
        );
      },
    );
  }


  /// Diálogo de confirmación para eliminar la cuenta del usuario.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Muestra un `AlertDialog` modal con:
  ///    - Título “Eliminación de cuenta”.
  ///    - Mensaje advirtiendo sobre la eliminación irreversible y el periodo de retención de datos.
  ///    - Botón “Cancelar” que cierra el diálogo sin tomar acción.
  ///    - Botón “Aceptar” que inicia la solicitud de eliminación.
  /// 2. Al pulsar “Aceptar”:
  ///    a) Llama a `requestAccountDeletion(context)` para procesar la eliminación en backend.
  ///    b) Cierra el diálogo una vez enviada la petición.
  /// 3. Gestiona la interfaz y estilos usando los temas actuales.
  ///
  /// @param context Contexto de Flutter necesario para mostrar el diálogo y navegar.
  /// @see requestAccountDeletion()
  Future<void> showDeleteAccountDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Eliminación de cuenta"),
          elevation: 24.0,
          backgroundColor: Theme.of(context).colorScheme.surface,

          /// Mensaje de advertencia para el usuario.
          content: Text(
            "Está a punto de eliminar toda la información relacionada con su cuenta. \n\n"
                "Por temas de seguridad y manejo de sus datos, estos se conservarán durante un "
                "plazo de 30 días para posibles devoluciones o reembolsos. \n\n"
                "Tenga en cuenta que esta acción no se puede deshacer, ¿Desea continuar?",
            style: Theme.of(context).dialogTheme.contentTextStyle,
          ),

          actions: <Widget>[
            /// Botón para cancelar la acción y cerrar el diálogo.
            TextButton(
              child: Text(
                "Cancelar",
                style: Theme.of(context).dialogTheme.contentTextStyle,
              ),
              onPressed: () {
                /// Cierre del diálogo sin eliminar la cuenta.
                Navigator.of(context).pop();
              },
            ),

            /// Botón para confirmar la eliminación de la cuenta.
            CustomButton.customElevatedButtonWithText(
              onPressed: () async {
                /// Llamada de la función de eliminación de la cuenta.
                await requestAccountDeletion(context);
                /// Cierre del diálogo después de la solicitud.
                Navigator.of(context).pop();
              },
              text: 'Aceptar',
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).colorScheme.primary,
              customTextStyle: CustomTextStyle.whiteSemiBold14WithShadow,
            ),
          ],
        );
      },
    );
  }
}


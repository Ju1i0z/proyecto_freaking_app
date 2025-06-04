import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../colors/app_colors.dart';
import '../components/custom_button.dart';
import '../components/custom_containers.dart';
import '../components/custom_navigator.dart';
import '../components/custom_text_field.dart';
import '../components/custom_text_style.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:http/http.dart' as http;
import '../model/product.dart';
import '../routes/app_routes.dart';
import '../widgets/favorite_products_widget.dart';
import 'cart_screen.dart';

/// Pantalla que muestra la lista de productos deseados o favoritos.
///
/// Esta clase contiene la interfaz de la pantalla que se muestra después de presionar el botón de lista de deseos en el menú inferior de la aplicación.
/// En esta pantalla aparece una lista con los productos seleccionados como favoritos por el usuario.
/// Desde el perfil permite al usuario ver y actualizar su nombre, cerrar sesión, solicitar la eliminación de su cuenta.
///
/// También incluye un diálogo de confirmación para salir de la aplicación.
class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  /// Controlador para el campo de texto del nombre de usuario.
  final TextEditingController userNameController = TextEditingController();

  List<Product> favoriteList = [];

  /// Estado para controlar si la aplicación puede cerrarse.
  bool _canPop = false;


  @override
  void initState() {
    super.initState();
    /// Carga el nombre de usuario almacenado en SharedPreferences al iniciar la pantalla.
    _loadUserName();
  }

  /// Método para cargar el nombre de usuario desde SharedPreferences.
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('name') ?? '';
    setState(() {
      userNameController.text = userName;
    });
  }

  /// Método para guardar el nuevo nombre en SharedPreferences.
  Future<void> saveNameToPreferences(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', newName);
  }

  /// Método para limpiar los datos del usuario en SharedPreferences.
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();

    /// Eliminar el contenido de SharedPreferences.
    await prefs.clear();
    prefs.setBool("onboarding", true);
  }

  /// Método para cerrar sesión.
  Future<void> logout(BuildContext context) async {
    try {
      /// Cerrar sesión de Firebase Auth.
      await FirebaseAuth.instance.signOut();

      /// Limpiar los datos de SharedPreferences.
      await clearUserData();

      /// Navegar a la pantalla de inicio de sesión.
      CustomNavigator.instantNavigationPushNamedAndRemoveUntil(context,
          AppRoutes.loginScreen);

    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  /// Método para obtener el customerId y el nombre desde SharedPreferences.
  Future<Map<String, String?>> getCustomerData() async {
    final prefs = await SharedPreferences.getInstance();
    String? stripeCustomerId = prefs.getString('stripeCustomerId');
    String? name = prefs.getString('name');
    return {
      'stripeCustomerId': stripeCustomerId,
      'name': name,
    };
  }

  /// Método para actualizar el nombre del cliente en Firebase y Stripe.
  Future<void> updateCustomerNameInFirebase(String newName) async {
    final data = await getCustomerData();
    String? stripeCustomerId = data['stripeCustomerId'];

    if (stripeCustomerId == null) {
      print('stripeCustomerId no está disponible en SharedPreferences');
      return;
    }

    /// Actualización del nombre en SharedPreferences.
    await saveNameToPreferences(newName);


    try {
      /// Preparación del URL de la función Firebase
      final url = Uri.parse('https://europe-west3-freaking-76982.cloudfunctions.net/updateCustomerName');

      /// Construcción del cuerpo de la solicitud con los campos customerId y newName.
      final body = jsonEncode({
        'customerId': stripeCustomerId,
        'newName': newName,
      });

      /// Realización de la solicitud POST.
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      /// Manejo de respuesta.
      if (response.statusCode == 200) {
        print('Nombre actualizado correctamente en Firebase y Stripe');

        /// Actualización del controlador con el nuevo nombre.
        setState(() {
          userNameController.text = newName;
        });
      } else {
        print('Error al actualizar el nombre: ${response.statusCode}');
        print('Detalles del error: ${response.body}');
      }
    } catch (e) {
      print('Error en la solicitud: $e');
    }
  }

  /// Método para verificar si hay pedidos pendientes.
  Future<bool> checkPendingOrders() async {
    try {
      /// Obtención del userId desde Firebase Auth.
      final userId = FirebaseAuth.instance.currentUser!.uid;

      /// Verificación de `userOrderRecord` para pedidos no recibidos.
      final userOrderSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('userOrderRecord')
          .where('orderState', isNotEqualTo: 'received')
          .get();

      /// Verificación de si hay pedidos pendientes.
      final hasPendingOrders = userOrderSnapshot.docs.isNotEmpty;

      /// Retornar true si hay pedidos pendientes, false si no.
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

    /// Método para mostrar una notificación de error.
    void showErrorNotification(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
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

  /// Método para solicitar la eliminación de la cuenta.
  Future<void> requestAccountDeletion(BuildContext context) async {
    try {
      /// Obtención de los datos relacionados con el usuario.
      final data = await getCustomerData();
      String? stripeCustomerId = data['stripeCustomerId'];

      /// Obtención del token de autenticación del usuario actual.
      final user = FirebaseAuth.instance.currentUser;
      /// Token de autenticación en los headers.
      final idToken = await user?.getIdToken();

      if (idToken == null) {
        throw Exception("No se pudo obtener el token de autenticación.");
      }

      /// Preparación de la URL de la función Firebase.
      final url = Uri.parse(
          'https://europe-west3-freaking-76982.cloudfunctions.net/requestAccountDeletion');

      /// Construcción del cuerpo de la solicitud con los datos necesarios.
      final body = jsonEncode({
        'stripeCustomerId': stripeCustomerId,
      });

      /// Realización de la solicitud POST.
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: body,
      );

      /// Manejo de respuesta.
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          print(responseData['message']);

          /// Modificación del estado de la cuenta en Firestore.
          final userDocRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
          await userDocRef.update({'accountState': 'disabled'});
          print('El estado de la cuenta se actualizó a "disabled".');

          /// Navegación al usuario a la pantalla principal.
          CustomNavigator.instantNavigationPushNamedAndRemoveUntil(
              context, AppRoutes.registerScreen);
        } else {
          print('Error al solicitar la eliminación de la cuenta: ${responseData['message']}');
          showErrorNotification(context);
        }
      } else {
        print('Error al llamar a la función Firebase: ${response.statusCode}');
        print('Detalles del error: ${response.body}');
        showErrorNotification(context);
      }
    } catch (e) {
      print("Error al solicitar la eliminación de la cuenta: $e");
      showErrorNotification(context);
    }
  }

  /// Método para mostrar el diálogo de confirmación para salir de la aplicación.
  Future<void> _showExitDialog(BuildContext context) async {
    bool? exitApp = await showDialog(
      context: context,
      barrierDismissible: false, // No cerrar tocando fuera del diálogo.
      builder: (context) =>
          AlertDialog(
            title: Text('¿Quieres salir de la aplicación?',
                style: Theme.of(context).dialogTheme.titleTextStyle),
            content: Text('Presiona "Salir" para cerrar la aplicación.',
                style: Theme.of(context).dialogTheme.contentTextStyle),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // No salir.
                child: Text('Cancelar',
                    style: Theme.of(context).dialogTheme.contentTextStyle),
              ),
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

    if (exitApp ?? false) {
      /// Si el usuario confirma que quiere salir.
      setState(() {
        _canPop = true;
      });
      SystemNavigator.pop(); // Cerrar la aplicación.
    }
  }

  /// Stream que escucha en tiempo real la subcolección `favoriteProducts` del usuario.
  ///
  /// 1. Obtiene `uid` del usuario autenticado.
  /// 2. Abona a `collection('users').doc(uid).collection('favoriteProducts').snapshots()`.
  /// 3. Por cada `QuerySnapshot`, mapea cada documento a `Product`:
  ///    - Obtiene `productRef` y descarga el documento de producto.
  ///    - Convierte a instancia `Product.fromFirestore`.
  /// 4. Devuelve un `Stream<List<Product>>` que emite cada lista actualizada.
  Stream<List<Product>> _favoriteProductsStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    /// Se escuchan los cambios en la subcolección:
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favoriteProducts')
        .snapshots()
    /// Se convierte cada QuerySnapshot a List<Product>.
        .asyncMap((querySnap) async {
      final List<Product> lista = [];
      for (final doc in querySnap.docs) {
        /// Se buscamos el documento real de producto:
        final productSnap = await doc['productRef'].get();
        lista.add(Product.fromFirestore(productSnap));
      }
      return lista;
    });
  }



  /// Widget que construye la interfaz de la pantalla "Lista de deseos".
  ///
  /// Estructura principal:
  /// - `PopScope` para interceptar el botón “atrás” y mostrar `_showExitDialog`.
  /// - `Scaffold` con cuerpo en un `Stack`:
  ///   1. `CustomContainer().header(context)` en la posición superior.
  ///   2. Título centralizado “Lista de deseos”.
  ///   3. Botón de perfil en la esquina superior izquierda, que abre un `AlertDialog` con opciones:
  ///      - Modificar nombre de usuario.
  ///      - Cerrar sesión.
  ///      - Eliminar cuenta.
  ///   4. Botón de cesta en la esquina superior derecha.
  ///   5. Debajo, un `Column` que contiene:
  ///      - `Divider` horizontal.
  ///      - `Expanded` con `StreamBuilder<List<Product>>`:
  ///        • Mientras espera datos, muestra `CircularProgressIndicator`.
  ///        • Si hay error, muestra texto con el error.
  ///        • Cuando hay datos, renderiza `FavoriteProductsWidget` con la lista actualizada.
  ///
  @override
  Widget build(BuildContext context) {
    return PopScope(
      /// Controla si la aplicación puede cerrarse.
      canPop: _canPop,
      /// Método que se ejecuta cuando se intenta cerrar la aplicación.
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        /// Mostrar el diálogo de confirmación antes de permitir cerrar la aplicación.
        await _showExitDialog(context);
      },
      child: Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                /// Encabezado de la pantalla.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: CustomContainer().header(context),
                ),
                /// Título de la aplicación.
                Positioned(
                  top: 55,
                  left: 0,
                  right: 0,
                  child: AutoSizeText(
                    "Lista de deseos",
                    style: CustomTextStyle.whiteSemiBold20,
                    textAlign: TextAlign.center,
                  ),
                ),
                /// Botón circular para acceder al perfil del usuario.
                Positioned(
                  top: 40,
                  left: 14,
                  child: CustomButton.customCircularElevatedButtonWithIcon(
                    onPressed: () {
                      /// Muestra un diálogo con las opciones de perfil del usuario.
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Perfil de usuario"),
                            titleTextStyle: Theme.of(context).dialogTheme.titleTextStyle,
                            elevation: 24.0,
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            content: Container(
                              width: 300.0,
                              height: 300.0,
                              child: SingleChildScrollView(
                                child: ListBody(
                                  children:
                                  <Widget>[
                                    /// Campo para modificar el nombre de usuario.
                                    Text(
                                      "Modificar nombre de usuario",
                                      style: Theme.of(context).dialogTheme.contentTextStyle,
                                    ),
                                    const SizedBox(height: 10),
                                    CustomTextField.customField(
                                      controller: userNameController,
                                      customTextStyle: Theme.of(context).dialogTheme.contentTextStyle!,
                                      cursorColor: Theme.of(context).colorScheme.primary,
                                      fillColor: AppColors.purple1,
                                      borderColor: Theme.of(context).colorScheme.primary,
                                      focusedBorderColor: Theme.of(context).colorScheme.primary,
                                      enabledBorderColor: Theme.of(context).colorScheme.primary,
                                      borderWidth: 3.0,
                                      focusedBorderWidth: 5.0,
                                      enabledBorderWidth: 3.0,
                                      contentVerticalPadding: 8.0,
                                      contentHorizontalPadding: 16.0,
                                    ),
                                    const SizedBox(height: 10),
                                    /// Botón para guardar las modificaciones del nombre de usuario.
                                    CustomButton.customElevatedButtonWithText(
                                      onPressed: () async {
                                        await saveNameToPreferences(userNameController.text);
                                        /// Actualiza el nombre en Firebase y Stripe.
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
                                        /// Muestra un diálogo de confirmación para cerrar sesión.
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text("Cierre de sesión"),
                                              titleTextStyle: Theme.of(context).dialogTheme.titleTextStyle,
                                              elevation: 24.0,
                                              backgroundColor: Theme.of(context).colorScheme.surface,
                                              content: Container(
                                                width: 300.0,
                                                height: 300.0,
                                                child: SingleChildScrollView(
                                                  child: ListBody(
                                                    children:
                                                    <Widget>[
                                                      Text(
                                                        "Esta a punto de cerrar la sesión de la cuenta actual. ¿Desea continuar?",
                                                        style: Theme.of(context).dialogTheme.contentTextStyle,
                                                      ),
                                                      const SizedBox(height: 10),

                                                      /// Botón para confirmar el cierre de sesión.
                                                      CustomButton.customElevatedButtonWithText(
                                                        onPressed: () async {
                                                          await logout(context);
                                                        },
                                                        text: 'Aceptar',
                                                        foregroundColor: AppColors.white,
                                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                                        customTextStyle: CustomTextStyle.whiteSemiBold14WithShadow,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text(
                                                    "Cerrar",
                                                    style: Theme.of(context).dialogTheme.contentTextStyle,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
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
                                        /// Muestra un diálogo de confirmación para eliminar la cuenta.
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text("Eliminación de cuenta"),
                                              titleTextStyle: Theme.of(context).dialogTheme.titleTextStyle,
                                              elevation: 24.0,
                                              backgroundColor: Theme.of(context).colorScheme.surface,
                                              content: Container(
                                                width: 300.0,
                                                height: 300.0,
                                                child: SingleChildScrollView(
                                                  child: ListBody(
                                                    children:
                                                    <Widget>[
                                                      Text(
                                                        "Está a punto de eliminar toda la información relacionada con su cuenta. Por temas de seguridad de y manejo de sus datos, estos se oonservarán durante un plazo de 30 días para posibles devoluciones o reembolsos. Tenga en cuenta que esta acción no se puede deshacer, ¿Desea continuar?",
                                                        style: Theme.of(context).dialogTheme.contentTextStyle,
                                                      ),
                                                      const SizedBox(height: 10),
                                                      CustomButton.customElevatedButtonWithText(
                                                        onPressed: () async {
                                                          await requestAccountDeletion(context);
                                                        },
                                                        text: 'Aceptar',
                                                        foregroundColor: AppColors.white,
                                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                                        customTextStyle: CustomTextStyle.whiteSemiBold14WithShadow,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text(
                                                    "Cerrar",
                                                    style: Theme.of(context).dialogTheme.contentTextStyle,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
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
                            actions: <Widget>[
                              TextButton(
                                child: Text(
                                  "Cerrar",
                                  style: Theme.of(context).dialogTheme.contentTextStyle,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
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
                /// Contenedor que engloba el `Divider` y el `StreamBuilder` de favoritos.
                Positioned(
                  top: 120,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Column(
                      children: [
                        /// Línea divisoria horizontal.
                        Divider(
                          thickness: 2.0,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        /// Widget expandido que contiene el StreamBuilder para favoritos.
                        Expanded(
                          child: StreamBuilder<List<Product>>(
                            stream: _favoriteProductsStream(),
                            /// Constructor del snapshot de datos.
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                /// Mientras espera la conexión al stream, muestra spinner.
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                /// En caso de error, muestra texto con el mensaje.
                                return Center(child: Text('Error: ${snapshot.error}'));
                              }
                              /// Cuando hay datos o la lista está vacía:
                              final favList = snapshot.data ?? [];
                              return FavoriteProductsWidget(
                                products: favList,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                )
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}
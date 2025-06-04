import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:freaking/model/product.dart';
import 'package:simple_shadow/simple_shadow.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../colors/app_colors.dart';
import '../components/custom_button.dart';
import '../components/custom_navigator.dart';
import '../components/custom_text_style.dart';
import '../model/user.dart';
import 'cart_screen.dart';

/// Pantalla de detalles de un producto.
///
/// Muestra la información completa de `widget.product`, incluyendo:
/// - Carrusel de imágenes con indicador.
/// - Nombre, categorías, puntos y descripción.
/// - Botones para volver, ir al carrito, marcar/desmarcar favorito y añadir al carrito.
///
/// También precarga las imágenes y carga el estado inicial de favorito.
class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  /// Controla si el producto está en favoritos.
  bool isFavorite = false;

  /// Controlador para el carrusel de imágenes.
  late final PageController _pageController;

  /// Lista de nombres de categorías.
  List<String> _categoryNames = [];

  @override
  void initState() {
    super.initState();
    debugPrint('ProductDetailsScreen seleccionada del producto id=${widget.product.id}');

    /// Inicializa el controlador de páginas.
    _pageController = PageController();

    /// Precarga todas las imágenes para mejorar el rendimiento.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var url in widget.product.images) {
        precacheImage(NetworkImage(url), context);
        debugPrint('precargando imagen: $url');
      }
    });

    /// Obtiene el estado inicial de favorito desde Firestore.
    _existsIn('favoriteProducts').then((v) {
      debugPrint('_existsIn(favoriteProducts) returned $v');
      setState(() => isFavorite = v);
      debugPrint('isFavorite inicial: $v');
    });

    /// 4. Carga los nombres de las categorías del producto.
    _fetchCategoryNames();
  }

  /// Carga y almacena localmente los nombres de las categorías del producto.
  ///
  /// Este método realiza lo siguiente:
  /// 1. Inicializa una lista vacía `names`.
  /// 2. Para cada `catId` en `widget.product.categories`:
  ///    a) Obtiene el documento `/categories/{catId}`.
  ///    b) Si existe, extrae el campo `name` y lo añade a `names`.
  ///    c) Captura y loggea errores individuales sin interrumpir el bucle.
  /// 3. Llama a `setState` para actualizar `_categoryNames` y refrescar la UI.
  Future<void> _fetchCategoryNames() async {
    debugPrint('_fetchCategoryNames: iniciando carga de categorías');
    final names = <String>[];

    for (var catId in widget.product.categories) {
      try {
        debugPrint('Obteniendo categoría id=$catId');
        final doc = await FirebaseFirestore.instance
            .collection('categories')
            .doc(catId)
            .get();
        if (doc.exists) {
          names.add(doc['name'] as String);
          debugPrint('Categoría cargada: ${doc["name"]}');
        } else {
          debugPrint('Categoría $catId no existe');
        }
      } catch (e) {
        print('Error al cargar categoría $catId: $e');
      }
    }

    // Actualiza la UI con los nombres obtenidos.
    setState(() => _categoryNames = names);
    debugPrint('_fetchCategoryNames: categorías cargadas=$_categoryNames');
  }

  /// Verifica si el producto está presente en la subcolección especificada del usuario.
  ///
  /// Este método realiza lo siguiente:
  /// 1. Recupera el usuario actualmente autenticado de Firebase Auth.
  /// 2. Construye la referencia al documento
  ///    `users/{uid}/{subcollection}/{productId}`.
  /// 3. Obtiene el snapshot y devuelve `true` si el documento existe, o `false` si no.
  ///
  /// @param subcollection Nombre de la subcolección (por ejemplo, 'favoriteProducts' o 'cartProducts').
  /// @return `true` si el documento existe; `false` en caso contrario.
  Future<bool> _existsIn(String subcollection) async {
    /// Usuario autenticado
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('_existsIn: usuario no autenticado');
      return false;
    }

    /// Referencia al documento en users/{uid}/{subcollection}/{productId}
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection(subcollection)
        .doc(widget.product.id);

    debugPrint('Comprobando existencia en ${ref.path}');
    /// Comprueba existencia del documento
    final snap = await ref.get();
    debugPrint('_existsIn: snap.exists=${snap.exists}');
    return snap.exists;
  }

  /// Marca o desmarca el producto como favorito en Firestore.
  ///
  /// Este método sigue estos pasos:
  /// 1. Obtiene el usuario autenticado de Firebase Auth.
  /// 2. Construye la referencia al documento en
  ///    `users/{uid}/favoriteProducts/{productId}`.
  /// 3. Comprueba si el documento ya existe:
  ///    - Si existe:
  ///      • Elimina el documento para desmarcar como favorito.
  ///      • Actualiza `isFavorite = false`.
  ///      • Imprime en consola el evento de eliminación.
  ///    - Si no existe:
  ///      • Crea el documento con `{ 'productRef': /products/{productId} }`.
  ///      • Actualiza `isFavorite = true`.
  ///      • Imprime en consola el evento de añadido.
  Future<void> _toggleFavorite() async {
    debugPrint('_toggleFavorite: toggling favorite para producto id=${widget.product.id}');
    /// UID del usuario autenticado
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('_toggleFavorite: usuario no autenticado');
      return;
    }

    /// Referencia al documento de favorito
    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favoriteProducts')
        .doc(widget.product.id);

    /// Comprueba si ya existe
    final snap = await favRef.get();
    if (snap.exists) {
      /// Si existe, elimina y actualiza estado
      await favRef.delete();
      setState(() => isFavorite = false);
      print('Producto [${widget.product.id}: ${widget.product.name}] eliminado de favoritos');
    } else {
      /// Si no existe, crea con referencia al producto y actualiza estado
      await favRef.set({
        'productRef': FirebaseFirestore.instance
            .collection('products')
            .doc(widget.product.id)
      });
      setState(() => isFavorite = true);
      print('Producto [${widget.product.id}: ${widget.product.name}] añadido a favoritos');
    }
  }

  /// Añade el producto al carrito o incrementa su cantidad si ya estaba.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Obtiene el UID del usuario actualmente autenticado en Firebase Auth.
  /// 2. Construye la referencia al documento en la subcolección
  ///    `users/{uid}/cartProducts/{productId}`.
  /// 3. Comprueba si el documento ya existe:
  ///    - Si existe, dispara un `update` con `FieldValue.increment(1)` para aumentar la cantidad.
  ///    - Si no existe, lo crea con:
  ///       • `productRef`: referencia al documento de producto en `/products`.
  ///       • `quantity`: 1.
  ///       • `priceAtAdd`: precio actual del producto.
  /// 4. Muestra un `SnackBar` informando al usuario de la acción realizada.
  /// 5. Actualiza el estado local `inCart` para reflejar que hay al menos una unidad en el carrito.
  ///
  /// @see CartProduct
  /// @see FieldValue.increment
  Future<void> _addToCart() async {
    debugPrint('_addToCart: agregando producto id=${widget.product.id} al carrito');
    // 1) UID del usuario autenticado
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('_addToCart: usuario no autenticado');
      return;
    }

    // 2) Referencia al documento en users/{uid}/cartProducts/{productId}
    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cartProducts')
        .doc(widget.product.id);

    // 3) Comprueba existencia
    final snap = await cartRef.get();
    if (snap.exists) {
      // 3a) Si existe, incrementa la cantidad en 1
      await cartRef.update({
        'quantity': FieldValue.increment(1),
      });
      debugPrint('Cantidad incrementada en la cesta para producto=${widget.product.id}');
    } else {
      // 3b) Si no existe, crea el documento con quantity=1 y priceAtAdd
      await cartRef.set(CartProduct(
        productRef: FirebaseFirestore.instance
            .collection('products')
            .doc(widget.product.id),
        quantity: 1,
        priceAtAdd: widget.product.price,
      ).toFirestore());
      debugPrint('Producto agregado al carrito id=${widget.product.id}');
    }
  }

  /// Construye la interfaz de la pantalla, compuesta por:
  /// - Botones superpuestos para volver y carrito.
  /// - Carrusel de imágenes con indicador.
  /// - Panel inferior blanco con detalles, favorito y añadir al carrito.
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    debugPrint('build() → construyendo UI para producto id=${widget.product.id}');

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                /// Botón “volver”
                Positioned(
                  top: 40,
                  left: 14,
                  child: CustomButton.customCircularElevatedButtonWithIcon(
                    onPressed: () => CustomNavigator.instantNavigationPop(context),
                    icon: SvgPicture.asset('assets/svg/icon/Arrow-Left.svg'),
                    backgroundColor: AppColors.purple3,
                    size: 70,
                  ),
                ),

                /// Botón “carrito”
                Positioned(
                  top: 40,
                  right: 14,
                  child: CustomButton.customCircularElevatedButtonWithIcon(
                    onPressed: () {
                      debugPrint('Navegando a CartScreen');
                      CustomNavigator.sharedAxisNavigationPush(
                          context: context, page: CartScreen());
                    },
                    icon: SvgPicture.asset('assets/svg/icon/Shopping.svg'),
                    backgroundColor: AppColors.purple3,
                    size: 70,
                  ),
                ),

                /// Carrusel de imágenes
                Positioned(
                  top: 125,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: widget.product.images.length,
                          itemBuilder: (_, i) {
                            debugPrint('Mostrando imagen ${i + 1}/${widget.product.images.length}');
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Image.network(
                                widget.product.images[i],
                                fit: BoxFit.contain,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 5),
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: widget.product.images.length,
                        effect: const WormEffect(
                          dotHeight: 12,
                          dotWidth: 12,
                          activeDotColor: Colors.white,
                        ),
                        onDotClicked: (i) {
                          debugPrint('Indicador dotClicked index=$i');
                          _pageController.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeIn,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                /// Panel inferior con detalles
                Positioned(
                  top: 350,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SimpleShadow(
                    opacity: 0.5,
                    color: Colors.black,
                    offset: const Offset(0, 4),
                    sigma: 3,
                    child: Center(
                      child: SizedBox(
                        width: screenWidth,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(50),
                              topRight: Radius.circular(50),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// Nombre
                                    Text(
                                      widget.product.name,
                                      style: CustomTextStyle
                                          .dynamicColorSemiBold20WithShadow(
                                          context),
                                      maxLines: 3,
                                    ),
                                    const SizedBox(height: 5),

                                    /// Categorías
                                    Text(
                                      "Categorías",
                                      style: CustomTextStyle
                                          .dynamicColorSemiBold20WithShadow(
                                          context),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      height: 40,
                                      child: SingleChildScrollView(
                                        child: Text(
                                          _categoryNames.isEmpty
                                              ? 'Cargando categorías...'
                                              : _categoryNames.join(', '),
                                          style: CustomTextStyle
                                              .dynamicColorSemiBold14WithShadow(
                                              context),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    /// Puntos
                                    Text(
                                      "Puntos al comprar",
                                      style: CustomTextStyle
                                          .dynamicColorSemiBold20WithShadow(
                                          context),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                            "assets/svg/icon/Star.svg"),
                                        const SizedBox(width: 5),
                                        Text(
                                          widget.product.pointsForPurchase
                                              .toString(),
                                          style: CustomTextStyle
                                              .dynamicColorSemiBold20WithShadow(
                                              context),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    /// Descripción
                                    Text(
                                      "Descripción",
                                      style: CustomTextStyle
                                          .dynamicColorSemiBold20WithShadow(
                                          context),
                                    ),
                                    const SizedBox(height: 10),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Text(
                                          widget.product.description,
                                          style: Theme.of(context).brightness ==
                                              Brightness.dark
                                              ? CustomTextStyle
                                              .whiteOpacity50SemiBold14WithShadow
                                              : CustomTextStyle
                                              .greyOpacity50SemiBold14WithShadow,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    /// Botón “Añadir a la cesta”
                                    Align(
                                      alignment: Alignment.center,
                                      child: CustomButton
                                          .customElevatedButtonWithTextAndPrice(
                                        onPressed: () {
                                          debugPrint(
                                              'Botón “Añadir a la cesta” presionado');
                                          _addToCart();
                                        },
                                        text: "Añadir a la cesta",
                                        price: "${widget.product.price}€",
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        customTextStyle: CustomTextStyle
                                            .whiteSemiBold14WithShadow,
                                        customPriceStyle:
                                        CustomTextStyle.yellowSemiBold20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// Botón favorito
                              Positioned(
                                left: 16,
                                bottom: 16,
                                child: IconButton(
                                  onPressed: () {
                                    debugPrint('Botón favorito presionado, isFavorite=$isFavorite');
                                    _toggleFavorite();
                                  },
                                  icon: isFavorite
                                      ? SvgPicture.asset(
                                      "assets/svg/icon/FilledFavorite.svg")
                                      : SvgPicture.asset(
                                      "assets/svg/icon/FavoriteBorder.svg"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

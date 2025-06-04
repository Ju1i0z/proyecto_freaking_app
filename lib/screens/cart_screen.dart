import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_shadow/simple_shadow.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../colors/app_colors.dart';
import '../components/custom_button.dart';
import '../components/custom_containers.dart';
import '../components/custom_navigator.dart';
import '../components/custom_text_style.dart';
import '../model/product.dart';
import '../model/user.dart';
import '../widgets/cart_products_widget.dart';
import 'package:auto_size_text/auto_size_text.dart';

/// Pantalla que muestra la lista de productos añadidos a la cesta.
///
/// Esta clase contiene la interfaz de la pantalla que se muestra después de presionar
/// el icono de la cesta. Se muestran los productos añadidos, el total acumulado
/// y un botón para realizar el pago mediante Stripe Checkout (usando price_data).
///
/// Layout general:
/// - Encabezado con CustomContainer().header
/// - Título “Mi cesta” centrado
/// - Botón de retroceso para volver a la pantalla anterior
/// - Lista de productos en la subcolección `cartProducts` en Firestore
/// - Panel inferior con el total y el botón “REALIZAR EL PAGO”
///
/// El flujo de pago:
/// 1. Obtiene customerId desde SharedPreferences
/// 2. Recupera CartProduct de Firestore y construye `items` con {name, unitAmount, quantity}
/// 3. Llama a la Cloud Function `createCheckoutSession` por POST
/// 4. Abre la URL de Checkout en el navegador para simular el pago en modo test.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  /// Booleano que controla si actualmente se está procesando la creación de la sesión.
  /// Cuando es true, el botón de pago muestra “Procesando…” y queda deshabilitado.
  bool isProcessingCheckout = false;

  @override
  void initState() {
    super.initState();
    debugPrint('Pantalla CartScreen iniciada');
  }

  /// Obtiene todos los CartProduct del usuario autenticado.
  ///
  /// Cada documento en `users/{uid}/cartProducts` se mapea a un CartProduct
  /// que incluye:
  ///  - productRef: DocumentReference al documento real en `Products/{productId}`
  ///  - quantity: cantidad que el usuario añadió
  ///  - priceAtAdd: precio unitario (double) en el momento de añadir
  ///
  /// @return Future<List<CartProduct>> con los elementos de la cesta.
  Future<List<CartProduct>> _getCartProducts() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    debugPrint('Obteniendo cartProducts para uid=$uid');
    final cartSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cartProducts')
        .get();

    final List<CartProduct> cartList = cartSnap.docs.map((doc) {
      final data = doc.data();
      return CartProduct(
        productRef: data['productRef'] as DocumentReference,
        quantity:   (data['quantity'] as num).toInt(),
        priceAtAdd: (data['priceAtAdd'] as num).toDouble(),
      );
    }).toList();

    debugPrint('CartProducts obtenidos: ${cartList.length}');
    return cartList;
  }

  /// Construye el arreglo `items` para Stripe Checkout usando price_data.
  ///
  /// Por cada `CartProduct`:
  ///  1. Lee el documento Product para obtener su nombre (`product.name`)
  ///  2. Usa `priceAtAdd` (double en euros) y lo convierte a céntimos internamente en la Function
  ///  3. Devuelve un mapa con:
  ///     {
  ///       'name': productName,
  ///       'unitAmount': priceAtAdd,  // en euros
  ///       'quantity': quantity
  ///     }
  ///
  /// @return Future<List<Map<String, dynamic>>> con los items listos para price_data.
  Future<List<Map<String, dynamic>>> _buildItems() async {
    final cartProducts = await _getCartProducts();
    final List<Map<String, dynamic>> items = [];
    debugPrint('Construyendo items para Stripe');

    for (final cartProd in cartProducts) {
      final productSnap = await cartProd.productRef.get();
      final productData = productSnap.data()! as Map<String, dynamic>;
      final productName = productData['name'] as String;
      final priceEuros = cartProd.priceAtAdd;
      final quantity = cartProd.quantity;

      items.add({
        'name':       productName,
        'unitAmount': priceEuros,
        'quantity':   quantity,
      });

      debugPrint(
          '   • Item agregado → name: $productName, '
              'unitAmount €$priceEuros, quantity: $quantity'
      );
    }

    debugPrint('Items con price_data (flutter): $items');
    return items;
  }

  /// Crea la sesión de Stripe Checkout invocando la Cloud Function `createCheckoutSession`.
  ///
  /// Recibe:
  ///  - customerId: ID del cliente en Stripe (string), obtenido del usuario
  ///  - items: lista de mapas con {name, unitAmount, quantity}
  ///
  /// Envía un JSON por POST a la Function con:
  ///  {
  ///    'customerId': customerId,
  ///    'currency': 'eur',
  ///    'items': items,
  ///    'successUrl': '<tu success URL>',
  ///    'cancelUrl': '<tu cancel URL>'
  ///  }
  ///
  /// La Function debe responder con { 'url': '<checkout_url>' } si todo va bien.
  /// @return Future<String?> con la URL de Checkout, o null si hubo error.
  Future<String?> _createStripeCheckoutSession({
    required String customerId,
    required List<Map<String, dynamic>> items,
  }) async {
    // Asegúrate de usar el endpoint exacto que aparece en Firebase Console
    const functionUrl =
        'https://europe-west3-freaking-76982.cloudfunctions.net/createCheckoutSession';

    final body = jsonEncode({
      'customerId': customerId,
      'currency':   'eur',
      'items':      items,
      'successUrl': 'https://example.com/success', // Ajústalas a tu dominio real
      'cancelUrl':  'https://example.com/cancel',
    });

    debugPrint('Enviando POST a Function: $functionUrl');
    final uri  = Uri.parse(functionUrl);
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    debugPrint(
        'Respuesta Function (price_data): '
            '${resp.statusCode} → ${resp.body}'
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return data['url'] as String;
    } else {
      return null;
    }
  }

  /// Método que se ejecuta al pulsar el botón “REALIZAR EL PAGO”.
  ///
  /// 1. Cambia `isProcessingCheckout` a true para deshabilitar el botón.
  /// 2. Obtiene `stripeCustomerId` desde SharedPreferences.
  /// 3. Construye la lista de `items` con `_buildItems()`. Si está vacía, muestra un SnackBar.
  /// 4. Llama a `_createStripeCheckoutSession` para obtener la URL de Checkout.
  /// 5. Si recibe la URL, la abre en el navegador; si falla, muestra un SnackBar.
  /// 6. Finalmente, vuelve `isProcessingCheckout` a false.
  Future<void> _onPayPressed() async {
    setState(() {
      isProcessingCheckout = true;
    });
    debugPrint('Iniciando flujo de pago');

    try {
      // 1) Obtener customerId de SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final stripeCustomerId = prefs.getString('stripeCustomerId');
      debugPrint('   • stripeCustomerId obtenido: $stripeCustomerId');
      if (stripeCustomerId == null) {
        throw Exception('No tienes un customerId guardado para Stripe.');
      }

      // 2) Construir items con price_data
      final items = await _buildItems();
      if (items.isEmpty) {
        debugPrint('El carrito está vacío, cancelando pago');
        return;
      }

      // 3) Crear sesión de Checkout
      final checkoutUrl = await _createStripeCheckoutSession(
        customerId: stripeCustomerId,
        items:      items,
      );
      if (checkoutUrl == null) {
        debugPrint('No se pudo iniciar Checkout en la Function');
        return;
      }
      debugPrint('URL de Checkout obtenida: $checkoutUrl');

      // 4) Abrir la URL en el navegador
      final uri = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(uri)) {
        debugPrint('Abriendo Checkout en el navegador');
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw Exception('No se pudo abrir la URL de Checkout.');
      }
    } catch (e) {
      debugPrint('Error en _onPayPressed: $e');
    } finally {
      setState(() {
        isProcessingCheckout = false;
      });
      debugPrint('Flujo de pago finalizado');
    }
  }

  /// Stream que emite la lista de Product que corresponden a los CartProduct.
  ///
  /// 1. Obtiene `uid` del usuario autenticado.
  /// 2. Escucha en tiempo real la subcolección `cartProducts`.
  /// 3. Para cada documento de `cartProducts`, lee el `productRef` y descarga el documento real.
  /// 4. Convierte a `Product.fromFirestore` y devuelve `Stream<List<Product>>`.
  Stream<List<Product>> _cartProductsStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cartProducts')
        .snapshots()
        .asyncMap((querySnap) async {
      final List<Product> lista = [];
      for (final doc in querySnap.docs) {
        final productSnap = await doc['productRef'].get();
        lista.add(Product.fromFirestore(productSnap));
      }
      debugPrint('_cartProductsStream emitió ${lista.length} productos');
      return lista;
    });
  }

  /// Stream que emite el total del carrito (double).
  ///
  /// 1. Obtiene `uid` del usuario autenticado.
  /// 2. Escucha la subcolección `cartProducts` en tiempo real.
  /// 3. Suma `priceAtAdd * quantity` para cada documento y emite el total.
  Stream<double> cartTotalStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cartProducts')
        .snapshots()
        .map((querySnap) {
      double total = 0.0;
      for (final doc in querySnap.docs) {
        final data = doc.data();
        final price = (data['priceAtAdd'] as num).toDouble();
        final quantity = (data['quantity'] as num).toDouble();
        total += price * quantity;
      }
      debugPrint('cartTotalStream calculó total: €$total');
      return total;
    });
  }

  //-------------------------------------------------------------------
  // Construcción de la UI en `build()`
  //-------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                /// Encabezado de la pantalla
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: CustomContainer().header(context),
                ),

                /// Título “Mi cesta”
                Positioned(
                  top: 55,
                  left: 0,
                  right: 0,
                  child: AutoSizeText(
                    "Mi cesta",
                    style: CustomTextStyle.whiteSemiBold20,
                    textAlign: TextAlign.center,
                  ),
                ),

                /// Botón “volver” para regresar a la pantalla anterior
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

                /// Contenido del carrito: Divider + lista de productos
                Positioned(
                  top: 120,
                  left: 0,
                  right: 0,
                  bottom: 200, // deja espacio para el panel inferior
                  child: Column(
                    children: [
                      /// Línea divisoria
                      Divider(
                        thickness: 2.0,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      /// Lista de productos en la cesta
                      Expanded(
                        child: StreamBuilder<List<Product>>(
                          stream: _cartProductsStream(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            }
                            final cartList = snapshot.data ?? [];
                            debugPrint('🔄 StreamBuilder recibió ${cartList.length} productos');
                            return CartProductsWidget(products: cartList);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                /// Panel inferior con TOTAL y botón “REALIZAR EL PAGO”
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: StreamBuilder<double>(
                    stream: cartTotalStream(),
                    builder: (context, snapshot) {
                      final total = snapshot.data ?? 0.0;
                      return Container(
                        height: 200,
                        width: screenWidth,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50),
                            topRight: Radius.circular(50),
                          ),
                        ),
                        child: SimpleShadow(
                          opacity: 0.5,
                          color: Colors.black,
                          offset: const Offset(0, 4),
                          sigma: 3,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30.0,
                              vertical: 20.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                /// Fila con “TOTAL:” y el valor calculado
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'TOTAL:',
                                      style: CustomTextStyle.whiteSemiBold20WithShadow,
                                    ),
                                    Text(
                                      '${total.toStringAsFixed(2)} €',
                                      style: CustomTextStyle.whiteSemiBold20WithShadow,
                                    ),
                                  ],
                                ),

                                /// Botón “REALIZAR EL PAGO”
                                SizedBox(
                                  width: double.infinity,
                                  child: CustomButton.customElevatedButtonWithText(
                                    onPressed: isProcessingCheckout
                                        ? () { /* No hacer nada mientras procesa */ }
                                        : _onPayPressed,
                                    text: isProcessingCheckout
                                        ? 'Procesando…'
                                        : 'REALIZAR EL PAGO',
                                    foregroundColor: AppColors.white,
                                    backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                    customTextStyle:
                                    CustomTextStyle.whiteSemiBold14WithShadow,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ], // children del Stack
            ),
          ),
        ], // children del Column
      ),
    );
  }
}

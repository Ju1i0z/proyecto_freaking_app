import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:simple_shadow/simple_shadow.dart';
import '../colors/app_colors.dart';
import '../components/custom_button.dart';
import '../components/custom_containers.dart';
import '../components/custom_navigator.dart';
import '../components/custom_text_style.dart';
import '../model/user.dart';
import 'cart_screen.dart';

/// Pantalla que muestra y gestiona los métodos de pago de un cliente.
///
/// Esta clase contiene la interfaz de la pantalla donde el usuario puede:
///  1. Ver la lista de tarjetas registradas en Stripe (modo prueba).
///  2. Marcar una tarjeta como predeterminada sin salir de la aplicación.
///  3. Acceder al carrito de compras desde el icono del carrito.
///
/// Funcionalidad principal:
///  - Al inicializar (`initState`), se carga la lista de PaymentMethods desde
///    la Cloud Function `paymentMethods?customerId=...`.
///  - Muestra un indicador de carga mientras se obtienen las tarjetas.
///  - Si no hay tarjetas, muestra un mensaje informando al usuario.
///  - Cada tarjeta se renderiza en un ListTile con su marca, últimos 4 dígitos,
///    fecha de vencimiento y un ícono si es la predeterminada.
///  - Al pulsar una tarjeta no predeterminada, aparece un diálogo de confirmación
///    y, si se acepta, se invoca la Cloud Function `setDefaultMethod` para actualizar
///    la tarjeta predeterminada en Stripe y refrescar la lista.
///
/// Navegación:
///  - El botón “volver” regresa a la pantalla anterior.
///  - El botón “carrito” abre la pantalla CartScreen para ver el carrito de compras.
///
/// Uso de debugPrint:
///  - Se añaden debugPrint en puntos clave: inicio de carga, fin de carga,
///    parseo de tarjetas, errores HTTP, inicio de build(), etc.
///
/// @param customerId (String) ID del cliente en Stripe, obtenido al iniciar sesión.
class PaymentMethodsScreen extends StatefulWidget {
  final String customerId;

  const PaymentMethodsScreen({Key? key, required this.customerId})
      : super(key: key);

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  /// Indica si actualmente se está cargando la lista de tarjetas.
  bool isLoading = false;

  /// Lista de objetos PaymentMethod que se mostrarán en la pantalla.
  List<PaymentMethod> tarjetas = [];

  @override
  void initState() {
    super.initState();
    debugPrint('Pantalla PaymentMethodsScreen iniciada');
    debugPrint('customerId=${widget.customerId}');
    _loadCards();
  }

  /// Carga las tarjetas asociadas al cliente desde la Cloud Function.
  ///
  /// Flujos:
  ///  1. Marca `isLoading = true` y llama a setState para mostrar el spinner.
  ///  2. Hace GET a `https://.../paymentMethods?customerId=...`.
  ///  3. Si la respuesta es 200, parsea el JSON y convierte cada elemento en
  ///     un PaymentMethod con `PaymentMethod.fromJson`.
  ///  4. Imprime en consola cuántas tarjetas se parsearon o el error HTTP.
  ///  5. Captura excepciones (timeout, socket, etc.) e imprime el error.
  ///  6. Finalmente, marca `isLoading = false` y actualiza la UI.
  Future<void> _loadCards() async {
    debugPrint('Iniciando _loadCards, isLoading=true');
    setState(() {
      isLoading = true;
    });

    final uri = Uri.parse(
      'https://europe-west3-freaking-76982.cloudfunctions.net/paymentMethods'
          '?customerId=${widget.customerId}',
    );

    try {
      debugPrint('→ Haciendo GET a $uri');
      final resp = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout al conectar con $uri');
        },
      );
      debugPrint('← Recibí respuesta: ${resp.statusCode}');

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final List listaJson = data['paymentMethods'] as List;
        tarjetas = listaJson
            .map((j) => PaymentMethod.fromJson(j as Map<String, dynamic>))
            .toList();
        debugPrint('Tarjetas: ${tarjetas.length} unidades');
      } else {
        debugPrint('Error HTTP: ${resp.statusCode} → ${resp.body}');
        tarjetas = [];
      }
    } catch (e) {
      debugPrint('Excepción en _loadCards: $e');
      tarjetas = [];
    } finally {
      setState(() {
        isLoading = false;
      });
      debugPrint('Fin _loadCards, isLoading=false');
    }
  }

  /// Devuelve un icono según la marca de la tarjeta.
  ///
  /// @param brand (String) Marca de la tarjeta (ej. “visa”, “mastercard”).
  /// @return IconData correspondiente a la marca.
  IconData _cardBrandIcon(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.payment;
      default:
        return Icons.credit_card;
    }
  }

  /// Muestra un diálogo para confirmar si se desea establecer la tarjeta como predeterminada.
  ///
  /// Si el usuario confirma:
  ///  1. Llama a `setDefaultMethod` en la Cloud Function, enviando {customerId, paymentMethodId}.
  ///  2. Si la respuesta es 200, recarga la lista de tarjetas y muestra un SnackBar de éxito.
  ///  3. Si no, extrae el mensaje de error y lo muestra en un SnackBar.
  ///
  /// @param paymentMethodId (String) ID del método de pago que se marcará como default.
  Future<void> _checkAsDefault(String paymentMethodId) async {
    debugPrint('_checkAsDefault: $paymentMethodId');
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Establecer como método predeterminado'),
        content: const Text('¿Quieres usar esta tarjeta como predeterminada?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar',
                style: Theme.of(context).dialogTheme.contentTextStyle),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Aceptar',
                style: Theme.of(context).dialogTheme.contentTextStyle),
          ),
        ],
      ),
    );
    if (confirmar != true) {
      debugPrint('Usuario canceló marcar como default');
      return;
    }

    debugPrint('Usuario confirmó marcar $paymentMethodId como default');
    // URL de la Cloud Function para actualizar el método predeterminado
    final url = Uri.parse(
      'https://europe-west3-freaking-76982.cloudfunctions.net/setDefaultMethod',
    );
    final body = jsonEncode({
      'customerId': widget.customerId,
      'paymentMethodId': paymentMethodId,
    });
    try {
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      debugPrint('← Respuesta setDefaultMethod: ${resp.statusCode}');
      if (resp.statusCode == 200) {
        debugPrint('Método predeterminado actualizado en Stripe, recargando tarjetas');
        await _loadCards();
      } else {
        final mensaje = jsonDecode(resp.body)['error'] ?? 'Error desconocido';
        debugPrint('Error setDefaultMethod: $mensaje');
      }
    } catch (e) {
      debugPrint('Excepción en setDefaultMethod: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('isLoading=$isLoading, tarjetas.length=${tarjetas.length}');

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

                /// Título de la aplicación
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

                /// Botón “volver” para regresar a la pantalla anterior
                Positioned(
                  top: 40,
                  left: 14,
                  child: CustomButton.customCircularElevatedButtonWithIcon(
                    onPressed: () =>
                        CustomNavigator.instantNavigationPop(context),
                    icon: SvgPicture.asset('assets/svg/icon/Arrow-Left.svg'),
                    backgroundColor: AppColors.purple3,
                    size: 70,
                  ),
                ),

                /// Botón “carrito” para ir a CartScreen
                Positioned(
                  top: 40,
                  right: 14,
                  child: CustomButton.customCircularElevatedButtonWithIcon(
                    onPressed: () {
                      debugPrint('🛒 Navegando a CartScreen');
                      CustomNavigator.sharedAxisNavigationPush(
                        context: context,
                        page: CartScreen(),
                      );
                    },
                    icon: SvgPicture.asset('assets/svg/icon/Shopping.svg'),
                    backgroundColor: AppColors.purple3,
                    size: 70,
                  ),
                ),

                /// Sección “Añadir métodos de pago” (botón no implementado aún)
                Positioned(
                  top: 130,
                  left: 14,
                  right: 14,
                  bottom: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SimpleShadow(
                            opacity: 0.5,
                            color: Colors.black,
                            offset: const Offset(0, 4),
                            sigma: 3,
                            child: SvgPicture.asset(
                                'assets/svg/icon/CreditCard.svg'),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "Añadir métodos de pago",
                            style: CustomTextStyle
                                .dynamicColorSemiBold20WithShadow(context),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            debugPrint('Botón “Agregar nueva tarjeta” presionado');

                          },
                          icon: const Icon(Icons.add_card),
                          label: Text(
                            'Agregar nueva tarjeta',
                            style: CustomTextStyle
                                .dynamicColorSemiBold14WithShadow2(context),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: AppColors.white,
                            backgroundColor: AppColors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// Sección de “Método de pago por defecto” + lista de tarjetas
                Positioned(
                  top: 260,
                  left: 14,
                  right: 14,
                  bottom: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Título de la sección
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SimpleShadow(
                            opacity: 0.5,
                            color: Colors.black,
                            offset: const Offset(0, 4),
                            sigma: 3,
                            child: SvgPicture.asset(
                              'assets/svg/icon/Setting.svg',
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "Método de pago por defecto",
                            style: CustomTextStyle
                                .dynamicColorSemiBold20WithShadow(context),
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      /// Contenedor que muestra spinner, mensaje o lista de tarjetas
                      Expanded(
                        child: Container(
                          // No se fija color para heredar fondo
                          child: isLoading
                          // Estado 1: cargando
                              ? const Center(child: CircularProgressIndicator())
                          // Estado 2: no hay tarjetas
                              : tarjetas.isEmpty
                              ? Center(
                            child: Text(
                              'No tienes tarjetas guardadas.',
                              style: CustomTextStyle
                                  .dynamicColorSemiBold20WithShadow(
                                  context),
                            ),
                          )
                          // Estado 3: hay al menos una tarjeta
                              : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 0,
                            ),
                            itemCount: tarjetas.length,
                            itemBuilder: (context, index) {
                              final t = tarjetas[index];
                              debugPrint(
                                  '🔹 Dibujando tarjeta index=$index id=${t.paymentMethodId}');
                              return Card(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimary,
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  contentPadding:
                                  const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 16,
                                  ),
                                  leading: Icon(
                                    _cardBrandIcon(t.brand),
                                    size: 32,
                                    color: Colors.blueGrey,
                                  ),
                                  title: Text(
                                    '${t.brand.toUpperCase()} •••• ${t.last4}',
                                    style: CustomTextStyle
                                        .dynamicColorSemiBold16WithShadow2(
                                        context),
                                  ),
                                  subtitle: Text(
                                    'Vence: ${t.expMonth}/${t.expYear}',
                                    style: CustomTextStyle
                                        .dynamicColorSemiBold14WithShadow2(
                                        context),
                                  ),
                                  trailing: t.isDefault
                                      ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 24,
                                  )
                                      : null,
                                  onTap: () {
                                    if (!t.isDefault) {
                                      debugPrint(
                                          'Tarjeta ${t.paymentMethodId} no es default, solicita cambiar');
                                      _checkAsDefault(
                                          t.paymentMethodId);
                                    } else {
                                      debugPrint(
                                          'Tarjeta ${t.paymentMethodId} ya es default');
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
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


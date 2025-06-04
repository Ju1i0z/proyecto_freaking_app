import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freaking/model/product.dart';
import 'package:freaking/components/custom_text_style.dart';

/// Widget que muestra la tarjeta de producto.
///
/// Esta clase representa cada producto como una tarjeta clicable. Al tocar la tarjeta,
/// se irá a la pantalla de detalles del producto en concreto
/// mediante una animación de tipo fadeThrough.
///
/// Descripción de campos:
/// - `product`: instancia de `Product` cuyos datos (imagen, nombre, etc.) se mostrarán
/// en la tarjeta clicable.
/// - `detailPage`: pantalla de detalles que se abrirá al tocar la tarjeta.
class ProductCard extends StatefulWidget {
  /// Objeto `Product` con la información a mostrar en esta tarjeta.
  final Product product;
  /// Widget que representa la pantalla de detalle del producto.
  final Widget detailPage;

  const ProductCard({
    super.key,
    required this.product,
    required this.detailPage,
  });

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  /// Lista de nombres de categorías asociadas al producto.
  List<String> categoryNames = [];

  @override
  void initState() {
    super.initState();
    /// Inicia la carga de nombres de categorías al construir el widget.
    _fetchCategoryNames();
  }

  /// Método que carga los nombres de todas las categorías asociadas al producto.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Recorre `widget.product.categories`, que es una lista de IDs de categorías.
  /// 2. Para cada ID, obtiene el documento Firestore en `categories/{categoryId}`.
  /// 3. Si el documento existe, extrae el campo `name` y lo agrega a `names`.
  /// 4. Finalmente, utiliza `setState` para asignar la lista resultante a `categoryNames`.
  Future<void> _fetchCategoryNames() async {
    final names = <String>[];
    for (var categoryRef in widget.product.categories) {
      final docRef = FirebaseFirestore.instance.doc('categories/$categoryRef');
      try {
        final doc = await docRef.get();
        if (doc.exists) names.add(doc['name'] as String);
      } catch (e) {
        debugPrint('Error al obtener categoría $categoryRef: $e');
      }
    }
    setState(() => categoryNames = names);
  }

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      /// Tipo de transición: fadeThrough (desvanece y cambia).
      transitionType: ContainerTransitionType.fadeThrough,
      /// Duración de la animación.
      transitionDuration: const Duration(milliseconds: 500),
      /// Pantalla que se abrirá al tocar la tarjeta.
      openBuilder: (context, _) => widget.detailPage,
      /// Constructor cerrado: muestra la tarjeta en la lista.
      closedBuilder: (context, openContainer) {
        /// Si aún no se han cargado los nombres de categorías, mostramos un spinner.
        if (categoryNames.isEmpty) {
          return SizedBox(
            width: 200,
            height: 250,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return GestureDetector(
          /// Al tocar la tarjeta, invoca `openContainer` para iniciar la animación.
          onTap: openContainer,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: Theme.of(context).colorScheme.tertiary,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    offset: Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
              width: 200,
              height: 250,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            /// Fondo de la zona de imagen con sombra y radio.
                            child: Container(
                              width: 195,
                              height: 122,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onSurface,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x40000000),
                                    offset: Offset(0, 4),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned.fill(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Align(
                              alignment: Alignment.center,
                                /// Primera imagen del producto recuperada de Firebase mediante http.
                                child: Image.network(
                                  widget.product.images[0],
                                  /// Escala de imagen para mantener la proporción.
                                  fit: BoxFit.contain,
                                  height: 105,
                                  width: 105,
                                  /// Cabecera que fuerza a la revisión de la imagen para comprobar si es la misma con el servidor.
                                  headers: const {'Cache-Control': 'no-cache'},
                                  /// Constructor de carga que muestra un spinner de carga mientras la imagen no haya sido cargada completamente.
                                  loadingBuilder: (context, child, progress) =>
                                  progress == null ? child : const Center(child: CircularProgressIndicator()),
                                  /// Constructor de errores que muestra un icono de error si la imagen no puede ser cargada (error 404...).
                                  errorBuilder: (context, error, stack) => const Icon(Icons.error),
                                ),
                              ),
                            ),
                        ],
                      ),
                      /// Nombre y categorías del producto
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Nombre del producto con estilo y límite de líneas.
                              Text(
                                widget.product.name,
                                style: CustomTextStyle.dynamicColorBold12WithShadow(context),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              /// Lista de nombres de categorías unidas por comas.
                              Text(
                                categoryNames.join(', '),
                                style: CustomTextStyle.dynamicColorSemiBold11WithShadow(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  /// Sección inferior: puntos obtenidos al comprar (icono + texto)
                  Positioned(
                    bottom: 5,
                    left: 10,
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/svg/icon/Star.svg',
                          width: 15,
                          height: 15,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          widget.product.pointsForPurchase.toString(),
                          style: CustomTextStyle.dynamicColorBold18WithShadow(context),
                        ),
                      ],
                    ),
                  ),
                  /// Sección inferior derecha: precio del producto
                  Positioned(
                    bottom: 5,
                    right: 10,
                    child: Text(
                      '${widget.product.price}€',
                      style: CustomTextStyle.dynamicColorBold18WithShadow(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      /// Control de colores y elevaciones cuando está abierto o cerrado.
      closedElevation: 0,
      openElevation: 0,
      closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      openShape: const RoundedRectangleBorder(),
      closedColor: Theme.of(context).cardColor,
      openColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}




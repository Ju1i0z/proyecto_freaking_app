import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freaking/model/product.dart';
import 'package:freaking/components/custom_text_style.dart';

/// Widget que muestra la tarjeta de un producto destacado.
///
/// Esta clase representa cada producto destacado como una tarjeta clicable. Al tocar la tarjeta,
/// se irá a la pantalla de detalles del producto en concreto
/// mediante una animación de tipo fadeThrough.
///
/// Descripción de campos:
/// - `product`: instancia de `Product` cuyos datos (imagen, nombre, etc.) se mostrarán
/// en la tarjeta clicable.
/// - `detailPage`: pantalla de detalles que se abrirá al tocar la tarjeta.
class FeaturedProductCard extends StatefulWidget {
  /// Objeto `Product` con la información a mostrar en esta tarjeta.
  final Product product;

  /// Widget que representa la pantalla de detalle del producto.
  final Widget detailPage;

  const FeaturedProductCard({
    super.key,
    required this.product,
    required this.detailPage,
  });

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<FeaturedProductCard> {
  /// Lista de nombres de categorías asociadas al producto.
  List<String> categoryNames = [];

  @override
  void initState() {
    super.initState();

    /// Inicia la carga de nombres de categorías al construir el widget.
    _fetchCategoryNames();
  }

  /// Método que carga los nombres de todas las categorías del producto destacado.
  ///
  /// Recorre `widget.product.categories`, que es una lista de IDs de categorías,
  /// obtiene cada documento Firestore correspondiente (`categories/{id}`) y,
  /// si existe, extrae el campo `name`. Al finalizar, asigna la lista resultante
  /// a `categoryNames` y actualiza el estado para renderizarla.
  Future<void> _fetchCategoryNames() async {
    List<String> names = [];

    for (String categoryRef in widget.product.categories) {
      DocumentReference categoryDoc =
          FirebaseFirestore.instance.doc('categories/$categoryRef');

      try {
        DocumentSnapshot doc = await categoryDoc.get();
        if (doc.exists) {
          names.add(doc['name']);
        } else {
          print("Documento no encontrado para la categoría: $categoryRef");
        }
      } catch (e) {
        print("Error al obtener la categoría: $e");
      }
    }

    if (names.isEmpty) {
      print("No se encontraron nombres de categorías.");
    }

    setState(() {
      categoryNames = names;
    });
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
            child: Center(child: CircularProgressIndicator()),
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
              width: 300,
              height: 150,
              margin: const EdgeInsets.only(right: 6, left: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 10),
                  Stack(
                    children: [
                      /// Fondo de la zona de imagen con sombra y radio.
                      Container(
                        width: 125,
                        height: 125,
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
                            height: 100,
                            width: 100,
                            /// Cabecera que fuerza a la revisión de la imagen para comprobar si es la misma con el servidor.
                            headers: const {'Cache-Control': 'no-cache'},
                            /// Constructor de carga que muestra un spinner de carga mientras la imagen no haya sido cargada completamente.
                            loadingBuilder: (ctx, child, progress) =>
                                progress == null ? child : const Center(child: CircularProgressIndicator()),
                            /// Constructor de errores que muestra un icono de error si la imagen no puede ser cargada (error 404...).
                            errorBuilder: (ctx, error, stack) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ],
                  ),
                  /// Nombre y categorías del producto
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 5.0, right: 5.0, top: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /// Nombre del producto con estilo y límite de líneas.
                          Text(
                            widget.product.name,
                            style: CustomTextStyle.dynamicColorBold12WithShadow(
                                context),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          /// Lista de nombres de categorías unidas por comas.

                          Text(
                            categoryNames.join(', '),
                            style: CustomTextStyle.dynamicColorSemiBold11WithShadow(context),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          /// Sección inferior: puntos obtenidos al comprar (icono + texto)
                          Row(
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/svg/icon/Star.svg",
                                    width: 15,
                                    height: 15,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    widget.product.pointsForPurchase.toString(),
                                    style: CustomTextStyle
                                        .dynamicColorSemiBold15WithShadow(
                                            context),
                                    textAlign: TextAlign.right,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              /// Sección inferior derecha: precio del producto
                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: Text(
                                  '${widget.product.price.toString()}€',
                                  style: CustomTextStyle
                                      .dynamicColorBold18WithShadow(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
      closedShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      openShape: const RoundedRectangleBorder(),
      closedColor: Theme.of(context).cardColor,
      openColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freaking/model/product.dart';
import 'package:freaking/components/custom_text_style.dart';
import '../colors/app_colors.dart';
import '../components/custom_button.dart';

/// Widget que muestra un producto en la lista de favoritos.
///
/// Esta clase representa una tarjeta clicable con animación `fadeThrough`. Contiene:
/// 1. La imagen, nombre, puntos y precio del producto.
/// 2. Un icono para eliminar de favoritos.
/// 3. Opcionalmente, un botón para añadir al carrito.
/// Al tocar la zona principal (sin incluir iconos/botones), navega a la pantalla
/// de detalles del producto seleccionado.
///
class FavoriteCard extends StatefulWidget {
  /// Objeto `Product` con la información a mostrar en esta tarjeta.
  final Product product;

  /// Widget que representa la pantalla de detalle del producto.
  final Widget detailPage;

  /// Callback que se llama cuando se pulsa el icono de eliminar.
  final VoidCallback onRemove;

  /// Callback opcional para el botón “Añadir a la cesta”.
  final VoidCallback? onAddToCart;

  const FavoriteCard({
    Key? key,
    required this.product,
    required this.detailPage,
    required this.onRemove,
    this.onAddToCart,
  }) : super(key: key);

  @override
  _FavoriteCardState createState() => _FavoriteCardState();
}

class _FavoriteCardState extends State<FavoriteCard> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// Ancho total de la pantalla, usado para dimensionar la tarjeta.
    final screenWidth = MediaQuery.of(context).size.width;

    return OpenContainer(
      /// Tipo de transición: fadeThrough (desvanece y cambia).
      transitionType: ContainerTransitionType.fadeThrough,
      /// Duración de la animación.
      transitionDuration: const Duration(milliseconds: 500),
      /// Pantalla que se abrirá al tocar la tarjeta.
      openBuilder: (context, _) => widget.detailPage,
      closedElevation: 0,
      openElevation: 0,
      closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      openShape: const RoundedRectangleBorder(),
      closedColor: Colors.transparent,
      openColor: Theme.of(context).scaffoldBackgroundColor,
      /// Constructor cerrado: muestra la tarjeta en la lista.
      closedBuilder: (context, openContainer) {
        return Stack(
          children: [
            /// Al tocar la tarjeta, invoca `openContainer` para iniciar la animación.
            GestureDetector(
              onTap: openContainer,
              child: Container(
                height: 115,
                width: screenWidth,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.black2_5
                      : AppColors.purple1,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2.0,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x40000000),
                      offset: Offset(0, 4),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Primera imagen del producto recuperada de Firebase mediante http.
                      Image.network(
                        widget.product.images[0],
                        /// Escala de imagen para mantener la proporción.
                        fit: BoxFit.contain,
                        height: 100,
                        width: 100,
                        /// Cabecera que fuerza a la revisión de la imagen para comprobar si es la misma con el servidor.
                        headers: const {'Cache-Control': 'no-cache'},
                        /// Constructor de carga que muestra un spinner de carga mientras la imagen no haya sido cargada completamente.
                        loadingBuilder: (context, child, progress) =>
                        progress == null ? child : const Center(child: CircularProgressIndicator()),
                        /// Constructor de errores que muestra un icono de error si la imagen no puede ser cargada (error 404...).
                        errorBuilder: (context, error, stack) => const Icon(Icons.error),
                      ),

                      const SizedBox(width: 5),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Nombre del producto.
                            Text(
                              widget.product.name,
                              style: CustomTextStyle.dynamicColorSemiBold12WithShadow(context),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            /// Puntos.
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/svg/icon/Star.svg',
                                  width: 12,
                                  height: 12,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  widget.product.pointsForPurchase.toString(),
                                  style: CustomTextStyle.dynamicColorSemiBold14WithShadow(context),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            /// Precio.
                            Text(
                              '${widget.product.price}€',
                              style: CustomTextStyle.dynamicColorSemiBold20WithShadow2(context),
                            ),
                          ],
                        ),
                      ),

                      /// Espacio en blanco para que no choque el botón abajo-derecha.
                      SizedBox(
                        width: screenWidth < 375 ? 40 : 50,
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// Icono para eliminar un producto favorito de la lista.
            Positioned(
              top: 5,
              right: 5,
              child: IconButton(
                icon: SvgPicture.asset('assets/svg/icon/Trash.svg'),
                onPressed: () {
                  widget.onRemove();
                },
              ),
            ),

            /// Botón para "Añadir a la cesta".
            if (widget.onAddToCart != null)
              Positioned(
                bottom: 10,
                right: 10,
                child: CustomButton.customElevatedCartButton(
                  onPressed: widget.onAddToCart!,
                  text: "Añadir a la cesta",
                  foregroundColor: Colors.transparent,
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.black2_5
                      : AppColors.purple1,
                  customTextStyle: CustomTextStyle.dynamicColorSemiBold11WithShadow(context),
                  context: context,
                ),
              ),
          ],
        );
      },
    );
  }
}


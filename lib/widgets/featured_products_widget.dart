import 'package:flutter/material.dart';
import 'package:freaking/widgets/featured_product_card.dart';
import '../model/product.dart';
import '../screens/product_details_screen.dart';

/// Widget que muestra productos agrupados por categoría.
///
/// Este widget muestra una lista horizontal de productos marcados como destacados.
/// Si la lista `products` está vacía, no renderiza nada (retorna un `SizedBox.shrink()`).
///
/// Descripción de campos:
/// - `products`: lista de instancias de `Product` que serán mostradas como destacados.
/// - `onProductTap`: callback que se ejecutará si se quiere manejar el evento de pulsar un producto.
///   (por ahora no se utiliza, ya que el `FeaturedProductCard` usa internamente su propia navegación).
///
class FeaturedProductsWidget extends StatelessWidget {
  /// Lista de objetos `Product` que se mostrarán en la lista horizontal.
  final List<Product> products;
  /// Callback que se invoca al tocar un producto.
  final void Function(Product) onProductTap;

  const FeaturedProductsWidget({
    super.key,
    required this.products,
    required this.onProductTap,
  });



  @override
  Widget build(BuildContext context) {
    /// Si no hay productos destacados, no se renderiza nada.
    if (products.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Título de la sección "Destacados".
        Padding(
          padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
          child: Text(
            "Destacados",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
          ),
        ),
        /// Lista horizontal de tarjetas `FeaturedProductCard`.
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return FeaturedProductCard(
                product: product,
                detailPage: ProductDetailsScreen(product: product),
              );
            },
          ),
        ),
      ],
    );

  }
}
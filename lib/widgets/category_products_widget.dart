import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freaking/components/custom_text_style.dart';
import '../model/product.dart';
import '../screens/product_details_screen.dart';
import '../widgets/product_card.dart';

/// Widget que muestra productos agrupados por categoría.
///
/// Esta clase construye una sección que primero obtiene el nombre de la categoría
/// desde Firestore y luego renderiza un título con ese nombre seguido de una lista
/// horizontal de tarjetas (`ProductCard`) para cada `Product` en `products`.
///
/// Descripción de campos:
/// - `categoryRef`: referencia al documento Firestore de la categoría (`/categories/{id}`).
/// - `products`: lista de objetos `Product` que pertenecen a esta categoría.
/// - `onProductTap`: callback que se ejecuta cuando se toca una tarjeta de producto.
///
class CategoryProductsWidget extends StatelessWidget {
  /// Referencia al documento de la categoría en Firestore
  final DocumentReference categoryRef;
  /// Lista de objetos `Product` que se mostrarán en la lista horizontal.
  final List<Product> products;
  /// Callback que se invoca al tocar un producto.
  final void Function(Product) onProductTap;

  const CategoryProductsWidget({
    super.key,
    required this.categoryRef,
    required this.products,
    required this.onProductTap,
  });

  /// Método que btiene el nombre de la categoría desde Firestore.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Llama a `categoryRef.get()` para obtener el documento.
  /// 2. Si existe, extrae el campo `name` y lo devuelve.
  /// 3. Si no existe, devuelve 'Categoría no encontrada'.
  /// 4. Si hay un error, lo imprime y devuelve 'Error al cargar categoría'.
  Future<String> _getCategoryName() async {
    try {
      final snapshot = await categoryRef.get();
      return snapshot.exists
          ? (snapshot['name'] as String? ?? 'Categoría desconocida')
          : 'Categoría no encontrada';
    } catch (e) {
      print('Error al obtener la categoría: $e');
      return 'Error al cargar categoría';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getCategoryName(),
      builder: (context, snapshot) {
        /// Mientras se espera el nombre de la categoría, se muestra un spinner centrado
        /// a modo de visualización de carga.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            /// Altura aproximada que ocupa el "título + lista"
            height: 300,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        /// Visualización del error al cargar el nombre de la categoría.
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Error al cargar categoría: ${snapshot.error}'),
          );
        }
        /// Obtención del nombre de la categoría.
        final categoryName = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Título con el nombre de la categoría.
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                categoryName,
                style: CustomTextStyle.dynamicColorBold20WithShadow(context),
              ),
            ),
            /// Lista horizontal de tarjetas de producto.
            SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(
                    product: product,
                    detailPage: ProductDetailsScreen(product: product),
                  );

                },
              ),
            ),
          ],
        );
      },
    );
  }
}



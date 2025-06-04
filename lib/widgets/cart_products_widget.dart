import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freaking/components/custom_text_style.dart';
import '../model/product.dart';
import '../screens/product_details_screen.dart';
import 'cart_card.dart';

/// Widget que muestra la lista de productos añadidos a la cesta del usuario.
///
/// Esta clase recibe una lista de `Product` y la muestra como un `ListView`
/// vertical desplazable. Para cada producto, utiliza `CartCard`, que incluye:
///  - Imagen, nombre, puntos y precio del producto.
///  - Icono para eliminar el producto de la lista de la cesta.
///
/// Si la lista `products` está vacía, en lugar del listado se muestra un mensaje
/// centrado indicando que no hay productos en la cesta.
///
/// La eliminación se realiza directamente en Firestore bajo la colección:
/// `/users/{uid}/favoriteProducts/{productId}`.
///
class CartProductsWidget extends StatelessWidget {
  /// Lista de objetos `Product` que se mostrarán en la lista horizontal.
  final List<Product> products;

  const CartProductsWidget({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    /// Si la lista está vacía, se muestra un mensaje informativo centrado.
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Image.asset("assets/img/eyes.png", width: 50, height: 50),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 30, right: 30),
              child: Text(
                "Parece que esto está un poco vacío ¿no crees?, ¿y si echamos un vistazo?",
                style: CustomTextStyle.dynamicColorSemiBold20WithShadow(context),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      );
    } else {
      /// Si hay productos, se construye un ListView.builder para la lista sea desplazable.
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return CartCard(
            product: product,
            detailPage: ProductDetailsScreen(product: product),
            /// Callback que se ejecuta al presionar el icono de eliminar.
            /// Elimina el documento correspondiente en Firestore:
            /// `/users/{uid}/cartProducts/{productId}`.
            onRemove: () async {
              final uid = FirebaseAuth.instance.currentUser!.uid;
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('cartProducts')
                  .doc(product.id)
                  .delete();

            },

          );
        },
      );
    }
  }
}

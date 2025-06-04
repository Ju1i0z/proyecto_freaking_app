import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freaking/components/custom_text_style.dart';
import '../model/product.dart';
import '../screens/product_details_screen.dart';
import '../widgets/favorite_card.dart';

/// Widget que muestra la lista de productos favoritos del usuario.
///
/// Esta clase recibe una lista de `Product` y la muestra como un `ListView`
/// vertical desplazable. Para cada producto, utiliza `FavoriteCard`, que incluye:
///  - Imagen, nombre, puntos y precio del producto.
///  - Icono para eliminar el producto de la lista de favoritos.
///  - Botón opcional “Añadir a la cesta” para añadir/incrementar la cantidad del producto en el carrito.
///
/// Si la lista `products` está vacía, en lugar del listado se muestra un mensaje
/// centrado indicando que no hay productos favoritos.
///
/// La eliminación se realiza directamente en Firestore bajo la colección:
/// `/users/{uid}/favoriteProducts/{productId}`. El añadido al carrito actualiza o crea
/// el documento en `/users/{uid}/cartProducts/{productId}` con `quantity` y `priceAtAdd`.
///
class FavoriteProductsWidget extends StatelessWidget {
  /// Lista de objetos `Product` que se mostrarán en la lista horizontal.
  final List<Product> products;

  const FavoriteProductsWidget({
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
        return FavoriteCard(
          product: product,
          detailPage: ProductDetailsScreen(product: product),
          /// Callback que se ejecuta al presionar el icono de eliminar.
          /// Elimina el documento correspondiente en Firestore:
          /// `/users/{uid}/favoriteProducts/{productId}`.
          onRemove: () async {
            final uid = FirebaseAuth.instance.currentUser!.uid;
            await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('favoriteProducts')
                .doc(product.id)
                .delete();

          },
          /// Callback que se ejecuta al presionar “Añadir a la cesta”.
          /// Comprueba si el producto ya existe en la subcolección `cartProducts`;
          /// si existe, incrementa `quantity` en 1; en caso contrario, crea el documento
          /// con `quantity = 1` y `priceAtAdd` igual al precio actual del producto.
          onAddToCart: () async {
            final uid = FirebaseAuth.instance.currentUser!.uid;
            final cartRef = FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('cartProducts')
                .doc(product.id);
            final snap = await cartRef.get();
            if (snap.exists) {
              await cartRef.update({'quantity': FieldValue.increment(1)});
            } else {
              await cartRef.set({
                'productRef': FirebaseFirestore.instance
                    .collection('products')
                    .doc(product.id),
                'quantity': 1,
                'priceAtAdd': product.price,
              });
            }
          },
        );
      },
    );
  }
  }
}


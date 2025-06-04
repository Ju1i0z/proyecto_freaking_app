import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String id; // ID autogenerado por Firestore
  String description;
  String name;
  List<String> categories; // IDs de las categorías
  bool featured;
  List<String> images; // URLs de las imágenes
  int pointsForPurchase;
  int pointsToRedeem;
  double price;
  bool redeemable;
  int stock;
  String stripeProductId;

  Product({
    required this.id, // Se obtiene desde Firestore
    required this.description,
    required this.name,
    required this.categories,
    required this.featured,
    required this.images,
    required this.pointsForPurchase,
    required this.pointsToRedeem,
    required this.price,
    required this.redeemable,
    required this.stock,
    required this.stripeProductId,
  });

  // Convertir desde Firestore
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Product(
      id: doc.id,
      description: data['description'],
      name: data['name'],
      categories: (data['categories'] as List<dynamic>)
          .map((category) => (category as DocumentReference).id)
          .toList(),
      featured: data['featured'],
      images: List<String>.from(data['images']),
      pointsForPurchase: data['pointsForPurchase'],
      pointsToRedeem: data['pointsToRedeem'],
      price: (data['price'] as num).toDouble(), // Asegurar conversión correcta
      redeemable: data['redeemable'],
      stock: data['stock'],
      stripeProductId: data['stripeProductId'],
    );
  }

  // Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'name': name,
      'categories': categories,
      'featured': featured,
      'images': images,
      'pointsForPurchase': pointsForPurchase,
      'pointsToRedeem': pointsToRedeem,
      'price': price,
      'redeemable': redeemable,
      'stock': stock,
      'stripeProductId': stripeProductId,
    };
  }
}

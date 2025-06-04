import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  String id;
  String name;
  // Puede ser nulo para categorías principales
  String? parentCategoryId;

  Category({
    required this.id,
    required this.name,
    // Opcional
    this.parentCategoryId,
  });

  // Convertir desde Firestore
  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Category(
      // Obtención del ID generado automáticamente por Firebase
      id: doc.id,
      name: data['name'],
      parentCategoryId: data['parentCategoryId'],
    );
  }

  // Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'parentCategoryId': parentCategoryId,
    };
  }
}

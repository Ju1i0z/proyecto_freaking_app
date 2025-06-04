import 'package:cloud_firestore/cloud_firestore.dart';

class GlobalCoupon {
  String description;
  String discountType; // 'percentage' o 'fixed_amount'
  double discountValue;
  List<DocumentReference> applicableCategories;
  double minPurchaseAmount;
  DateTime validUntil;
  bool isActive;
  String stripeCouponId;

  GlobalCoupon({
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.applicableCategories,
    required this.minPurchaseAmount,
    required this.validUntil,
    required this.isActive,
    required this.stripeCouponId,
  });

  // Convertir desde Firestore
  factory GlobalCoupon.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return GlobalCoupon(
      description: data['description'],
      discountType: data['discountType'],
      discountValue: data['discountValue'].toDouble(),
      applicableCategories: List<DocumentReference>.from(data['applicableCategories']),
      minPurchaseAmount: data['minPurchaseAmount'].toDouble(),
      validUntil: (data['validUntil'] as Timestamp).toDate(),
      isActive: data['isActive'],
      stripeCouponId: data['stripeCouponId'],
    );
  }

  // Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'applicableCategories': applicableCategories,
      'minPurchaseAmount': minPurchaseAmount,
      'validUntil': validUntil,
      'isActive': isActive,
      'stripeCouponId': stripeCouponId,
    };
  }
}

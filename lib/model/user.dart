import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  String uid;
  String name;
  String email;
  String stripeCustomerId;
  String accountState;
  DateTime createdAt;
  int accumulatedPoints;
  Address address;
  List<PaymentMethod> paymentMethods = [];
  List<PaymentHistory> userPaymentsHistory = [];
  List<CartProduct> cartProducts = [];
  List<FavoriteProduct> favoriteProducts = [];
  List<PointsHistory> pointsHistory = [];
  List<OrderHistory> userOrdersHistory = [];
  List<RedeemedCoupon> redeemedCoupons = [];

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.accountState,
    required this.stripeCustomerId,
    required this.createdAt,
    required this.accumulatedPoints,
    required this.address,
  });

  // Convertir desde Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id,  // El ID autogenerado de Firebase
      name: data['name'],
      email: data['email'],
      stripeCustomerId: data['stripeCustomerId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      accumulatedPoints: data['accumulatedPoints'],
      address: Address.fromFirestore(data['address']),
      accountState: data['accountState'],
    );
  }

  // Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'accountState': accountState,
      'stripeCustomerId': stripeCustomerId,
      'createdAt': createdAt,
      'accumulatedPoints': accumulatedPoints,
      'address': address.toFirestore(),
    };
  }

  // Cargar datos desde shared_preferences
  Future<UserModel> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getString('userId') ?? '';
    final email = prefs.getString('email') ?? '';
    final accumulatedPoints = prefs.getInt('accumulated_points') ?? 0;

    // Cargar dirección desde SharedPreferences
    final address = Address(
      city: prefs.getString('address_city') ?? '',
      country: prefs.getString('address_country') ?? '',
      mobile: prefs.getString('address_mobile') ?? '',
      postalCode: prefs.getString('address_postal_code') ?? '',
      province: prefs.getString('address_province') ?? '',
      streetAddress: prefs.getString('address_street_address') ?? '',
    );

    final name = prefs.getString('name') ?? '';
    final stripeCustomerId = prefs.getString('stripeCustomerId') ?? '';

    // Se añade la fecha actual para la fecha de creación de la cuenta
    final createdAtTimestamp = prefs.getString('createdAt');
    final createdAt = createdAtTimestamp != null
        ? DateTime.parse(createdAtTimestamp)
        : DateTime.now();

    return UserModel(
      uid: userId,
      email: email,
      accumulatedPoints: accumulatedPoints,
      address: address,
      name: name,
      stripeCustomerId: stripeCustomerId,
      createdAt: createdAt,
      accountState: accountState,
    );
  }
}

class Address {
  String city;
  String country;
  String mobile;
  String postalCode;
  String province;
  String streetAddress;

  Address({
    required this.city,
    required this.country,
    required this.mobile,
    required this.postalCode,
    required this.province,
    required this.streetAddress,
  });

  // Convertir desde Firestore
  factory Address.fromFirestore(Map<String, dynamic> data) {
    return Address(
      city: data['city'],
      country: data['country'],
      mobile: data['mobile'],
      postalCode: data['postalCode'],
      province: data['province'],
      streetAddress: data['streetAddress'],
    );
  }

  // Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'city': city,
      'country': country,
      'mobile': mobile,
      'postalCode': postalCode,
      'province': province,
      'streetAddress': streetAddress,
    };
  }
}

// Clase para productos favoritos
class FavoriteProduct {
  DocumentReference productRef;

  FavoriteProduct({
    required this.productRef,
  });

  factory FavoriteProduct.fromFirestore(Map<String, dynamic> data) {
    return FavoriteProduct(
      productRef: data['productRef'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productRef': productRef,
    };
  }
}

// Clase para los métodos de pago
class PaymentMethod {
  String paymentMethodId;
  String brand;
  String last4;
  int expMonth;
  int expYear;
  bool isDefault;

  PaymentMethod({
    required this.paymentMethodId,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    required this.isDefault,
  });

  factory PaymentMethod.fromFirestore(Map<String, dynamic> data) {
    return PaymentMethod(
      paymentMethodId: data['paymentMethodId'],
      brand: data['brand'],
      last4: data['last4'],
      expMonth: data['expMonth'],
      expYear: data['expYear'],
      isDefault: data['isdefault'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'paymentMethodId': paymentMethodId,
      'brand': brand,
      'last4': last4,
      'expMonth': expMonth,
      'expYear': expYear,
      'isdefault': isDefault,
    };
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      paymentMethodId:  json['id'],
      brand:            json['brand'],
      last4:            json['last4'],
      expMonth:         json['expMonth'],
      expYear:          json['expYear'],
      isDefault:        json['isDefault'],
    );
  }

}

// Clase para el historial de pagos
class PaymentHistory {
  String paymentId;
  double amount;
  String status;
  String currency;
  String paymentMethod;
  DateTime paymentDate;

  PaymentHistory({
    required this.paymentId,
    required this.amount,
    required this.status,
    required this.currency,
    required this.paymentMethod,
    required this.paymentDate,
  });

  factory PaymentHistory.fromFirestore(Map<String, dynamic> data) {
    return PaymentHistory(
      paymentId: data['paymentId'],
      amount: data['amount'].toDouble(),
      status: data['status'],
      currency: data['currency'],
      paymentMethod: data['paymentMethod'],
      paymentDate: (data['paymentDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'paymentId': paymentId,
      'amount': amount,
      'status': status,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'paymentDate': paymentDate,
    };
  }
}

// Clase para los productos en el carrito
class CartProduct {
  DocumentReference productRef;
  int quantity;
  double priceAtAdd;

  CartProduct({
    required this.productRef,
    required this.quantity,
    required this.priceAtAdd,
  });

  factory CartProduct.fromFirestore(Map<String, dynamic> data) {
    return CartProduct(
      productRef: data['productRef'],
      quantity: data['quantity'],
      priceAtAdd: data['priceAtAdd'].toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productRef': productRef,
      'quantity': quantity,
      'priceAtAdd': priceAtAdd,
    };
  }
}


// Clase para el historial de puntos
class PointsHistory {
  int pointsAdded;
  int pointsSpent;
  String action;
  String reference;
  DateTime transactionDate;

  PointsHistory({
    required this.pointsAdded,
    required this.pointsSpent,
    required this.action,
    required this.reference,
    required this.transactionDate,
  });

  factory PointsHistory.fromFirestore(Map<String, dynamic> data) {
    return PointsHistory(
      pointsAdded: data['pointsAdded'],
      pointsSpent: data['pointsSpent'],
      action: data['action'],
      reference: data['reference'],
      transactionDate: (data['transactionDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'pointsAdded': pointsAdded,
      'pointsSpent': pointsSpent,
      'action': action,
      'reference': reference,
      'transactionDate': transactionDate,
    };
  }
}

// Clase para el historial de pedidos del usuario
class OrderHistory {
  DateTime orderDate;
  String orderState;
  double finalAmount;
  String paymentIntentId;
  String chargeId;
  String failureReason;
  ShippingInfo shippingInfo;
  DocumentReference paymentMethodRef;

  OrderHistory({
    required this.orderDate,
    required this.orderState,
    required this.finalAmount,
    required this.paymentIntentId,
    required this.chargeId,
    required this.failureReason,
    required this.shippingInfo,
    required this.paymentMethodRef,
  });

  factory OrderHistory.fromFirestore(Map<String, dynamic> data) {
    return OrderHistory(
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      orderState: data['orderState'],
      finalAmount: data['finalAmount'].toDouble(),
      paymentIntentId: data['paymentIntentId'],
      chargeId: data['chargeId'],
      failureReason: data['failureReason'],
      shippingInfo: ShippingInfo.fromFirestore(data['shippingInfo']),
      paymentMethodRef: data['paymentMethodRef'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'orderDate': orderDate,
      'orderState': orderState,
      'finalAmount': finalAmount,
      'paymentIntentId': paymentIntentId,
      'chargeId': chargeId,
      'failureReason': failureReason,
      'shippingInfo': shippingInfo.toFirestore(),
      'paymentMethodRef': paymentMethodRef,
    };
  }
}

// Clase para la información de envío
class ShippingInfo {
  String carrier;
  String trackingNumber;
  DateTime estimatedDelivery;

  ShippingInfo({
    required this.carrier,
    required this.trackingNumber,
    required this.estimatedDelivery,
  });

  factory ShippingInfo.fromFirestore(Map<String, dynamic> data) {
    return ShippingInfo(
      carrier: data['carrier'],
      trackingNumber: data['trackingNumber'],
      estimatedDelivery: (data['estimatedDelivery'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'carrier': carrier,
      'trackingNumber': trackingNumber,
      'estimatedDelivery': estimatedDelivery,
    };
  }
}

// Clase para los cupones canjeados por el usuario
class RedeemedCoupon {
  String description;
  String discountType;
  double discountValue;
  double minPurchaseAmount;
  DateTime validUntil;
  DateTime redeemAt;
  List<DocumentReference> applicableCategories;
  bool isUsed;
  String stripeCouponId;

  RedeemedCoupon({
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.minPurchaseAmount,
    required this.validUntil,
    required this.redeemAt,
    required this.applicableCategories,
    required this.isUsed,
    required this.stripeCouponId,
  });

  factory RedeemedCoupon.fromFirestore(Map<String, dynamic> data) {
    return RedeemedCoupon(
      description: data['description'],
      discountType: data['discountType'],
      discountValue: data['discountValue'].toDouble(),
      minPurchaseAmount: data['minPurchaseAmount'].toDouble(),
      validUntil: (data['validUntil'] as Timestamp).toDate(),
      redeemAt: (data['redeemAt'] as Timestamp).toDate(),
      applicableCategories: List<DocumentReference>.from(data['applicableCategories']),
      isUsed: data['isUsed'],
      stripeCouponId: data['stripeCouponId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'minPurchaseAmount': minPurchaseAmount,
      'validUntil': validUntil,
      'redeemAt': redeemAt,
      'applicableCategories': applicableCategories,
      'isUsed': isUsed,
      'stripeCouponId': stripeCouponId,
    };
  }
}



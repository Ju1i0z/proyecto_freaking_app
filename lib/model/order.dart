import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  DocumentReference userRef; // Referencia al usuario
  DateTime orderDate; // Fecha del pedido
  String orderState; // Estado del pedido (e.g., 'Confirmado')
  double finalAmount; // Monto total del pedido
  String paymentIntentId; // ID de la intención de pago en Stripe
  String chargeId; // ID del cargo en Stripe
  ShippingInfo shippingInfo; // Información de envío
  DocumentReference paymentMethodRef; // Referencia al método de pago
  DiscountUsed? discountUsed; // Descuentos utilizados (opcional)
  List<DocumentReference> products; // Lista de referencias de productos

  Order({
    required this.userRef,
    required this.orderDate,
    required this.orderState,
    required this.finalAmount,
    required this.paymentIntentId,
    required this.chargeId,
    required this.shippingInfo,
    required this.paymentMethodRef,
    this.discountUsed, // Descuento opcional
    required this.products,
  });

  // Convertir desde Firestore
  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Order(
      userRef: data['userRef'],
      orderDate: DateTime.parse(data['orderDate']),
      orderState: data['orderState'],
      finalAmount: data['finalAmount'].toDouble(),
      paymentIntentId: data['paymentIntentId'],
      chargeId: data['chargeId'],
      shippingInfo: ShippingInfo.fromFirestore(data['shippingInfo']),
      paymentMethodRef: data['paymentMethodRef'],
      discountUsed: data['discountsUsed'] != null
          ? DiscountUsed.fromFirestore(data['discountsUsed'])
          : null,
      products: (data['products'] as List)
          .map((productRef) => productRef as DocumentReference)
          .toList(),
    );
  }

  // Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userRef': userRef,
      'orderDate': orderDate.toIso8601String(),
      'orderState': orderState,
      'finalAmount': finalAmount,
      'paymentIntentId': paymentIntentId,
      'chargeId': chargeId,
      'shippingInfo': shippingInfo.toFirestore(),
      'paymentMethodRef': paymentMethodRef,
      if (discountUsed != null) 'discountsUsed': discountUsed!.toFirestore(),
      'products': products,
    };
  }
}

// Clase para la información de envío
class ShippingInfo {
  String carrier; // Proveedor del servicio de envío (e.g., 'DHL')
  String trackingNumber; // Número de seguimiento
  DateTime estimatedDelivery; // Fecha estimada de entrega

  ShippingInfo({
    required this.carrier,
    required this.trackingNumber,
    required this.estimatedDelivery,
  });

  // Convertir desde Firestore
  factory ShippingInfo.fromFirestore(Map<String, dynamic> data) {
    return ShippingInfo(
      carrier: data['carrier'],
      trackingNumber: data['trackingNumber'],
      estimatedDelivery: DateTime.parse(data['estimatedDelivery']),
    );
  }

  // Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'carrier': carrier,
      'trackingNumber': trackingNumber,
      'estimatedDelivery': estimatedDelivery.toIso8601String(),
    };
  }
}

// Clase para el descuento utilizado
class DiscountUsed {
  String discountType; // Tipo de descuento ('global' o 'personal')
  DocumentReference couponRef; // Referencia al cupón utilizado

  DiscountUsed({
    required this.discountType,
    required this.couponRef,
  });

  // Convertir desde Firestore
  factory DiscountUsed.fromFirestore(Map<String, dynamic> data) {
    return DiscountUsed(
      discountType: data['discountType'],
      couponRef: data['couponRef'],
    );
  }

  // Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'discountType': discountType,
      'couponRef': couponRef,
    };
  }
}

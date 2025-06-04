import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  DocumentReference userRef; // Referencia al usuario
  String paymentId; // ID del pago en Stripe
  double amount; // Monto del pago
  String status; // Estado del pago (e.g., 'succeeded')
  String currency; // Moneda del pago (e.g., 'eur')
  DateTime paymentDate; // Fecha del pago
  DocumentReference orderRef; // Referencia al pedido
  DocumentReference paymentMethodRef; // Referencia al método de pago

  Payment({
    required this.userRef,
    required this.paymentId,
    required this.amount,
    required this.status,
    required this.currency,
    required this.paymentDate,
    required this.orderRef,
    required this.paymentMethodRef,
  });

  // Convertir desde Firestore
  factory Payment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Payment(
      userRef: data['userRef'],
      paymentId: data['paymentId'],
      amount: data['amount'].toDouble(),
      status: data['status'],
      currency: data['currency'],
      paymentDate: DateTime.parse(data['paymentDate']),
      orderRef: data['orderRef'],
      paymentMethodRef: data['paymentMethodRef'],
    );
  }

  // Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userRef': userRef,
      'paymentId': paymentId,
      'amount': amount,
      'status': status,
      'currency': currency,
      'paymentDate': paymentDate.toIso8601String(),
      'orderRef': orderRef,
      'paymentMethodRef': paymentMethodRef,
    };
  }
}

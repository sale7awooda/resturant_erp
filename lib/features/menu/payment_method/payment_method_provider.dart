// payment_method_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PaymentMethod { cashPayment, mobileBanking }

final paymentMethodProvider =
    StateProvider<String?>((ref) => PaymentMethod.cashPayment.name);

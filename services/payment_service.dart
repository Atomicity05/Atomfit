import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService {
  late Razorpay _razorpay;

  void init({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
    required Function(ExternalWalletResponse) onExternalWallet,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }

  void openCheckout({required int amountInPaise, required String contact, required String email}) {
    var options = {
      'key': 'rzp_test_jK1YOBHFKi2Xno', // Replace with your Razorpay key
      'amount': 50000, // e.g., 50000 = ₹500
      'name': 'AtomKart',
      'description': 'Dress Purchase',
      'prefill': {'contact': contact, 'email': email},
      'theme': {'color': '#F37254'},
      'method': {
        'upi': true,
        'card': true,
        'netbanking': true,
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay: $e');
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}

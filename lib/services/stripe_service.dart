import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();

  Future<bool> makePayment({required amount}) async {
    try {
      String? paymentIntentClientSecret = await _createPaymentIntent(
        amount,
        "USD",
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: "Global Cart",
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return true;

    } catch (e) {
      return false;

    }
  }


  Future<String?> _createPaymentIntent(double amount, String currency) async {
    try {
      final Dio dio = Dio();
      Map<String, dynamic> data = {
        "amount": (amount * 100).toInt().toString(),
        "currency": currency,
      };
      var response = await dio.post(
        "https://api.stripe.com/v1/payment_intents",
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Authorization": "Bearer sk_test_51QYKh1KThqSiL34vGBVcPb4XDCyzOgxNkBC14kORIDRf8lzqW8yZAiF6ON8XMZ3BRVGMN8dO2Z8hwjfcbzOFSrTp00xQk7i0O4",
            "Content-Type": 'application/x-www-form-urlencoded'
          },
        ),
      );
      if (response.data != null) {
        return response.data["client_secret"];
      }
      return null;
    } catch (e) {
      print(e);
    }
    return null;
  }

}
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();

  final Dio dio = Dio();

  Future<void> makePayment(BuildContext context, int amount) async {
    try {
      // Call your backend to create a PaymentIntent
      final clientSecret = await _createPaymentIntent(amount, 'usd');

      if (clientSecret == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content:Text('Failed to create payment intent')),
        );
        return;
      }

      // Initialize the Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          style: ThemeMode.system,
          merchantDisplayName: 'Your App Name',
        ),
      );

      // Present the Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // If successful, show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment successful!')),
      );
    } catch (e) {
      print('Error during payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }


  Future<String?> _createPaymentIntent(int amount, String currency) async {
    final url = Uri.parse('https://api.stripe.com/v1/payment_intents');
    final response = await http.post(
      url,

      headers: {

        'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',

        "Content-Type": 'application/x-www-form-urlencoded',
      },
      body: {
        'amount': _calculatedAmount(amount),
        'currency': currency,
      },
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final responseData = jsonDecode(response.body);
      print('Response: $responseData');
      return responseData["client_secret"];
    } else {
      print('Failed to create payment intent: ${response.body}');
      return null;
    }
  }

  String _calculatedAmount(int amount) {
    // Convert the amount to the smallest currency unit (cents)
    return (amount * 100).toString();
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:vrize_stripe/pages/custome_card_pay_screen.dart';
import 'package:vrize_stripe/widget/container_with_fill.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? paymentIntent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe Payment'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: ClipRect(
                child: Align(
                  alignment: Alignment.center,
                  // Adjust the widthFactor and heightFactor to clip the image
                  widthFactor: 0.5, // Use 0.5 to clip half of the image horizontally
                  heightFactor: 0.5, // Use 0.5 to clip half of the image vertically
                  child: Image.network(
                    'https://strapi.dhiwise.com/uploads/618fa90c201104b94458e1fb_639c3c682573ede2ef7e67c9_Best_Flutter_app_development_tools_and_app_builders_OG_image_ac87c76436.jpg',
                    // Provide width and height to the image for better control
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover, // This ensures the image covers the clip area
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            CustomButtonContainer(
              onPressed: () async {
                await makePayment();
              }, 
              text: 'Pay Now with Card',
            ),
            CustomButtonContainer(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CustomeCardPaymnetScreen()),
                );
              },
              text: 'Pay Now with Custom Card',
            ),
          ],
        ),
      ),
    );
  }
  Future<void> makePayment() async {
    try {
      paymentIntent = await createPaymentIntent('100', 'USD');
      if (kDebugMode) {
        print("Payment Intent: ${paymentIntent!['client_secret']}");
      }

      await Stripe.instance
          .initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent![
              'client_secret'], //Gotten from payment intent
              style: ThemeMode.light,
              merchantDisplayName: 'sam'))
          .then((value) {});

      displayPaymentSheet();
    } catch (err) {
      throw Exception(err);
    }
  }

  void setupPaymentMethod(String clientSecret) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
        ),
      );

      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      if (kDebugMode) {
        print("Error setting up payment: $e");
      }
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        if (kDebugMode) {
          print("Payment Successfully Completed");
        }
        final snackBar = SnackBar(
          content: const Text('Payment Successfully Completed!'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: '',
            onPressed: () {
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } catch (e) {
      if (kDebugMode) {
        print('$e');
      }
      final snackBar = SnackBar(
        content:  Text(e.toString()),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '',
          onPressed: () {
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'setup_future_usage': "off_session"
      };

      ///off_session added to save card details stripe

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer sk_test_51OsMYXSFnYhx5DszZOSxnFEUJlc0Nq8BFYPVsVsRgRlIlebNP3w1XHAbceWro1P0PmeymTWmlbHEObA8VSjXH6pF00zunyInhC',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

}
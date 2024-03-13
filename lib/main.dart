import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:vrize_stripe/constansts.dart';
import 'package:vrize_stripe/pages/setup_future_payment.dart'; // Import kIsWeb

void main() async {
  /// Initialize Flutter Binding
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = MyConstants.publishableKey;

  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      //initial route
      home: SetupFuturePaymentScreen(),
    );
  }
}


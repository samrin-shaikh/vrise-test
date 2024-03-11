import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:vrize_stripe/pages/custome_card_pay_screen.dart';
import 'package:vrize_stripe/pages/home_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb

void main() async {
  /// Initialize Flutter Binding
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey =
  "pk_test_51OsMYXSFnYhx5Dsz3Ixv8fhPUxNdp2lO2MdVPYH5mIlboOTUaIhcGscEULPqkEeZGyOBPA0FGc6gnz9z1KDevMmH00Lv7h1A5J";

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
      home: kIsWeb?
          const CustomeCardPaymnetScreen():
      const HomeScreen(),
    );
  }
}


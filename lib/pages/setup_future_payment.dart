import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import '../apiHelper/api_helper.dart';
import '../constansts.dart';


class SetupFuturePaymentScreen extends StatefulWidget {
  @override
  _SetupFuturePaymentScreenState createState() =>
      _SetupFuturePaymentScreenState();
}

class _SetupFuturePaymentScreenState extends State<SetupFuturePaymentScreen> {
  PaymentIntent? _retrievedPaymentIntent;
  CardFieldInputDetails? _card;
  SetupIntent? _setupIntentResult;
  String _email = 'email@stripe.com';
  Map<String, dynamic> setupIntentResponse = {};
  int step = 0;
  String? customerid;
  String? paymentid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text('Setup Future Payment'),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              initialValue: _email,
              decoration: const InputDecoration(hintText: 'Email', labelText: 'Email'),
              onChanged: (value) {
                setState(() {
                  _email = value;
                });
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: CardField(
              onCardChanged: (card) {
                setState(() {
                  _card = card;
                });
              },
            ),
          ),
          ElevatedButton(onPressed: _handleSavePress, child: const Text("Save Card")),
          const SizedBox(height: 20,),
          ElevatedButton(onPressed: (){
            retrivePaymentMethod(customerid!,paymentid!);
          }, child: const Text("Retrieve Card")),
        ],
      ),
    );
  }


  Future<void> _handleSavePress() async {
    try {
      setupIntentResponse = await _createSetupIntent(_email);
      const billingDetails = BillingDetails(
        name: "Test User",
        email: 'email@stripe.com',
        phone: '+48888000888',
        address: Address(
          city: 'Houston',
          country: 'US',
          line1: '1459  Circle Drive',
          line2: '',
          state: 'Texas',
          postalCode: '77063',
        ),
      );

      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: billingDetails,
          ),
        ),
      );
      final paymentMethodId = paymentMethod.id;
      print("Payment Method ID: $paymentMethodId");
        setState(() {
          paymentid = paymentMethodId;
        });

      final setupIntentResult = await Stripe.instance.confirmSetupIntent(
        paymentIntentClientSecret: setupIntentResponse['client_secret'],
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: billingDetails,
          ),
        ),
      );

      print('Setup Intent created $setupIntentResult');
      print('Setup Intent ID:  ${setupIntentResult.id}');

      final customerId = await _createCustomer();
      setState(() {
        customerid = customerId;
      });

      attachPaymentmethod(customerId,paymentMethodId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Success: Setup intent created.',
          ),
        ),
      );
      setState(() {
        step = 1;
        _setupIntentResult = setupIntentResult;
        print("setup Payment ID ${_setupIntentResult!.paymentMethodId}");
      });
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error code: $error')));
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _createSetupIntent(String email) async {
    final url = Uri.parse(ApiConstants.setupIntent);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${MyConstants.secretKey}',
      },
      body: json.encode({
        'email': email,
      }),
    );
    final Map<String, dynamic> bodyResponse = json.decode(response.body);
    final clientSecret = bodyResponse['client_secret'] as String;
    log('Client token  $clientSecret');

    return bodyResponse;
  }
  Future<Map<String, dynamic>> retrivePaymentMethod(String customerId, String paymnetId) async {
    try {
      Map<String, dynamic> body = {
      };
      var response = await http.get(
        Uri.parse('${ApiConstants.retrivePaymentMethod}$customerId/payment_methods/$paymnetId'),
        headers: {
          'Authorization': 'Bearer ${MyConstants.secretKey}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
      );
      final Map<String, dynamic> bodyResponse = json.decode(response.body);
      log('Retrieve data $bodyResponse');
      return bodyResponse;
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  Future<String> attachPaymentmethod(String customerId, String paymentMethod) async {
    try {
      Map<String, dynamic> body = {
        'customer': customerId,
      };
      var response = await http.post(
        Uri.parse('${ApiConstants.attachPaymentMethod}$paymentMethod/attach'),
        headers: {
          'Authorization': 'Bearer ${MyConstants.secretKey}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      final Map<String, dynamic> bodyResponse = json.decode(response.body);
      final customerIdResponnse = bodyResponse['id'] as String;
      print('attach Payment id  $customerIdResponnse');

      return customerId;
    } catch (err) {
      throw Exception(err.toString());
    }
  }


  Future<String> _createCustomer() async {
    try {
      Map<String, dynamic> body = {
        'name': 'Samarin Shaikh',
        'email': 'ssamrin10@gmail.com',
      };

      var response = await http.post(
        Uri.parse(ApiConstants.createCustomer),
        headers: {
          'Authorization': 'Bearer ${MyConstants.secretKey}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      final Map<String, dynamic> bodyResponse = json.decode(response.body);
      final customerId = bodyResponse['id'] as String;
      return customerId;
    } catch (err) {
      throw Exception(err.toString());
    }
  }

}

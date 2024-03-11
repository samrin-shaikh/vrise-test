import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import '../widget/container_with_fill.dart';

class CustomeCardPaymnetScreen extends StatefulWidget {
  const CustomeCardPaymnetScreen({Key? key}) : super(key: key);

  @override
  State<CustomeCardPaymnetScreen> createState() => _CustomeCardPaymnetScreenState();
}

class _CustomeCardPaymnetScreenState extends State<CustomeCardPaymnetScreen> {
  CardDetails _card = CardDetails();
  bool? _saveCard = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      decoration: const InputDecoration(hintText: 'Number'),
                      onChanged: (number) {
                        setState(() {
                          _card = _card.copyWith(number: number);
                        });
                      },
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    width: 80,
                    child: TextField(
                      maxLength: 2,
                      decoration: const InputDecoration(hintText: 'Card Expiry'),
                      onChanged: (number) {
                        setState(() {
                          _card = _card.copyWith(
                              expirationYear: int.tryParse(number));
                        });
                      },
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    width: 80,
                    child: TextField(
                      maxLength: 2,
                      decoration: const InputDecoration(hintText: 'Expiry Month'),
                      onChanged: (number) {
                        setState(() {
                          _card = _card.copyWith(
                              expirationMonth: int.tryParse(number));
                        });
                      },
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    width: 80,
                    child: TextField(
                      maxLength: 3,
                      decoration: const InputDecoration(hintText: 'CVC'),
                      onChanged: (number) {
                        setState(() {
                          _card = _card.copyWith(cvc: number);
                        });
                      },
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ),
            CheckboxListTile(
              value: _saveCard,
              onChanged: (value) {
                setState(() {
                  _saveCard = value;
                });
              },
              title: const Text('Save card during payment'),
            ),
            CustomButtonContainer(
              onPressed: () async {
                await _handlePayPress();
              },
              text: 'Pay Now',
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _handlePayPress() async {
    // await Stripe.instance.dangerouslyUpdateCardDetails(_card);
    const String customerEmail = 'email@stripe.com';
    final String customerId = await createCustomer(customerEmail);
    print("Customer created: $customerId");

    try {
      // 1. Gather customer billing information (ex. email)

      const billingDetails = BillingDetails(
        email: customerEmail,
        phone: '+48888000888',
        address: Address(
          city: 'Houston',
          country: 'US',
          line1: '1459  Circle Drive',
          line2: '',
          state: 'Texas',
          postalCode: '77063',
        ),
      ); // mocked data for tests

      // 2. Create payment method

      final paymentMethod = await Stripe.instance.createPaymentMethod(
          params: const PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(
              billingDetails: billingDetails,
            ),
          ));
      print("Payment method created: ${paymentMethod.id}");

      await attachPaymentMethod(customerId, paymentMethod.id);
      final paymentIntentResult = await createPaymentIntent(
          '100',
          'USD'
      );

      if (paymentIntentResult['error'] != null) {
        // Error during creating or confirming Intent
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${paymentIntentResult['error']}')));
        return;
      }

      if (paymentIntentResult['client_secret'] != null &&
          paymentIntentResult['next_action'] == null) {
        // Payment succedeed

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
            Text('Success!: The payment was confirmed successfully!')));
        return;
      }

      if (paymentIntentResult['clientSecret'] != null &&
          paymentIntentResult['requiresAction'] == true) {

        final paymentIntent = await Stripe.instance
            .handleNextAction(paymentIntentResult['client_secret']);

        if (paymentIntent.status == PaymentIntentsStatus.RequiresConfirmation) {
          await confirmIntent(paymentIntent.id);
        } else {
          // Payment succedeed
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error: ${paymentIntentResult['error']}')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
      rethrow;
    }
  }

  Future<void> confirmIntent(String paymentIntentId) async {
    print("lll");
    final result = await callNoWebhookPayEndpointIntentId(
        paymentIntentId: paymentIntentId);
    if (result['error'] != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${result['error']}')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Success!: The payment was confirmed successfully!')));
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      //Request body
      Map<String, dynamic> body = {
        'amount': '100',
        'currency': currency,
        'setup_future_usage': "off_session"

      };

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
  Future<Map<String, dynamic>> callNoWebhookPayEndpointIntentId({
    required String paymentIntentId,
  }) async {
    final url = Uri.parse('https://api.stripe.com/v1/charge-card-off-session');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'paymentIntentId': paymentIntentId}),
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> callNoWebhookPayEndpointMethodId({
    required bool useStripeSdk,
    required String paymentMethodId,
    required String currency,
    List<String>? items,
  }) async {
    final url = Uri.parse('https://api.stripe.com/v1/pay-without-webhooks');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'useStripeSdk': useStripeSdk,
        'paymentMethodId': paymentMethodId,
        'currency': currency,
        'items': items
      }),
    );
    return json.decode(response.body);
  }


  Future<List<Map<String, dynamic>>> retrieveCustomerPaymentMethods(String customerId) async {
    final Uri url = Uri.parse('https://api.stripe.com/v1/payment_methods');
    final response = await http.get(
      url.replace(queryParameters: {
        'customer': customerId,
        'type': 'card',
      }),
      headers: {
        'Authorization': 'Bearer sk_test_51OsMYXSFnYhx5DszZOSxnFEUJlc0Nq8BFYPVsVsRgRlIlebNP3w1XHAbceWro1P0PmeymTWmlbHEObA8VSjXH6pF00zunyInhC',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Map<String, dynamic>> paymentMethods = List<Map<String, dynamic>>.from(data['data']);
      return paymentMethods;
    } else {
      // Handle error or invalid response
      throw Exception('Failed to retrieve payment methods. Status code: ${response.statusCode}');
    }
  }
  Future<String> createCustomer(String email) async {
    /// Replace with your endpoint URL
    /// With localhost and port app will not save this card need t0 add server URL
    final Uri url = Uri.parse('http://localhost:54992/create-customer');
    final response = await http.post(url, body: {
      'email': email, // customer's email
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['customerId']; // Ensure your backend returns the customerId
    } else {
      throw Exception('Failed to create customer');
    }
  }
  Future<void> attachPaymentMethod(String customerId, String paymentMethodId) async {
    /// Replace with your endpoint URL
    /// With localhost and port app will not save this card need t0 add server URL
    final Uri url = Uri.parse('http://localhost:54992/attach-payment-method');
    final response = await http.post(url, body: {
      'customerId': customerId,
      'paymentMethodId': paymentMethodId,
    });

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Payment method attached successfully");
      }
    } else {
      throw Exception('Failed to attach payment method');
    }
  }
  Future<List<String>> listSavedCards(String customerId) async {
    /// Replace with your endpoint URL
    /// With localhost and port app will not save this card need t0 add server URL
    final Uri url = Uri.parse('http://localhost:54992/list-payment-methods?customerId=$customerId');

    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      List<String> cardDetails = data.map((card) =>
      "Card: ${card['card']['brand']} **** **** **** ${card['card']['last4']}, Exp: ${card['card']['exp_month']}/${card['card']['exp_year']}"
      ).toList();
      return cardDetails;
    } else {
      throw Exception('Failed to load saved cards');
    }
  }

}

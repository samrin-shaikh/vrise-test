
import 'package:vrize_stripe/constansts.dart';

class ApiConstants {
  static const baseUrl = "https://api.stripe.com/v1/";

  static Map<String, String> headers = {
    'Authorization': 'Bearer ${MyConstants.secretKey}',
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  static const String createCustomer = '${ApiConstants.baseUrl}customers';
  static const String createPaymentMethod = '${ApiConstants.baseUrl}payment_methods';
  static const String setupIntent = '${ApiConstants.baseUrl}setup_intents';
  static const String attachPaymentMethod = '${ApiConstants.baseUrl}payment_methods/';
  static const String retrivePaymentMethod = '${ApiConstants.baseUrl}customers/';


}

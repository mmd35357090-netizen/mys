import 'package:get/get_state_manager/src/simple/get_controllers.dart';
// import 'package:mercadopago_sdk/mercadopago_sdk.dart';

class MercadappagoPaymentController extends GetxController {
  final String accessToken =
      "APP_USR-198032055845990-040405-759ac20c431fdb0db1a4513178bdff82-675559183";
  final String clientId = "198032055845990";
  final String clientSecret = "ZYIggIkgxtHAcaYaG85zqyqB5D4VaOgN";
  final String publicKey = "APP_USR-386101b1-2bb8-4c7f-8bc4-c45fb097218e";

//   Future<Map<String, dynamic>> createCheckout() async{
//     print('createCheckout creating checkout');
//     var mp = MP(clientId, clientSecret);
//
//     var preference = {
//       "items": [
//         {
//           "title": "Test",
//           "quantity": 1,
//           "currency_id": "BR",
//           "unit_price": 10.4
//         }
//       ]
//     };
//
//
//     var result = await mp.createPreference(preference);
//     print('createCheckout creating done');
//     print('createCheckout result: $result');
//     return result;
//   }
//
//   Future<Map<String, dynamic>> getPayment() async {
//     var mp = MP(clientId, clientSecret);
//     print('getPayment result: init...');
//     final paymentInfo = await mp.getPayment("675559183-0b7b187a-9c2a-46f1-b778-cbbe46e6458c");
//     print('getPayment result: $paymentInfo');
//     return paymentInfo;
//   }
}




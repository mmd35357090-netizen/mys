import 'dart:async';
import 'dart:developer';
import 'package:foap/api_handler/apis/payment_gateway_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/setting_imports.dart';
import 'package:foap/model/post_promotion_model.dart';
import 'package:foap/util/constant_util.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:foap/helper/imports/event_imports.dart';

class CheckoutController extends GetxController {
  final UserProfileManager _userProfileManager = Get.find();

  final Razorpay _razorpay = Razorpay();
  RxBool useWallet = false.obs;
  RxDouble balanceToPay = 0.toDouble().obs;
  double totalAmountToPay = 0;
  String itemName = '';

  Rx<PaymentGateway> selectedPaymentGateway =
      Rx<PaymentGateway>(PaymentGateway.stripe);

  RxBool googlePaySupported = false.obs;
  Rx<ProcessingPaymentStatus?> processingPayment =
      Rx<ProcessingPaymentStatus?>(null);

  late Function(List<Payment>) transactionHandler;
  List<Payment> transactions = [];

  clear() {
    useWallet.value = false;
    balanceToPay.value = 0.0;
    totalAmountToPay = 0;
    itemName = '';

    selectedPaymentGateway.value = PaymentGateway.stripe;

    googlePaySupported.value = false;
    processingPayment.value = null;

    transactions = [];
  }

  checkIfGooglePaySupported() async {
    googlePaySupported.value =
        await stripe.Stripe.instance.isPlatformPaySupported();
  }

  selectPaymentGateway(PaymentGateway gateway) {
    selectedPaymentGateway.value = gateway;
  }

  useWalletSwitchChange({
    required bool status,
    required double totalAmount,
    required Function(List<Payment>) transactionHandler,
  }) {
    this.transactionHandler = transactionHandler;

    useWallet.value = status;
    totalAmountToPay = totalAmount;
    balanceToPay.value = totalAmount -
        (status == true
            ? double.parse(_userProfileManager.user.value!.balance)
            : 0);
  }

  payAndBuy({
    required double totalAmount,
    required String itemName,
    required PaymentGateway paymentGateway,
    required Function(List<Payment>) transactionHandler,
  }) {
    totalAmountToPay = totalAmount;
    this.itemName = itemName;
    this.transactionHandler = transactionHandler;
    if (useWallet.value) {
      Payment payment = Payment();
      payment.paymentMode = '3';
      payment.amount = (totalAmountToPay >
                  double.parse(_userProfileManager.user.value!.balance)
              ? _userProfileManager.user.value!.balance
              : totalAmountToPay)
          .toString();
      payment.transactionId = '';
      transactions = [payment];
    }

    switch (paymentGateway) {
      case PaymentGateway.creditCard:
        Get.to(() => const StripeCardPayment());
        break;
      // case PaymentGateway.applePay:
      //   applePay();
      //   break;
      // case PaymentGateway.paypal:
      //   payWithPaypal();
      //   break;
      case PaymentGateway.razorpay:
        launchRazorpayPayment();
        break;
      case PaymentGateway.stripe:
        payWithStripe();
        break;
      // case PaymentGateway.googlePay:
      //   payWithGooglePay();
      //   break;
      case PaymentGateway.inAppPurchase:
        placeOrder();
        break;
      case PaymentGateway.wallet:
        placeOrder();
        break;
    }
  }

  // applePay() async {
  //   try {
  //     // 1. Present Apple Pay sheet
  //     await stripe.Stripe.instance.presentApplePay(
  //       params: stripe.ApplePayPresentParams(
  //         cartItems: [
  //           stripe.ApplePayCartSummaryItem.immediate(
  //             label: 'Product Test',
  //             amount: '$totalAmountToPay',
  //           ),
  //         ],
  //         country: 'US',
  //         currency: 'USD',
  //       ),
  //     );
  //
  //     // 2. fetch Intent Client Secret from backend
  //     PaymentGatewayApi.fetchPaymentIntentClientSecret(
  //         amount: totalAmountToPay,
  //         resultCallback: (clientSecret) async {
  //           // 2. Confirm apple pay payment
  //           await stripe.Stripe.instance.confirmApplePayPayment(clientSecret);
  //
  //           Payment payment = Payment();
  //           payment.paymentMode = '6';
  //           payment.amount = balanceToPay.value.toString();
  //           payment.transactionId = randomId();
  //
  //           transactions.removeWhere((element) => element.paymentMode == '6');
  //           transactions.add(payment);
  //
  //           placeOrder();
  //         });
  //   } catch (e) {
  //     AppUtil.showToast(message: 'Error1: $e', isSuccess: false);
  //     PlatformException error = (e as PlatformException);
  //     if (error.code != 'Canceled') {
  //       processingPayment.value = ProcessingPaymentStatus.failed;
  //     }
  //   }
  // }
  //
  // payWithGooglePay() async {
  //   final googlePaySupported =
  //       await stripe.Stripe.instance.isPlatformPaySupported();
  //   if (googlePaySupported) {
  //     try {
  //       // 1. fetch Intent Client Secret from backend
  //       PaymentGatewayApi.fetchPaymentIntentClientSecret(
  //           amount: totalAmountToPay,
  //           resultCallback: (clientSecret) async {
  //             // 2.present google pay sheet
  //             await stripe.Stripe.instance.initGooglePay(
  //                 stripe.GooglePayInitParams(
  //                     testEnv: true,
  //                     merchantName: AppConfigConstants.appName,
  //                     countryCode: 'us'));
  //
  //             await stripe.Stripe.instance.presentGooglePay(
  //               stripe.PresentGooglePayParams(clientSecret: clientSecret),
  //             );
  //
  //             Payment payment = Payment();
  //             payment.paymentMode = '7';
  //             payment.amount = balanceToPay.value.toString();
  //             payment.transactionId = randomId();
  //
  //             transactions.removeWhere((element) => element.paymentMode == '7');
  //             transactions.add(payment);
  //
  //             placeOrder();
  //           });
  //     } catch (e) {
  //       PlatformException error = (e as PlatformException);
  //       if (error.code != 'Canceled') {
  //         processingPayment.value = ProcessingPaymentStatus.failed;
  //         AppUtil.showToast(message: 'Error: $e', isSuccess: false);
  //       }
  //     }
  //   } else {
  //     processingPayment.value = ProcessingPaymentStatus.failed;
  //
  //     AppUtil.showToast(
  //         message: 'Google pay is not supported on this device',
  //         isSuccess: false);
  //   }
  // }

  // payWithPaypal() async {
  //   Loader.show(status: loadingString.tr);
  //
  //   PaymentGatewayApi.fetchPaypalClientToken(
  //       resultCallback: (paypalClientToken) async {
  //     if (paypalClientToken != null) {
  //       final request =
  //           BraintreePayPalRequest(amount: totalAmountToPay.toString());
  //       BraintreePaymentMethodNonce? result =
  //           await Braintree.requestPaypalNonce(
  //         paypalClientToken,
  //         request,
  //       );
  //       if (result != null) {
  //         processingPayment.value = ProcessingPaymentStatus.inProcess;
  //
  //         String deviceData = '';
  //         if (Platform.isAndroid) {
  //           DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //           AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //           deviceData = 'android, ${androidInfo.model}';
  //         } else {
  //           DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //           IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  //           deviceData = 'iOS, ${iosInfo.utsname.machine}';
  //         }
  //         Loader.dismiss();
  //
  //         PaymentGatewayApi.sendPaypalPayment(
  //             amount: balanceToPay.value,
  //             nonce: result.nonce,
  //             deviceData: deviceData,
  //             resultCallback: (paymentId) {
  //               if (paymentId != null) {
  //                 Payment payment = Payment();
  //                 payment.paymentMode = '2';
  //                 payment.amount = balanceToPay.value.toString();
  //                 payment.transactionId = paymentId;
  //
  //                 transactions
  //                     .removeWhere((element) => element.paymentMode == '2');
  //                 transactions.add(payment);
  //                 placeOrder();
  //               } else {
  //                 processingPayment.value = ProcessingPaymentStatus.failed;
  //               }
  //             });
  //       } else {
  //         Loader.dismiss();
  //       }
  //     } else {
  //       Loader.dismiss();
  //       processingPayment.value = ProcessingPaymentStatus.failed;
  //     }
  //   });
  // }

  payWithStripe() async {
    PaymentGatewayApi.fetchPaymentIntentClientSecret(
        amount: balanceToPay.value,
        resultCallback: (clientSecret) async {
          log('initPaymentSheet');

          await stripe.Stripe.instance.initPaymentSheet(
            paymentSheetParameters: stripe.SetupPaymentSheetParameters(
              paymentIntentClientSecret: clientSecret,

              merchantDisplayName: AppConfigConstants.appName,
              customerId: _userProfileManager.user.value!.id.toString(),
              // applePay: const stripe.PaymentSheetApplePay(
              //   merchantCountryCode: 'US',
              // ),
              // googlePay: const stripe.PaymentSheetGooglePay(
              //   merchantCountryCode: 'US',
              //   testEnv: true,
              // ),
              style: isDarkMode ? ThemeMode.dark : ThemeMode.light,
              appearance: stripe.PaymentSheetAppearance(
                colors: stripe.PaymentSheetAppearanceColors(
                  background: Theme.of(Get.context!).cardColor,
                  primary: Colors.blue,
                  componentBorder: AppColorConstants.dividerColor,
                ),
                shapes: const stripe.PaymentSheetShape(
                  borderWidth: 1,
                  shadow: stripe.PaymentSheetShadowParams(color: Colors.red),
                ),
                primaryButton: stripe.PaymentSheetPrimaryButtonAppearance(
                  shapes: const stripe.PaymentSheetPrimaryButtonShape(
                      blurRadius: 8),
                  colors: stripe.PaymentSheetPrimaryButtonTheme(
                    light: stripe.PaymentSheetPrimaryButtonThemeColors(
                      background: Theme.of(Get.context!).primaryColor,
                      text: const Color.fromARGB(255, 235, 92, 30),
                      border: const Color.fromARGB(255, 235, 92, 30),
                    ),
                  ),
                ),
              ),
              // billingDetails: billingDetails,
            ),
          );
          // await stripe.Stripe.instance.presentPaymentSheet();
          log('confirmStripePayment');
          confirmStripePayment();
        });
  }

  confirmStripePayment() async {
    try {
      // 3. display the payment sheet.
      await stripe.Stripe.instance.presentPaymentSheet();
      // stripe.Stripe.instance.confirmPaymentSheetPayment();

      Payment payment = Payment();
      payment.paymentMode = '4';
      payment.amount = balanceToPay.value.toString();
      payment.transactionId = randomId();

      transactions.removeWhere((element) => element.paymentMode == '4');
      transactions.add(payment);

      placeOrder();
    } on Exception catch (e) {
      if (e is stripe.StripeException) {
        stripe.StripeException error = e;

        if (error.error.code != stripe.FailureCode.Canceled) {
          processingPayment.value = ProcessingPaymentStatus.failed;
          AppUtil.showToast(message: 'Error: $e', isSuccess: false);
        }
        // processingPayment.value = ProcessingPaymentStatus.failed;

        // AppUtil.showToast(
        //     context: context!,
        //     message: 'Error from Stripe: ${e.error.localizedMessage}',
        //     isSuccess: true);
      } else {
        processingPayment.value = ProcessingPaymentStatus.failed;

        AppUtil.showToast(message: 'Unforeseen error: $e', isSuccess: true);
      }
    }
  }

  launchRazorpayPayment() async {
    SettingsController settingsController = Get.find();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    var options = {
      'key': settingsController.setting.value!.razorpayKey!,
      //<-- your razorpay api key/test or live mode goes here.
      'amount': balanceToPay.value * 100,
      'name': AppConfigConstants.appName,
      'description': itemName,
      'prefill': {
        'contact': _userProfileManager.user.value!.phone ?? '',
        'email': _userProfileManager.user.value!.email ?? ''
      },
      'external': {'wallets': []},
      // 'order_id': getRandString(15),
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      processingPayment.value = ProcessingPaymentStatus.failed;

      debugPrint(e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Payment payment = Payment();
    payment.paymentMode = '5';
    payment.amount = balanceToPay.value.toString();
    payment.transactionId = response.paymentId!;

    transactions.removeWhere((element) => element.paymentMode == '5');
    transactions.add(payment);

    placeOrder();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
    // Do something when payment fails
  }

  placeOrder() {
    processingPayment.value = ProcessingPaymentStatus.inProcess;
    transactionHandler(transactions);
  }

  orderPlaced() {
    Timer(const Duration(seconds: 1), () {
      processingPayment.value = ProcessingPaymentStatus.completed;
    });
  }

  orderFailed() {
    processingPayment.value = ProcessingPaymentStatus.failed;
  }
}

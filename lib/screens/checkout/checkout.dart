import 'package:foap/components/payment_method_tile.dart';
import 'package:foap/controllers/profile/profile_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/post_promotion_model.dart';
import 'package:foap/screens/settings_menu/settings_controller.dart';
import 'package:foap/helper/imports/event_imports.dart';

class Checkout extends StatefulWidget {
  final String itemName;
  final double amountToPay;
  final Function(List<Payment>) transactionCallbackHandler;
  final VoidCallback? shareToFeedCallback;

  const Checkout(
      {super.key,
      required this.itemName,
      required this.amountToPay,
      this.shareToFeedCallback,
      required this.transactionCallbackHandler});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  final CheckoutController _checkoutController = Get.find();
  final ProfileController _profileController = Get.find();
  final SettingsController _settingsController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    _profileController.getMyProfile();
    _settingsController.loadSettings();

    _checkoutController.checkIfGooglePaySupported();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkoutController.useWalletSwitchChange(
          status: false,
          totalAmount: widget.amountToPay,
          transactionHandler: widget.transactionCallbackHandler);
    });

    super.initState();
  }

  @override
  void dispose() {
    _checkoutController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Obx(() => _checkoutController.processingPayment.value != null
          ? statusView()
          : SizedBox(
              height: Get.height,
              child: Column(
                children: [
                  backNavigationBar(title: makePaymentString.tr),
                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    BodyLargeText(payableAmountString.tr,
                                        weight: TextWeight.bold),
                                    BodyLargeText(
                                      ' (\$${widget.amountToPay})',
                                      weight: TextWeight.bold,
                                      color: AppColorConstants.themeColor,
                                    ),
                                  ],
                                ).setPadding(
                                    top: 16,
                                    bottom: 16,
                                    left: DesignConstants.horizontalPadding,
                                    right: DesignConstants.horizontalPadding),
                                // divider().vP16,
                                walletView(),
                                paymentGateways()
                                    .hp(DesignConstants.horizontalPadding),
                                const SizedBox(
                                  height: 25,
                                ),
                              ]),
                        ),
                        // Positioned(
                        //     bottom: 20,
                        //     left: 25,
                        //     right: 25,
                        //     child: checkoutButton())
                      ],
                    ),
                  ),
                ],
              ),
            )),
    );
  }

  Widget statusView() {
    return _checkoutController.processingPayment.value ==
            ProcessingPaymentStatus.inProcess
        ? processingView()
        : _checkoutController.processingPayment.value ==
                ProcessingPaymentStatus.completed
            ? orderPlacedView()
            : errorView();
  }

  Widget walletView() {
    return Obx(() => _profileController.user.value == null
        ? Container()
        : Column(
            children: [
              if (double.parse(_profileController.user.value!.balance) > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BodyExtraLargeText(
                          '${walletString.tr} (\$${_userProfileManager.user.value!.balance})',
                          weight: TextWeight.bold,
                          color: AppColorConstants.themeColor,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                BodyLargeText(useBalanceString.tr,
                                    weight: TextWeight.medium),
                                BodyLargeText(
                                  ' (\$${widget.amountToPay > double.parse(_userProfileManager.user.value!.balance) ? _userProfileManager.user.value!.balance : widget.amountToPay})',
                                  weight: TextWeight.medium,
                                  color: AppColorConstants.themeColor,
                                ),
                              ],
                            ),
                            Obx(() => Switch(
                                activeColor: AppColorConstants.themeColor,
                                value: _checkoutController.useWallet.value,
                                onChanged: (value) {
                                  _checkoutController.useWalletSwitchChange(
                                      status: value,
                                      totalAmount: widget.amountToPay,
                                      transactionHandler:
                                          widget.transactionCallbackHandler);
                                }))
                          ],
                        )
                      ],
                    ).hp(DesignConstants.horizontalPadding),
                  ],
                ),
            ],
          ));
  }

  Widget paymentGateways() {
    return Obx(() => _checkoutController.balanceToPay.value > 0 ||
            _checkoutController.useWallet.value == false
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Heading6Text(
                    payUsingString.tr,
                    weight: TextWeight.bold,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    color: AppColorConstants.cardColor,
                    child: Heading6Text(
                      '\$${_checkoutController.balanceToPay.value}',
                      weight: TextWeight.medium,
                      color: AppColorConstants.themeColor,
                    ).p4,
                  ).round(5)
                ],
              ),
              const SizedBox(
                height: 20,
              ),

              // Obx(() => _checkoutController.googlePaySupported.value == true
              //     ? PaymentMethodTile(
              //         text: googlePayString.tr,
              //         icon: "assets/google-pay.png",
              //         price: '\$${_checkoutController.balanceToPay.value}',
              //         isSelected:
              //             _checkoutController.selectedPaymentGateway.value ==
              //                 PaymentGateway.googlePay,
              //         press: () {
              //           _checkoutController
              //               .selectPaymentGateway(PaymentGateway.googlePay);
              //           checkout();
              //         },
              //       )
              //     : Container()),
              // PaymentMethodTile(
              //   text: paypalString.tr,
              //   icon: "assets/paypal.png",
              //   price: '\$${_checkoutController.balanceToPay.value}',
              //   isSelected: _checkoutController.selectedPaymentGateway.value ==
              //       PaymentGateway.paypal,
              //   press: () {
              //     log('PaymentMethodTile paypal');
              //
              //     _checkoutController
              //         .selectPaymentGateway(PaymentGateway.paypal);
              //     checkout();
              //   },
              // ),
              PaymentMethodTile(
                text: stripeString.tr,
                icon: "assets/stripe.png",
                price: '\$${_checkoutController.balanceToPay.value}',
                isSelected: _checkoutController.selectedPaymentGateway.value ==
                    PaymentGateway.stripe,
                press: () {
                  // _checkoutController.launchRazorpayPayment();
                  _checkoutController
                      .selectPaymentGateway(PaymentGateway.stripe);
                  checkout();
                },
              ),
              PaymentMethodTile(
                text: razorPayString.tr,
                icon: "assets/razorpay.png",
                price: '\$${_checkoutController.balanceToPay.value}',
                isSelected: _checkoutController.selectedPaymentGateway.value ==
                    PaymentGateway.razorpay,
                press: () {
                  // _checkoutController
                  //     .selectPaymentGateway(PaymentGateway.razorpay);
                  // checkout();
                },
              ),
              // PaymentMethodTile(
              //   text: inAppPurchase,
              //   icon: "assets/in_app_purchases.png",
              //   price: '\$${_checkoutController.balanceToPay.value}',
              //   isSelected: _checkoutController.selectedPaymentGateway.value ==
              //       PaymentGateway.razorpay,
              //   press: () {
              //     // _checkoutController.launchRazorpayPayment();
              //     _checkoutController
              //         .selectPaymentGateway(PaymentGateway.inAppPurchse);
              //   },
              // ),
              // PaymentMethodTile(
              //   text: cash,
              //   icon: "assets/cash.png",
              //   price: _checkoutController.useWallet.value
              //       ? '${widget.ticketOrder.ticketAmount! - double.parse(_userProfileManager.user.value!.balance)}'
              //       : '\$${widget.ticketOrder.ticketAmount!}',
              //   press: () {
              //     // PaymentModel payment = PaymentModel();
              //     // payment.id = getRandString(20);
              //     // payment.mode = 'cash';
              //     // payment.amount = booking.bookingTotalDoubleValue();
              //     // placeOrder(payment);
              //   },
              // ),
            ],
          )
        : AppThemeButton(
            text: makePaymentString.tr,
            onPress: () {
              checkout();
            }));
  }

  checkout() {
    if (_checkoutController.useWallet.value) {
      if (widget.amountToPay <
          double.parse(_userProfileManager.user.value!.balance)) {
        _checkoutController.payAndBuy(
            itemName: widget.itemName,
            totalAmount: widget.amountToPay,
            paymentGateway: PaymentGateway.wallet,
            transactionHandler: (paymentTransactions) {
              widget.transactionCallbackHandler(paymentTransactions);
            });
      } else {
        _checkoutController.payAndBuy(
            itemName: widget.itemName,
            totalAmount: widget.amountToPay,
            paymentGateway: _checkoutController.selectedPaymentGateway.value,
            transactionHandler: (paymentTransactions) {
              widget.transactionCallbackHandler(paymentTransactions);
            });
      }
    } else {
      _checkoutController.payAndBuy(
          itemName: widget.itemName,
          totalAmount: widget.amountToPay,
          paymentGateway: _checkoutController.selectedPaymentGateway.value,
          transactionHandler: (paymentTransactions) {
            widget.transactionCallbackHandler(paymentTransactions);
          });
    }
  }

  Widget processingView() {
    return SizedBox(
      height: Get.height,
      width: Get.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie.asset('assets/lottie/loading.json'),
          const SizedBox(
            height: 40,
          ),
          Heading3Text(
            placingOrderString.tr,
            weight: TextWeight.semiBold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 10,
          ),
          BodyLargeText(
            doNotCloseAppString.tr,
            weight: TextWeight.regular,
            textAlign: TextAlign.center,
          ),
        ],
      ).hp(DesignConstants.horizontalPadding),
    );
  }

  Widget orderPlacedView() {
    return SizedBox(
      height: Get.height,
      width: Get.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie.asset('assets/lottie/success.json'),
          const SizedBox(
            height: 40,
          ),
          Heading3Text(
            transactionCompletedString.tr,
            weight: TextWeight.semiBold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 40,
          ),
          SizedBox(
              width: 200,
              height: 50,
              child: AppThemeButton(
                  text: thanks.tr,
                  onPress: () {
                    Get.close(2);
                  })),
          const SizedBox(
            height: 20,
          ),
          if (widget.shareToFeedCallback != null)
            SizedBox(
                width: 200,
                height: 50,
                child: AppThemeBorderButton(
                    text: shareToFeedString.tr,
                    onPress: () {
                      widget.shareToFeedCallback!();
                    }))
        ],
      ).hp(DesignConstants.horizontalPadding),
    );
  }

  Widget errorView() {
    return SizedBox(
      height: Get.height,
      width: Get.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie.asset('assets/lottie/error.json'),
          const SizedBox(
            height: 40,
          ),
          Heading3Text(
            errorInBookingString.tr,
            weight: TextWeight.semiBold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 10,
          ),
          BodyLargeText(
            pleaseTryAgainString.tr,
            weight: TextWeight.regular,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 40,
          ),
          SizedBox(
              width: 100,
              height: 40,
              child: AppThemeBorderButton(
                  text: tryAgainString.tr,
                  onPress: () {
                    Get.back();
                  }))
        ],
      ).hp(DesignConstants.horizontalPadding),
    );
  }
}

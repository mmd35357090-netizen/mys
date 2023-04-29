import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:foap/components/payment_method_tile.dart';
import 'package:foap/controllers/profile_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/add_on/controller/event/checkout_controller.dart';
import 'package:foap/screens/settings_menu/settings_controller.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/event_imports.dart';
import 'package:lottie/lottie.dart';

class EventCheckout extends StatefulWidget {
  final EventTicketOrderRequest ticketOrder;
  final UserModel? giftToUser;

  const EventCheckout({Key? key, required this.ticketOrder, this.giftToUser})
      : super(key: key);

  @override
  State<EventCheckout> createState() => _EventCheckoutState();
}

class _EventCheckoutState extends State<EventCheckout> {
  final CheckoutController _checkoutController = CheckoutController();
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
          false, widget.ticketOrder, context);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Obx(() => _checkoutController.processingPayment.value != null
          ? statusView()
          : SizedBox(
              height: Get.height,
              child: Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  backNavigationBar(
                      context: context, title: LocalizationString.buyTicket),
                  divider(context: context).tP8,
                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    BodyLargeText(
                                        LocalizationString.payableAmount,
                                        weight: TextWeight.bold),
                                    BodyLargeText(
                                      ' (\$${widget.ticketOrder.amountToBePaid!})',
                                      weight: TextWeight.bold,
                                      color: AppColorConstants.themeColor,
                                    ),
                                  ],
                                ).setPadding(top: 16, left: 16, right: 16),
                                divider(context: context).vP16,
                                walletView(),
                                paymentGateways().hP16,
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
                    // divider(context: context).vP25,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BodyMediumText(
                          '${LocalizationString.wallet} (\$${_userProfileManager.user.value!.balance})',
                          weight: TextWeight.medium,
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
                                BodyLargeText(LocalizationString.useBalance,
                                    weight: TextWeight.medium),
                                BodyLargeText(
                                  ' (\$${widget.ticketOrder.amountToBePaid! > double.parse(_userProfileManager.user.value!.balance) ? _userProfileManager.user.value!.balance : widget.ticketOrder.amountToBePaid!})',
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
                                      value, widget.ticketOrder, context);
                                }))
                          ],
                        )
                      ],
                    ).hP16,
                  ],
                ),
              const SizedBox(
                height: 10,
              ),
              if (double.parse(_profileController.user.value!.balance) > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BodyMediumText(
                          LocalizationString.coins,
                          weight: TextWeight.medium,
                          color: AppColorConstants.themeColor,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                BodyLargeText(LocalizationString.availableCoins,
                                    weight: TextWeight.medium),
                                BodyLargeText(
                                  ' (${_userProfileManager.user.value!.coins})',
                                  weight: TextWeight.medium,
                                  color: AppColorConstants.themeColor,
                                ),
                              ],
                            ),
                            redeemBtn()
                          ],
                        )
                      ],
                    ).hP16,
                    divider(context: context).vP25,
                  ],
                ),
            ],
          ));
  }

  redeemBtn() {
    return InkWell(
      onTap: () {
        if (_userProfileManager.user.value!.coins <
            _settingsController.setting.value!.minCoinsWithdrawLimit) {
          AppUtil.showToast(
              message: LocalizationString.minCoinsRedeemLimit.replaceAll(
                  '{{coins}}',
                  _settingsController.setting.value!.minCoinsWithdrawLimit
                      .toString()),
              isSuccess: false);
        } else {
          askNumberOfCoinToRedeem();
        }
      },
      child: Center(
        child: Container(
            height: 35.0,
            width: 100,
            color: AppColorConstants.themeColor,
            child: Center(
              child: BodyLargeText(LocalizationString.redeem,
                  weight: TextWeight.medium),
            )).round(5).backgroundCard(),
      ),
    );
  }

  Future<void> askNumberOfCoinToRedeem() async {
    BuildContext dialogContext;

    return showDialog(
        context: context,
        builder: (context) {
          dialogContext = context;

          return AlertDialog(
            title: Text(
              LocalizationString.enterNumberOfCoins,
            ),
            content: Container(
              color: AppColorConstants.backgroundColor,
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: FontSizes.b2),
                        onChanged: (value) {
                          if (textController.text.isNotEmpty) {
                            _settingsController
                                .redeemCoinValueChange(int.parse(value));
                          } else {
                            _settingsController.redeemCoinValueChange(0);
                          }
                        },
                        controller: textController,
                      ).lP8,
                    ),
                  ),
                  Obx(() => Container(
                        height: 50,
                        color: AppColorConstants.themeColor,
                        child: Center(
                          child: BodyMediumText(
                                  '= \$${(_settingsController.redeemCoins * _settingsController.setting.value!.coinsValue).toStringAsFixed(2)}',
                                  weight: TextWeight.medium)
                              .hP8,
                        ),
                      ).rightRounded(10)),
                ],
              ),
            ).round(10),
            actions: <Widget>[
              AppThemeButton(
                text: LocalizationString.redeem,
                onPress: () {
                  if (textController.text.isNotEmpty) {
                    int coins = int.parse(textController.text);
                    if (coins >=
                        _settingsController
                            .setting.value!.minCoinsWithdrawLimit) {
                      if (coins >=
                          _userProfileManager.user.value!.coins) {
                        AppUtil.showToast(
                            message: LocalizationString.enterValidAmountOfCoins
                                .replaceAll(
                                    '{{coins}}',
                                    _settingsController
                                        .setting.value!.minCoinsWithdrawLimit
                                        .toString()),
                            isSuccess: false);
                        return;
                      }
                      _profileController.redeemRequest(coins, context, () {
                        _checkoutController.update();
                      });
                      textController.text = '';
                      Navigator.pop(dialogContext);
                    } else {
                      AppUtil.showToast(
                          message: LocalizationString.minCoinsRedeemLimit
                              .replaceAll(
                                  '{{coins}}',
                                  _settingsController
                                      .setting.value!.minCoinsWithdrawLimit
                                      .toString()),
                          isSuccess: false);
                    }
                  }
                },
              ),
            ],
          );
        });
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
                    LocalizationString.payUsing,
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
              // PaymentMethodTile(
              //   text: LocalizationString.creditCard,
              //   icon: "assets/credit-card.png",
              //   price: '\$${_checkoutController.balanceToPay.value}',
              //   isSelected: _checkoutController.selectedPaymentGateway.value ==
              //       PaymentGateway.creditCard,
              //   press: () {
              //     _checkoutController
              //         .selectPaymentGateway(PaymentGateway.creditCard);
              //     // Get.to(() => NewCreditCardPayment(booking: booking));
              //   },
              // ),
              if (Stripe.instance.isApplePaySupported.value)
                PaymentMethodTile(
                  text: LocalizationString.applePay,
                  icon: _settingsController.darkMode.value
                      ? "assets/apple_pay.png"
                      : "assets/apple_pay_light.png",
                  price: '\$${_checkoutController.balanceToPay.value}',
                  isSelected:
                      _checkoutController.selectedPaymentGateway.value ==
                          PaymentGateway.applePay,
                  press: () {
                    // _checkoutController.applePay();
                    _checkoutController
                        .selectPaymentGateway(PaymentGateway.applePay);
                    checkout();
                  },
                ),

              Obx(() => _checkoutController.googlePaySupported.value == true
                  ? PaymentMethodTile(
                      text: LocalizationString.googlePay,
                      icon: "assets/google-pay.png",
                      price: '\$${_checkoutController.balanceToPay.value}',
                      isSelected:
                          _checkoutController.selectedPaymentGateway.value ==
                              PaymentGateway.googlePay,
                      press: () {
                        // _checkoutController.applePay();
                        _checkoutController
                            .selectPaymentGateway(PaymentGateway.googlePay);
                        checkout();
                      },
                    )
                  : Container()),
              // PaymentMethodTile(
              //   text: LocalizationString.paypal,
              //   icon: "assets/paypal.png",
              //   price: '\$${_checkoutController.balanceToPay.value}',
              //   isSelected: _checkoutController.selectedPaymentGateway.value ==
              //       PaymentGateway.paypal,
              //   press: () {
              //     // _checkoutController.launchBrainTree();
              //     _checkoutController
              //         .selectPaymentGateway(PaymentGateway.paypal);
              //   },
              // ),
              PaymentMethodTile(
                text: LocalizationString.stripe,
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
                text: LocalizationString.razorPay,
                icon: "assets/razorpay.png",
                price: '\$${_checkoutController.balanceToPay.value}',
                isSelected: _checkoutController.selectedPaymentGateway.value ==
                    PaymentGateway.razorpay,
                press: () {
                  _checkoutController
                      .selectPaymentGateway(PaymentGateway.razorpay);
                  checkout();
                },
              ),
              // PaymentMethodTile(
              //   text: LocalizationString.inAppPurchase,
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
              //   text: LocalizationString.cash,
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
        : Container());
  }

  // widget.ticketOrder.amountToBePaid! -
  // double.parse(_userProfileManager.user.value!.balance) >
  // 0

  Widget checkoutButton() {
    return AppThemeButton(
        text: LocalizationString.payAndBuy,
        onPress: () {
          checkout();
        });
  }

  checkout() {
    if (_checkoutController.useWallet.value) {
      if (widget.ticketOrder.amountToBePaid! <
          double.parse(_userProfileManager.user.value!.balance)) {
        _checkoutController.payAndBuy(
            ticketOrder: widget.ticketOrder,
            paymentGateway: PaymentGateway.wallet);
      } else {
        _checkoutController.payAndBuy(
            ticketOrder: widget.ticketOrder,
            paymentGateway: _checkoutController.selectedPaymentGateway.value);
      }
    } else {
      _checkoutController.payAndBuy(
          ticketOrder: widget.ticketOrder,
          paymentGateway: _checkoutController.selectedPaymentGateway.value);
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
          Lottie.asset('assets/lottie/loading.json'),
          const SizedBox(
            height: 40,
          ),
          Heading3Text(
            LocalizationString.placingOrder,
            weight: TextWeight.semiBold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 10,
          ),
          BodyLargeText(
            LocalizationString.doNotCloseApp,
            weight: TextWeight.regular,
            textAlign: TextAlign.center,
          ),
        ],
      ).hP16,
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
          Lottie.asset('assets/lottie/success.json'),
          const SizedBox(
            height: 40,
          ),
          Heading3Text(
            LocalizationString.bookingConfirmed,
            weight: TextWeight.semiBold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 40,
          ),
          SizedBox(
              width: 200,
              height: 50,
              child: AppThemeBorderButton(
                  text: LocalizationString.bookMoreTickets,
                  onPress: () {
                    Get.close(3);
                  }))
        ],
      ).hP16,
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
          Lottie.asset('assets/lottie/error.json'),
          const SizedBox(
            height: 40,
          ),
          Heading3Text(
            LocalizationString.errorInBooking,
            weight: TextWeight.semiBold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 10,
          ),
          BodyLargeText(
            LocalizationString.pleaseTryAgain,
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
                  text: LocalizationString.tryAgain,
                  onPress: () {
                    Get.back();
                  }))
        ],
      ).hP16,
    );
  }
}

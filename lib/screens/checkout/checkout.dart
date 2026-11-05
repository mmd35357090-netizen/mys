import 'package:foap/components/payment_method_tile.dart';
import 'package:foap/controllers/profile/profile_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/post_promotion_model.dart';
import 'package:foap/screens/settings_menu/settings_controller.dart';
import 'package:foap/helper/imports/event_imports.dart';
import 'package:foap/api_handler/apis/deposit_api.dart';
import 'package:foap/screens/wallet/add_money.dart';
import 'package:foap/helper/play_build.dart';
import 'package:foap/model/deposit_model.dart';

class Checkout extends StatefulWidget {
  final String itemName;
  final double amountToPay;
  final Function(List<Payment>) transactionCallbackHandler;
  final VoidCallback? shareToFeedCallback;

  /// A digital in-app feature (for example a post boost). In the Play Store
  /// build it is paid with coins only; otherwise nothing changes.
  final bool digitalItem;

  const Checkout(
      {super.key,
      required this.itemName,
      required this.amountToPay,
      this.digitalItem = false,
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

  bool get _coinOnly => kPlayStoreBuild && widget.digitalItem;

  // card payment (Stripe) is off for now
  static const bool _stripeEnabled = false;

  // true when the admin has switched on at least one manual deposit method
  // (bKash, Nagad, ...): then the "Add money" card is shown on this screen.
  bool _hasDepositMethods = false;

  // USD that the user already sent and that waits for the admin's approval
  double _pendingUsd = 0;

  double get _balance =>
      double.tryParse(_userProfileManager.user.value?.balance ?? '0') ?? 0;

  void _loadPending() {
    DepositApi.getRequests(
        page: 1,
        resultCallback: (items, meta) {
          double sum = 0;
          for (final r in items) {
            if (r.status == DepositStatus.pending) sum += r.usdAmount;
          }
          if (mounted) setState(() => _pendingUsd = sum);
        });
  }

  String _usd(double v) => '\$${v.toStringAsFixed(2)}';

  @override
  void initState() {
    if (!_coinOnly) {
      DepositApi.getMethods(resultCallback: (methods) {
        if (mounted) {
          setState(() => _hasDepositMethods = methods.isNotEmpty);
        }
      });
      _loadPending();
    }
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
                                if (_coinOnly) ...[
                                  coinView(),
                                ] else ...[
                                  if (_hasDepositMethods)
                                    walletSummary()
                                  else
                                    walletView(),
                                  paymentGateways()
                                      .hp(DesignConstants.horizontalPadding),
                                ],
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

  /// Play Store build: the price is shown in coins and paid from the coin balance.
  Widget coinView() {
    return Obx(() {
      final setting = _settingsController.setting.value;
      final rate = setting?.boostCoinsPerUsd ?? 100;
      final coinsNeeded = (widget.amountToPay * rate).ceil();
      final myCoins = _userProfileManager.user.value?.coins ?? 0;
      final enough = myCoins >= coinsNeeded;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BodyExtraLargeText('${availableCoinsString.tr} ($myCoins)',
              weight: TextWeight.bold, color: AppColorConstants.themeColor),
          const SizedBox(height: 8),
          BodyLargeText('${coinsRequiredString.tr}: $coinsNeeded',
              weight: TextWeight.medium),
          const SizedBox(height: 20),
          if (!enough)
            BodySmallText(notEnoughCoinsString.tr,
                color: AppColorConstants.subHeadingTextColor),
          if (!enough) const SizedBox(height: 12),
          if (enough)
            AppThemeButton(
                text: payWithCoinsString.tr,
                onPress: () {
                  _checkoutController.payWithCoins(
                      itemName: widget.itemName,
                      totalAmount: widget.amountToPay,
                      transactionHandler: (paymentTransactions) {
                        widget.transactionCallbackHandler(paymentTransactions);
                      });
                }),
        ],
      ).setPadding(
          top: 20,
          left: DesignConstants.horizontalPadding,
          right: DesignConstants.horizontalPadding);
    });
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

  /// Shows what has to be paid, what the wallet holds and what to do next:
  /// pay from the wallet when it is enough, otherwise add the missing amount.
  Widget walletSummary() {
    return Obx(() {
      final double amount = widget.amountToPay;
      final double balance = _balance;
      final bool enough = balance + 0.001 >= amount;
      final double missing = enough ? 0 : (amount - balance);
      final double toAdd = double.parse(missing.toStringAsFixed(2));
      final double pending = _pendingUsd;

      Widget row(String label, String value, {bool bold = false, Color? color}) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BodyLargeText(label,
                  weight: bold ? TextWeight.bold : TextWeight.regular),
              BodyLargeText(value,
                  weight: bold ? TextWeight.bold : TextWeight.medium,
                  color: color),
            ],
          ),
        );
      }

      return Container(
        margin: EdgeInsets.fromLTRB(DesignConstants.horizontalPadding, 4,
            DesignConstants.horizontalPadding, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColorConstants.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: enough
                  ? AppColorConstants.themeColor
                  : AppColorConstants.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            row(checkoutYouPayString.tr, _usd(amount), bold: true),
            row(checkoutYourWalletString.tr, _usd(balance)),
            if (!enough)
              row(checkoutStillNeededString.tr, _usd(toAdd),
                  bold: true, color: AppColorConstants.themeColor),
            const SizedBox(height: 10),
            if (pending > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColorConstants.themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: BodySmallText(
                    checkoutPendingString.tr.replaceAll('{{amount}}', _usd(pending)),
                    color: AppColorConstants.mainTextColor),
              ),
            if (enough) ...[
              BodySmallText(checkoutWalletEnoughString.tr,
                  color: AppColorConstants.subHeadingTextColor),
              const SizedBox(height: 12),
              AppThemeButton(
                  text: checkoutPayFromWalletString.tr
                      .replaceAll('{{amount}}', _usd(amount)),
                  onPress: () {
                    _checkoutController.useWalletSwitchChange(
                        status: true,
                        totalAmount: widget.amountToPay,
                        transactionHandler: widget.transactionCallbackHandler);
                    _checkoutController.payAndBuy(
                        itemName: widget.itemName,
                        totalAmount: widget.amountToPay,
                        paymentGateway: PaymentGateway.wallet,
                        transactionHandler: (paymentTransactions) {
                          widget.transactionCallbackHandler(paymentTransactions);
                        });
                  }),
            ] else ...[
              BodySmallText(checkoutHowItWorksString.tr,
                  color: AppColorConstants.subHeadingTextColor),
              const SizedBox(height: 12),
              AppThemeButton(
                  text: checkoutAddAmountString.tr
                      .replaceAll('{{amount}}', _usd(toAdd)),
                  onPress: () async {
                    final added = await Get.to(
                        () => AddMoneyScreen(initialUsd: toAdd));
                    if (added == true) {
                      _profileController.getMyProfile();
                      _loadPending();
                    }
                  }),
            ],
          ],
        ),
      );
    });
  }

  /// A greyed-out option for a payment method that a later version will bring.
  Widget comingSoonTile(String name) {
    return Container(
      height: 50,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BodyLargeText(name,
              weight: TextWeight.medium,
              color: AppColorConstants.subHeadingTextColor),
          BodySmallText(comingSoonString.tr,
              color: AppColorConstants.subHeadingTextColor),
        ],
      ),
    ).vP8;
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
              // Stripe is switched off for now. Set _stripeEnabled = true to bring it back.
              if (_stripeEnabled)
                PaymentMethodTile(
                  text: stripeString.tr,
                  icon: "assets/stripe.png",
                  price: '\$${_checkoutController.balanceToPay.value}',
                  isSelected:
                      _checkoutController.selectedPaymentGateway.value ==
                          PaymentGateway.stripe,
                  press: () {
                    _checkoutController
                        .selectPaymentGateway(PaymentGateway.stripe);
                    checkout();
                  },
                ),
              comingSoonTile(googlePayString.tr),
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

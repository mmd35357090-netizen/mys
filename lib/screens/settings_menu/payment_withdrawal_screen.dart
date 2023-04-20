import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/setting_imports.dart';
import '../../components/transaction_tile.dart';
import '../../controllers/profile_controller.dart';
import '../../model/payment_model.dart';

class PaymentWithdrawalScreen extends StatefulWidget {
  const PaymentWithdrawalScreen({Key? key}) : super(key: key);

  @override
  PaymentWithdrawalState createState() => PaymentWithdrawalState();
}

class PaymentWithdrawalState extends State<PaymentWithdrawalScreen> {
  final ProfileController _profileController = Get.find();
  final SettingsController _settingsController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileController.getMyProfile();
      _profileController.getWithdrawHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(
            height: 50,
          ),
          backNavigationBar(
              context: context, title: LocalizationString.earnings),
          divider(context: context).vP8,
          const SizedBox(
            height: 20,
          ),
          totalBalanceView(),
          const SizedBox(
            height: 20,
          ),
          totalCoinBalanceView(),
          const SizedBox(
            height: 20,
          ),
          Padding(
              padding:
                  const EdgeInsets.only(left: 15.0, top: 15.0, bottom: 15.0),
              child: BodyLargeText(LocalizationString.transactionHistory,
                  weight: TextWeight.bold)),
          Expanded(
            child: GetBuilder<ProfileController>(
                init: _profileController,
                builder: (ctx) {
                  return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _profileController.payments.length,
                      itemBuilder: (context, index) {
                        PaymentModel paymentModel =
                            _profileController.payments[index];
                        return TransactionTile(model: paymentModel);
                      });
                }),
          ),
        ]));
  }

  totalBalanceView() {
    return GetBuilder<ProfileController>(
        init: _profileController,
        builder: (ctx) {
          return Container(
            color: AppColorConstants.cardColor,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BodySmallText(
                            LocalizationString.availableBalanceToWithdraw,
                            weight: TextWeight.medium),
                        const SizedBox(height: 10),
                        Heading3Text(
                            '\$${_userProfileManager.user.value!.balance}',
                            weight: TextWeight.bold)
                      ]),
                ),
                withdrawBtn()
              ],
            ).p16,
          ).round(10);
        }).hP16;
  }

  totalCoinBalanceView() {
    return GetBuilder<ProfileController>(
        init: _profileController,
        builder: (ctx) {
          return Container(
            color: AppColorConstants.cardColor,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BodySmallText(
                          LocalizationString.availableCoins,
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Heading3Text(
                                '${_userProfileManager.user.value!.coins}',
                                weight: TextWeight.bold),
                            const SizedBox(height: 5),
                            BodyMediumText(
                              '= \$${(_settingsController.setting.value!.coinsValue * _userProfileManager.user.value!.coins).toStringAsFixed(2)}',
                              weight: TextWeight.bold,
                              color: AppColorConstants.themeColor,
                            ),
                          ],
                        )
                      ]),
                ),
                redeemBtn()
              ],
            ).p16,
          ).round(10);
        }).hP16;
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
                        style: TextStyle(
            fontSize: FontSizes.b2),
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
                      _profileController.redeemRequest(coins, context, () {});
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

  withdrawBtn() {
    return InkWell(
      onTap: () {
        if (int.parse(_userProfileManager.user.value!.balance) < 50) {
          AppUtil.showToast(
              message: LocalizationString.minWithdrawLimit.replaceAll(
                  '{{cash}}',
                  _settingsController.setting.value!.minWithdrawLimit
                      .toString()),
              isSuccess: false);
        } else if ((_userProfileManager.user.value!.paypalId ?? '')
            .isEmpty) {
          AppUtil.showToast(
              message: LocalizationString.pleaseEnterPaypalId,
              isSuccess: false);
        } else {
          _profileController.withdrawalRequest();
        }
      },
      child: Center(
        child: Container(
            height: 35.0,
            width: 100,
            color: AppColorConstants.themeColor,
            child: Center(
              child: BodySmallText(LocalizationString.withdraw,
                  weight: TextWeight.medium),
            )).round(5).backgroundCard(),
      ),
    );
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
              child: BodySmallText(LocalizationString.redeem,
                  weight: TextWeight.medium),
            )).round(5).backgroundCard(),
      ),
    );
  }
}

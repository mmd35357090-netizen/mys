import 'package:foap/util/biometric_helper.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/setting_imports.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../components/transaction_tile.dart';
import '../../controllers/profile/profile_controller.dart';
import '../../model/payment_model.dart';
import '../wallet/add_money.dart';
import '../../api_handler/apis/deposit_api.dart';
import '../wallet/deposit_history.dart';

class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  PaymentWithdrawalState createState() => PaymentWithdrawalState();
}

class PaymentWithdrawalState extends State<Transactions> {
  final ProfileController _profileController = Get.find();
  final SettingsController _settingsController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  TextEditingController textController = TextEditingController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  // Add money / My deposits show only while the admin has a deposit method switched ON.
  // When it is OFF the buttons and their space are gone, the list moves up.
  bool _hasDepositMethods = false;

  @override
  void initState() {
    super.initState();

    DepositApi.getMethods(resultCallback: (methods) {
      if (mounted) setState(() => _hasDepositMethods = methods.isNotEmpty);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileController.getMyProfile();
      _profileController.getTransactionHistory(() {});
    });
  }

  loadMore() {
    _profileController.getTransactionHistory(() {
      _refreshController.loadComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          backNavigationBar(title: transactionHistoryString.tr),
          const SizedBox(
            height: 20,
          ),
          totalBalanceView(),
          if (_hasDepositMethods) const SizedBox(height: 12),
          if (_hasDepositMethods) depositButtons(),
          Expanded(
            child: GetBuilder<ProfileController>(
                init: _profileController,
                builder: (ctx) {
                  if (_profileController.transactions.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: BodyLargeText(
                            'No transactions yet. Boosts, refunds, withdrawals and other money activity appear here.',
                            textAlign: TextAlign.center,
                            color: AppColorConstants.subHeadingTextColor),
                      ),
                    );
                  }
                  return ListView.builder(
                      padding: EdgeInsets.only(
                          top: 25,
                          bottom: 100,
                          left: DesignConstants.horizontalPadding,
                          right: DesignConstants.horizontalPadding),
                      itemCount: _profileController.transactions.length,
                      itemBuilder: (context, index) {
                        TransactionModel transactionModel =
                            _profileController.transactions[index];
                        return TransactionTile(model: transactionModel);
                      }).addPullToRefresh(
                      refreshController: _refreshController,
                      onRefresh: () {},
                      onLoading: () {
                        loadMore();
                      },
                      enablePullUp: true,
                      enablePullDown: false);
                }),
          ),
        ]));
  }

  depositButtons() {
    return Row(
      children: [
        Expanded(
          child: AppThemeButton(
              text: addMoneyString.tr,
              onPress: () async {
                final added = await Get.to(() => const AddMoneyScreen());
                if (added == true) {
                  _profileController.getMyProfile();
                }
              }),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: BorderSide(
                    color: AppColorConstants.themeColor, width: 1.2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16))),
            onPressed: () async {
              await Get.to(() => const DepositHistoryScreen());
              _profileController.getMyProfile();
              _profileController.getTransactionHistory(() {});
            },
            child: Text(myDepositsString.tr,
                style: TextStyle(color: AppColorConstants.themeColor)),
          ),
        ),
      ],
    ).hp(DesignConstants.horizontalPadding);
  }

  // "-1.04904e-7" style float leftovers are shown as $0.00
  String _balanceText() {
    final String raw = _userProfileManager.user.value!.balance;
    final double? value = double.tryParse(raw);
    if (value == null) {
      return raw;
    }
    return '\$${(value < 0.005 ? 0.0 : value).toStringAsFixed(2)}';
  }

  totalBalanceView() {
    return GetBuilder<ProfileController>(
        init: _profileController,
        builder: (ctx) {
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColorConstants.themeColor,
                  AppColorConstants.themeColor.withValues(alpha: 0.72),
                ],
              ),
              boxShadow: [
                BoxShadow(
                    color: AppColorConstants.themeColor.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BodySmallText(availableBalanceToWithdrawString.tr,
                            weight: TextWeight.medium,
                            color: Colors.white.withValues(alpha: 0.85)),
                        const SizedBox(height: 8),
                        Heading3Text(_balanceText(),
                            weight: TextWeight.bold, color: Colors.white)
                      ]),
                ),
                withdrawBtn()
              ],
            ),
          );
        }).hp(DesignConstants.horizontalPadding);
  }

  withdrawBtn() {
    return InkWell(
      onTap: () {
        final int minWithdraw =
            _settingsController.setting.value?.minWithdrawLimit ?? 50;
        if (double.parse(_userProfileManager.user.value!.balance) < minWithdraw) {
          AppUtil.showToast(
              message: minWithdrawLimitString.tr.replaceAll(
                  '{{cash}}',
                  _settingsController.setting.value!.minWithdrawLimit
                      .toString()),
              isSuccess: false);
        } else if ((_userProfileManager.user.value!.paypalId ?? '').isEmpty) {
          AppUtil.showToast(
              message: pleaseEnterPaypalIdString.tr, isSuccess: false);
        } else {
          BiometricHelper.confirmIfEnabled(withdrawString.tr).then((ok) {
            if (ok) {
              _profileController.withdrawalRequest();
            }
          });
        }
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            withdrawString.tr,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColorConstants.themeColor),
          ),
        ),
      ),
    );
  }
}

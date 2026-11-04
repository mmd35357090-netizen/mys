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

  // Add money / My deposits are shown only while the admin has at least one
  // deposit method switched on.
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
                minimumSize: const Size.fromHeight(50),
                side: BorderSide(color: AppColorConstants.themeColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
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
                        BodySmallText(availableBalanceToWithdrawString.tr,
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
        }).hp(DesignConstants.horizontalPadding);
  }

  withdrawBtn() {
    return InkWell(
      onTap: () {
        if (double.parse(_userProfileManager.user.value!.balance) < 50) {
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
          _profileController.withdrawalRequest();
        }
      },
      child: Center(
        child: Container(
            height: 35.0,
            width: 100,
            color: AppColorConstants.themeColor,
            child: Center(
              child: BodyLargeText(
                withdrawString.tr,
                weight: TextWeight.medium,
                color: Colors.white,
              ),
            )).round(5).backgroundCard(),
      ),
    );
  }
}

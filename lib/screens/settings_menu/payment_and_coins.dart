import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/setting_imports.dart';

class PaymentAndCoins extends StatefulWidget {
  const PaymentAndCoins({super.key});

  @override
  State<PaymentAndCoins> createState() => _PaymentAndCoinsState();
}

class _PaymentAndCoinsState extends State<PaymentAndCoins> {
  final SettingsController settingsController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  int coin = 0;

  @override
  void initState() {
    super.initState();
    coin = _userProfileManager.user.value!.coins;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: paymentAndCoinsString.tr),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Column(
                  children: [
                    addTileEvent('${coinsString.tr} ($coin)', () {
                      Get.to(() => const PackagesScreen());
                    }),
                    addTileEvent(transactionHistoryString.tr, () {
                      Get.to(() => const Transactions());
                    }),
                  ],
                ),
                const SizedBox(
                  height: 50,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  addTileEvent(String title, VoidCallback action) {
    return InkWell(
        onTap: action,
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [BodyLargeText(title, weight: TextWeight.medium)],
                  ),
                ),
                // const Spacer(),
                ThemeIconWidget(
                  ThemeIcon.nextArrow,
                  color: AppColorConstants.iconColor,
                  size: 15,
                )
              ]).hp(DesignConstants.horizontalPadding),
            ),
            divider()
          ],
        ));
  }
}

import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';

import '../settings_menu/packages_screen.dart';

class EarnCoinForContestPopup extends StatefulWidget {
  final int needCoins;

  const EarnCoinForContestPopup({Key? key, required this.needCoins})
      : super(key: key);

  @override
  State<EarnCoinForContestPopup> createState() =>
      _EarnCoinForContestPopupState();
}

class _EarnCoinForContestPopupState extends State<EarnCoinForContestPopup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          backNavigationBar(context: context, title: LocalizationString.coins),
          divider(context: context).tP8,
          const Spacer(),
          Container(
                  height: 450,
                  color: AppColorConstants.backgroundColor,
                  child: Column(
                    children: [
                      Heading6Text(
                        LocalizationString.youNeed,
                      ).bp(20),
                      Heading4Text(
                        '${widget.needCoins} ${LocalizationString.coins}',
                        weight: TextWeight.bold,
                        color: AppColorConstants.themeColor,
                      ).bp(15),
                      Heading6Text(
                        LocalizationString.toJoinThisCompetition,
                      ).bp(120),
                      Heading5Text(
                        LocalizationString.watchAdsToEarnCoins,
                        color: AppColorConstants.themeColor,
                      ).ripple(() {}).bp(20),
                      AppThemeButton(
                        text: LocalizationString.buyCoins,
                        onPress: () {
                          Get.back();
                          Get.to(() => const PackagesScreen());
                        },
                      ).hP16
                    ],
                  ).setPadding(top: 70, bottom: 45))
              .round(20)
              .hP25,
          const Spacer(),
        ],
      ),
    );
  }
}

import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/setting_imports.dart';

import '../../controllers/subscription_packages_controller.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({Key? key}) : super(key: key);

  @override
  PackagesScreenState createState() => PackagesScreenState();
}

class PackagesScreenState extends State<PackagesScreen> {
  final SubscriptionPackageController packageController = Get.find();
  final SettingsController settingsController = Get.find();

  @override
  void initState() {
    super.initState();

    settingsController.getSettings();
    packageController.initiate(context);
  }

  @override
  void dispose() {
    packageController.subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(
          height: 50,
        ),
        backNavigationBar(context: context, title: LocalizationString.packages),
        divider(context: context).tP8,
        const Expanded(child: CoinPackagesWidget()),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            BodyLargeText(LocalizationString.watchAds,
                weight: TextWeight.bold, color: AppColorConstants.themeColor),
            const SizedBox(height: 10),
            Obx(() => BodyMediumText(
                  settingsController.setting.value == null
                      ? LocalizationString.watchAdsReward
                          .replaceAll('coins_value', LocalizationString.loading)
                      : LocalizationString.watchAdsReward.replaceAll(
                          'coins_value',
                          settingsController
                              .setting.value!.watchVideoRewardCoins
                              .toString()),
                )),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                height: 45,
                child: AppThemeButton(
                    text: LocalizationString.watchAds,
                    onPress: () {
                      packageController.showRewardedAds();
                    }),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ).hP16
      ]),
    );
  }
}

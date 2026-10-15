import 'package:foap/helper/imports/common_import.dart';

import 'package:url_launcher/url_launcher.dart';

import '../screens/settings_menu/settings_controller.dart';

class ForceUpdateView extends StatelessWidget {
  ForceUpdateView({super.key}) ;
  final SettingsController settingsController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.backgroundColor,
      height: Get.height,
      width: Get.width,
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: Get.height * 0.1,
          ),
          Expanded(
              child: Image.asset(
            'assets/force_update.png',
            fit: BoxFit.contain,
          ).p25),
          Heading4Text(
            timeToUpdateAppString.tr.toUpperCase(),
            weight: TextWeight.bold,
            textAlign: TextAlign.center,
          ).hP25,
          SizedBox(
            height: Get.height * 0.03,
          ),
          Heading3Text(
            usingOlderVersionMessageString.tr,
            weight: TextWeight.regular,
            textAlign: TextAlign.center,
          ).hP25,
          SizedBox(
            height: Get.height * 0.07,
          ),
          SizedBox(
            height: 50,
            width: 280,
            child: AppThemeButton(
              cornerRadius: 25,
              text: updateString.tr,
              onPress: () async {
                await launchUrl(
                    Uri.parse(settingsController.setting.value!.latestAppDownloadLink!));
              },
              backgroundColor: const Color(0xff512e98),
            ),
          ),
          SizedBox(
            height: Get.height * 0.1,
          ),
        ],
      )),
    );
  }
}

class InvalidPurchaseView extends StatelessWidget {
  const InvalidPurchaseView({super.key}) ;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: SizedBox(
        height: Get.height,
        width: Get.width,
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: Get.height * 0.1,
            ),
            Expanded(
                child: Image.asset(
              'assets/force_update.png',
              fit: BoxFit.contain,
            ).p25),
            Heading4Text(
              'Invalid purchase code'.toUpperCase(),
              weight: TextWeight.bold,
              textAlign: TextAlign.center,
            ).hP25,
            SizedBox(
              height: Get.height * 0.03,
            ),
            Heading3Text(
              'Please buy the original code from codecanyon.net to use this app',
              weight: TextWeight.regular,
              textAlign: TextAlign.center,
            ).hP25,
            SizedBox(
              height: Get.height * 0.07,
            ),
            SizedBox(
              height: 50,
              width: 280,
              child: AppThemeButton(
                cornerRadius: 25,
                text: okString.tr,
                onPress: () async {
                  await launchUrl(Uri.parse(
                      'https://codecanyon.net/item/timeline-chat-calling-live-social-media-photo-video-sharing-app-iosandroidadmin-panel/39825646'));
                },
                backgroundColor: const Color(0xff512e98),
              ),
            ),
            SizedBox(
              height: Get.height * 0.1,
            ),
          ],
        )),
      ),
    );
  }
}

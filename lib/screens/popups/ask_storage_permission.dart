import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/util/shared_prefs.dart';
import 'package:permission_handler/permission_handler.dart';
import '../dashboard/loading.dart';

class AskStoragePermission extends StatelessWidget {
  const AskStoragePermission({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 200,
            width: 200,
            color: AppColorConstants.themeColor.withValues(alpha: 0.1),
            child: ThemeIconWidget(
              ThemeIcon.files,
              size: 100,
              color: AppColorConstants.themeColor,
            ),
          ).circular,
          const SizedBox(
            height: 40,
          ),
          BodyLargeText(
            'We will access your files for sharing with friends in chat',
            textAlign: TextAlign.center,
            weight: TextWeight.semiBold,
          ),
          const SizedBox(
            height: 50,
          ),
          AppThemeButton(
              text: nextString.tr,
              onPress: () async {
                await Permission.storage.request();
                SharedPrefs().setTutorialSeen();
                Get.offAll(() => LoadingScreen());
              }),
        ],
      ).hp(DesignConstants.horizontalPadding),
    );
  }
}

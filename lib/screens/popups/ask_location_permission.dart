import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/popups/ask_contact_permission.dart';
import 'package:permission_handler/permission_handler.dart';

class AskLocationPermission extends StatelessWidget {
  const AskLocationPermission({super.key});

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
              ThemeIcon.location,
              size: 100,
              color: AppColorConstants.themeColor,
            ),
          ).circular,
          const SizedBox(
            height: 40,
          ),
          BodyLargeText(
            'We will collect your location for sharing location with friends in chat',
            textAlign: TextAlign.center,
            weight: TextWeight.semiBold,
          ),
          const SizedBox(
            height: 50,
          ),
          AppThemeButton(
              text: nextString.tr,
              onPress: () async {
                await Permission.location.request();
                Get.to(() => AskContactPermission());
              }),
        ],
      ).hp(DesignConstants.horizontalPadding),
    );
  }
}

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
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColorConstants.themeColor.withValues(alpha: 0.18),
                  AppColorConstants.themeColor.withValues(alpha: 0.06)
                ],
              ),
            ),
            child: Center(
              child: Container(
                height: 96,
                width: 96,
                decoration: BoxDecoration(
                    color: AppColorConstants.themeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AppColorConstants.themeColor
                              .withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6))
                    ]),
                child: Center(
                  child: ThemeIconWidget(ThemeIcon.location,
                      size: 46, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          BodyLargeText(
            'We will collect your location for sharing location with friends in chat',
            textAlign: TextAlign.center,
            weight: TextWeight.medium,
            color: AppColorConstants.subHeadingTextColor,
          ).hP16,
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

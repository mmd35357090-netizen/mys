import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/popups/ask_mic_permission.dart';
import 'package:permission_handler/permission_handler.dart';

class AskGalleryPermission extends StatelessWidget {
  const AskGalleryPermission({super.key});

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
                  child: ThemeIconWidget(ThemeIcon.gallery,
                      size: 46, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          BodyLargeText(
            'We will access your gallery for sharing image/video with friends in chat and create posts',
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
                await Permission.photos.request();
                Get.to(()=> AskMicPermission());
              }),
        ],
      ).hp(DesignConstants.horizontalPadding),
    );
  }
}

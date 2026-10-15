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
            height: 200,
            width: 200,
            color: AppColorConstants.themeColor.withValues(alpha: 0.1),
            child: ThemeIconWidget(
              ThemeIcon.gallery,
              size: 100,
              color: AppColorConstants.themeColor,
            ),
          ).circular,
          const SizedBox(
            height: 40,
          ),
          BodyLargeText(
            'We will access your gallery for sharing image/video with friends in chat and create posts',
            textAlign: TextAlign.center,
            weight: TextWeight.semiBold,
          ),
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

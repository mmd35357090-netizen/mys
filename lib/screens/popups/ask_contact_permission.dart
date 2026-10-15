import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'ask_image_permission.dart';

class AskContactPermission extends StatelessWidget {
  const AskContactPermission({super.key});

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
              ThemeIcon.contacts,
              size: 100,
              color: AppColorConstants.themeColor,
            ),
          ).circular,
          const SizedBox(
            height: 40,
          ),
          BodyLargeText(
            'We will access your contact list for sharing contacts with friends in chat',
            textAlign: TextAlign.center,
            weight: TextWeight.semiBold,
          ),
          const SizedBox(
            height: 50,
          ),
          AppThemeButton(
              text: nextString.tr,
              onPress: () async {
                await FlutterContacts.requestPermission();
                Get.to(() => const AskGalleryPermission());
              }),
        ],
      ).hp(DesignConstants.horizontalPadding),
    );
  }
}

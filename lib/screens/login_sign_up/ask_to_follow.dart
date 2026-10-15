import 'package:foap/main.dart';
import 'package:foap/screens/popups/ask_location_permission.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helper/imports/common_import.dart';
import '../dashboard/loading.dart';

class AskToFollow extends StatelessWidget {
  const AskToFollow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Image.asset(
            'assets/follow.png',
            height: 200,
          ),
          const SizedBox(
            height: 40,
          ),
          Heading6Text(
            '1. Receive Weekly Updates of Free App Source Code\n '
            '2. Pre-launch Enhancements ahead of the New App Release\n'
            '3. Explore Job Opportunities with Our Team\n'
            '4. Unlock Your Earning Potential',
            weight: TextWeight.regular,
            textAlign: TextAlign.start,
          ),
          const SizedBox(
            height: 40,
          ),
          AppThemeButton(
              text: followString.tr,
              onPress: () async {
                await launchUrl(
                    Uri.parse('https://instagram.com/singhcoders/'));
              }),
          const Spacer(),
          BodyLargeText(skipString.tr).ripple(() {
            if (isPermissionsAsked == false) {
              Get.offAll(() => const AskLocationPermission());
            } else {
              Get.offAll(() => const LoadingScreen());
            }
          }),
          const SizedBox(
            height: 40,
          ),
        ],
      ).hp(DesignConstants.horizontalPadding),
    );
  }
}

import 'package:foap/helper/imports/common_import.dart';

class NotEligibleForSubscription extends StatelessWidget {
  const NotEligibleForSubscription({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: settingsString.tr),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 40,
                ),
                Image.asset(
                  'assets/not_eligible.png',
                  width: Get.width * 0.7,
                ),
                const SizedBox(
                  height: 40,
                ),
                Heading5Text(
                  'You are not eligible to create subsriptions',
                  textAlign: TextAlign.center,
                ),
              ],
            ).hp(DesignConstants.horizontalPadding),
          ),
        ],
      ),
    );
  }
}

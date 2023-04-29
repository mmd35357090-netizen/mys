import 'package:flutter_switch/flutter_switch.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/setting_imports.dart';

class PrivacyOptions extends StatefulWidget {
  const PrivacyOptions({Key? key}) : super(key: key);

  @override
  State<PrivacyOptions> createState() => _PrivacyOptionsState();
}

class _PrivacyOptionsState extends State<PrivacyOptions> {
  final SettingsController settingsController = Get.find();

  @override
  void initState() {
    settingsController.loadSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          backNavigationBar(
              context: context, title: LocalizationString.privacy),
          divider(context: context).tP8,
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Column(
                  children: [
                    shareLocationTile(),
                    bioMetricLoginTile(),
                  ],
                ),
                const SizedBox(
                  height: 50,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  shareLocationTile() {
    return Column(
      children: [
        SizedBox(
          height: 65,
          child: Row(children: [
            Container(
                    color: AppColorConstants.themeColor.withOpacity(0.2),
                    child: Image.asset(
                      'assets/dark-mode.png',
                      height: 20,
                      width: 20,
                      color: AppColorConstants.themeColor,
                    ).p8)
                .circular,
            const SizedBox(width: 10),
            Expanded(
              child: BodyLargeText(LocalizationString.shareLocation,
                  weight: TextWeight.medium),
            ),
            // const Spacer(),
            Obx(() => FlutterSwitch(
                  inactiveColor: AppColorConstants.disabledColor,
                  activeColor: AppColorConstants.themeColor,
                  width: 50.0,
                  height: 30.0,
                  valueFontSize: 15.0,
                  toggleSize: 20.0,
                  value: settingsController.shareLocation.value,
                  borderRadius: 30.0,
                  padding: 8.0,
                  // showOnOff: true,
                  onToggle: (val) {
                    settingsController.shareLocationToggle(val);
                  },
                )),
          ]).hP16,
        ),
        divider(context: context)
      ],
    );
  }

  bioMetricLoginTile() {
    return Obx(() => settingsController.bioMetricType.value == 0
        ? Container()
        : Column(
            children: [
              SizedBox(
                height: 75,
                child: Row(children: [
                  Container(
                          color: AppColorConstants.themeColor.withOpacity(0.2),
                          child: Image.asset(
                            settingsController.bioMetricType.value == 1
                                ? 'assets/face-id.png'
                                : 'assets/fingerprint.png',
                            height: 20,
                            width: 20,
                            color: AppColorConstants.themeColor,
                          ).p8)
                      .circular,
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BodyLargeText(LocalizationString.faceIdOrTouchId,
                                weight: TextWeight.medium)
                            .bP4,
                        BodySmallText(
                          LocalizationString.unlockYourAppUsingBiometricLogin,
                        ),
                      ],
                    ),
                  ),
                  // const Spacer(),
                  FlutterSwitch(
                    inactiveColor: AppColorConstants.disabledColor,
                    activeColor: AppColorConstants.themeColor,
                    width: 50.0,
                    height: 30.0,
                    valueFontSize: 15.0,
                    toggleSize: 20.0,
                    value: settingsController.bioMetricAuthStatus.value,
                    borderRadius: 30.0,
                    padding: 8.0,
                    // showOnOff: true,
                    onToggle: (value) {
                      settingsController.biometricLogin(value);
                    },
                  ),
                ]).hP16,
              ),
              divider(context: context)
            ],
          ));
  }
}

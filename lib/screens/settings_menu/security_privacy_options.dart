import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/setting_imports.dart';
import '../../universal_components/menu_tiles.dart';
import '../../util/biometric_helper.dart';


class PrivacyOptions extends StatefulWidget {
  const PrivacyOptions({super.key});

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
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: privacyString.tr),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(DesignConstants.horizontalPadding,
                  16, DesignConstants.horizontalPadding, 40),
              children: [
                Obx(() => MenuSection(tiles: [
                      bioMetricLoginTile(),
                      accountPrivacyTile(),
                      onlineStatusTile(),
                    ])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _switch(bool value, ValueChanged<bool> onChanged) {
    return WKToggleSwitch1(
      inactiveColor: AppColorConstants.disabledColor,
      activeColor: AppColorConstants.themeColor,
      width: 50.0,
      height: 30.0,
      initialValue: value,
      onChanged: onChanged,
    );
  }

  Widget bioMetricLoginTile() {
    final state = settingsController.bioMetricState.value;
    final ready = state == BiometricState.ready;
    final type = settingsController.bioMetricType.value;
    final title = type == 1
        ? 'Face unlock'
        : type == 2
            ? 'Fingerprint unlock'
            : faceIdOrTouchIdString.tr;
    final subtitle = ready
        ? unlockYourAppUsingBiometricLoginString.tr
        : state == BiometricState.notEnrolled
            ? 'Add a fingerprint or face in your phone Settings to use this.'
            : 'Biometric is not supported on this device.';
    return MenuRow(
      icon: Icons.fingerprint_rounded,
      color: const Color(0xFF10B981),
      title: title,
      subtitle: subtitle,
      trailing: Switch(
        value: settingsController.bioMetricAuthStatus.value,
        activeColor: AppColorConstants.themeColor,
        onChanged: (ready || settingsController.bioMetricAuthStatus.value)
            ? (value) => settingsController.biometricLogin(value)
            : null,
      ),
    );
  }

  Widget accountPrivacyTile() {
    return MenuRow(
      icon: Icons.lock_outline_rounded,
      color: const Color(0xFF6366F1),
      title: privateAccountString.tr,
      subtitle: privateAccountMsgString.tr,
      trailing: _switch(settingsController.isPrivateAccount.value,
          (isPrivate) {
        settingsController.toggleAccountPrivacy(isPrivate);
      }),
    );
  }

  Widget onlineStatusTile() {
    return MenuRow(
      icon: Icons.circle_outlined,
      color: const Color(0xFF22C55E),
      title: shareOnlineStatusStaring.tr,
      subtitle: shareOnlineStatusMsgString.tr,
      trailing: _switch(settingsController.isShareOnlineStatus.value,
          (status) {
        settingsController.toggleShowOnlineStatusSetting(status);
      }),
    );
  }
}

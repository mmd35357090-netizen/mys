import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/login_signup_imports.dart';
import '../../controllers/misc/subscription_packages_controller.dart';
import '../../manager/socket_manager.dart';
import '../../util/biometric_helper.dart';
import '../../util/shared_prefs.dart';
import 'dashboard_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final UserProfileManager _userProfileManager = Get.find();
  final SubscriptionPackageController packageController = Get.find();

  int _type = 0; // 0 = nothing to show yet
  bool _busy = false;
  bool _opened = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _openNextScreen() {
    if (_opened) return;
    _opened = true;
    if (_userProfileManager.isLogin == true) {
      packageController.initiate();
      Get.offAll(() => const DashboardScreen());
      getIt<SocketManager>().connect();
    } else {
      Get.offAll(() => const LoginScreen());
    }
  }

  Future<void> _start() async {
    if (_userProfileManager.isLogin != true) {
      _openNextScreen();
      return;
    }
    final enabled = await SharedPrefs().getBioMetricAuthStatus();
    if (!enabled) {
      _openNextScreen();
      return;
    }
    final state = await BiometricHelper.state();
    if (state != BiometricState.ready) {
      // fingerprint / face was removed from the phone: do not lock the user
      // out, switch the lock off and continue.
      SharedPrefs().setBioMetricAuthStatus(false);
      _openNextScreen();
      return;
    }
    final t = await BiometricHelper.type();
    if (!mounted) return;
    setState(() => _type = t == 0 ? 2 : t);
    _unlock();
  }

  Future<void> _unlock() async {
    if (_busy) return;
    _busy = true;
    final ok = await BiometricHelper.authenticate(
        'Please authenticate to open the app');
    _busy = false;
    if (ok) _openNextScreen();
  }

  Future<void> _logout() async {
    SharedPrefs().setBioMetricAuthStatus(false);
    _userProfileManager.logout();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      canPop: false,
      backgroundColor: AppColorConstants.backgroundColor,
      body: _type == 0
          ? const SizedBox()
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 96,
                      width: 96,
                      decoration: BoxDecoration(
                          color: AppColorConstants.themeColor
                              .withValues(alpha: 0.12),
                          shape: BoxShape.circle),
                      child: Icon(
                          _type == 1
                              ? Icons.face_unlock_outlined
                              : Icons.fingerprint_rounded,
                          size: 52,
                          color: AppColorConstants.themeColor),
                    ),
                    const SizedBox(height: 28),
                    Heading4Text(appLockedString.tr, weight: TextWeight.bold),
                    const SizedBox(height: 8),
                    BodyMediumText(
                      _type == 1
                          ? unlockAppWithFaceIdString.tr
                          : unlockAppWithTouchIdString.tr,
                      textAlign: TextAlign.center,
                      color: AppColorConstants.subHeadingTextColor,
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: _unlock,
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: AppColorConstants.themeColor,
                            borderRadius: BorderRadius.circular(16)),
                        child: BodyLargeText(
                            _type == 1 ? useFaceIdString.tr : useTouchIdString.tr,
                            color: Colors.white,
                            weight: TextWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    BodyMediumText('Log out',
                            color: AppColorConstants.subHeadingTextColor)
                        .ripple(_logout),
                  ],
                ),
              ),
            ),
    );
  }
}

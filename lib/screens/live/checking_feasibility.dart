import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:get/get.dart';
import 'package:foap/helper/imports/live_imports.dart';
import 'package:permission_handler/permission_handler.dart';

class CheckingLiveFeasibility extends StatefulWidget {
  const CheckingLiveFeasibility({Key? key}) : super(key: key);

  @override
  State<CheckingLiveFeasibility> createState() =>
      _CheckingLiveFeasibilityState();
}

class _CheckingLiveFeasibilityState extends State<CheckingLiveFeasibility> {
  final AgoraLiveController _agoraLiveController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _agoraLiveController.clear();
    super.dispose();
  }

  openSettingAppForAccess() {
    _agoraLiveController.checkFeasibilityToLive(
        context: context, isOpenSettings: true);
  }

  @override
  Widget build(BuildContext context) {
    _agoraLiveController.checkFeasibilityToLive(
        context: context, isOpenSettings: false);

    const colorizeColors = [
      Colors.purple,
      Colors.blue,
      Colors.yellow,
      Colors.red,
    ];
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Center(
        child: Stack(
          children: [
            const rtc_local_view.SurfaceView(),
            Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Obx(() => _agoraLiveController.canLive.value == 0
                    ? Center(
                        child: AnimatedTextKit(
                          animatedTexts: [
                            ColorizeAnimatedText(
                              LocalizationString.checkingConnection,
                              textStyle: TextStyle(
                                  fontSize: FontSizes.h3,
                                  fontWeight: FontWeight.bold
                              ),
                              colors: colorizeColors,
                            ),
                          ],
                          isRepeatingAnimation: true,
                          onTap: () {},
                        ),
                      )
                    : _agoraLiveController.canLive.value == -1
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 200,
                                width: 200,
                                color: AppColorConstants.red
                                    .withOpacity(0.5),
                                child: const ThemeIconWidget(
                                  ThemeIcon.camera,
                                  size: 100,
                                ),
                              ).circular,
                              const SizedBox(
                                height: 150,
                              ),
                              Text(
                                _agoraLiveController.errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: FontSizes.h3,
                                    fontWeight: TextWeight.regular),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                width: 200,
                                height: 50,
                                child: AppThemeButton(
                                  text: LocalizationString.allow,
                                  onPress: () {
                                    openAppSettings();
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                width: 200,
                                height: 45,
                                child: Center(
                                  child: Heading4Text(
                                    LocalizationString.back,

                                  ),
                                ),
                              ).ripple(() {
                                Get.back();
                              })
                            ],
                          ).hP16
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const SizedBox(width: 20.0, height: 100.0),
                              Heading3Text(
                                LocalizationString.goingLive,
                              ),
                              const SizedBox(width: 20.0, height: 100.0),
                              DefaultTextStyle(
                                style: TextStyle(fontSize: FontSizes.h3, fontWeight: TextWeight.semiBold),
                                child: AnimatedTextKit(
                                  pause: const Duration(milliseconds: 10),
                                  totalRepeatCount: 1,
                                  animatedTexts: [
                                    RotateAnimatedText('3',
                                        duration: const Duration(seconds: 1),
                                        textStyle: TextStyle(fontSize: FontSizes.h3,fontWeight: TextWeight.regular)),
                                    RotateAnimatedText('2',
                                        duration: const Duration(seconds: 1),
                                        textStyle: TextStyle(fontSize: FontSizes.h3,fontWeight: TextWeight.regular)),
                                    RotateAnimatedText('1',
                                        duration: const Duration(seconds: 1),
                                        textStyle: TextStyle(fontSize: FontSizes.h3,fontWeight: TextWeight.regular)),
                                    RotateAnimatedText(LocalizationString.go,
                                        duration: const Duration(seconds: 1),
                                        textStyle: TextStyle(fontSize: FontSizes.h3,fontWeight: TextWeight.regular)),
                                  ],
                                  onTap: () {},
                                  onFinished: () {
                                    goToLive();
                                  },
                                ),
                              ),
                            ],
                          ))),
          ],
        ),
      ),
    );
  }

  goToLive() {
    _agoraLiveController.initializeLive();
  }
}

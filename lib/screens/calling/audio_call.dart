import 'package:foap/helper/imports/call_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:pip_view/pip_view.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../components/timer_widget.dart';
import '../dashboard/dashboard_screen.dart';

class AudioCallingScreen extends StatefulWidget {
  final Call call;

  const AudioCallingScreen({
    super.key,
    required this.call,
  });

  @override
  State<AudioCallingScreen> createState() => _AudioCallingScreenState();
}

class _AudioCallingScreenState extends State<AudioCallingScreen> {
  final AgoraCallController agoraCallController = Get.find();
  final GlobalKey<TimerViewState> _timerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable(); // Turn on wakelock feature till call is running
  }

  @override
  void dispose() {
    WakelockPlus.disable(); // Turn off wakelock feature after call end
    super.dispose();
    agoraCallController.clear();
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return PIPView(
      builder: (context, isFloating) {
        return Scaffold(
          backgroundColor: AppColorConstants.backgroundColor,
          body: widget.call.isOutGoing == true
              ? outgoingCallView(isFloating)
                  .hp(DesignConstants.horizontalPadding)
              : incomingCallView(isFloating)
                  .hp(DesignConstants.horizontalPadding),
        );
      },
      floatingHeight: 150,
      floatingWidth: 100,
    );
  }

  Widget connectedCallView(bool isFloating) {
    return Stack(
      children: [
        Center(child: _renderRemoteView(isFloating)),
        isFloating == false ? _bottomPortionWidget() : Container(),
        // isFloating == false ? topBar() : Container(),
      ],
    );
  }

  Widget incomingCallView(bool isFloating) {
    return GetBuilder<AgoraCallController>(
        init: agoraCallController,
        builder: (ctx) {
          return agoraCallController.remoteJoined.value == false
              ? Stack(
                  children: [
                    Center(child: _renderRemoteView(isFloating)),
                    _incomingCallBottomPortionWidget(),
                  ],
                )
              : connectedCallView(isFloating);
        });
  }

  Widget outgoingCallView(bool isFloating) {
    return GetBuilder<AgoraCallController>(
        init: agoraCallController,
        builder: (ctx) {
          return agoraCallController.remoteJoined.value == false
              ? Column(
                  children: [
                    Expanded(child: _renderRemoteView(isFloating)),
                    const SizedBox(
                      height: 80,
                    ),
                    _bottomPortionWidget()
                  ],
                )
              : connectedCallView(isFloating);
        });
  }

  Widget topBar() {
    return Column(
      children: [
        const SizedBox(
          height: 50,
        ),
        SizedBox(
          height: 70,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ThemeIconWidget(
                  ThemeIcon.backArrow,
                  color: Colors.white,
                  size: 25,
                ).p8.ripple(() {
                  // Get.back();
                  PIPView.of(context)!
                      .presentBelow(const DashboardScreen());
                }),
                const SizedBox(
                  width: 25,
                )
              ]),
        ),
      ],
    );
  }

  // Generate remote preview
  Widget _renderRemoteView(bool isFloating) {
    if (agoraCallController.remoteJoined.value == false) {
      return Stack(
        children: [
          agoraCallController.reConnectingRemoteView.value == true
              ? Container(
                  color: AppColorConstants.red,
                  child: Center(
                      child: Heading3Text(
                    reConnectingString.tr,
                    color: AppColorConstants.subHeadingTextColor,
                  )))
              : const SizedBox(),
          Center(child: opponentInfo(isFloating)),
        ],
      );
    } else {
      return opponentInfo(isFloating);
    }
  }

  Widget opponentInfo(bool isFloating) {
    return isFloating
        ? UserAvatarView(
            user: widget.call.opponent,
            size: double.infinity,
            onTapHandler: () {},
          )
        : Column(
            children: [
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    color: AppColorConstants.themeColor,
                    child: UserAvatarView(
                      user: widget.call.opponent,
                      size: 150,
                      onTapHandler: () {},
                    ).p8,
                  ).circular,
                ],
              ),
              Heading3Text(
                widget.call.opponent.userName,
                weight: TextWeight.bold,
                color: AppColorConstants.mainTextColor,
              ),
              const SizedBox(
                height: 5,
              ),
              agoraCallController.remoteJoined.value == false
                  ? BodyExtraLargeText(
                      widget.call.isOutGoing
                          ? ringingString.tr
                          : incomingCallString.tr,
                      weight: TextWeight.medium,
                      color: AppColorConstants.mainTextColor,
                    )
                  : _timerView(),
              const Spacer(),
            ],
          );
  }

  //Timer Ui
  Widget _timerView() => TimerView(
        key: _timerKey,
      );

  // Ui & UX For Bottom Portion (Switch Camera,Video On/Off,Mic On/Off)
  Widget _bottomPortionWidget() => Container(
        margin: const EdgeInsets.only(bottom: 50, left: 35, right: 25),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Obx(() => Container(
                  color: agoraCallController.mutedAudio.value
                      ? AppColorConstants.themeColor.withOpacity(0.5)
                      : AppColorConstants.themeColor,
                  height: 80,
                  width: 80,
                  child: ThemeIconWidget(
                    agoraCallController.mutedAudio.value
                        ? ThemeIcon.micOff
                        : ThemeIcon.mic,
                    size: 20,
                    color: Colors.white,
                  ).p16,
                )).circular.ripple(() {
              agoraCallController.onToggleMuteAudio();
            }),
            const SizedBox(
              width: 25,
            ),
            Container(
              color: AppColorConstants.red,
              height: 80,
              width: 80,
              child: const ThemeIconWidget(
                ThemeIcon.declineCall,
                size: 30,
                color: Colors.white,
              ).p16,
            ).circular.ripple(() {
              agoraCallController.onCallEnd(widget.call);
            }),
          ],
        ),
      );

  Widget _incomingCallBottomPortionWidget() => Container(
        margin: const EdgeInsets.only(bottom: 50),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              color: AppColorConstants.red,
              height: 80,
              width: 80,
              child: const ThemeIconWidget(
                ThemeIcon.declineCall,
                size: 30,
                color: Colors.white,
              ).p16,
            ).circular.ripple(() {
              agoraCallController.declineIncomingCall(call: widget.call);
            }),
            const SizedBox(
              width: 25,
            ),
            Container(
              color: AppColorConstants.themeColor,
              height: 80,
              width: 80,
              child: const ThemeIconWidget(
                ThemeIcon.acceptCall,
                size: 30,
                color: Colors.white,
              ).p16,
            ).circular.ripple(() {
              agoraCallController.initiateAcceptCall(call: widget.call);
            }),
          ],
        ),
      );
}

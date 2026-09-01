import 'package:foap/helper/imports/call_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:pip_view/pip_view.dart';
import '../dashboard/dashboard_screen.dart';

class NotAnsweredCall extends StatefulWidget {
  final Call call;

  const NotAnsweredCall({
    super.key,
    required this.call,
  });

  @override
  State<NotAnsweredCall> createState() => _NotAnsweredCallState();
}

class _NotAnsweredCallState extends State<NotAnsweredCall> {
  final AgoraCallController agoraCallController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    agoraCallController.clear();
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: outgoingCallView().hp(DesignConstants.horizontalPadding),
    );
  }

  Widget outgoingCallView() {
    return Column(
      children: [
        Expanded(child: _renderRemoteView()),
        const SizedBox(
          height: 80,
        ),
        declinedCallButtonsWidget()
      ],
    );
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
  Widget _renderRemoteView() {
    return Center(child: opponentInfo());
  }

  Widget opponentInfo() {
    return Column(
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
        BodyExtraLargeText(
          noAnswerString.tr,
          weight: TextWeight.medium,
          color: AppColorConstants.mainTextColor,
        ),
        const Spacer(),
      ],
    );
  }

  Widget declinedCallButtonsWidget() => Container(
        margin: const EdgeInsets.only(bottom: 50, left: 35, right: 25),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: [
                Container(
                  color: AppColorConstants.red,
                  height: 80,
                  width: 80,
                  child: ThemeIconWidget(
                    ThemeIcon.close,
                    size: 20,
                    color: Colors.white,
                  ).p16,
                ).circular,
                const SizedBox(
                  height: 5,
                ),
                BodyLargeText(cancelString.tr),
              ],
            ).ripple(() {
              Get.back();
            }),
            const SizedBox(
              width: 25,
            ),
            Column(
              children: [
                Container(
                  color: AppColorConstants.green,
                  height: 80,
                  width: 80,
                  child: const ThemeIconWidget(
                    ThemeIcon.callback,
                    size: 30,
                    color: Colors.white,
                  ).p16,
                ).circular,
                const SizedBox(
                  height: 5,
                ),
                BodyLargeText(callbackString.tr),
              ],
            ).ripple(() {
              Get.back();
              agoraCallController.makeCallRequest(call: widget.call);
            }),
          ],
        ),
      );
}

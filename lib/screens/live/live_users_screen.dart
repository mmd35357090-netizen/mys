import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/number_extension.dart';
import 'package:foap/model/live_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../controllers/live/agora_live_controller.dart';
import '../../controllers/live/live_users_controller.dart';
import 'live_end_screen.dart';

class LiveUserScreen extends StatefulWidget {
  const LiveUserScreen({super.key});

  @override
  State<LiveUserScreen> createState() => _LiveUserScreenState();
}

class _LiveUserScreenState extends State<LiveUserScreen> {
  final AgoraLiveController _agoraLiveController = Get.find();
  final LiveUserController _liveUserController = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _liveUserController.getLiveUsers(() {});
    });
    super.initState();
  }

  loadMore() {
    _liveUserController.loadMore(() {});
  }

  @override
  void dispose() {
    _liveUserController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColorConstants.backgroundColor,
      body: KeyboardDismissOnTap(
          child: Column(
        children: [
          backNavigationBar(title: liveUsersString.tr),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Obx(
              () => _liveUserController.liveStreamUser.isEmpty
                  ? emptyData(title: noLiveUserString, subTitle: '')
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.9),
                      itemCount: _liveUserController.liveStreamUser.length,
                      padding: EdgeInsets.only(
                          left: DesignConstants.horizontalPadding,
                          right: DesignConstants.horizontalPadding),
                      itemBuilder: (context, index) {
                        final liveStreaming =
                            _liveUserController.liveStreamUser[index];

                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColorConstants.themeColor
                                    .withValues(alpha: 0.28),
                                AppColorConstants.themeColor
                                    .withValues(alpha: 0.08),
                              ],
                            ),
                            border: Border.all(
                                color: AppColorConstants.dividerColor
                                    .withValues(alpha: 0.5),
                                width: 0.6),
                          ),
                          child: Stack(
                            children: [
                              Align(
                                alignment: const Alignment(0, -0.25),
                                child: UserPlaneImageView(
                                  size: Get.width / 4,
                                  user: liveStreaming.host![0],
                                ),
                              ),
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: AppColorConstants.red,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Text('LIVE',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.6)),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                      color: Colors.black
                                          .withValues(alpha: 0.45),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.remove_red_eye_rounded,
                                          size: 13, color: Colors.white),
                                      const SizedBox(width: 4),
                                      BodySmallText(
                                        liveStreaming.totalUsers!.formatNumber,
                                        color: Colors.white,
                                        weight: TextWeight.semiBold,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 12,
                                right: 12,
                                bottom: 12,
                                child: BodyMediumText(
                                  liveStreaming.host![0].userName,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  weight: TextWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ).ripple(() {
                          _liveUserController.getLiveDetail(
                              channelName: liveStreaming.channelName,
                              resultCallback: (result) {
                                LiveModel live = LiveModel();
                                live.channelName =
                                    liveStreaming.channelName;
                                live.mainHostUserDetail =
                                    liveStreaming.host!.first;
                                live.token = liveStreaming.token;
                                live.id = liveStreaming.id;
                                if (result.isOngoing) {
                                  _agoraLiveController.joinAsAudience(
                                    live: live,
                                  );
                                } else {
                                  Get.to(() => LiveEndScreen(
                                        live: live,
                                      ));
                                }
                              });
                        });
                      }).addPullToRefresh(
                      refreshController: _refreshController,
                      onRefresh: () {},
                      onLoading: () {
                        loadMore();
                      },
                      enablePullUp: true,
                      enablePullDown: false),
            ),
          ),
        ],
      )),
    );
  }
}

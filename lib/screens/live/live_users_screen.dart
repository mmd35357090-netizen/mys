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
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 1),
                      itemCount: _liveUserController.liveStreamUser.length,
                      padding: EdgeInsets.only(
                          left: DesignConstants.horizontalPadding,
                          right: DesignConstants.horizontalPadding),
                      itemBuilder: (context, index) {
                        final liveStreaming =
                            _liveUserController.liveStreamUser[index];

                        return Container(
                          color: AppColorConstants.themeColor.withOpacity(0.2),
                          child: Stack(
                            children: [
                              Center(
                                child: UserPlaneImageView(
                                  size: Get.width / 3,
                                  user: liveStreaming.host![0],
                                  // hideBorder: true,
                                  // hideOnlineIndicator: true,
                                  // hideLiveIndicator: true,
                                ),
                              ),
                              Positioned(
                                top: 15,
                                right: 10,
                                child: Container(
                                  width: 70,
                                  height: 30,
                                  color: AppColorConstants.themeColor,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const ThemeIconWidget(
                                        ThemeIcon.group,
                                        color: Colors.white,
                                      ).p4,
                                      BodyLargeText(
                                        liveStreaming.totalUsers!.formatNumber,
                                        color: Colors.white,
                                      )
                                    ],
                                  ),
                                ).round(20),
                              ),
                            ],
                          ),
                        ).round(20).ripple(() {
                          _liveUserController.getLiveDetail(
                              channelName: liveStreaming.channelName,
                              resultCallback: (result) {
                                LiveModel live = LiveModel();
                                live.channelName = liveStreaming.channelName;
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

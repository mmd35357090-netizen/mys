import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/number_extension.dart';
import 'package:get/get.dart';
import '../../components/search_bar.dart';
import '../../controllers/agora_live_controller.dart';
import '../../model/call_model.dart';
import 'live_users_controller.dart';

class LiveUserScreen extends StatefulWidget {
  const LiveUserScreen({Key? key}) : super(key: key);

  @override
  State<LiveUserScreen> createState() => _LiveUserScreenState();
}

class _LiveUserScreenState extends State<LiveUserScreen> {
  final AgoraLiveController _agoraLiveController = Get.find();
  final LiveUserController _liveUserController = Get.find();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _liveUserController.getLiveUsers();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColorConstants.backgroundColor,
      body: KeyboardDismissOnTap(
          child: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          backNavigationBar(
              context: context, title: LocalizationString.liveUsers),
          divider(context: context).tP8,
          const SizedBox(
            height: 20,
          ),
          // SearchBar(
          //         showSearchIcon: true,
          //         iconColor: Theme.of(context).primaryColor,
          //         onSearchChanged: (value) {
          //           // _chatController.searchTextChanged(value);
          //         },
          //         onSearchStarted: () {
          //           //controller.startSearch();
          //         },
          //         onSearchCompleted: (searchTerm) {})
          //     .p16,
          Expanded(
            child: Obx(
              () => GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8),
                  itemCount: _liveUserController.liveStreamUser.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final liveStreaming =
                        _liveUserController.liveStreamUser[index];

                    return InkWell(
                      onTap: () {
                        Live live = Live(
                            channelName: liveStreaming.channelName,
                            isHosting: false,
                            host: liveStreaming.host!.first,
                            token: liveStreaming.token,
                            liveId: liveStreaming.id);
                        _agoraLiveController.joinAsAudience(
                          live: live,
                        );
                      },
                      child: Stack(
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: UserAvatarView(
                                  size: double.infinity,
                                  user: liveStreaming.host![0],
                                  hideBorder: true,
                                )),
                          ),
                          Positioned(
                            top: 15,
                            right: 10,
                            child: Container(
                              width: 70,
                              height: 30,
                              color:
                                  AppColorConstants.themeColor.withOpacity(0.4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const ThemeIconWidget(ThemeIcon.group).p4,
                                  Obx(() => BodyLargeText(_liveUserController
                                      .totalLiveUsers.value.formatNumber))
                                ],
                              ),
                            ).round(20),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
          ),
        ],
      )),
    );
  }
}

import 'dart:convert';

import 'package:foap/helper/common_import.dart';
import 'package:get/get.dart';

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
      backgroundColor: Theme.of(context).backgroundColor,
      body: KeyboardDismissOnTap(
          child: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          backNavigationBar(
              context: context, title: LocalizationString.liveUsers),
          divider(context: context).tP8,
          SearchBar(
                  showSearchIcon: true,
                  iconColor: Theme.of(context).primaryColor,
                  onSearchChanged: (value) {
                    // _chatController.searchTextChanged(value);
                  },
                  onSearchStarted: () {
                    //controller.startSearch();
                  },
                  onSearchCompleted: (searchTerm) {})
              .p16,
          Expanded(
            child: Obx(
              () => GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8),
                  itemCount: _liveUserController.liveStreamUser.length,
                  itemBuilder: (context, index) {
                    final streamingUser =
                        _liveUserController.liveStreamUser[index];
                    final user = UserModel();
                    user.liveCallDetail = streamingUser;
                    user.id = streamingUser.id;
                    return InkWell(
                      onTap: () {
                        Live live = Live(
                            channelName: user.liveCallDetail!.channelName,
                            isHosting: false,
                            host: user,
                            token: user.liveCallDetail!.token,
                            liveId: user.liveCallDetail!.id);
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
                              child: Image.network(
                                streamingUser.userdetails![0].picture!,
                                fit: BoxFit.fill,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/live.png',
                                height: 20,
                                width: 20,
                              ).p8,
                              const Icon(Icons.group,size: 20).p4,
                              Obx(()=>Text(_liveUserController.totalLiveUsers.value))
                            ],
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

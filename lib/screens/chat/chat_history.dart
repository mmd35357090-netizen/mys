import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:foap/components/sm_tab_bar.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../calling/call_history.dart';
import '../settings_menu/settings_controller.dart';
import 'group/open_group_listing.dart';

class ChatHistory extends StatefulWidget {
  const ChatHistory({super.key}) ;

  @override
  State<ChatHistory> createState() => _ChatHistoryState();
}

class _ChatHistoryState extends State<ChatHistory> {
  final ChatHistoryController _chatController = Get.find();
  final ChatDetailController _chatDetailController = Get.find();
  final SettingsController _settingsController = Get.find();

  List<String> tabs = [privateString.tr, openGroupsString.tr];

  @override
  void initState() {
    super.initState();
    _chatController.getChatRooms();
    _chatController.refreshPublicGroups(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColorConstants.backgroundColor,
      floatingActionButton: Container(
        height: 50,
        width: 50,
        color: AppColorConstants.themeColor,
        child: ThemeIconWidget(
          ThemeIcon.edit,
          size: 25,
          color: Colors.white,
        ),
      ).circular.ripple(() {
        selectUsers();
      }).bP16,
      body: KeyboardDismissOnTap(
          child: DefaultTabController(
              length: tabs.length,
              child: Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ThemeIconWidget(
                        ThemeIcon.backArrow,
                      ).ripple(() {
                        Get.back();
                      }),
                      BodyLargeText(chatsString.tr, weight: TextWeight.medium),
                      _settingsController.setting.value!.enableAudioCalling ||
                              _settingsController
                                  .setting.value!.enableVideoCalling
                          ? ThemeIconWidget(
                              ThemeIcon.mobile,
                              color: AppColorConstants.iconColor,
                              size: 25,
                            ).ripple(() {
                              Get.to(() => const CallHistory());
                            })
                          : const SizedBox(
                              width: 25,
                            ),
                    ],
                  ).setPadding(
                      left: DesignConstants.horizontalPadding,
                      right: DesignConstants.horizontalPadding,
                      top: 8,
                      bottom: 8),
                  SFSearchBar(
                          showSearchIcon: true,
                          iconColor: AppColorConstants.themeColor,
                          onSearchChanged: (value) {
                            _chatController.searchTextChanged(value);
                          },
                          onSearchStarted: () {
                            //controller.startSearch();
                          },
                          onSearchCompleted: (searchTerm) {})
                      .p16,
                  SizedBox(
                      width: Get.width,
                      child: SMTabBar(
                        tabs: tabs,
                        canScroll: false,
                      )),
                  Expanded(
                      child: TabBarView(
                          children: [chatListView(), OpenGroupListing()]))
                ],
              ))),
    );
  }

  Widget chatListView() {
    return GetBuilder<ChatHistoryController>(
        init: _chatController,
        builder: (ctx) {
          return _chatController.groupedRooms.keys.isNotEmpty
              ? ListView.separated(
                  padding: EdgeInsets.only(
                      top: 20,
                      bottom: 50,
                      left: DesignConstants.horizontalPadding,
                      right: DesignConstants.horizontalPadding),
                  itemCount: _chatController.groupedRooms.keys.length,
                  itemBuilder: (BuildContext context, int index) {
                    String key =
                        _chatController.groupedRooms.keys.toList()[index];
                    List<ChatRoomModel> rooms =
                        _chatController.groupedRooms[key] ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Heading5Text(
                          key,
                          weight: TextWeight.bold,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        for (ChatRoomModel room in rooms)
                          Column(
                            children: [
                              Dismissible(
                                key: UniqueKey(),
                                onDismissed: (direction) {
                                  _chatController.deleteRoom(room);
                                },
                                background: Container(
                                  color: AppColorConstants.red,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Heading6Text(
                                        deleteString.tr,
                                        weight: TextWeight.bold,
                                        color: AppColorConstants.mainTextColor,
                                      )
                                    ],
                                  ),
                                ),
                                child: ChatHistoryTile(model: room)
                                    .ripple(() async {
                                  _chatController.clearUnreadCount(
                                      chatRoom: room);

                                  Get.to(() => ChatDetail(chatRoom: room))!
                                      .then((value) {
                                    _chatController.getChatRooms();
                                  });
                                }),
                              ),
                              const SizedBox(
                                height: 10,
                              )
                            ],
                          ),
                      ],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(
                      height: 16,
                    );
                  })
              : emptyData(
                  title: noChatFoundString,
                  subTitle: '',
                );
        });
  }

  void selectUsers() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) => FractionallySizedBox(
              heightFactor: 0.9,
              child: SelectUserForChat(userSelected: (user) {
                _chatDetailController.getChatRoomWithUser(
                    userId: user.id,
                    callback: (room) {
                      Loader.dismiss();

                      Get.close(1);
                      Get.to(() => ChatDetail(
                                // opponent: usersList[index - 1].toChatRoomMember,
                                chatRoom: room,
                              ))!
                          .then((value) {
                        _chatController.getChatRooms();
                      });
                    });
              }),
            ));
  }
}

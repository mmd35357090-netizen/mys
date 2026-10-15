import 'package:foap/components/call_history_tile.dart';
import 'package:foap/controllers/chat_and_call/call_history_controller.dart';
import 'package:foap/controllers/chat_and_call/chat_detail_controller.dart';
import 'package:foap/helper/imports/call_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/chat/chat_detail.dart';
import 'package:foap/screens/chat/select_users.dart';

class CallHistory extends StatefulWidget {
  const CallHistory({super.key}) ;

  @override
  State<CallHistory> createState() => _CallHistoryState();
}

class _CallHistoryState extends State<CallHistory> {
  final CallHistoryController _callHistoryController = CallHistoryController();
  final ChatDetailController _chatDetailController = Get.find();

  @override
  void initState() {
    _callHistoryController.callHistory();
    super.initState();
  }

  @override
  void dispose() {
    _callHistoryController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: [
            backNavigationBarWithTrailingWidget(
              widget: ThemeIconWidget(ThemeIcon.mobile).ripple(() {
                selectUsers();
              }),
              title: callLogString.tr,
            ),
            Expanded(
              child: GetBuilder<CallHistoryController>(
                  init: _callHistoryController,
                  builder: (ctx) {
                    ScrollController scrollController = ScrollController();
                    scrollController.addListener(() {
                      if (scrollController.position.maxScrollExtent ==
                          scrollController.position.pixels) {
                        if (!_callHistoryController.isLoading) {
                          _callHistoryController.callHistory();
                        }
                      }
                    });

                    return _callHistoryController.groupedCalls.keys.isNotEmpty
                        ? ListView.separated(
                            padding: EdgeInsets.only(
                                top: 20,
                                bottom: 50,
                                left: DesignConstants.horizontalPadding,
                                right: DesignConstants.horizontalPadding),
                            itemCount:
                                _callHistoryController.groupedCalls.keys.length,
                            itemBuilder: (BuildContext context, int index) {
                              String key = _callHistoryController
                                  .groupedCalls.keys
                                  .toList()[index];
                              List<CallHistoryModel> calls =
                                  _callHistoryController.groupedCalls[key] ??
                                      [];

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
                                  for (CallHistoryModel call in calls)
                                    Column(
                                      children: [
                                        CallHistoryTile(model: call).ripple(() {
                                          _callHistoryController.reInitiateCall(
                                            call: call,
                                          );
                                        }),
                                        const SizedBox(
                                          height: 10,
                                        )
                                      ],
                                    ),
                                ],
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return divider(height: 0.2).vP8;
                            })
                        : _callHistoryController.isLoading == true
                            ? Container()
                            : emptyData(
                                title: noCallFoundString.tr,
                                subTitle: makeSomeCallsString.tr,
                              );
                  }),
            ),
          ],
        ));
  }

  void selectUsers() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) => SelectUserForChat(userSelected: (user) {
              _chatDetailController.getChatRoomWithUser(
                  userId: user.id,
                  callback: (room) {
                    Loader.dismiss();

                    Get.back();
                    Get.to(() => ChatDetail(
                          // opponent: usersList[index - 1].toChatRoomMember,
                          chatRoom: room,
                        ));
                  });
            }));
  }
}

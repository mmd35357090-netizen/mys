import 'package:foap/components/user_card.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/event_imports.dart';
import '../../../../controllers/misc/user_network_controller.dart';

class SelectUserToGiftEventTicket extends StatefulWidget {
  final EventModel event;
  final bool isAlreadyBooked;
  final Function(UserModel)? selectUserCallback;

  const SelectUserToGiftEventTicket(
      {super.key,
      required this.event,
      required this.isAlreadyBooked,
      this.selectUserCallback})
      ;

  @override
  SelectUserToGiftEventTicketState createState() =>
      SelectUserToGiftEventTicketState();
}

class SelectUserToGiftEventTicketState
    extends State<SelectUserToGiftEventTicket> {
  final UserNetworkController _userNetworkController = UserNetworkController();
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() {
    _userNetworkController.clear();
    _userNetworkController
        .getFollowingUsers(_userProfileManager.user.value!.id);
  }

  @override
  void didUpdateWidget(covariant SelectUserToGiftEventTicket oldWidget) {
    loadData();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _userNetworkController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: [
            backNavigationBar(title: selectUserString.tr),
            Expanded(
              child: GetBuilder<UserNetworkController>(
                  init: _userNetworkController,
                  builder: (ctx) {
                    ScrollController scrollController = ScrollController();
                    scrollController.addListener(() {
                      if (scrollController.position.maxScrollExtent ==
                          scrollController.position.pixels) {
                        if (!_userNetworkController.isLoading.value) {
                          _userNetworkController.getFollowingUsers(
                              _userProfileManager.user.value!.id);
                        }
                      }
                    });

                    List<UserModel> usersList =
                        _userNetworkController.following;
                    return _userNetworkController.isLoading.value
                        ? const ShimmerUsers()
                            .hp(DesignConstants.horizontalPadding)
                        : Column(
                            children: [
                              usersList.isEmpty
                                  ? noUserFound(context)
                                  : Expanded(
                                      child: ListView.separated(
                                        padding: const EdgeInsets.only(
                                            top: 20, bottom: 50),
                                        controller: scrollController,
                                        itemCount: usersList.length,
                                        itemBuilder: (context, index) {
                                          return UserTile(
                                              profile: usersList[index],
                                              viewCallback: () {
                                                if (widget.isAlreadyBooked) {
                                                  widget.selectUserCallback!(
                                                      usersList[index]);
                                                  Get.back();
                                                } else {
                                                  Get.to(() => BuyTicket(
                                                        event: widget.event,
                                                        giftToUser:
                                                            usersList[index],
                                                      ));
                                                }
                                              });
                                        },
                                        separatorBuilder: (context, index) {
                                          return const SizedBox(
                                            height: 20,
                                          );
                                        },
                                      ).hp(DesignConstants.horizontalPadding),
                                    ),
                            ],
                          );
                  }),
            ),
          ],
        ));
  }
}

import 'package:foap/controllers/misc/users_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../components/user_card.dart';
import '../../controllers/post/add_post_controller.dart';

class SelectUser extends StatefulWidget {
  final Function(UserModel) userSelected;

  const SelectUser({super.key, required this.userSelected});

  @override
  SelectUserState createState() => SelectUserState();
}

class SelectUserState extends State<SelectUser> {
  final UsersController _usersController = Get.find();
  final AddPostController addPostController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColorConstants.cardColor,
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          SFSearchBar(
              needBackButton: true,
              showSearchIcon: true,
              iconColor: AppColorConstants.themeColor,
              onSearchChanged: (value) {
                _usersController.setSearchTextFilter(value, () {});
              },
              onSearchStarted: () {
                //controller.startSearch();
              },
              onSearchCompleted: (searchTerm) {}),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: SizedBox(
              child: GetBuilder<UsersController>(
                  init: _usersController,
                  builder: (ctx) {
                    ScrollController scrollController = ScrollController();
                    scrollController.addListener(() {
                      if (scrollController.position.maxScrollExtent ==
                          scrollController.position.pixels) {
                        if (!_usersController
                            .dataWrapper.isLoading.value) {}
                      }
                    });

                    List<UserModel> usersList =
                        _usersController.searchedUsers;
                    return _usersController.dataWrapper.isLoading.value
                        ? const ShimmerUsers()
                            .hp(DesignConstants.horizontalPadding)
                        : usersList.isNotEmpty
                            ? Obx(() => ListView.separated(
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 50),
                                  controller: scrollController,
                                  itemCount: usersList.length,
                                  itemBuilder: (context, index) {
                                    return Obx(() => SelectableUserTile(
                                          model: usersList[index],
                                          isSelected: addPostController
                                              .collaborators
                                              .where((e) =>
                                                  e.id ==
                                                  usersList[index].id)
                                              .isNotEmpty,
                                          selectionHandler: () {
                                            addPostController
                                                .addCollaborator(
                                                    usersList[index]);
                                          },
                                        ));
                                  },
                                  separatorBuilder: (context, index) {
                                    return divider(height: 1).vP16;
                                  },
                                ))
                            : emptyUser(
                                title: noUserFoundString.tr,
                                subTitle: followSomeUserToChatString.tr,
                              );
                  }),
            ),
          ),
        ],
      ).hp(DesignConstants.horizontalPadding),
    ).topRounded(40);
  }
}

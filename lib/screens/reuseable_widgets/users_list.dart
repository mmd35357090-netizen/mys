import 'package:foap/helper/imports/common_import.dart';
import '../../components/user_card.dart';
import '../../controllers/misc/users_controller.dart';

class UsersList extends StatelessWidget {
  final UsersController _usersController = Get.find();

  UsersList({super.key});

  @override
  Widget build(BuildContext context) {
    return usersView();
  }

  Widget usersView() {
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (!_usersController.dataWrapper.isLoading.value) {
          _usersController.loadUsers(() {});
        }
      }
    });

    return Obx(() => _usersController.dataWrapper.isLoading.value
        ? const ShimmerUsers()
        : _usersController.searchedUsers.isNotEmpty
            ? GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15.0,
                    mainAxisSpacing: 15.0,
                    childAspectRatio: 0.6),
                controller: scrollController,
                padding: EdgeInsets.only(
                    top: 20,
                    left: DesignConstants.horizontalPadding,
                    right: DesignConstants.horizontalPadding),
                itemCount: _usersController.searchedUsers.length,
                itemBuilder: (BuildContext ctx, int index) {
                  return UserCard(
                    profile: _usersController.searchedUsers[index],
                    followCallback: () {
                      _usersController
                          .followUser(_usersController.searchedUsers[index]);
                    },
                    unFollowCallback: () {
                      _usersController
                          .unFollowUser(_usersController.searchedUsers[index]);
                    },
                  );
                },
              )
            : SizedBox(
                height: Get.size.height * 0.5,
                child: emptyUser(title: noUserFoundString.tr, subTitle: ''),
              ));
  }
}

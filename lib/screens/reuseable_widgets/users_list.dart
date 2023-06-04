import 'package:flutter/material.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import '../../components/empty_states.dart';
import '../../components/shimmer_widgets.dart';
import '../../components/user_card.dart';
import '../../controllers/misc/users_controller.dart';
import '../../helper/localization_strings.dart';

class UsersList extends StatelessWidget {
  final UsersController _usersController = Get.find();

  UsersList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return usersView();
  }

  Widget usersView() {
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (!_usersController.accountsIsLoading) {
          _usersController.loadUsers();
        }
      }
    });

    return _usersController.accountsIsLoading
        ? const ShimmerUsers()
        : _usersController.searchedUsers.isNotEmpty
            ? ListView.separated(
                controller: scrollController,
                padding: EdgeInsets.only(
                    top: 20,
                    left: DesignConstants.horizontalPadding,
                    right: DesignConstants.horizontalPadding),
                itemCount: _usersController.searchedUsers.length,
                itemBuilder: (BuildContext ctx, int index) {
                  return UserTile(
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
                separatorBuilder: (BuildContext ctx, int index) {
                  return const SizedBox(
                    height: 20,
                  );
                })
            : SizedBox(
                height: Get.size.height * 0.5,
                child: emptyUser(title: noUserFoundString.tr, subTitle: ''),
              );
  }
}

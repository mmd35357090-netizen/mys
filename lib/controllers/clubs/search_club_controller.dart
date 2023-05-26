import 'package:foap/apiHandler/apis/club_api.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/club_imports.dart';

import '../../apiHandler/api_controller.dart';

class SearchClubsController extends GetxController {
  RxList<ClubModel> clubs = <ClubModel>[].obs;

  int clubsPage = 1;
  bool canLoadMoreClubs = true;
  RxBool isLoadingClubs = false.obs;

  RxString searchText = ''.obs;

  clear() {
    isLoadingClubs.value = false;
    clubs.value = [];
    clubsPage = 1;
    canLoadMoreClubs = true;
    searchText = ''.obs;
  }

  searchTextChanged(String text) {
    canLoadMoreClubs = true;
    searchText.value = text;
    searchClubs(name: text, refresh: true);
  }

  searchClubs(
      {String? name,
      int? categoryId,
      int? userId,
      int? isJoined,
      bool? refresh}) {
    if (canLoadMoreClubs) {
      isLoadingClubs.value = true;
      ClubApi.getClubs(
          name: name,
          categoryId: categoryId,
          userId: userId,
          isJoined: isJoined,
          page: clubsPage,
          resultCallback: (result, metadata) {
            if (refresh == true) {
              clubs.value = result;
            } else {
              clubs.addAll(result);
            }
            isLoadingClubs.value = false;

            clubsPage += 1;
            canLoadMoreClubs = result.length >= metadata.perPage;

            update();
          });
    }
  }

  clubDeleted(ClubModel club) {
    clubs.removeWhere((element) => element.id == club.id);
    clubs.refresh();
  }

  joinClub(ClubModel club) {
    clubs.value = clubs.map((element) {
      if (element.id == club.id) {
        element.isJoined = true;
      }
      return element;
    }).toList();

    clubs.refresh();
    ClubApi.joinClub(clubId: club.id!, resultCallback: (){});
  }

  leaveClub(ClubModel club) {
    clubs.value = clubs.map((element) {
      if (element.id == club.id) {
        element.isJoined = false;
      }
      return element;
    }).toList();

    clubs.refresh();
    ClubApi.leaveClub(clubId: club.id!);
  }
}

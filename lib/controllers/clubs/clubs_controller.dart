import 'package:foap/apiHandler/apis/club_api.dart';
import 'package:foap/helper/imports/club_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';

import '../../apiHandler/api_controller.dart';
import '../../model/category_model.dart';

class ClubsController extends GetxController {
  final UserProfileManager _userProfileManager = Get.find();

  RxList<ClubModel> clubs = <ClubModel>[].obs;
  RxList<CategoryModel> categories = <CategoryModel>[].obs;
  RxList<ClubMemberModel> members = <ClubMemberModel>[].obs;
  RxList<ClubInvitation> invitations = <ClubInvitation>[].obs;

  RxBool isLoadingCategories = false.obs;

  int clubsPage = 1;
  bool canLoadMoreClubs = true;
  RxBool isLoadingClubs = false.obs;

  int invitationsPage = 1;
  bool canLoadMoreInvitations = true;
  RxBool isLoadingInvitations = false.obs;

  int membersPage = 1;
  bool canLoadMoreMembers = true;
  bool isLoadingMembers = false;

  RxInt segmentIndex = (0).obs;

  clear() {
    isLoadingClubs.value = false;
    clubs.clear();
    clubsPage = 1;
    canLoadMoreClubs = true;

    invitationsPage = 1;
    canLoadMoreInvitations = true;
    isLoadingInvitations.value = false;
    invitations.clear();

    segmentIndex.value = 0;
  }

  clearMembers() {
    isLoadingMembers = false;
    members.value = [];
    membersPage = 1;
    canLoadMoreMembers = true;
  }

  refreshClubs() {
    canLoadMoreClubs = true;
    selectedSegmentIndex(index: segmentIndex.value, forceRefresh: true);
  }

  selectedSegmentIndex({required int index, required bool forceRefresh}) {
    if (isLoadingClubs.value == true) {
      return;
    }
    update();
    if (index == 0 && (segmentIndex.value != index || forceRefresh == true)) {
      clear();
      getClubs(isStartOver: true);
    } else if (index == 1 &&
        (segmentIndex.value != index || forceRefresh == true)) {
      clear();
      getClubs(isJoined: 1, isStartOver: true);
    } else if (index == 2 &&
        (segmentIndex.value != index || forceRefresh == true)) {
      clear();
      getClubs(userId: _userProfileManager.user.value!.id, isStartOver: true);
    } else if (index == 3 &&
        (segmentIndex.value != index || forceRefresh == true)) {
      getClubInvitations();
    }

    segmentIndex.value = index;
  }

  getClubs(
      {String? name,
      int? categoryId,
      int? userId,
      int? isJoined,
      required bool isStartOver}) {
    if (canLoadMoreClubs) {
      if (isStartOver == true) {
        isLoadingClubs.value = true;
      }
      ClubApi.getClubs(
          name: name,
          categoryId: categoryId,
          userId: userId,
          isJoined: isJoined,
          page: clubsPage,
          resultCallback: (result, metadata) {
            clubs.addAll(result);
            clubs.value = clubs.toSet().toList();
            isLoadingClubs.value = false;

            canLoadMoreClubs = result.length >= metadata.perPage;

            clubsPage += 1;
            update();
          });
    }
  }

  getClubInvitations() {
    if (canLoadMoreInvitations) {
      isLoadingInvitations.value = true;
      ClubApi.getClubInvitations(
          page: invitationsPage,
          resultCallback: (result, metadata) {
            invitations.addAll(result);
            isLoadingInvitations.value = false;

            invitationsPage += 1;
            canLoadMoreInvitations = result.length >= metadata.perPage;

            update();
          });
    }
  }

  clubDeleted(ClubModel club) {
    clubs.removeWhere((element) => element.id == club.id);
    clubs.refresh();
  }

  getMembers({int? clubId}) {
    if (canLoadMoreMembers) {
      isLoadingMembers = true;
      ClubApi.getClubMembers(
          clubId: clubId,
          page: membersPage,
          resultCallback: (result, metadata) {
            members.addAll(result);
            isLoadingMembers = false;

            membersPage += 1;
            canLoadMoreMembers = result.length >= metadata.perPage;

            update();
          });
    }
  }

  getCategories() {
    isLoadingCategories.value = true;
    ClubApi.getClubCategories(resultCallback: (result) {
      categories.value = result;
      isLoadingCategories.value = false;

      update();
    });
  }

  joinClub(ClubModel club) {
    if (club.isRequestBased == true) {
      clubs.value = clubs.map((element) {
        if (element.id == club.id) {
          element.isRequested = true;
        }
        return element;
      }).toList();

      clubs.refresh();

      ClubApi.sendClubJoinRequest(clubId: club.id!);
    } else {
      clubs.value = clubs.map((element) {
        if (element.id == club.id) {
          element.isJoined = true;
        }
        return element;
      }).toList();

      clubs.refresh();

      ClubApi.joinClub(clubId: club.id!, resultCallback: () {});
    }
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

  acceptClubInvitation(ClubInvitation invitation) {
    invitations.remove(invitation);
    invitations.refresh();
    ClubApi.acceptDeclineClubInvitation(
        invitationId: invitation.id!, replyStatus: 10);
  }

  declineClubInvitation(ClubInvitation invitation) {
    invitations.remove(invitation);
    invitations.refresh();
    ClubApi.acceptDeclineClubInvitation(
        invitationId: invitation.id!, replyStatus: 3);
  }

  removeMemberFromClub(ClubModel club, ClubMemberModel member) {
    members.remove(member);
    update();

    ClubApi.removeMemberFromClub(clubId: club.id!, userId: member.id);
  }

  deleteClub({required ClubModel club, required VoidCallback callback}) {
    ClubApi.deleteClub(
      club.id!,
    );
    Get.back();
    callback();
    ;
  }
}

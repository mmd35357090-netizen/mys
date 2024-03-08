import 'package:foap/api_handler/apis/club_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../api_handler/apis/post_api.dart';
import '../../manager/db_manager.dart';
import '../../model/club_join_request.dart';
import '../../model/club_model.dart';
import '../../model/data_wrapper.dart';
import '../../model/post_model.dart';
import '../../model/post_search_query.dart';
import '../../screens/dashboard/posts.dart';
import '../../screens/profile/other_user_profile.dart';
import '../chat_and_call/chat_detail_controller.dart';
import 'package:foap/helper/list_extension.dart';

class ClubDetailController extends GetxController {
  final ChatDetailController _chatDetailController = Get.find();

  RxList<PostModel> posts = <PostModel>[].obs;
  RxList<ClubJoinRequest> joinRequests = <ClubJoinRequest>[].obs;

  Rx<ClubModel?> club = Rx<ClubModel?>(null);
  PostSearchQuery postSearchQuery = PostSearchQuery();
  DataWrapper postDataWrapper = DataWrapper();
  DataWrapper requestsDataWrapper = DataWrapper();

  clear() {
    posts.clear();
    joinRequests.clear();

    postDataWrapper = DataWrapper();
    requestsDataWrapper = DataWrapper();
  }

  setClub(ClubModel clubObj) {
    club.value = clubObj;
    club.refresh();

    update();
  }

  getClubJoinRequests({required int clubId}) {
    if (requestsDataWrapper.haveMoreData.value) {
      requestsDataWrapper.isLoading.value = true;

      ClubApi.getClubJoinRequests(
          clubId: clubId,
          page: requestsDataWrapper.page,
          resultCallback: (result, metadata) {
            joinRequests.addAll(result);
            joinRequests.unique((e) => e.id);

            requestsDataWrapper.processCompletedWithData(metadata);
          });
    }
  }

  postTextTapHandler({required PostModel post, required String text}) {
    if (text.startsWith('#')) {
      Get.to(() => Posts(
            hashTag: text.replaceAll('#', ''),
          ));
    } else {
      String userTag = text.replaceAll('@', '');
      if (post.mentionedUsers
          .where((element) => element.userName == userTag)
          .isNotEmpty) {
        int mentionedUserId = post.mentionedUsers
            .where((element) => element.userName == userTag)
            .first
            .id;
        Get.to(() => OtherUserProfile(userId: mentionedUserId));
      }
    }
  }

  removePostFromList(PostModel post) {
    posts.removeWhere((element) => element.id == post.id);
    posts.refresh();
  }

  removeUsersAllPostFromList(PostModel post) {
    posts.removeWhere((element) => element.user.id == post.user.id);

    posts.refresh();
  }

  joinClub() {
    if (club.value!.isRequestBased == true) {
      club.value!.isRequested = true;
      club.refresh();

      ClubApi.sendClubJoinRequest(clubId: club.value!.id!);
    } else {
      club.value!.isJoined = true;
      club.refresh();

      ClubApi.joinClub(
          clubId: club.value!.id!,
          resultCallback: () {
            if (club.value!.enableChat == 1) {
              _chatDetailController.getRoomDetail(club.value!.chatRoomId!,
                  (chatRoom) {
                getIt<DBManager>().saveRooms([chatRoom]);
              });
            }
          });
    }
  }

  leaveClub() {
    club.value!.isJoined = false;
    club.refresh();

    ClubApi.leaveClub(clubId: club.value!.id!);
  }

  acceptClubJoinRequest(ClubJoinRequest request) {
    joinRequests.remove(request);
    joinRequests.refresh();
    update();

    ClubApi.acceptDeclineClubJoinRequest(
        requestId: request.id!, replyStatus: 10);
  }

  declineClubJoinRequest(ClubJoinRequest request) {
    joinRequests.remove(request);
    joinRequests.refresh();
    update();

    ClubApi.acceptDeclineClubJoinRequest(
        requestId: request.id!, replyStatus: 3);
  }

  refreshPosts({required int clubId, required VoidCallback callback}) {
    postDataWrapper = DataWrapper();
    getPosts(clubId: clubId, callback: callback);
  }

  loadMorePosts({required int clubId, required VoidCallback callback}) {
    if (postDataWrapper.haveMoreData.value == true) {
      if (postDataWrapper.page == 1) {
        postDataWrapper.isLoading.value = true;
      }
      getPosts(clubId: clubId, callback: callback);
    } else {
      callback();
    }
  }

  void getPosts({required int clubId, required VoidCallback callback}) async {
    PostApi.getPosts(
        clubId: clubId,
        page: postDataWrapper.page,
        resultCallback: (result, metadata) {
          posts.addAll(result);
          posts.sort((a, b) => b.createDate!.compareTo(a.createDate!));
          posts.unique((e) => e.id);

          postDataWrapper.processCompletedWithData(metadata);

          callback();
          update();
        });
  }
}

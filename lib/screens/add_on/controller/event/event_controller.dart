import 'dart:ui';

import 'package:foap/api_handler/apis/events_api.dart';
import 'package:foap/helper/enum.dart';
import 'package:foap/helper/list_extension.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/event_imports.dart';

import '../../../../api_handler/apis/post_api.dart';
import '../../../../model/data_wrapper.dart';
import '../../../../model/post_model.dart';

class EventsController extends GetxController {
  RxList<EventModel> events = <EventModel>[].obs;
  RxList<EventCategoryModel> categories = <EventCategoryModel>[].obs;
  RxList<EventMemberModel> members = <EventMemberModel>[].obs;
  RxList<PostModel> posts = <PostModel>[].obs;

  RxBool isLoadingCategories = false.obs;

  int eventsPage = 1;
  bool canLoadMoreEvents = true;
  RxBool isLoadingEvents = false.obs;

  int membersPage = 1;
  bool canLoadMoreMembers = true;
  bool isLoadingMembers = false;

  RxInt segmentIndex = (-1).obs;
  RxString searchText = ''.obs;

  String? _searchText;
  int? _categoryId;
  int? _status;
  int? _isJoined;
  DataWrapper postDataWrapper = DataWrapper();

  clear() {
    isLoadingEvents.value = false;
    events.value = [];
    eventsPage = 1;
    canLoadMoreEvents = true;
    postDataWrapper = DataWrapper();
    posts.clear();
  }

  clearMembers() {
    isLoadingMembers = false;
    members.value = [];
    membersPage = 1;
    canLoadMoreMembers = true;
  }

  searchEvents(String text) {
    events.value = [];
    canLoadMoreEvents = true;
    searchText.value = text;
    _searchText = text;
    getEvents();
  }

  setCategoryId(int categoryId) {
    events.value = [];
    canLoadMoreEvents = true;
    _categoryId = categoryId;
    getEvents();
  }

  setIsJoined(int isJoined) {
    events.value = [];
    canLoadMoreEvents = true;
    _isJoined = isJoined;
    getEvents();
  }

  getEvents() {
    if (canLoadMoreEvents) {
      isLoadingEvents.value = true;
      EventApi.getEvents(
          name: _searchText,
          status: _status,
          categoryId: _categoryId,
          isJoined: _isJoined,
          page: eventsPage,
          resultCallback: (result, metadata) {
            events.addAll(result);
            isLoadingEvents.value = false;
            events.unique((e) => e.id);
            canLoadMoreEvents = result.length >= metadata.perPage;
            eventsPage += 1;

            update();
          });
    }
  }

  getMembers({int? eventId}) {
    if (canLoadMoreMembers) {
      isLoadingMembers = true;
      EventApi.getEventMembers(
          eventId: eventId,
          page: membersPage,
          resultCallback: (result) {
            members.addAll(result);
            isLoadingMembers = false;
            members.unique((e) => e.id);

            membersPage += 1;
            // if (response.eventMembers.length == response.metaData?.perPage) {
            //   canLoadMoreMembers = true;
            // } else {
            //   canLoadMoreMembers = false;
            // }
          });

      update();
    }
  }

  getCategories() {
    isLoadingCategories.value = true;
    EventApi.getEventCategories(resultCallback: (result) {
      categories.value =
          result.where((element) => element.events.isNotEmpty).toList();

      isLoadingCategories.value = false;
    });
  }

  reactOnEvent({required ReactionOnEvent reaction, required int eventId}) {
    events.value = events.map((element) {
      if (element.id == eventId) {
        element.reaction = reaction;
      }
      return element;
    }).toList();

    events.refresh();

    EventApi.reactOnEvent(reaction: reaction, eventId: eventId);
  }

  refreshPosts({required VoidCallback callback}) {
    postDataWrapper = DataWrapper();
    getPosts(callback: callback);
  }

  loadMorePosts({required VoidCallback callback}) {
    if (postDataWrapper.haveMoreData.value == true) {
      if (postDataWrapper.page == 1) {
        postDataWrapper.isLoading.value = true;
      }
      getPosts(callback: callback);
    } else {
      callback();
    }
  }

  void getPosts({required VoidCallback callback}) async {
    PostApi.getPosts(
        postType: PostCategory.event,
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

  removePostFromList(PostModel post) {
    posts.removeWhere((element) => element.id == post.id);
    posts.refresh();
  }

  removeUsersAllPostFromList(PostModel post) {
    posts.removeWhere((element) => element.user.id == post.user.id);
    posts.refresh();
  }
}

import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:foap/components/post_card.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/dashboard/posts.dart';
import '../../components/hashtag_tile.dart';
import '../../components/search_bar.dart';
import '../../components/user_card.dart';
import '../../controllers/explore_controller.dart';
import '../../controllers/post_controller.dart';
import '../../segmentAndMenu/horizontal_menu.dart';

class Explore extends StatefulWidget {
  const Explore({Key? key}) : super(key: key);

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  final ExploreController exploreController = ExploreController();
  final PostController postController = Get.find();

  @override
  void initState() {
    super.initState();
    exploreController.getSuggestedUsers();
  }

  @override
  void didUpdateWidget(covariant Explore oldWidget) {
    exploreController.getSuggestedUsers();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    exploreController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: KeyboardDismissOnTap(
            child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            Row(
              children: [
                const ThemeIconWidget(
                  ThemeIcon.backArrow,
                  size: 25,
                ).ripple(() {
                  Get.back();
                }),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: SFSearchBar(
                      showSearchIcon: true,
                      iconColor: AppColorConstants.themeColor,
                      onSearchChanged: (value) {
                        exploreController.searchTextChanged(value);
                      },
                      onSearchStarted: () {
                        //controller.startSearch();
                      },
                      onSearchCompleted: (searchTerm) {}),
                ),
                Obx(() => exploreController.searchText.isNotEmpty
                    ? Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            height: 50,
                            width: 50,
                            color: AppColorConstants.themeColor,
                            child: ThemeIconWidget(
                              ThemeIcon.close,
                              color: AppColorConstants.backgroundColor,
                              size: 25,
                            ),
                          ).round(20).ripple(() {
                            exploreController.closeSearch();
                          }),
                        ],
                      )
                    : Container())
              ],
            ).setPadding(left: 16, right: 16, top: 25, bottom: 20),
            GetBuilder<ExploreController>(
                init: exploreController,
                builder: (ctx) {
                  return exploreController.searchText.isNotEmpty
                      ? Expanded(
                          child: Column(
                            children: [
                              segmentView(),
                              divider(height: 0.2),
                              searchedResult(
                                  segment: exploreController.selectedSegment),
                            ],
                          ),
                        )
                      : searchSuggestionView();
                })
          ],
        )),
      ),
    );
  }

  Widget segmentView() {
    return HorizontalSegmentBar(
        width: MediaQuery.of(context).size.width,
        onSegmentChange: (segment) {
          exploreController.segmentChanged(segment);
        },
        segments: [
          topString.tr,
          accountString.tr,
          hashTagsString.tr,
          // locations,
        ]);
  }

  Widget searchSuggestionView() {
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (!exploreController.suggestUserIsLoading) {
          exploreController.getSuggestedUsers();
        }
      }
    });

    return exploreController.suggestUserIsLoading
        ? Expanded(child: const ShimmerUsers().hP16)
        : exploreController.suggestedUsers.isNotEmpty
            ? Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Heading3Text(suggestedUsersString.tr,
                        weight: TextWeight.bold),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.only(top: 20, bottom: 50),
                          itemCount: exploreController.suggestedUsers.length,
                          itemBuilder: (BuildContext ctx, int index) {
                            return UserTile(
                              profile: exploreController.suggestedUsers[index],
                              followCallback: () {
                                exploreController.followUser(
                                    exploreController.suggestedUsers[index]);
                              },
                              unFollowCallback: () {
                                exploreController.unFollowUser(
                                    exploreController.suggestedUsers[index]);
                              },
                            );
                          },
                          separatorBuilder: (BuildContext ctx, int index) {
                            return const SizedBox(
                              height: 20,
                            );
                          }),
                    ),
                  ],
                ).hP16,
              )
            : Container();
  }

  Widget searchedResult({required int segment}) {
    switch (segment) {
      case 0:
        return topPosts();
      case 1:
        return Expanded(child: usersView().hP16);
      case 2:
        return Expanded(child: hashTagView().hP16);
      // case 3:
      //   return Expanded(child: locationView()).hP16;
    }
    return usersView();
  }

  Widget usersView() {
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (!exploreController.accountsIsLoading) {
          exploreController.searchData();
        }
      }
    });

    return exploreController.accountsIsLoading
        ? const ShimmerUsers()
        : exploreController.searchedUsers.isNotEmpty
            ? ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.only(top: 20),
                itemCount: exploreController.searchedUsers.length,
                itemBuilder: (BuildContext ctx, int index) {
                  return UserTile(
                    profile: exploreController.searchedUsers[index],
                    followCallback: () {
                      exploreController
                          .followUser(exploreController.searchedUsers[index]);
                    },
                    unFollowCallback: () {
                      exploreController
                          .unFollowUser(exploreController.searchedUsers[index]);
                    },
                  );
                },
                separatorBuilder: (BuildContext ctx, int index) {
                  return const SizedBox(
                    height: 20,
                  );
                })
            : SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: emptyUser(title: noUserFoundString.tr, subTitle: ''),
              );
  }

  Widget hashTagView() {
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (!exploreController.hashtagsIsLoading) {
          exploreController.searchData();
        }
      }
    });

    return exploreController.hashtagsIsLoading
        ? const ShimmerHashtag()
        : exploreController.hashTags.isNotEmpty
            ? ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.only(top: 20),
                itemCount: exploreController.hashTags.length,
                itemBuilder: (BuildContext ctx, int index) {
                  return HashTagTile(
                    hashtag: exploreController.hashTags[index],
                    onItemCallback: () {
                      Get.to(() => Posts(
                            hashTag: exploreController.hashTags[index].name,
                          ));
                    },
                  );
                },
              )
            : SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: emptyData(title: noHashtagFoundString.tr, subTitle: ''),
              );
  }

  // Widget locationView() {
  //   return ListView.builder(
  //     padding: const EdgeInsets.only(top: 20),
  //     itemCount: controller.locations.length,
  //     itemBuilder: (BuildContext ctx, int index) {
  //       return LocationTile(
  //         location: controller.locations[index],
  //         onItemCallback: () {
  //           Get.to(() => Posts(locationId: controller.locations[index].id));
  //         },
  //       );
  //     },
  //   );
  // }

  Widget topPosts() {
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (!postController.isLoadingPosts) {
          exploreController.searchData();
        }
      }
    });

    return GetBuilder<PostController>(
        init: postController,
        builder: (ctx) {
          return Expanded(
              child: postController.isLoadingPosts
                  ? const PostBoxShimmer()
                  : postController.posts.isNotEmpty
                      ? ListView.builder(
                          controller: scrollController,
                          itemCount: postController.posts.length,
                          // physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) =>
                              PostCard(
                                      model: postController.posts[index],
                                      removePostHandler: () {},
                                      blockUserHandler: () {},
                                      viewInsightHandler: () {})
                                  .ripple(() {
                            Get.to(() => Posts(
                                  posts: List.from(postController.posts),
                                  index: index,
                                  page: postController.postsCurrentPage,
                                  totalPages: postController.totalPages,
                                ));
                          }),
                        ).hP16
                      : SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: emptyPost(
                              title: noPostFoundString.tr, subTitle: ''),
                        ));
        });
  }
}

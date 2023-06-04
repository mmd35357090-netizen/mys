import 'dart:math';
import 'package:get/get.dart';
import '../../components/highlights_bar.dart';
import '../../components/post_card.dart';
import '../../components/segmented_control.dart';
import '../../controllers/story/highlights_controller.dart';
import '../../controllers/profile/profile_controller.dart';
import '../../helper/imports/common_import.dart';
import '../../model/post_model.dart';
import '../add_on/ui/reel/reels_list.dart';
import '../dashboard/mentions.dart';
import '../dashboard/posts.dart';
import '../highlights/choose_stories.dart';
import '../highlights/hightlights_viewer.dart';

class HighlightsView extends StatelessWidget {
  final HighlightsController _highlightsController = Get.find();

  HighlightsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HighlightsController>(
        init: _highlightsController,
        builder: (ctx) {
          return _highlightsController.isLoading == true
              ? const StoryAndHighlightsShimmer()
              : HighlightsBar(
                  highlights: _highlightsController.highlights,
                  addHighlightCallback: () {
                    Get.to(() => const ChooseStoryForHighlights());
                  },
                  viewHighlightCallback: (highlight) {
                    Get.to(() => HighlightViewer(highlight: highlight))!
                        .then((value) {
                      //loadData();
                    });
                  },
                );
        });
  }
}

// class PostList extends StatelessWidget {
//   final ProfileController _profileController = Get.find();
//
//   PostList({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: GetBuilder<ProfileController>(
//           init: _profileController,
//           builder: (ctx) {
//             ScrollController scrollController = ScrollController();
//             scrollController.addListener(() {
//               if (scrollController.position.maxScrollExtent ==
//                   scrollController.position.pixels) {
//                 _profileController.getPosts(_profileController.user.value!.id);
//               }
//             });
//
//             List<PostModel> posts = _profileController.posts;
//
//             return _profileController.isLoadingPosts
//                 ? const PostBoxShimmer()
//                 : ListView.builder(
//                     controller: scrollController,
//                     itemCount: posts.length,
//                     physics: const NeverScrollableScrollPhysics(),
//                     shrinkWrap: true,
//                     itemBuilder: (BuildContext context, int index) => PostCard(
//                             model: posts[index],
//                             removePostHandler: () {},
//                             blockUserHandler: () {},
//                             viewInsightHandler: () {})
//                         .ripple(() {
//                       Get.to(() => Posts(
//                           posts: List.from(posts),
//                           index: index,
//                           userId: _profileController.user.value!.id,
//                           page: _profileController.postsCurrentPage,
//                           totalPages: _profileController.totalPages));
//                     }),
//                   ).hP16;
//           }),
//     );
//   }
// }

class MentionsList extends StatelessWidget {
  final ProfileController _profileController = Get.find();

  MentionsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GetBuilder<ProfileController>(
          init: _profileController,
          builder: (ctx) {
            ScrollController scrollController = ScrollController();
            scrollController.addListener(() {
              if (scrollController.position.maxScrollExtent ==
                  scrollController.position.pixels) {
                _profileController
                    .getMentionPosts(_profileController.user.value!.id);
              }
            });

            List<PostModel> posts = _profileController.mentions;

            return _profileController.isLoadingPosts
                ? const PostBoxShimmer()
                : ListView.builder(
                    controller: scrollController,
                    itemCount: posts.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    // You won't see infinite size error
                    // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    //     crossAxisCount: 3,
                    //     crossAxisSpacing: 8.0,
                    //     mainAxisSpacing: 8.0,
                    //     mainAxisExtent: 100),
                    itemBuilder: (BuildContext context, int index) => PostCard(
                            model: posts[index],
                            removePostHandler: () {},
                            blockUserHandler: () {},
                            viewInsightHandler: () {})
                        .ripple(() {
                      Get.to(() => Mentions(
                          posts: List.from(posts),
                          index: index,
                          userId: _profileController.user.value!.id,
                          page: _profileController.mentionsPostPage,
                          totalPages: _profileController.totalPages));
                    }),
                  ).hP16;
          }),
    );
  }
}

class ReelsGrid extends StatelessWidget {
  final ProfileController _profileController = Get.find();

  ReelsGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GetBuilder<ProfileController>(
          init: _profileController,
          builder: (ctx) {
            ScrollController scrollController = ScrollController();
            scrollController.addListener(() {
              if (scrollController.position.maxScrollExtent ==
                  scrollController.position.pixels) {
                if (!_profileController.isLoadingReels) {
                  _profileController
                      .getReels(_profileController.user.value!.id);
                }
              }
            });

            List<PostModel> posts = _profileController.reels;

            return _profileController.isLoadingReels
                ? const PostBoxShimmer()
                : GridView.builder(
                    controller: scrollController,
                    itemCount: posts.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    // You won't see infinite size error
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemBuilder: (BuildContext context, int index) =>
                        Stack(children: [
                      AspectRatio(
                        aspectRatio: 0.7,
                        child: CachedNetworkImage(
                          imageUrl: posts[index].gallery.first.thumbnail,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              AppUtil.addProgressIndicator(size: 100),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.error,
                          ),
                        ).round(10),
                      ).ripple(() {
                        Get.to(() => ReelsList(
                              reels: List.from(posts),
                              index: index,
                              userId: _profileController.user.value!.id,
                              page: _profileController.reelsCurrentPage,
                            ));
                      }),
                      const Positioned(
                        right: 5,
                        top: 5,
                        child: ThemeIconWidget(
                          ThemeIcon.videoPost,
                          size: 30,
                          color: Colors.white,
                        ),
                      )
                    ]),
                  ).hP16;
          }),
    );
  }
}

// class UserPostMedia extends StatefulWidget {
//   final int userId;
//
//   UserPostMedia({Key? key, required this.userId}) : super(key: key);
//
//   @override
//   State<UserPostMedia> createState() => _UserPostMediaState();
// }
//
// class _UserPostMediaState extends State<UserPostMedia>
//     with SingleTickerProviderStateMixin {
//   final ProfileController _profileController = Get.find();
//   final UserProfileManager _userProfileManager = Get.find();
//
//   TabController? controller;
//
//   List<ThemeIcon> icons = [
//     ThemeIcon.gallery,
//     ThemeIcon.mention,
//     // ThemeIcon.story,
//   ];
//
//   List<String> texts = [
//     LocalizationString.feed,
//     LocalizationString.mentions,
//     // ThemeIcon.story,
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     controller = TabController(vsync: this, length: 2)
//       ..addListener(() {
//         if (controller!.indexIsChanging == false) {
//           _profileController.segmentChanged(controller!.index);
//         }
//       });
//
//     // _highlightsController.getHighlights(userId: widget.userId);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Stack(
//           children: [
//             Positioned(
//                 left: 16,
//                 right: 16,
//                 bottom: 0,
//                 child: Container(
//                   height: 2,
//                   color: AppColorConstants.dividerColor,
//                 )),
//             Obx(() => SMIconAndTextTabBar(
//               icons: icons,
//               texts: texts,
//               controller: controller,
//               selectedTab: _profileController.selectedSegment.value,
//               // controller: controller,
//             )),
//           ],
//         ),
//         Obx(() => SizedBox(
//           height: max(
//               400,
//               ((Get.width - (2 * (DesignConstants.horizontalPadding))) *
//                   0.7 *
//                   (_profileController.selectedSegment.value == 0
//                       ? (_profileController.posts.length / 3)
//                       : _profileController.selectedSegment.value == 1
//                       ? _profileController.reels.length
//                       : _profileController.mentions.length))
//                   .toDouble()),
//           child: TabBarView(
//             controller: controller,
//             children: [
//               addPhotoGrid(_profileController.posts),
//               addPhotoGrid(_profileController.mentions),
//             ],
//           ),
//         )),
//       ],
//     );
//   }
//
//   addPhotoGrid(List<PostModel> posts) {
//     ScrollController scrollController = ScrollController();
//     scrollController.addListener(() {
//       if (scrollController.position.maxScrollExtent ==
//           scrollController.position.pixels) {
//         if (_profileController.selectedSegment.value == 0) {
//           if (!_profileController.isLoadingPosts) {
//             _profileController.getPosts(_userProfileManager.user.value!.id);
//           }
//         } else {
//           if (!_profileController.mentionsPostsIsLoading) {
//             _profileController
//                 .getMyMentions(_userProfileManager.user.value!.id);
//           }
//         }
//       }
//     });
//
//     return _profileController.isLoadingPosts
//         ? const PostBoxShimmer()
//         : GridView.builder(
//       controller: scrollController,
//       itemCount: posts.length,
//       padding: const EdgeInsets.only(top: 20, bottom: 50),
//       physics: const NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       // You won't see infinite size error
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         crossAxisSpacing: 5.0,
//         mainAxisSpacing: 5.0,
//         childAspectRatio: 0.7,
//       ),
//       itemBuilder: (BuildContext context, int index) => Stack(children: [
//         CachedNetworkImage(
//           imageUrl: posts[index].gallery.first.thumbnail,
//           fit: BoxFit.cover,
//           height: double.infinity,
//           placeholder: (context, url) =>
//               AppUtil.addProgressIndicator(size: 100),
//           errorWidget: (context, url, error) => const Icon(
//             Icons.error,
//           ),
//         ).round(10).ripple(() {
//           Get.to(() => Posts(
//               posts: List.from(posts),
//               index: index,
//               userId: _userProfileManager.user.value!.id,
//               source: _profileController.selectedSegment.value == 0
//                   ? PostSource.posts
//                   : PostSource.mentions,
//               page: _profileController.selectedSegment.value == 0
//                   ? _profileController.postsCurrentPage
//                   : _profileController.mentionsPostPage,
//               totalPages: _profileController.totalPages));
//         }),
//         posts[index].gallery.length == 1
//             ? posts[index].gallery.first.isVideoPost == true
//             ? const Positioned(
//           right: 5,
//           top: 5,
//           child: ThemeIconWidget(
//             ThemeIcon.videoPost,
//             size: 30,
//             color: Colors.white,
//           ),
//         )
//             : Container()
//             : const Positioned(
//             right: 5,
//             top: 5,
//             child: ThemeIconWidget(
//               ThemeIcon.multiplePosts,
//               color: Colors.white,
//               size: 30,
//             ))
//       ]),
//     ).hP16;
//   }
// }

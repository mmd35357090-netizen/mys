// import 'package:foap/helper/imports/common_import.dart';
// import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
// import '../../components/post_card/post_card.dart';
// import '../../controllers/post/post_controller.dart';
// import '../../model/post_model.dart';
// import '../../model/post_search_query.dart';
//
// class Mentions extends StatefulWidget {
//   final int? userId;
//   final List<PostModel>? posts;
//   final int? index;
//   final int? page;
//   final int? totalPages;
//
//   const Mentions(
//       {super.key,
//       this.userId,
//       this.posts,
//       this.index,
//       this.page,
//       this.totalPages})
//       ;
//
//   @override
//   State<Mentions> createState() => _MentionsState();
// }
//
// class _MentionsState extends State<Mentions> {
//   final PostController _postController = Get.find();
//   final ItemScrollController itemScrollController = ItemScrollController();
//   final ItemPositionsListener itemPositionsListener =
//       ItemPositionsListener.create();
//
//   @override
//   void initState() {
//     super.initState();
//     loadData();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _postController.addPosts(
//           widget.posts ?? [], widget.page, widget.totalPages);
//
//       if (widget.index != null) {
//         Future.delayed(const Duration(milliseconds: 200), () {
//           itemScrollController.jumpTo(
//             index: widget.index!,
//           );
//         });
//       }
//     });
//   }
//
//   void loadData() {
//     if (widget.userId != null) {
//       MentionedPostSearchQuery query =
//           MentionedPostSearchQuery(userId: widget.userId!);
//       _postController.setMentionedPostSearchQuery(query);
//     }
//   }
//
//   @override
//   void dispose() {
//     _postController.clearMentions();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AppScaffold(
//         backgroundColor: AppColorConstants.backgroundColor,
//         body: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const SizedBox(
//               height: 55,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 ThemeIconWidget(
//                   ThemeIcon.backArrow,
//                   color: AppColorConstants.iconColor,
//                   size: 25,
//                 ).ripple(() {
//                   Get.back();
//                 }),
//               ],
//             ).hp(20),
//             const SizedBox(
//               height: 20,
//             ),
//             Expanded(child: postsView()),
//           ],
//         ));
//   }
//
//   postsView() {
//     ScrollController scrollController = ScrollController();
//     scrollController.addListener(() {
//       if (scrollController.position.maxScrollExtent ==
//           scrollController.position.pixels) {
//         if (!_postController.mentionsDataWrapper.isLoading.value) {
//           _postController.getMyMentions();
//         }
//       }
//     });
//
//     return GetBuilder<PostController>(
//         init: _postController,
//         builder: (ctx) {
//           List<PostModel> posts = _postController.mentions;
//
//           return _postController.postDataWrapper.isLoading.value
//               ? const HomeScreenShimmer()
//               : posts.isEmpty
//                   ? Center(child: BodyLargeText(noDataString.tr))
//                   : ScrollablePositionedList.builder(
//                       itemScrollController: itemScrollController,
//                       itemPositionsListener: itemPositionsListener,
//                       padding: const EdgeInsets.only(top: 10, bottom: 50),
//                       itemCount: posts.length,
//                       itemBuilder: (context, index) {
//                         PostModel model = posts[index];
//                         return Column(
//                           children: [
//                             PostCard(
//                                 model: model,
//                                 removePostHandler: () {
//                                   _postController.removePostFromList(model);
//                                 },
//                                 blockUserHandler: () {
//                                   _postController
//                                       .removeUsersAllPostFromList(model);
//                                 }),
//                             const SizedBox(
//                               height: 15,
//                             )
//                           ],
//                         );
//                       },
//                     );
//         });
//   }
// }

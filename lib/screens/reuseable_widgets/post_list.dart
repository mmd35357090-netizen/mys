import 'package:foap/helper/imports/common_import.dart';
import '../../components/post_card.dart';
import '../../controllers/post/post_controller.dart';

class PostList extends StatelessWidget {
  final PostController postController = Get.find();

  PostList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return topPosts();
  }

  Widget topPosts() {
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (!postController.isLoadingPosts) {
          postController.getPosts(() {});
        }
      }
    });

    return GetBuilder<PostController>(
        init: postController,
        builder: (ctx) {
          return Container(
              child: postController.isLoadingPosts
                  ? const PostBoxShimmer()
                  : postController.posts.isNotEmpty
                      ? ListView.builder(
                          padding: const EdgeInsets.only(top: 20, bottom: 100),
                          controller: scrollController,
                          itemCount: postController.posts.length,
                          // physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) =>
                              PostCard(
                                  model: postController.posts[index],
                                  removePostHandler: () {},
                                  blockUserHandler: () {},
                                  viewInsightHandler: () {}),
                        ).hp(DesignConstants.horizontalPadding)
                      : SizedBox(
                          height: Get.size.height * 0.5,
                          child: emptyPost(
                              title: noPostFoundString.tr, subTitle: ''),
                        ));
        });
  }
}

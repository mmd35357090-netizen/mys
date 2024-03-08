import 'package:flutter/gestures.dart';
import '../../controllers/post/post_controller.dart';
import '../../helper/imports/common_import.dart';
import '../../model/post_model.dart';
import '../../model/post_search_query.dart';
import '../../screens/dashboard/posts.dart';
import '../../screens/profile/other_user_profile.dart';

class RichTextPostTitle extends StatelessWidget {
  final PostModel model;

  const RichTextPostTitle({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return richTextPostTitle();
  }

  Align richTextPostTitle() {
    List<String> split = model.postTitle.split(' ');

    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
          textAlign: TextAlign.left,
          text: TextSpan(children: [
            for (String text in split)
              text.startsWith('#')
                  ? TextSpan(
                      text: '$text ',
                      style: TextStyle(
                          color: AppColorConstants.themeColor,
                          fontSize: FontSizes.b3,
                          fontWeight: FontWeight.w700),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          postTextTapHandler(post: model, text: text);
                          // widget.textTapHandler(text);
                        },
                    )
                  : text.startsWith('@')
                      ? TextSpan(
                          text: '$text ',
                          style: TextStyle(
                              color: AppColorConstants.themeColor,
                              fontSize: FontSizes.b3,
                              fontWeight: FontWeight.w700),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // widget.textTapHandler(text);
                              postTextTapHandler(post: model, text: text);
                            },
                        )
                      : TextSpan(
                          text: '$text ',
                          style: TextStyle(
                              color: AppColorConstants.mainTextColor,
                              fontSize: FontSizes.b3,
                              fontWeight: FontWeight.w400))
          ])),
    );
  }

  postTextTapHandler({required PostModel post, required String text}) {
    final PostController postController = Get.find();

    if (text.startsWith('#')) {
      PostSearchQuery query = PostSearchQuery();
      query.hashTag = text.replaceAll('#', '');
      postController.setPostSearchQuery(query: query, callback: () {});

      Get.to(() => const Posts());
      // _postController.getPosts();
    } else {
      String userTag = text.replaceAll('@', '');
      if (post.mentionedUsers
          .where((element) => element.userName == userTag)
          .isNotEmpty) {
        int mentionedUserId = post.mentionedUsers
            .where((element) => element.userName == userTag)
            .first
            .id;
        Get.to(() => OtherUserProfile(userId: mentionedUserId))!.then((value) {
          postController.getPosts(() {});
        });
      } else {
        // print('not found');
      }
    }
  }
}

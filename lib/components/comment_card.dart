import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text.dart';
import 'package:foap/apiHandler/apis/users_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../model/comment_model.dart';

import '../model/post_gallery.dart';
import '../model/search_model.dart';

import '../screens/dashboard/posts.dart';
import '../screens/home_feed/post_media_full_screen.dart';
import '../screens/profile/other_user_profile.dart';

class CommentTile extends StatefulWidget {
  final CommentModel model;

  const CommentTile({Key? key, required this.model}) : super(key: key);

  @override
  CommentTileState createState() => CommentTileState();
}

class CommentTileState extends State<CommentTile> {
  late final CommentModel model;

  @override
  void initState() {
    super.initState();
    model = widget.model;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarView(
                url: model.userPicture,
                name: model.userName,
                size: 35,
              ).ripple(() {
                Get.to(() => OtherUserProfile(userId: model.userId));
              }),
              const SizedBox(width: 10),
              Flexible(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const SizedBox(height: 4),
                  Heading6Text(
                    model.userName,
                    weight: TextWeight.medium,
                  ).ripple(() {
                    Get.to(() => OtherUserProfile(userId: model.userId));
                  }),
                  model.type == CommentType.text
                      ? showCommentText()
                      : showCommentMedia()
                ],
              ))
            ],
          )),
          BodySmallText(model.commentTime, weight: TextWeight.medium).tP4
        ]);
  }

  showCommentText() {
    return DetectableText(
      text: model.comment,
      detectionRegExp: RegExp(
        "(?!\\n)(?:^|\\s)([#@]([$detectionContentLetters]+))|$urlRegexContent",
        multiLine: true,
      ),
      detectedStyle: TextStyle(
          fontSize: FontSizes.b3,
          fontWeight: TextWeight.semiBold,
          color: AppColorConstants.grayscale900),
      basicStyle: TextStyle(
          fontSize: FontSizes.b3, color: AppColorConstants.grayscale900),
      onTap: (tappedText) {
        commentTextTapHandler(text: tappedText);
        // postCardController.titleTextTapped(text: tappedText,post: widget.model);
      },
    );
  }

  showCommentMedia() {
    return CachedNetworkImage(
      imageUrl: model.filename,
      height: 150,
      width: 150,
      fit: BoxFit.cover,
    ).round(10).tP16.ripple(() {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) =>
              PostMediaFullScreen(gallery: [
                PostGallery(
                  id: 0,
                  postId: 0,
                  fileName: "",
                  filePath: model.filename ?? "",
                  mediaType: 1, //  image=1, video=2, audio=3
                )
              ]),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    });
  }

  commentTextTapHandler({required String text}) {
    if (text.startsWith('#')) {
      Get.to(() => Posts(
            hashTag: text.replaceAll('#', ''),
          ));
    } else {
      String userTag = text.replaceAll('@', '');

      UserSearchModel searchModel = UserSearchModel();
      searchModel.isExactMatch = 1;
      searchModel.searchText = userTag;
      UsersApi.searchUsers(
          searchModel: searchModel,
          page: 1,
          resultCallback: (result, metadata) {
            if (result.isNotEmpty) {
              Get.to(() => OtherUserProfile(userId: result.first.id));
            }
          });
    }
  }
}

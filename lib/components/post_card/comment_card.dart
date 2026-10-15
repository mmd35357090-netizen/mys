import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text.dart';
import 'package:foap/api_handler/apis/users_api.dart';
import 'package:foap/controllers/misc/misc_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../model/comment_model.dart';
import '../../model/post_gallery.dart';
import '../../model/search_model.dart';
import '../../screens/dashboard/posts.dart';
import '../../screens/home_feed/post_media_full_screen.dart';
import '../../screens/profile/other_user_profile.dart';

class CommentTile extends StatefulWidget {
  final CommentModel model;
  final Function(CommentModel) replyActionHandler;
  final Function(CommentModel) deleteActionHandler;
  final Function(CommentModel) favActionHandler;
  final Function(CommentModel) reportActionHandler;
  final Function(CommentModel) loadMoreChildCommentsActionHandler;

  const CommentTile({
    super.key,
    required this.model,
    required this.replyActionHandler,
    required this.deleteActionHandler,
    required this.favActionHandler,
    required this.reportActionHandler,
    required this.loadMoreChildCommentsActionHandler,
  });

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  bool isFavourite = false;

  @override
  void initState() {
    isFavourite = widget.model.isFavourite;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarView(
                url: widget.model.userPicture,
                name: widget.model.user!.userName.isEmpty
                    ? widget.model.user!.name
                    : widget.model.user!.userName,
                size: widget.model.level == 1 ? 35 : 20,
              ).ripple(() {
                Get.to(() => OtherUserProfile(
                    userId: widget.model.userId, user: widget.model.user));
              }),
              const SizedBox(width: 10),
              Flexible(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Row(
                        children: [
                          BodyMediumText(
                            widget.model.userName,
                            weight: TextWeight.medium,
                          ).rP8,
                          if (widget.model.user?.isVerified == true)
                            verifiedUserTag().rP4,
                          BodySmallText(
                            widget.model.commentTime,
                            weight: TextWeight.semiBold,
                            color: AppColorConstants.subHeadingTextColor
                                .withValues(alpha: 0.5),
                          ),
                        ],
                      ).ripple(() {
                        Get.to(() => OtherUserProfile(
                            userId: widget.model.userId,
                            user: widget.model.user));
                      }),
                      const Spacer(),
                      if (widget.model.isPinned)
                        Row(
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: ThemeIconWidget(
                                ThemeIcon.pin,
                                color: AppColorConstants.themeColor,
                                size: 25,
                              ),
                            ).ripple(() {
                              setState(() {
                                widget.model.isPinned = false;
                                MiscController controller = Get.find();
                                controller.removeFromPin(
                                    PinContentType.comment,
                                    widget.model.id);
                              });
                            }),
                            const SizedBox(
                              width: 20,
                            ),
                          ],
                        ),
                      ThemeIconWidget(
                        isFavourite ? ThemeIcon.favFilled : ThemeIcon.fav,
                        color: isFavourite
                            ? AppColorConstants.red
                            : AppColorConstants.iconColor,
                      ).ripple(() {
                        setState(() {
                          isFavourite = !isFavourite;
                          widget.model.isFavourite =
                              !widget.model.isFavourite;
                        });
                        widget.favActionHandler(widget.model);
                      }),
                      if (widget.model.user?.isMe == true &&
                          widget.model.canReply)
                        Row(
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            ThemeIconWidget(
                              ThemeIcon.moreVertical,
                            ).ripple(() {
                              openActionPopup();
                            }),
                          ],
                        )
                    ],
                  ),
                  widget.model.type == CommentType.text
                      ? showCommentText()
                      : showCommentMedia(),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      if (widget.model.canReply)
                        BodySmallText(
                          replyString.tr,
                          weight: TextWeight.semiBold,
                        ).rp(20).ripple(() {
                          widget.replyActionHandler(widget.model);
                        }),
                      if (widget.model.user?.isMe == true)
                        BodySmallText(
                          deleteString.tr,
                          weight: TextWeight.semiBold,
                          color: Colors.red,
                        ).ripple(() {
                          widget.deleteActionHandler(widget.model);
                        }),
                      if (widget.model.user?.isMe == false)
                        BodySmallText(
                          reportString.tr,
                          weight: TextWeight.semiBold,
                          color: Colors.red,
                        ).ripple(() {
                          widget.reportActionHandler(widget.model);
                        }),
                    ],
                  )
                ],
              ))
            ],
          ),
          Column(
            children: [
              for (CommentModel comment in widget.model.replies)
                CommentTile(
                    model: comment,
                    replyActionHandler: (comment) {
                      widget.reportActionHandler(comment);
                    },
                    deleteActionHandler: (comment) {
                      widget.deleteActionHandler(comment);
                    },
                    favActionHandler: (comment) {
                      widget.favActionHandler(comment);
                    },
                    reportActionHandler: (comment) {
                      widget.reportActionHandler(comment);
                    },
                    loadMoreChildCommentsActionHandler: (comment) {
                      widget.loadMoreChildCommentsActionHandler(comment);
                    }).setPadding(left: 50, top: 15)
            ],
          ),
          if (widget.model.pendingReplies > 0)
            BodySmallText(
              '${viewString.tr} ${widget.model.pendingReplies} ${moreRepliesString.tr}',
              weight: TextWeight.bold,
              color: AppColorConstants.subHeadingTextColor,
            ).setPadding(top: 25, left: 50).ripple(() {
              widget.loadMoreChildCommentsActionHandler(widget.model);
            }),
        ]);
  }

  showCommentText() {
    return DetectableText(
      text: widget.model.comment,
      detectionRegExp: RegExp(
        "(?!\\n)(?:^|\\s)([#@]([$detectionContentLetters]+))|$urlRegexContent",
        multiLine: true,
      ),
      detectedStyle: TextStyle(
          fontSize: FontSizes.b3,
          fontWeight: TextWeight.semiBold,
          color: AppColorConstants.mainTextColor),
      basicStyle: TextStyle(
          fontSize: FontSizes.b3, color: AppColorConstants.mainTextColor),
      onTap: (tappedText) {
        commentTextTapHandler(text: tappedText);
      },
    );
  }

  showCommentMedia() {
    return CachedNetworkImage(
      imageUrl: widget.model.filePath,
      height: 150,
      width: 150,
      fit: BoxFit.cover,
    ).round(10).tP16.ripple(() {
      Navigator.push(
        Get.context!,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) =>
              PostMediaFullScreen(gallery: [
            PostGallery(
              id: 0,
              postId: 0,
              fileName: "",
              filePath: widget.model.filePath,
              height: 0,
              width: 0,
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
            title: text,
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
              Get.to(() => OtherUserProfile(
                  userId: result.first.id, user: result.first));
            }
          });
    }
  }

  void openActionPopup() {
    Get.bottomSheet(Container(
      color: AppColorConstants.cardColor.darken(),
      child: Wrap(
        children: [
          ListTile(
              title: Center(
                  child: Heading6Text(
                replyString.tr,
                weight: TextWeight.semiBold,
              )),
              onTap: () async {
                Get.back();
                widget.replyActionHandler(widget.model);
              }),
          divider(),
          ListTile(
              title: Center(
                  child: Heading6Text(
                deleteString.tr,
                weight: TextWeight.semiBold,
              )),
              onTap: () async {
                Get.back();
                widget.deleteActionHandler(widget.model);
              }),
          divider(),
          ListTile(
              title: Center(
                  child: Heading6Text(
                widget.model.isPinned ? unPinString.tr : pinString.tr,
                weight: TextWeight.semiBold,
              )),
              onTap: () async {
                Get.back();
                MiscController miscController = Get.find();

                setState(() {
                  if (widget.model.isPinned) {
                    miscController.removeFromPin(
                        PinContentType.comment, widget.model.id);
                    widget.model.isPinned = false;
                  } else {
                    miscController.addToPin(
                        PinContentType.comment, widget.model.id, (id) {
                      widget.model.pinId = id;
                    });
                    widget.model.isPinned = true;
                  }
                });
              }),
          divider(),
          ListTile(
              title: Center(
                  child: BodyLargeText(
                cancelString.tr,
                weight: TextWeight.semiBold,
                color: AppColorConstants.red,
              )),
              onTap: () => Get.back()),
        ],
      ),
    ).topRounded(40));
  }
}

import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/models.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../components/post_card/comment_card.dart';
import '../../components/smart_text_field.dart';
import '../../controllers/misc/users_controller.dart';
import '../../controllers/post/comments_controller.dart';
import '../post/tag_hashtag_view.dart';
import '../post/tag_users_view.dart';

class CommentsScreen extends StatefulWidget {
  final PostModel? model;
  final int? postId;
  final bool? isPopup;
  final VoidCallback? handler;
  final VoidCallback commentPostedCallback;

  const CommentsScreen(
      {super.key,
      this.model,
      this.postId,
      this.handler,
      this.isPopup,
      required this.commentPostedCallback});

  @override
  CommentsScreenState createState() => CommentsScreenState();
}

class CommentsScreenState extends State<CommentsScreen> {
  TextEditingController commentInputField = TextEditingController();
  final CommentsController _commentsController = CommentsController();
  final UsersController _usersController = Get.find();
  final SmartTextFieldController _smartTextFieldController = Get.find();

  final RefreshController _commentsRefreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    _smartTextFieldController.clear();
    super.initState();
    loadData();
  }

  @override
  dispose() {
    _commentsController.clear();
    super.dispose();
  }

  loadData() {
    _commentsController.getComments(widget.postId ?? widget.model!.id, () {
      _commentsRefreshController.loadComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: <Widget>[
            backNavigationBar(title: commentsString.tr),
            Obx(() => _smartTextFieldController.hashTags.isNotEmpty ||
                    _usersController.searchedUsers.isNotEmpty
                ? Expanded(
                    child: Container(
                      width: double.infinity,
                      color: AppColorConstants.disabledColor,
                      child: _smartTextFieldController.isEditing.value == 1
                          ? Container(
                              // height: 500,
                              width: double.infinity,
                              color: AppColorConstants.disabledColor
                                  .withValues(alpha: 0.1),
                              child: _smartTextFieldController
                                      .currentHashtag.isNotEmpty
                                  ? TagHashtagView()
                                  : _smartTextFieldController
                                          .currentUserTag.isNotEmpty
                                      ? TagUsersView()
                                      : Container().ripple(() {
                                          FocusManager
                                              .instance.primaryFocus
                                              ?.unfocus();
                                        }),
                            )
                          : Container(),
                    ),
                  )
                : Flexible(
                    child: GetBuilder<CommentsController>(
                        init: _commentsController,
                        builder: (ctx) {
                          return ListView.separated(
                            controller: _commentsController.controller,
                            padding: EdgeInsets.only(
                                top: 20,
                                left: DesignConstants.horizontalPadding,
                                right: DesignConstants.horizontalPadding),
                            itemCount: _commentsController.comments.length,
                            itemBuilder: (context, index) {
                              CommentModel comment =
                                  _commentsController.comments[index];
                              return CommentTile(
                                model: comment,
                                replyActionHandler: (comment) {
                                  _commentsController
                                      .setReplyComment(comment);
                                },
                                deleteActionHandler: (comment) {
                                  _commentsController.deleteComment(
                                    comment: comment,
                                  );
                                },
                                favActionHandler: (isFav) {
                                  _commentsController.favUnfavComment(
                                    comment: comment,
                                  );
                                },
                                reportActionHandler: (comment) {
                                  _commentsController.reportComment(
                                    commentId: comment.id,
                                  );
                                },
                                loadMoreChildCommentsActionHandler:
                                    (comment) {
                                  _commentsController.getChildComments(
                                    page: comment.currentPageForReplies,
                                    postId:
                                        widget.postId ?? widget.model!.id,
                                    parentId: comment.id,
                                  );
                                },
                              );
                            },
                            separatorBuilder: (ctx, index) {
                              return const SizedBox(
                                height: 20,
                              );
                            },
                          ).addPullToRefresh(
                              refreshController:
                                  _commentsRefreshController,
                              onRefresh: () {},
                              onLoading: () {
                                loadData();
                              },
                              enablePullUp: true,
                              enablePullDown: false);
                        }))),
            Obx(() => _commentsController.replyingComment.value == null
                ? Container()
                : Container(
                    color: AppColorConstants.cardColor,
                    child: Row(
                      children: [
                        BodySmallText(
                          '${replyingToString.tr} ${_commentsController.replyingComment.value!.userName}',
                          weight: TextWeight.regular,
                        ),
                        const Spacer(),
                        ThemeIconWidget(ThemeIcon.close).ripple(() {
                          _commentsController.setReplyComment(null);
                        })
                      ],
                    ).setPadding(
                        left: DesignConstants.horizontalPadding,
                        right: DesignConstants.horizontalPadding,
                        top: 12,
                        bottom: 12),
                  )),
            buildMessageTextField(),
            const SizedBox(height: 20)
          ],
        ));
  }

  Widget buildMessageTextField() {
    return Container(
      height: 50.0,
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              color: AppColorConstants.cardColor.withValues(alpha: 0.5),
              child: Row(children: <Widget>[
                Expanded(
                  child: SizedBox(
                    height: 100,
                    child: Obx(() {
                      commentInputField.value = TextEditingValue(
                          text: _smartTextFieldController.searchText.value,
                          selection: TextSelection.fromPosition(
                              TextPosition(
                                  offset: _smartTextFieldController
                                      .position.value)));

                      return SmartTextField(
                          maxLine: 1,
                          controller: commentInputField,
                          onTextChangeActionHandler: (text, offset) {
                            _smartTextFieldController.textChanged(
                                text, offset);
                          },
                          onFocusChangeActionHandler: (status) {
                            if (status == true) {
                              _smartTextFieldController.startedEditing();
                            } else {
                              _smartTextFieldController.stoppedEditing();
                            }
                          });
                    }),
                  ),
                ),
                ThemeIconWidget(
                  ThemeIcon.camera,
                  color: AppColorConstants.mainTextColor,
                ).rP8.ripple(
                    () => _commentsController.selectPhoto(handler: () {
                          _commentsController.postMediaCommentsApiCall(
                              type: CommentType.image,
                              postId: widget.postId ?? widget.model!.id,
                              commentPosted: () {
                                widget.commentPostedCallback();
                              });
                        })),
                ThemeIconWidget(
                  ThemeIcon.gif,
                  color: AppColorConstants.mainTextColor,
                ).rP8.ripple(() {
                  commentInputField.text = '';
                  _commentsController.openGify(() {
                    _commentsController.postMediaCommentsApiCall(
                        type: CommentType.gif,
                        postId: widget.postId ?? widget.model!.id,
                        commentPosted: () {
                          widget.commentPostedCallback();
                        });
                  });
                }),
              ]).hP8,
            ).borderWithRadius(value: 0.5, radius: 15),
          ),
          const SizedBox(width: 20),
          Container(
            width: 45,
            height: 45,
            color: AppColorConstants.mainTextColor,
            child: InkWell(
              onTap: addNewMessage,
              child: Icon(
                Icons.send,
                color: AppColorConstants.themeColor,
              ),
            ),
          ).circular
        ],
      ),
    );
  }

  void addNewMessage() {
    if (commentInputField.text.trim().isNotEmpty) {
      final filter = ProfanityFilter();
      bool hasProfanity = filter.hasProfanity(commentInputField.text);
      if (hasProfanity) {
        AppUtil.showToast(
            message: notAllowedMessageString.tr, isSuccess: true);
        return;
      }

      _commentsController.postCommentsApiCall(
          comment: commentInputField.text.trim(),
          postId: widget.postId ?? widget.model!.id,
          commentPosted: () {
            widget.commentPostedCallback();
          });
      commentInputField.text = '';
    }
  }
}

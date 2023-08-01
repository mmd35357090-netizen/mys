import 'dart:async';
import 'package:foap/helper/imports/common_import.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../components/comment_card.dart';
import '../../components/hashtag_tile.dart';
import '../../components/user_card.dart';
import '../../controllers/post/comments_controller.dart';
import '../../model/post_model.dart';

class CommentsScreen extends StatefulWidget {
  final PostModel? model;
  final int? postId;
  final bool? isPopup;
  final VoidCallback? handler;
  final VoidCallback commentPostedCallback;

  const CommentsScreen(
      {Key? key,
      this.model,
      this.postId,
      this.handler,
      this.isPopup,
      required this.commentPostedCallback})
      : super(key: key);

  @override
  CommentsScreenState createState() => CommentsScreenState();
}

class CommentsScreenState extends State<CommentsScreen> {
  TextEditingController commentInputField = TextEditingController();
  final ScrollController _controller = ScrollController();
  final CommentsController _commentsController = CommentsController();
  final RefreshController _commentsRefreshController =
      RefreshController(initialRefresh: false);
  final RefreshController _usersRefreshController =
      RefreshController(initialRefresh: false);
  final RefreshController _hashtagRefreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
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
    return Container(
        color: AppColorConstants.backgroundColor.lighten(0.02),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: widget.isPopup == true ? 0 : 50,
            ),
            backNavigationBar(title: commentsString.tr),
            Obx(() => _commentsController.hashTags.isNotEmpty ||
                    _commentsController.searchedUsers.isNotEmpty
                ? Expanded(
                    child: Container(
                      // height: 500,
                      width: double.infinity,
                      color: AppColorConstants.disabledColor,
                      child: _commentsController.hashTags.isNotEmpty
                          ? hashTagView()
                          : _commentsController.searchedUsers.isNotEmpty
                              ? usersView()
                              : Container(),
                    ),
                  )
                : Flexible(
                    child: GetBuilder<CommentsController>(
                        init: _commentsController,
                        builder: (ctx) {
                          return ListView.separated(
                            padding:  EdgeInsets.only(
                                top: 20, left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding),
                            itemCount: _commentsController.comments.length,
                            // reverse: true,
                            controller: _controller,
                            itemBuilder: (context, index) {
                              return CommentTile(
                                  model: _commentsController.comments[index]);
                            },
                            separatorBuilder: (ctx, index) {
                              return const SizedBox(
                                height: 20,
                              );
                            },
                          ).addPullToRefresh(
                              refreshController: _commentsRefreshController,
                              onRefresh: () {},
                              onLoading: () {
                                loadData();
                              },
                              enablePullUp: true,
                              enablePullDown: false);
                        }))),
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
              color: AppColorConstants.cardColor.withOpacity(0.5),
              child: Row(children: <Widget>[
                Expanded(
                  child: Obx(() {
                    TextEditingValue(
                        text: _commentsController.searchText.value,
                        selection: TextSelection.fromPosition(TextPosition(
                            offset: _commentsController.position.value)));

                    return TextField(
                      controller: commentInputField,
                      onChanged: (text) {
                        _commentsController.textChanged(
                            text, commentInputField.selection.baseOffset);
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: writeCommentString.tr,
                        hintStyle: TextStyle(
                            fontSize: FontSizes.b2,
                            color: AppColorConstants.grayscale700),
                      ),
                      textInputAction: TextInputAction.send,
                      style: TextStyle(
                          fontSize: FontSizes.b2,
                          color: AppColorConstants.grayscale900),
                      onSubmitted: (_) {
                        addNewMessage();
                      },
                      onTap: () {
                        Timer(
                            const Duration(milliseconds: 300),
                            () => _controller
                                .jumpTo(_controller.position.maxScrollExtent));
                      },
                    );
                  }),
                ),
                ThemeIconWidget(
                  ThemeIcon.camera,
                  color: AppColorConstants.grayscale900,
                ).rP8.ripple(() => _commentsController.selectPhoto(handler: () {
                      _commentsController.postMediaCommentsApiCall(
                          type: CommentType.image,
                          postId: widget.postId ?? widget.model!.id,
                          commentPosted: () {
                            widget.commentPostedCallback();
                          });
                      Timer(
                          const Duration(milliseconds: 500),
                          () => _controller
                              .jumpTo(_controller.position.maxScrollExtent));
                    })),
                ThemeIconWidget(
                  ThemeIcon.gif,
                  color: AppColorConstants.grayscale900,
                ).rP8.ripple(() {
                  commentInputField.text = '';
                  _commentsController.openGify(() {
                    _commentsController.postMediaCommentsApiCall(
                        type: CommentType.gif,
                        postId: widget.postId ?? widget.model!.id,
                        commentPosted: () {
                          widget.commentPostedCallback();
                        });
                    Timer(
                        const Duration(milliseconds: 500),
                        () => _controller
                            .jumpTo(_controller.position.maxScrollExtent));
                  });
                }),
              ]).hP8,
            ).borderWithRadius(value: 0.5, radius: 15),
          ),
          const SizedBox(width: 20),
          Container(
            width: 45,
            height: 45,
            color: AppColorConstants.grayscale900,
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
        AppUtil.showToast(message: notAllowedMessageString.tr, isSuccess: true);
        return;
      }

      _commentsController.postCommentsApiCall(
          comment: commentInputField.text.trim(),
          postId: widget.postId ?? widget.model!.id,
          commentPosted: () {
            widget.commentPostedCallback();
          });
      commentInputField.text = '';
      // widget.model?.totalComment = comments.length;

      Timer(const Duration(milliseconds: 500),
          () => _controller.jumpTo(_controller.position.maxScrollExtent));
    }
  }

  usersView() {
    return GetBuilder<CommentsController>(
        init: _commentsController,
        builder: (ctx) {
          return ListView.separated(
              padding:  EdgeInsets.only(top: 20, left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding),
              itemCount: _commentsController.searchedUsers.length,
              itemBuilder: (BuildContext ctx, int index) {
                return UserTile(
                  profile: _commentsController.searchedUsers[index],
                  viewCallback: () {
                    _commentsController.addUserTag(
                        _commentsController.searchedUsers[index].userName);
                  },
                );
              },
              separatorBuilder: (BuildContext ctx, int index) {
                return const SizedBox(
                  height: 20,
                );
              }).addPullToRefresh(
              refreshController: _usersRefreshController,
              onRefresh: () {},
              onLoading: () {
                _commentsController.searchUsers(
                    text: _commentsController.currentUserTag.value);
              },
              enablePullUp: true,
              enablePullDown: false);
        });
  }

  hashTagView() {
    return GetBuilder<CommentsController>(
        init: _commentsController,
        builder: (ctx) {
          return ListView.builder(
            padding:  EdgeInsets.only(left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding),
            itemCount: _commentsController.hashTags.length,
            itemBuilder: (BuildContext ctx, int index) {
              return HashTagTile(
                hashtag: _commentsController.hashTags[index],
                onItemCallback: () {
                  _commentsController
                      .addHashTag(_commentsController.hashTags[index].name);
                },
              );
            },
          ).addPullToRefresh(
              refreshController: _hashtagRefreshController,
              onRefresh: () {},
              onLoading: () {
                _commentsController.searchHashTags(
                    text: _commentsController.currentHashtag.value);
              },
              enablePullUp: true,
              enablePullDown: false);
        });
  }
}

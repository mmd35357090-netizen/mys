import 'dart:async';
import 'package:foap/controllers/fund_raising/fund_raising_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../components/post_card/comment_card.dart';

class CampaignCommentsScreen extends StatefulWidget {
  const CampaignCommentsScreen({
    super.key,
  }) ;

  @override
  CampaignCommentsScreenState createState() => CampaignCommentsScreenState();
}

class CampaignCommentsScreenState extends State<CampaignCommentsScreen> {
  TextEditingController commentInputField = TextEditingController();
  final ScrollController _controller = ScrollController();
  final FundRaisingController _fundraisingController = Get.find();

  final RefreshController _commentsRefreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  dispose() {
    super.dispose();
  }

  loadData() {
    _fundraisingController.getComments(() {
      _commentsRefreshController.loadComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: AppColorConstants.backgroundColor.lighten(0.02),
        child: Column(
          children: <Widget>[
            Expanded(
              child: GetBuilder<FundRaisingController>(
                  init: _fundraisingController,
                  builder: (ctx) {
                    return ListView.separated(
                      padding: EdgeInsets.only(
                          top: 20,
                          left: DesignConstants.horizontalPadding,
                          right: DesignConstants.horizontalPadding),
                      itemCount: _fundraisingController.comments.length,
                      controller: _controller,
                      itemBuilder: (context, index) {
                        return CommentTile(
                          model: _fundraisingController.comments[index],
                          replyActionHandler: (comment) {
                            _fundraisingController.setReplyComment(comment);
                          },
                          deleteActionHandler: (comment) {
                            _fundraisingController.deleteComment(
                              comment: comment,
                            );
                          },
                          favActionHandler: (comment) {
                            _fundraisingController.favUnfavComment(
                              comment: comment,
                            );
                          },
                          reportActionHandler: (comment) {
                            _fundraisingController.reportComment(
                              commentId: comment.id,
                            );
                          },
                          loadMoreChildCommentsActionHandler: (comment) {
                            _fundraisingController.getChildComments(
                              page: comment.currentPageForReplies,
                              parentId: comment.id,
                              refId: _fundraisingController
                                  .currentCampaign.value!.id,
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
                        refreshController: _commentsRefreshController,
                        onRefresh: () {},
                        onLoading: () {
                          loadData();
                        },
                        enablePullUp: true,
                        enablePullDown: false);
                  }),
            ),
            Obx(() => _fundraisingController.replyingComment.value == null
                ? Container()
                : Container(
                    color: AppColorConstants.cardColor,
                    child: Row(
                      children: [
                        BodySmallText(
                          '${replyingToString.tr} ${_fundraisingController.replyingComment.value!.userName}',
                          weight: TextWeight.regular,
                        ),
                        const Spacer(),
                        ThemeIconWidget(ThemeIcon.close).ripple(() {
                          _fundraisingController.setReplyComment(null);
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
            child: TextField(
              controller: commentInputField,
              onChanged: (text) {},
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: writeCommentString.tr,
                hintStyle: TextStyle(
                    fontSize: FontSizes.b2,
                    color: AppColorConstants.mainTextColor),
              ),
              textInputAction: TextInputAction.send,
              style: TextStyle(
                  fontSize: FontSizes.b2,
                  color: AppColorConstants.mainTextColor),
              onSubmitted: (_) {
                addNewMessage();
              },
              onTap: () {
                Timer(
                    const Duration(milliseconds: 300),
                    () => _controller
                        .jumpTo(_controller.position.maxScrollExtent));
              },
            ).hP8.borderWithRadius(value: 0.5, radius: 15),
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
        AppUtil.showToast(message: notAllowedMessageString.tr, isSuccess: true);
        return;
      }

      _fundraisingController.postComment(
        commentInputField.text.trim(),
      );
      commentInputField.text = '';
      FocusScope.of(context).requestFocus(FocusNode());

      Timer(const Duration(milliseconds: 500),
          () => _controller.jumpTo(_controller.position.maxScrollExtent));
    }
  }
}

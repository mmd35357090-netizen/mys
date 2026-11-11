import 'dart:async';
import 'package:foap/helper/imports/common_import.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../components/post_card/comment_card.dart';
import '../../controllers/coupons/near_by_offers.dart';

class OfferCommentsScreen extends StatefulWidget {
  const OfferCommentsScreen({
    super.key,
  }) ;

  @override
  OfferCommentsScreenState createState() => OfferCommentsScreenState();
}

class OfferCommentsScreenState extends State<OfferCommentsScreen> {
  TextEditingController commentInputField = TextEditingController();
  final ScrollController _controller = ScrollController();
  final NearByOffersController _nearByOffersController = Get.find();
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
    _nearByOffersController.getOfferComments(() {
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
              child: GetBuilder<NearByOffersController>(
                  init: _nearByOffersController,
                  builder: (ctx) {
                    return ListView.separated(
                      padding: EdgeInsets.only(
                          top: 20,
                          left: DesignConstants.horizontalPadding,
                          right: DesignConstants.horizontalPadding),
                      itemCount: _nearByOffersController.comments.length,
                      // reverse: true,
                      controller: _controller,
                      itemBuilder: (context, index) {
                        return CommentTile(
                          model: _nearByOffersController.comments[index],
                          replyActionHandler: (comment) {
                            _nearByOffersController.setReplyComment(comment);
                          },
                          deleteActionHandler: (comment) {
                            _nearByOffersController.deleteComment(
                              comment: comment,
                            );
                          },
                          favActionHandler: (comment) {
                            _nearByOffersController.favUnfavComment(
                              comment: comment,
                            );
                          },
                          reportActionHandler: (comment) {
                            _nearByOffersController.reportComment(
                              commentId: comment.id,
                            );
                          },
                          loadMoreChildCommentsActionHandler: (comment) {
                            _nearByOffersController.getChildComments(
                              page: comment.currentPageForReplies,
                              offerId: _nearByOffersController
                                  .currentOffer.value!.id,
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
                        refreshController: _commentsRefreshController,
                        onRefresh: () {},
                        onLoading: () {
                          loadData();
                        },
                        enablePullUp: true,
                        enablePullDown: false);
                  }),
            ),
            Obx(() => _nearByOffersController.replyingComment.value == null
                ? Container()
                : Container(
                    color: AppColorConstants.cardColor,
                    child: Row(
                      children: [
                        BodySmallText(
                          '${replyingToString.tr} ${_nearByOffersController.replyingComment.value!.userName}',
                          weight: TextWeight.regular,
                        ),
                        const Spacer(),
                        ThemeIconWidget(ThemeIcon.close).ripple(() {
                          _nearByOffersController.setReplyComment(null);
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
      height: 54.0,
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
      padding: const EdgeInsets.only(left: 6, right: 6),
      decoration: BoxDecoration(
        color: AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
            color: AppColorConstants.dividerColor.withValues(alpha: 0.5),
            width: 0.6),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: commentInputField,
              onChanged: (text) {},
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                hintText: writeCommentString.tr,
                hintStyle: TextStyle(
                    fontSize: FontSizes.b2,
                    color: AppColorConstants.subHeadingTextColor),
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
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [
                AppColorConstants.themeColor,
                AppColorConstants.themeColor.withValues(alpha: 0.75)
              ]),
            ),
            child: InkWell(
              onTap: addNewMessage,
              child: const Icon(
                Icons.send_rounded,
                size: 19,
                color: Colors.white,
              ),
            ),
          )
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

      _nearByOffersController.postOfferComment(
        commentInputField.text.trim(),
      );
      commentInputField.text = '';
      FocusScope.of(context).requestFocus(FocusNode());

      Timer(const Duration(milliseconds: 500),
          () => _controller.jumpTo(_controller.position.maxScrollExtent));
    }
  }
}

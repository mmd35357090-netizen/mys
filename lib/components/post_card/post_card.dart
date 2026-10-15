import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:foap/components/post_card/poll_post_tile.dart';
import 'package:foap/components/post_card/post_user_info.dart';
import 'package:foap/components/post_card/reshared_post_card.dart';
import 'package:foap/components/post_card/post_text_widget.dart';
import 'package:foap/components/post_card/share_post.dart';
import 'package:foap/controllers/clubs/clubs_controller.dart';
import 'package:foap/helper/imports/competition_imports.dart';
import 'package:foap/helper/imports/event_imports.dart';
import 'package:foap/screens/fund_raising/fund_raising_campaign_detail.dart';
import 'package:foap/screens/jobs_listing/job_detail.dart';
import 'package:foap/screens/near_by_offers/offer_detail.dart';
import 'package:foap/components/post_card/video_widget.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/post_imports.dart';
import 'package:foap/screens/shop_feature/home/ad_detail_screen.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../controllers/chat_and_call/chat_detail_controller.dart';
import '../../controllers/coupons/near_by_offers.dart';
import '../../controllers/fund_raising/fund_raising_controller.dart';
import '../../controllers/home/home_controller.dart';
import '../../controllers/post/comments_controller.dart';
import '../../screens/post/liked_by_users.dart';
import '../../controllers/post/promotion_controller.dart';
import '../../screens/chat/chat_detail.dart';
import '../../screens/club/club_detail.dart';
import '../../screens/home_feed/comments_screen.dart';
import '../../screens/live/gifts_list.dart';
import '../../screens/post/post_promotion/post_promotion.dart';
import '../../screens/post/view_post_insight.dart';
import '../../screens/profile/other_user_profile.dart';
import 'audio_tile.dart';
import 'classified_product_post_tile.dart';
import 'club_post_tile.dart';
import 'competition_post_tile.dart';
import 'event_post_tile.dart';
import 'fund_raising_campaign_tile.dart';
import 'job_post_tile.dart';
import 'offer_post_tile.dart';

class PostMediaTile extends StatelessWidget {
  final PostCardController postCardController = Get.find();
  final HomeController homeController = Get.find();

  final PostModel model;
  final bool isResharedPost;

  PostMediaTile(
      {super.key, required this.model, required this.isResharedPost});

  @override
  Widget build(BuildContext context) {
    return mediaTile();
  }

  Widget mediaTile() {
    if (model.gallery.length > 1) {
      return SizedBox(
        height: 350,
        child: Stack(
          children: [
            WKCarouselSlider(
              items: mediaList(isResharedPost),
              // aspectRatio: 1,
              enlargeCenterPage: false,
              enableInfiniteScroll: false,
              height: double.infinity,
              viewportFraction: 1,
              onPageChanged: (index) {
                postCardController.updateGallerySlider(index, model.id);
              },
            ),
            Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: Obx(
                    () {
                      return WKIndicator1(
                        dotsCount: model.gallery.length,
                        position: (postCardController
                                .postScrollIndexMapping[model.id] ??
                            0),
                        activeDotColor: AppColorConstants.themeColor,
                        dotColor: AppColorConstants.disabledColor,
                      );
                    },
                  ),
                ))
          ],
        ),
      );
    } else {
      return model.contentType == PostContentType.media
          ? model.gallery.first.isVideoPost == true
              ? videoPostTile(
                  media: model.gallery.first, isReshared: isResharedPost)
              : model.gallery.first.isAudioPost
                  ? AudioPostTile(
                      post: model,
                      isResharedPost: isResharedPost,
                    )
                  : photoPostTile(model.gallery.first)
          : model.contentType == PostContentType.event
              ? EventPostTile(
                  post: model,
                  isResharedPost: isResharedPost,
                )
              : model.contentType == PostContentType.competitionAdded ||
                      model.contentType ==
                          PostContentType.competitionResultDeclared
                  ? CompetitionPostTile(
                      post: model,
                      isResharedPost: isResharedPost,
                    )
                  : model.contentType == PostContentType.fundRaising
                      ? FundRaisingCampaignPostTile(
                          post: model,
                          isResharedPost: isResharedPost,
                        )
                      : model.contentType == PostContentType.job
                          ? JobPostTile(
                              post: model,
                              isResharedPost: isResharedPost,
                            )
                          : model.contentType == PostContentType.offer
                              ? OfferPostTile(
                                  post: model,
                                  isResharedPost: isResharedPost,
                                )
                              : model.contentType ==
                                      PostContentType.classified
                                  ? ClassifiedProductPostTile(
                                      post: model,
                                      isResharedPost: isResharedPost,
                                    )
                                  : model.contentType ==
                                          PostContentType.donation
                                      ? FundRaisingCampaignPostTile(
                                          post: model,
                                          isResharedPost: isResharedPost,
                                        )
                                      : model.contentType ==
                                              PostContentType.club
                                          ? ClubPostTile(
                                              post: model,
                                              isResharedPost:
                                                  isResharedPost,
                                            )
                                          : model.contentType ==
                                                  PostContentType.poll
                                              ? PollPostTile(
                                                  post: model,
                                                  isResharedPost:
                                                      isResharedPost,
                                                )
                                              : Container();
    }
  }

  List<Widget> mediaList(bool isReshared) {
    return model.gallery.map((item) {
      if (item.isVideoPost == true) {
        return videoPostTile(media: item, isReshared: isReshared);
      } else {
        return photoPostTile(item);
      }
    }).toList();
  }

  Widget videoPostTile(
      {required PostGallery media, required bool isReshared}) {
    return VisibilityDetector(
      key: Key(media.id.toString()),
      onVisibilityChanged: (visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        homeController.setCurrentVisibleVideo(
            media: media, visibility: visiblePercentage);
      },
      child: Obx(() => VideoPostTile(
            media: media,
            width: isReshared
                ? Get.width -
                    ((DesignConstants.horizontalPadding * 3) + 10)
                : Get.width,
            url: media.filePath,
            isLocalFile: false,
            play: homeController.currentVisibleVideoId.value == media.id,
            onTapActionHandler: () {},
          )),
    );
  }

  Widget photoPostTile(PostGallery media) {
    return CachedNetworkImage(
      imageUrl: media.filePath,
      fit: BoxFit.cover,
      width: Get.width,
      placeholder: (context, url) =>
          AppUtil.addProgressIndicator(size: 100),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}

class PostContent extends StatelessWidget {
  final PostModel model;
  final PostCardController postCardController = Get.find();

  final FlareControls flareControls = FlareControls();

  final bool isSponsored;

  PostContent({
    super.key,
    required this.model,
    required this.isSponsored,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
            onDoubleTap: () {
              if (!model.isLocked) {
                postCardController.likeUnlikePost(post: model);
                flareControls.play("like");
              }
            },
            child: Stack(
              children: [
                if (!model.isLocked)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (model.postTitle.isNotEmpty)
                        RichTextPostTitle(model: model).setPadding(
                            left: DesignConstants.horizontalPadding / 2,
                            right: DesignConstants.horizontalPadding / 2,
                            bottom: 25),
                      PostMediaTile(
                        model: model,
                        isResharedPost: model.sharedPost != null,
                      ),
                      if (model.sharedPost != null)
                        ResharedPostCard(model: model.sharedPost!)
                            .setPadding(
                                left: DesignConstants.horizontalPadding,
                                right: 10,
                                top: 5,
                                bottom: 15),
                    ],
                  ),
                if (!model.isLocked)
                  Obx(() => Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: Center(
                              child: SizedBox(
                                width: 80,
                                height: 80,
                                child: FlareActor(
                                  'assets/like.flr',
                                  controller: flareControls,
                                  animation: 'idle',
                                  color: postCardController.likedPosts
                                              .contains(model) ||
                                          model.isLike
                                      ? Colors.red
                                      : Colors.white,
                                ),
                              ),
                            )),
                      )),
                if (model.isLocked)
                  Container(
                    height: 350,
                    width: double.infinity,
                    color: AppColorConstants.themeColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ThemeIconWidget(
                          ThemeIcon.lock,
                          color: Colors.white,
                          size: 150,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Heading5Text(
                          subscribeToViewThisContentString.tr.replaceAll(
                              '{{userName}}', model.user.userName),
                          color: Colors.white,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ).ripple(() {
                    Get.to(OtherUserProfile(
                        userId: model.user.id, user: model.user));
                  })
              ],
            )),
      ],
    );
  }

  void openClubDetail() async {
    Get.to(() => ClubDetail(
        club: model.postedInClub!,
        needRefreshCallback: () {},
        deleteCallback: (club) {}));
  }
}

class PostCard extends StatefulWidget {
  final PostModel model;

  final VoidCallback removePostHandler;
  final VoidCallback blockUserHandler;

  const PostCard({
    super.key,
    required this.model,
    required this.removePostHandler,
    required this.blockUserHandler,
  });

  @override
  PostCardState createState() => PostCardState();
}

class PostCardState extends State<PostCard> {
  final HomeController homeController = Get.find();
  final PostCardController postCardController = Get.find();
  final ChatDetailController chatDetailController = Get.find();

  final PromotionController _promotionController = Get.find();
  final ChatDetailController _chatDetailController = Get.find();

  TextEditingController commentInputField = TextEditingController();
  final CommentsController _commentsController = CommentsController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
        key: Key(widget.model.id.toString()),
        onVisibilityChanged: (visibilityInfo) {
          var visiblePercentage = visibilityInfo.visibleFraction * 100;
          if (visiblePercentage >= 80) {
            postCardController.postView(
                postId: widget.model.id,
                source: widget.model.postPromotionData != null
                    ? ItemViewSource.promotion
                    : ItemViewSource.normal,
                postPromotionId: widget.model.postPromotionData?.id);
          }
        },
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: PostUserInfo(
                    post: widget.model,
                    isSponsored: widget.model.postPromotionData != null,
                    removePostHandler: widget.removePostHandler,
                    blockUserHandler: widget.blockUserHandler,
                    isResharedPost: false,
                  )),
                ],
              ).setPadding(
                  left: DesignConstants.horizontalPadding / 2,
                  right: DesignConstants.horizontalPadding / 2,
                  bottom: 16),
              PostContent(
                model: widget.model,
                isSponsored: widget.model.postPromotionData != null,
              ),
              if (widget.model.isMyPost)
                Container(
                  color: AppColorConstants.cardColor.darken(),
                  height: 50,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BodyLargeText(
                        viewInsightsString.tr,
                        weight: TextWeight.semiBold,
                      ).ripple(() {
                        Get.to(() => ViewPostInsights(post: widget.model));
                      }),
                      AppThemeButton(
                          text: boostPost.tr,
                          cornerRadius: 5,
                          height: 36,
                          onPress: () {
                            _promotionController
                                .setPromotingPost(widget.model);
                            Get.to(() => PostPromotionScreen());
                          })
                    ],
                  ).hp(DesignConstants.horizontalPadding),
                ),
              if (!widget.model.isMyPost &&
                  widget.model.isPendingCollaborationRequest)
                Container(
                  color: AppColorConstants.cardColor.darken(),
                  height: 50,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BodyLargeText(
                        collaborationRequestString.tr,
                        weight: TextWeight.semiBold,
                      ),
                      Row(
                        children: [
                          AppThemeButton(
                              text: acceptString.tr,
                              cornerRadius: 5,
                              height: 36,
                              onPress: () {
                                AddPostController controller = Get.find();
                                controller.updateCollaborationStatus(
                                    id: widget.model.myCollaboration.id,
                                    status:
                                        CollaborationStatusType.accepted);
                                setState(() {
                                  widget.model.acceptMyCollaboration();
                                });
                              }),
                          const SizedBox(
                            width: 5,
                          ),
                          AppThemeButton(
                              backgroundColor: AppColorConstants.red,
                              text: rejectString.tr,
                              cornerRadius: 5,
                              height: 36,
                              onPress: () {
                                setState(() {
                                  widget.model.removeMyCollaboration();
                                });
                                AddPostController controller = Get.find();
                                controller.updateCollaborationStatus(
                                    id: widget.model.myCollaboration.id,
                                    status:
                                        CollaborationStatusType.rejected);
                              })
                        ],
                      )
                    ],
                  ).hp(DesignConstants.horizontalPadding),
                ),
              const SizedBox(
                height: 20,
              ),
              if (widget.model.postPromotionData != null)
                sponsoredPostView().bP16,
              commentAndLikeWidget()
                  .hp(DesignConstants.horizontalPadding / 2),
            ]));
  }

  Widget sponsoredPostView() {
    return Container(
      color: AppColorConstants.themeColor,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BodyLargeText(
              widget.model.postPromotionData?.type == GoalType.website
                  ? widget.model.postPromotionData!.urlText!
                  : widget.model.postPromotionData?.type ==
                          GoalType.message
                      ? sendMessagesString.tr
                      : viewProfileString.tr,
              color: Colors.white,
              weight: TextWeight.semiBold,
            ),
            ThemeIconWidget(ThemeIcon.nextArrow,
                size: 25, color: Colors.white)
          ]).p8.ripple(() {
        widget.model.postPromotionData?.type == GoalType.website
            ? launchUrl(
                Uri.parse(widget.model.postPromotionData?.url ?? ''))
            : widget.model.postPromotionData?.type == GoalType.message
                ? openChatRoom()
                : Get.to(() => OtherUserProfile(
                    userId: widget.model.user.id,
                    user: widget.model.user));
      }),
    );
  }

  Widget commentAndLikeWidget() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Obx(() => ThemeIconWidget(
                    postCardController.likedPosts.contains(widget.model) ||
                            widget.model.isLike
                        ? ThemeIcon.favFilled
                        : ThemeIcon.fav,
                    color: postCardController.likedPosts
                                .contains(widget.model) ||
                            widget.model.isLike
                        ? AppColorConstants.red
                        : AppColorConstants.iconColor,
                    size: 15,
                  ).ripple(() {
                    postCardController.likeUnlikePost(
                      post: widget.model,
                    );
                  })),
              const SizedBox(
                width: 5,
              ),
              Obx(() {
                int totalLikes = 0;
                if (postCardController.likedPosts.contains(widget.model)) {
                  PostModel post = postCardController.likedPosts
                      .where((e) => e.id == widget.model.id)
                      .first;
                  totalLikes = post.totalLike;
                } else {
                  totalLikes = widget.model.totalLike;
                }
                return BodyMediumText(
                  '$totalLikes',
                  color: AppColorConstants.mainTextColor,
                ).ripple(() {
                  Get.to(() => LikedByUsers(
                        postId: widget.model.id,
                      ));
                });
              }),
            ],
          ),
          if (widget.model.commentsEnabled)
            Row(
              children: [
                ThemeIconWidget(
                  ThemeIcon.message,
                  size: 15,
                ),
                const SizedBox(
                  width: 5,
                ),
                BodyMediumText(
                  '${widget.model.totalComment}',
                  color: AppColorConstants.mainTextColor,
                ).ripple(() {
                  openComments();
                }),
              ],
            ).ripple(() {
              openComments();
            }),
          Row(
            children: [
              ThemeIconWidget(
                ThemeIcon.eye,
                size: 15,
              ),
              const SizedBox(
                width: 5,
              ),
              BodyMediumText(
                '${widget.model.totalView}',
                // weight: TextWeight.semiBold,
                color: AppColorConstants.mainTextColor,
              ),
            ],
          ),
          if (widget.model.sharedPost == null)
            Row(
              children: [
                ThemeIconWidget(
                  ThemeIcon.share,
                  size: 15,
                ),
                const SizedBox(
                  width: 5,
                ),
                BodyMediumText(
                  '${widget.model.totalShare}',
                  color: AppColorConstants.mainTextColor,
                )
              ],
            ).ripple(() {
              showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => FractionallySizedBox(
                      heightFactor: 0.95,
                      child: SharePost(post: widget.model)));
            }),
          if (!widget.model.isMyPost &&
              widget.model.user.role != UserRole.admin)
            Row(
              children: [
                ThemeIconWidget(
                  ThemeIcon.gift,
                  size: 15,
                ),
              ],
            ).ripple(() {
              showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return FractionallySizedBox(
                        heightFactor: 0.8,
                        child:
                            GiftsPageView(giftSelectedCompletion: (gift) {
                          Get.back();
                          homeController.sendPostGift(
                              gift, widget.model.user.id, widget.model.id);
                        }));
                  });
            }),

          if (widget.model.contentType == PostContentType.event)
            Row(
              children: [
                ThemeIconWidget(
                  ThemeIcon.event,
                  size: 15,
                ),
                const SizedBox(
                  width: 5,
                ),
                BodyMediumText(!widget.model.event!.isCompleted &&
                        !widget.model.event!.isTicketBooked
                    ? bookNow.tr
                    : viewString.tr)
              ],
            ).ripple(() {
              Get.to(() => EventDetail(
                  event: widget.model.event!, needRefreshCallback: () {}));
            }),
          if (widget.model.contentType == PostContentType.competitionAdded)
            Row(
              children: [
                ThemeIconWidget(
                  ThemeIcon.event,
                  size: 15,
                ),
                const SizedBox(
                  width: 5,
                ),
                BodyMediumText(widget.model.competition!.isPast ||
                        widget.model.competition!.isJoined
                    ? viewString.tr
                    : joinString.tr)
              ],
            ).ripple(() {
              Get.to(() => CompetitionDetailScreen(
                  competitionId: widget.model.competition!.id,
                  refreshPreviousScreen: () {}));
            }),
          if (widget.model.contentType ==
              PostContentType.competitionResultDeclared)
            Row(
              children: [
                ThemeIconWidget(
                  ThemeIcon.event,
                  size: 15,
                ),
                const SizedBox(
                  width: 5,
                ),
                BodyMediumText(viewResultString.tr)
              ],
            ).ripple(() {
              Get.to(() => CompetitionDetailScreen(
                  competitionId: widget.model.competition!.id,
                  refreshPreviousScreen: () {}));
            }),
          if (widget.model.contentType == PostContentType.fundRaising)
            Row(
              children: [
                ThemeIconWidget(
                  ThemeIcon.event,
                  size: 15,
                ),
                const SizedBox(
                  width: 5,
                ),
                BodyMediumText(donateNowString.tr)
              ],
            ).ripple(() {
              final FundRaisingController fundRaisingController =
                  Get.find();

              fundRaisingController
                  .setCurrentCampaign(widget.model.fundRaisingCampaign!);
              Get.to(() => FundRaisingCampaignDetail(
                    campaign: widget.model.fundRaisingCampaign!,
                  ));
            }),
          if (widget.model.contentType == PostContentType.job)
            Row(
              children: [
                ThemeIconWidget(
                  ThemeIcon.event,
                  size: 15,
                ),
                const SizedBox(
                  width: 5,
                ),
                BodyMediumText(applyString.tr)
              ],
            ).ripple(() {
              Get.to(() => JobDetail(
                    job: widget.model.job!,
                  ));
            }),
          if (widget.model.contentType == PostContentType.offer)
            Row(
              children: [
                ThemeIconWidget(
                  ThemeIcon.event,
                  size: 15,
                ),
                const SizedBox(
                  width: 5,
                ),
                BodyMediumText(viewString.tr)
              ],
            ).ripple(() {
              final NearByOffersController nearByOffersController =
                  Get.find();
              nearByOffersController.setCurrentOffer(widget.model.offer!);
              Get.to(() => OfferDetail(
                    offer: widget.model.offer!,
                  ));
            }),
          if (widget.model.contentType == PostContentType.classified)
            if (widget.model.product?.isSold != true &&
                widget.model.product?.isDeleted != true)
              Row(
                children: [
                  ThemeIconWidget(
                    ThemeIcon.cart,
                    size: 15,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  BodyMediumText(buyString.tr)
                ],
              ).ripple(() {
                Get.to(() => AdDetailScreen(
                      widget.model.product!,
                    ));
              }),
          if (widget.model.contentType == PostContentType.donation)
            Row(
              children: [
                ThemeIconWidget(
                  ThemeIcon.event,
                  size: 15,
                ),
                const SizedBox(
                  width: 5,
                ),
                BodyMediumText(donateNowString.tr)
              ],
            ).ripple(() {
              final FundRaisingController fundRaisingController =
                  Get.find();

              fundRaisingController
                  .setCurrentCampaign(widget.model.fundRaisingCampaign!);
              Get.to(() => FundRaisingCampaignDetail(
                    campaign: widget.model.fundRaisingCampaign!,
                  ));
            }),
          if (widget.model.contentType == PostContentType.club)
            Row(
              children: [
                ThemeIconWidget(
                  ThemeIcon.event,
                  size: 15,
                ),
                const SizedBox(
                  width: 5,
                ),
                BodyMediumText(widget.model.createdClub!.isJoined == true
                    ? viewString.tr
                    : joinString.tr)
              ],
            ).ripple(() {
              ClubsController clubController = Get.find();
              clubController.getClubDetail(widget.model.createdClub!.id!,
                  (club) {
                Get.to(() => ClubDetail(
                      club: club,
                      needRefreshCallback: () {},
                      deleteCallback: (club) {},
                    ));
              });
            })
        ]);
  }

  openChatRoom() {
    Loader.show(status: loadingString.tr);
    _chatDetailController.getChatRoomWithUser(
        userId: widget.model.user.id,
        callback: (room) {
          Loader.dismiss();
          Get.to(() => ChatDetail(
                chatRoom: room,
              ));
        });
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
          postId: widget.model.id,
          commentPosted: () {
            setState(() {
              widget.model.totalComment += 1;
            });
          });
      commentInputField.text = '';
    }
  }

  void openComments() {
    Get.to(() => CommentsScreen(
          isPopup: true,
          model: widget.model,
          commentPostedCallback: () {
            setState(() {
              widget.model.totalComment += 1;
            });
          },
        ));
    // showModalBottomSheet(
    //     backgroundColor: Colors.transparent,
    //     context: Get.context!,
    //     isScrollControlled: true,
    //     builder: (context) => FractionallySizedBox(
    //         heightFactor: 0.8,
    //         child: CommentsScreen(
    //           isPopup: true,
    //           model: widget.model,
    //           commentPostedCallback: () {
    //             setState(() {
    //               widget.model.totalComment += 1;
    //             });
    //           },
    //         ).round(40)));
  }
}

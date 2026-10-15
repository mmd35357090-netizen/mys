import 'package:chewie/chewie.dart';
import 'package:foap/components/post_card/share_post.dart';
import 'package:foap/components/user_card.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/reel_imports.dart';
import 'package:foap/helper/number_extension.dart';
import 'package:foap/screens/home_feed/comments_screen.dart';
import 'package:foap/screens/live/gifts_list.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../profile/other_user_profile.dart';

class ReelVideoPlayer extends StatefulWidget {
  final PostModel reel;

  const ReelVideoPlayer({
    super.key,
    required this.reel,
  });

  @override
  State<ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
  late Future<void> initializeVideoPlayerFuture;
  VideoPlayerController? videoPlayerController;
  late bool playVideo;
  final ReelsController _reelsController = Get.find();
  final UserFollowUnfollowBtnController _userFollowUnfollowBtnController =
      UserFollowUnfollowBtnController();

  @override
  void initState() {
    super.initState();
    _userFollowUnfollowBtnController.setUser(widget.reel.user);
    prepareVideo(url: widget.reel.gallery.first.filePath);
  }

  @override
  void didUpdateWidget(covariant ReelVideoPlayer oldWidget) {
    playVideo =
        _reelsController.currentViewingReel.value!.id == widget.reel.id;

    if (playVideo == true) {
      play();
    } else {
      pause();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder(
          future: initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            final size = MediaQuery.of(context).size;

            // calculate scale for aspect ratio widget
            var scale = videoPlayerController!.value.aspectRatio /
                size.aspectRatio;

            // check if adjustments are needed...
            if (videoPlayerController!.value.aspectRatio <
                size.aspectRatio) {
              scale = 1 / scale;
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return GestureDetector(
                  onLongPress: () {
                    pause();
                  },
                  onLongPressUp: () {
                    play();
                  },
                  child: VisibilityDetector(
                    key: Key(widget.reel.gallery.first.filePath),
                    onVisibilityChanged: (VisibilityInfo info) {
                      if (info.visibleFraction == 1.0) {
                        play();
                      } else if (info.visibleFraction < 0.4) {
                        pause();
                      }
                    },
                    child: Transform.scale(
                        scale: scale,
                        // Adjust the offset to cut from left and right
                        child: SizedBox(
                          key: PageStorageKey(
                              widget.reel.gallery.first.filePath),
                          child: Chewie(
                            key: PageStorageKey(
                                widget.reel.gallery.first.filePath),
                            controller: ChewieController(
                              allowFullScreen: false,
                              videoPlayerController:
                                  videoPlayerController!,
                              aspectRatio:
                                  videoPlayerController!.value.aspectRatio,

                              showOptions: false,
                              showControls: false,
                              autoInitialize: true,
                              looping: true,
                              autoPlay: false,

                              // allowMuting: true,
                              errorBuilder: (context, errorMessage) {
                                return Center(
                                  child: Text(
                                    errorMessage,
                                    style: const TextStyle(
                                        color: Colors.white),
                                  ),
                                );
                              },
                            ),
                          ),
                        )),
                  ));
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.0001),
                    // You can add more colors to customize the gradient
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black26,
                  ],
                ),
              ),
            )),
        Positioned(
            bottom: 25,
            left: DesignConstants.horizontalPadding,
            right: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.reel.isMyPost &&
                    widget.reel.user.role != UserRole.admin)
                  Column(
                    children: [
                      AppThemeButton(
                          width: 100,
                          height: 30,
                          text: sendGiftString.tr,
                          onPress: () {
                            showModalBottomSheet<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return FractionallySizedBox(
                                      heightFactor: 0.8,
                                      child: GiftsPageView(
                                          giftSelectedCompletion: (gift) {
                                        Get.back();
                                        _reelsController.sendPostGift(
                                            gift,
                                            widget.reel.user.id,
                                            widget.reel.id);
                                      }));
                                });
                          }),
                      const SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                Row(
                  children: [
                    UserAvatarView(
                      size: 25,
                      user: widget.reel.user,
                      hideOnlineIndicator: true,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    BodyLargeText(
                      widget.reel.user.userName,
                      weight: TextWeight.medium,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    if (widget.reel.user.followingStatus ==
                        FollowingStatus.notFollowing)
                      UserFollowUnfollowButton(
                        isSmallSized: true,
                        controller: _userFollowUnfollowBtnController,
                      )
                  ],
                ).ripple(() {
                  Get.to(
                      () => OtherUserProfile(userId: widget.reel.user.id));
                }),
                const SizedBox(
                  height: 10,
                ),
                if (widget.reel.postTitle.isNotEmpty)
                  Column(
                    children: [
                      BodyLargeText(
                        widget.reel.postTitle,
                        weight: TextWeight.medium,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                SizedBox(
                    width: Get.width * 0.5,
                    height: 25,
                    child: Row(
                      children: [
                        ThemeIconWidget(
                          ThemeIcon.music,
                          size: 15,
                          color: Colors.white,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          // width: Get.width * 0.5,
                          child: BodySmallText(
                            widget.reel.audio == null
                                ? originalAudioString.tr
                                : widget.reel.audio!.name,
                            weight: TextWeight.medium,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ).ripple(() {
                      if (widget.reel.audio != null) {
                        Get.to(() => ReelAudioDetail(
                              audio: widget.reel.audio!,
                            ));
                      }
                    }))
              ],
            )),
        Positioned(
            bottom: 25,
            right: DesignConstants.horizontalPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Column(
                      children: [
                        InkWell(
                            onTap: () {
                              _reelsController.likeUnlikeReel(
                                  post: widget.reel);
                              // widget.likeTapHandler();
                            },
                            child: ThemeIconWidget(
                              _reelsController.likedReels
                                          .contains(widget.reel) ||
                                      widget.reel.isLike
                                  ? ThemeIcon.favFilled
                                  : ThemeIcon.fav,
                              color: _reelsController.likedReels
                                          .contains(widget.reel) ||
                                      widget.reel.isLike
                                  ? AppColorConstants.red
                                  : Colors.white,
                            )),
                        const SizedBox(
                          height: 5,
                        ),
                        BodyMediumText(
                            '${_reelsController.currentViewingReel.value?.totalLike}',
                            color: Colors.white)
                        // }),
                      ],
                    )),
                const SizedBox(
                  height: 20,
                ),
                if (widget.reel.sharedPost == null)
                  Column(
                    children: [
                      ThemeIconWidget(
                        ThemeIcon.share,
                        size: 25,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      BodyMediumText(
                        '${widget.reel.totalShare}',
                        color: Colors.white,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ).ripple(() {
                    showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => FractionallySizedBox(
                            heightFactor: 0.95,
                            child: SharePost(post: widget.reel)));
                  }),
                if (widget.reel.commentsEnabled)
                  Column(
                    children: [
                      ThemeIconWidget(
                        ThemeIcon.message,
                        size: 25,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      BodyMediumText(
                        widget.reel.totalComment.formatNumber,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ).ripple(() {
                    openComments();
                  }),
                if (widget.reel.audio != null)
                  Column(
                    children: [
                      CachedNetworkImage(
                              height: 25,
                              width: 25,
                              imageUrl: widget.reel.audio!.thumbnail)
                          .borderWithRadius(value: 1, radius: 5)
                          .ripple(() {
                        if (widget.reel.audio != null) {
                          Get.to(() =>
                              ReelAudioDetail(audio: widget.reel.audio!));
                        }
                      }),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ThemeIconWidget(
                  ThemeIcon.moreVertical,
                  size: 25,
                  color: Colors.white,
                ).ripple(() {
                  openActionPopup();
                })
              ],
            ))
      ],
    );
  }

  prepareVideo({required String url}) {
    if (videoPlayerController != null) {
      videoPlayerController!.pause();
    }

    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(url));

    initializeVideoPlayerFuture =
        videoPlayerController!.initialize().then((_) {
      setState(() {});

      if (playVideo == true) {
        play();
      } else {
        pause();
      }
    });

    // videoPlayerController!.addListener(checkVideoProgress);
  }

  play() {
    videoPlayerController!.play().then((value) => {
          // videoPlayerController!.addListener(checkVideoProgress)
        });
  }

  openComments() {
    Get.bottomSheet(CommentsScreen(
      isPopup: true,
      model: widget.reel,
      commentPostedCallback: () {
        setState(() {
          widget.reel.totalComment += 1;
        });
      },
    ));
  }

  pause() {
    videoPlayerController!.pause();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // isFreeTimePlayed = true;
      });
    });
  }

  clear() {
    videoPlayerController!.pause();
    videoPlayerController!.dispose();
  }

  void openActionPopup() {
    Get.bottomSheet(Container(
      color: AppColorConstants.cardColor.darken(),
      child: widget.reel.user.isMe
          ? Wrap(
              children: [
                ListTile(
                    title: Center(
                        child: Heading6Text(
                      deleteString.tr,
                      weight: TextWeight.semiBold,
                    )),
                    onTap: () async {
                      Get.back();
                      _reelsController.deletePost(
                        post: widget.reel,
                      );
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
            )
          : Wrap(
              children: [
                ListTile(
                    title: Center(
                        child: Heading6Text(
                      reportString.tr,
                      weight: TextWeight.bold,
                    )),
                    onTap: () async {
                      Get.back();

                      AppUtil.showNewConfirmationAlert(
                        title: reportString.tr,
                        subTitle: areYouSureToReportPostString.tr,
                        okHandler: () {
                          _reelsController.reportPost(
                              post: widget.reel,
                              callback: () {
                                AppUtil.showToast(
                                    message:
                                        reelReportedSuccessfullyString.tr,
                                    isSuccess: true);
                              });
                        },
                        cancelHandler: () {
                          Get.back();
                        },
                      );
                    }),
                ListTile(
                    title: Center(
                        child: Heading6Text(blockUserString.tr,
                            weight: TextWeight.bold)),
                    onTap: () async {
                      Get.back();
                      AppUtil.showNewConfirmationAlert(
                        title: blockString.tr,
                        subTitle: areYouSureToBlockUserString.tr,
                        okHandler: () {
                          _reelsController.blockUser(
                              userId: widget.reel.user.id,
                              callback: () {
                                AppUtil.showToast(
                                    message:
                                        userBlockedSuccessfullyString.tr,
                                    isSuccess: true);
                              });
                        },
                        cancelHandler: () {
                          Get.back();
                        },
                      );
                    }),
                divider(),
                ListTile(
                    title: Center(
                      child: Heading6Text(
                        cancelString.tr,
                        weight: TextWeight.regular,
                        color: AppColorConstants.red,
                      ),
                    ),
                    onTap: () => Get.back()),
                const SizedBox(
                  height: 25,
                )
              ],
            ),
    ).round(40));
  }
}

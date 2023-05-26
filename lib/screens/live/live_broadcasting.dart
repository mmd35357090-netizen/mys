import 'package:animate_do/animate_do.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/number_extension.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'package:foap/helper/imports/live_imports.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wakelock/wakelock.dart';

import '../../components/user_card.dart';
import '../../controllers/gift_controller.dart';
import '../../controllers/subscription_packages_controller.dart';
import '../../model/call_model.dart';
import '../../model/chat_message_model.dart';
import '../../model/gift_model.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class LiveBroadcastScreen extends StatefulWidget {
  final Live live;

  const LiveBroadcastScreen({Key? key, required this.live}) : super(key: key);

  @override
  State<LiveBroadcastScreen> createState() => _LiveBroadcastScreenState();
}

class _LiveBroadcastScreenState extends State<LiveBroadcastScreen> {
  final AgoraLiveController _agoraLiveController = Get.find();
  final GiftController _giftController = GiftController();
  final SubscriptionPackageController packageController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    packageController.initiate();
    _giftController.loadMostUsedGifts();
    Wakelock.enable(); // Turn on wakelock feature till call is running
  }

  @override
  void dispose() {
    // _agoraLiveController.clear();
    super.dispose();
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Obx(
                () => _agoraLiveController.liveEnd.value == false
                    ? onLiveWidget()
                    : liveEndWidget(),
              ),
            ),
            Obx(() {
              return _agoraLiveController.sendingGift.value == null
                  ? Container()
                  : Positioned(
                      left: 0,
                      top: 0,
                      right: 0,
                      bottom: 0,
                      child: Pulse(
                        duration: const Duration(milliseconds: 500),
                        child: Center(
                          child: Image.network(
                            _agoraLiveController.sendingGift.value!.logo,
                            height: 80,
                            width: 80,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ));
            })
          ],
        ));
  }

  Widget askLiveEndConfirmation() {
    return Container(
      width: Get.width,
      height: Get.height,
      color: AppColorConstants.backgroundColor.withOpacity(0.8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Column(
          children: [
            const SizedBox(
              height: 400,
            ),
            Heading3Text(
              endLiveCallConfirmationString.tr,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: Get.width * 0.4,
                  child: AppThemeButton(
                    text: yesString.tr,
                    onPress: () {
                      _agoraLiveController.onCallEnd(isHost: true);
                      _agoraLiveController.loadGiftsReceived();
                    },
                  ),
                ),
                SizedBox(
                  width: Get.width * 0.4,
                  child: AppThemeButton(
                    enabledBackgroundColor: Colors.red,
                    text: noString.tr,
                    onPress: () {
                      _agoraLiveController.dontEndLiveCall();
                    },
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 50,
            )
          ],
        ).hP16,
      ),
    );
  }

  Widget onLiveWidget() {
    return Stack(
      children: [
        Center(
          child: widget.live.isHosting == true
              ? _renderLocalPreview()
              : _renderRemoteVideo(),
        ),
        topBar(context),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            children: [
              !widget.live.isHosting
                  ? Stack(
                      children: [
                        messagesListView(),
                        Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: defaultCoinsView()),
                      ],
                    )
                  : messagesListView(),
              messageComposerView()
            ],
          ),
        ),
        widget.live.isHosting ? _actionWidgetForHostUser() : Container(),
        _agoraLiveController.askLiveEndConformation.value == true
            ? Positioned(
                left: 0, right: 0, bottom: 0, child: askLiveEndConfirmation())
            : Container()
      ],
    );
  }

  Widget liveEndWidget() {
    return widget.live.isHosting
        ? liveEndWidgetForHosts()
        : liveEndWidgetForViewers();
  }

  Widget liveEndWidgetForViewers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 50,
        ),
        Row(
          children: [
            const ThemeIconWidget(
              ThemeIcon.close,
              size: 25,
              color: Colors.white,
            ).ripple(() {
              if (widget.live.isHosting) {
                _agoraLiveController.closeLive();
              } else {
                Get.back();
              }
            }),
            const Spacer()
          ],
        ),
        hostUserInfo(),
      ],
    ).hP16;
  }

  Widget liveEndWidgetForHosts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 50,
        ),
        Row(
          children: [
            const ThemeIconWidget(
              ThemeIcon.close,
              size: 25,
              color: Colors.white,
            ).ripple(() {
              if (widget.live.isHosting) {
                _agoraLiveController.closeLive();
              } else {
                Get.back();
              }
            }),
            const Spacer()
          ],
        ).hP16,
        const SizedBox(
          height: 20,
        ),
        Heading4Text(
          liveEndString.tr,
          weight: TextWeight.medium,
          color: Colors.white,
        ),
        Container(
          height: 5,
          width: 100,
          color: AppColorConstants.themeColor,
        ).round(10).tP8,
        const SizedBox(
          height: 40,
        ),
        liveStatisticsInfo().hP16,
        const SizedBox(
          height: 50,
        ),
        Expanded(child: giftersView())
      ],
    );
  }

  Widget liveStatisticsInfo() {
    return Container(
      width: Get.width / 1.4,
      color: AppColorConstants.cardColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: (Get.width / 1.4) / 2.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Heading4Text(
                            '${_agoraLiveController.allJoinedUsers.length}',
                            weight: TextWeight.medium)
                        .bP8,
                    BodySmallText(
                      usersString.tr,
                      weight: TextWeight.bold,
                      color: AppColorConstants.themeColor,
                    ),
                  ],
                ),
              ),
              // const Spacer(),
              SizedBox(
                width: (Get.width / 1.4) / 2.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Heading4Text(_agoraLiveController.liveTime,
                            weight: TextWeight.medium)
                        .bP8,
                    BodySmallText(
                      durationString.tr,
                      weight: TextWeight.bold,
                      color: AppColorConstants.themeColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: (Get.width / 1.4) / 2.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Heading4Text('${_agoraLiveController.giftsReceived.length}',
                            weight: TextWeight.medium)
                        .bP8,
                    BodySmallText(
                      giftsString.tr,
                      weight: TextWeight.bold,
                      color: AppColorConstants.themeColor,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: (Get.width / 1.4) / 2.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Heading4Text(
                            _agoraLiveController.totalCoinsEarned.toString(),
                            weight: TextWeight.medium)
                        .bP8,
                    BodySmallText(
                      coinsEarnedString.tr,
                      weight: TextWeight.bold,
                      color: AppColorConstants.themeColor,
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ).p16,
    ).round(20);
  }

  Widget hostUserInfo() {
    return Column(
      children: [
        const SizedBox(
          height: 150,
        ),
        UserAvatarView(
          user: widget.live.isHosting
              ? _userProfileManager.user.value!
              : _agoraLiveController.host!,
          hideLiveIndicator: _agoraLiveController.liveEnd.value == true,
          size: 100,
        ),
        const SizedBox(
          height: 10,
        ),
        Heading4Text(
          widget.live.isHosting
              ? _userProfileManager.user.value!.userName
              : _agoraLiveController.host!.userName,
          weight: TextWeight.bold,
          color: AppColorConstants.grayscale700,
        ),
        const SizedBox(
          height: 20,
        ),
        Heading6Text(liveEndString.tr, weight: TextWeight.medium),
      ],
    );
  }

  Widget messageComposerView() {
    return Container(
      // color: ColorConstants.backgroundColor.withOpacity(0.9),
      color: Colors.black,

      height: 70,
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  color: AppColorConstants.cardColor,
                  child: Obx(() => TextField(
                        controller: _agoraLiveController.messageTf.value,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: FontSizes.b2,
                            color: AppColorConstants.grayscale900),
                        maxLines: 50,
                        onChanged: (text) {
                          _agoraLiveController.messageChanges();
                        },
                        decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.only(
                                left: 10, right: 10, top: 5),
                            labelStyle: TextStyle(fontSize: FontSizes.b2),
                            hintStyle: TextStyle(fontSize: FontSizes.b2),
                            hintText: pleaseEnterMessageString.tr),
                      )),
                ).round(10),
              ),
              const SizedBox(
                width: 20,
              ),
              ThemeIconWidget(
                ThemeIcon.send,
                size: 40,
                color: AppColorConstants.themeColor,
              ).ripple(() {
                sendMessage();
              }),
              if (widget.live.isHosting == false)
                const SizedBox(
                  width: 20,
                ),
              if (widget.live.isHosting == false)
                Container(
                  height: 40,
                  width: 40,
                  color: AppColorConstants.themeColor,
                  child: const ThemeIconWidget(
                    ThemeIcon.diamond,
                    color: Colors.yellow,
                    size: 25,
                  ),
                ).circular.ripple(() {
                  showModalBottomSheet<void>(
                      backgroundColor: Colors.transparent,
                      context: context,
                      enableDrag: true,
                      isDismissible: true,
                      builder: (BuildContext context) {
                        return FractionallySizedBox(
                            heightFactor: 0.8,
                            child:
                                GiftsPageView(giftSelectedCompletion: (gift) {
                              Get.back();
                              _agoraLiveController.sendGift(gift);
                            }));
                      });
                }),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ).hP16,
    );
  }

  Widget topBar(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 30,
        ),
        SizedBox(
          height: 70,
          child: Row(children: [
            const ThemeIconWidget(
              ThemeIcon.downArrow,
              color: Colors.white,
              size: 25,
            ),
            const SizedBox(
              width: 20,
            ),
            Heading6Text(
              joinedUsersString.tr,
              weight: TextWeight.bold,
              color: AppColorConstants.grayscale600,
            ),
            const Spacer(),
            widget.live.isHosting == false
                ? const ThemeIconWidget(
                    ThemeIcon.close,
                    size: 25,
                    color: Colors.white,
                  ).circular.ripple(() {
                    _agoraLiveController.onCallEnd(isHost: false);
                  })
                : Image.asset(
                    'assets/live.png',
                    height: 30,
                  ),
          ]).ripple(() {
            showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return const LiveJoinedUsers();
                });
          }),
        ).hP16,
      ],
    );
  }

  // Generate local preview
  Widget _renderLocalPreview() {
    return Obx(() => _agoraLiveController.mutedVideo.value
        ? Container(
            color: AppColorConstants.red,
            child: Center(
                child: Heading6Text(
              videoPausedString.tr,
              color: AppColorConstants.grayscale600,
            )))
        : _agoraLiveController.engine != null
            ? AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _agoraLiveController.engine!,
                  canvas: const VideoCanvas(uid: 0),
                ),
              )
            : Container());
  }

  // Generate remote preview
  Widget _renderRemoteVideo() {
    return Stack(
      children: [
        _agoraLiveController.reConnectingRemoteView.value
            ? Container(
                color: AppColorConstants.red,
                child: Center(
                    child: Heading6Text(
                  reConnectingString.tr,
                  color: AppColorConstants.grayscale600,
                )))
            : _agoraLiveController.videoPaused.value
                ? Container(
                    color: AppColorConstants.themeColor,
                    child: Center(
                        child: Heading6Text(
                      videoPausedString.tr,
                      color: AppColorConstants.grayscale600,
                    )))
                : _agoraLiveController.engine != null
                    ? AgoraVideoView(
                        controller: VideoViewController.remote(
                          rtcEngine: _agoraLiveController.engine!,
                          canvas: VideoCanvas(
                              uid: _agoraLiveController.remoteUserId.value),
                          connection:
                              RtcConnection(channelId: widget.live.channelName),
                        ),
                      )
                    : Container(),
      ],
    );
  }

  // Ui & UX For Bottom Portion (Switch Camera,Video On/Off,Mic On/Off)
  Widget _actionWidgetForHostUser() => Positioned(
        right: 0,
        bottom: (widget.live.isHosting) ? 100 : 120,
        child: SizedBox(
          width: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Obx(() => _agoraLiveController.giftsReceived.isEmpty
                  ? Container()
                  : Container(
                      color: AppColorConstants.themeColor,
                      child: Column(
                        children: [
                          const ThemeIconWidget(
                            ThemeIcon.diamond,
                            size: 20,
                            color: Colors.white,
                          ).circular.ripple(() {
                            _agoraLiveController.onToggleCamera();
                          }),
                          const SizedBox(
                            height: 10,
                          ),
                          BodySmallText(
                              _agoraLiveController.totalCoinsEarned.formatNumber
                                  .toString(),
                              weight: TextWeight.medium)
                        ],
                      ).p8,
                    ).round(15)),
              const SizedBox(
                height: 20,
              ),
              const ThemeIconWidget(
                ThemeIcon.cameraSwitch,
                size: 30,
                color: Colors.white,
              ).circular.ripple(() {
                _agoraLiveController.onToggleCamera();
              }),
              const SizedBox(
                height: 20,
              ),
              Obx(() => ThemeIconWidget(
                    _agoraLiveController.mutedVideo.value
                        ? ThemeIcon.videoCameraOff
                        : ThemeIcon.videoCamera,
                    size: 30,
                    color: Colors.white,
                  )).circular.ripple(() {
                _agoraLiveController.onToggleMuteVideo();
              }),
              const SizedBox(
                height: 20,
              ),
              Obx(() => ThemeIconWidget(
                    _agoraLiveController.mutedAudio.value
                        ? ThemeIcon.micOff
                        : ThemeIcon.mic,
                    size: 30,
                    color: Colors.white,
                  )).circular.ripple(() {
                _agoraLiveController.onToggleMuteAudio();
              }),
              const SizedBox(
                height: 20,
              ),
              const ThemeIconWidget(
                ThemeIcon.close,
                size: 30,
                color: Colors.white,
              ).circular.ripple(() {
                _agoraLiveController.askConfirmationForEndCall();
              }),
              // const SizedBox(
              //   height: 20,
              // ),
            ],
          ),
        ),
      );

  Widget messagesListView() {
    return Container(
      height: MediaQuery.of(context).size.height / 2.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.transparent,
            Colors.black.withOpacity(0.7),
            Colors.black.withOpacity(0.9)
          ],
        ),
      ),
      child: GetBuilder<AgoraLiveController>(
          init: _agoraLiveController,
          builder: (ctx) {
            return ListView.separated(
                padding: const EdgeInsets.only(
                    top: 10, bottom: 50, left: 16, right: 70),
                itemCount: _agoraLiveController.messages.length,
                itemBuilder: (ctx, index) {
                  ChatMessageModel message =
                      _agoraLiveController.messages[index];
                  if (message.messageContentType == MessageContentType.gift) {
                    return giftMessageTile(message);
                  }
                  return textMessageTile(message);
                },
                separatorBuilder: (ctx, index) {
                  return const SizedBox(
                    height: 10,
                  );
                });
          }),
    );
  }

  Widget textMessageTile(ChatMessageModel message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AvatarView(size: 25, url: message.userPicture, name: message.userName),
        const SizedBox(
          width: 10,
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyMediumText(
                message.userName,
                weight: TextWeight.semiBold,
                color: AppColorConstants.grayscale500,
              ),
              BodySmallText(
                message.decrypt,
                color: AppColorConstants.grayscale500,
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget giftMessageTile(ChatMessageModel message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AvatarView(size: 25, url: message.userPicture, name: message.userName),
        const SizedBox(
          width: 10,
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyMediumText(
                message.userName,
                weight: TextWeight.semiBold,
                color: AppColorConstants.grayscale600,
              ),
              Row(
                children: [
                  BodySmallText(
                    sentAGiftString.tr,
                    color: AppColorConstants.grayscale600,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  CachedNetworkImage(
                    imageUrl: message.giftContent.image,
                    height: 20,
                    width: 20,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  BodySmallText(
                    message.giftContent.coins.toString(),
                    color: AppColorConstants.grayscale600,
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget defaultCoinsView() {
    return SizedBox(
      height: 60,
      child: Obx(() => ListView.separated(
          padding: const EdgeInsets.only(left: 16, right: 16),
          scrollDirection: Axis.horizontal,
          itemCount: _giftController.topGifts.length,
          itemBuilder: (ctx, index) {
            return giftBox(_giftController.topGifts[index]).ripple(() {
              _agoraLiveController.sendGift(_giftController.topGifts[index]);
            });
          },
          separatorBuilder: (ctx, index) {
            return const SizedBox(
              width: 15,
            );
          })),
    );
  }

  Widget giftBox(GiftModel gift) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.network(
          gift.logo,
          height: 30,
          width: 30,
          fit: BoxFit.contain,
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ThemeIconWidget(
              ThemeIcon.diamond,
              size: 18,
              color: AppColorConstants.themeColor,
            ),
            const SizedBox(
              width: 5,
            ),
            BodySmallText(
              gift.coins.toString(),
            ),
          ],
        )
      ],
    ).round(10);
  }

  Widget giftersView() {
    return Column(
      children: [
        Heading4Text(
          giftsReceivedString.tr,
          weight: TextWeight.semiBold,
          color: Colors.white,
        ),
        Container(
          height: 5,
          width: 180,
          color: AppColorConstants.themeColor,
        ).round(10).tP8,
        const SizedBox(
          height: 20,
        ),
        Expanded(
          child: Container(
            color: AppColorConstants.cardColor,
            child: ListView.separated(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 25, bottom: 100),
                itemCount: _agoraLiveController.giftsReceived.length,
                itemBuilder: (ctx, index) {
                  return GifterUserTile(
                    gift: _agoraLiveController.giftsReceived[index],
                  );
                },
                separatorBuilder: (ctx, index) {
                  return const SizedBox(height: 15);
                }).addPullToRefresh(
                refreshController: _refreshController,
                onRefresh: () {},
                onLoading: () {
                  _agoraLiveController.loadGiftsReceived();
                },
                enablePullUp: true,
                enablePullDown: false),
          ).topRounded(50),
        ),
      ],
    );
  }

  sendMessage() {
    if (_agoraLiveController.messageTf.value.text.removeAllWhitespace
        .trim()
        .isNotEmpty) {
      _agoraLiveController
          .sendTextMessage(_agoraLiveController.messageTf.value.text);
    }
  }
}

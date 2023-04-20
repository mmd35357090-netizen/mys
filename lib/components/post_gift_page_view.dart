import 'package:flutter/material.dart';
import 'package:foap/components/reply_chat_cells/post_gift_controller.dart';
import 'package:foap/helper/common_import.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../controllers/gift_controller.dart';
import '../model/gift_model.dart';
import '../model/post_gift_model.dart';
import '../screens/settings_menu/coin_packages_widget.dart';
import '../theme/icon_enum.dart';
import '../theme/theme_icon.dart';

class PostGiftPageView extends StatefulWidget {
  final Function(PostGiftModel) giftSelectedCompletion;
  final int? postId;

  const PostGiftPageView(
      {Key? key, required this.giftSelectedCompletion, this.postId})
      : super(key: key);

  @override
  State<PostGiftPageView> createState() => _PostGiftPageViewState();
}

class _PostGiftPageViewState extends State<PostGiftPageView> {
  int currentView = 0;
  List<Widget> pages = [];

  @override
  void initState() {
    pages = [
      GiftsListing(
        giftSelectedCompletion: widget.giftSelectedCompletion,
        postId: widget.postId,
      ),
      coinPackages(),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.darken(0.48),
      child: Column(
        children: [
          Container(
            height: 60,
            color: Theme.of(context).primaryColor.darken(0.48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${LocalizationString.availableCoins} : ',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                    ThemeIconWidget(
                      ThemeIcon.diamond,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(getIt<UserProfileManager>().user!.coins.toString(),
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(color: Colors.white)),
                  ],
                ),
                currentView == 0
                    ? Container(
                            color: Theme.of(context).primaryColor,
                            child: Text(
                              LocalizationString.coins,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontWeight: FontWeight.w700),
                            ).setPadding(
                                left: 10, right: 10, top: 5, bottom: 5))
                        .round(20)
                        .ripple(() {
                        setState(() {
                          currentView = 1;
                        });
                      })
                    : const ThemeIconWidget(
                        ThemeIcon.close,
                        size: 20,
                      ).ripple(() {
                        setState(() {
                          currentView = 0;
                        });
                      }),
              ],
            ).p16,
          ).topRounded(20),
          Expanded(child: pages[currentView]),
        ],
      ),
    );
  }

  Widget coinPackages() {
    return const CoinPackagesWidget();
  }
}

class GiftsListing extends StatefulWidget {
  final Function(PostGiftModel) giftSelectedCompletion;
  final int? postId;

  const GiftsListing(
      {Key? key, required this.giftSelectedCompletion, this.postId})
      : super(key: key);

  @override
  State<GiftsListing> createState() => _GiftsListingState();
}

class _GiftsListingState extends State<GiftsListing> {
  final PostGiftController _postGiftController = Get.find();

  @override
  void initState() {
    if (widget.postId != null) {
      _postGiftController.fetchPostGift(widget.postId!);
    } else {
      _postGiftController.fetchTimelinePostGift();
    }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor.darken(),
      child: Obx(() {
        return ListView.separated(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 50),
            itemCount: _postGiftController.timelineGift.length,
            itemBuilder: (context, index) {
              PostGiftModel postGift = _postGiftController.timelineGift[index];
              // return Container(child: Text(postGift.name.toString()));
              return giftBox(postGift).ripple(() {
                widget.giftSelectedCompletion(postGift);
              });
            },
            separatorBuilder: (context, index) {
              return const SizedBox(
                height: 25,
              );
            });
      }),
    );
  }

  Widget giftBox(PostGiftModel gift) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ThemeIconWidget(
          ThemeIcon.diamond,
          size: 25,
          color: Theme.of(context).iconTheme.color,
        ),
        const SizedBox(
          width: 2,
        ),
        Text(
          gift.coin.toString(),
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(
          width: 25,
        ),
        Expanded(
          child: Row(
            children: [
              // const Spacer(),
              Container(
                color: Theme.of(context).primaryColor,
                child: Center(
                  child: Text(
                    gift.name.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w700, color: Colors.white),
                  ).setPadding(top: 5, bottom: 5, left: 10, right: 10),
                ),
              ).round(40),
              const Spacer(),
            ],
          ),
        ),
        // const Spacer()
      ],
    ).round(10);
  }
}

class PostGiftsReceived extends StatefulWidget {
  final int postId;

  const PostGiftsReceived({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostGiftsReceived> createState() => _PostGiftsReceivedState();
}

class _PostGiftsReceivedState extends State<PostGiftsReceived> {
  final PostGiftController _postGiftController = Get.find();

  @override
  void initState() {
    _postGiftController.fetchPostGift(widget.postId);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor.darken(),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Text(
            LocalizationString.giftsReceived,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Obx(() {
              return ListView.separated(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 20, bottom: 50),
                  itemCount: _postGiftController.timelineGift.length,
                  itemBuilder: (context, index) {
                    PostGiftModel postGift =
                        _postGiftController.timelineGift[index];
                    // return Container(child: Text(postGift.name.toString()));
                    return giftBox(postGift);
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      height: 25,
                    );
                  });
            }),
          ),
        ],
      ),
    ).topRounded(40);
  }

  Widget giftBox(PostGiftModel gift) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ThemeIconWidget(
          ThemeIcon.diamond,
          size: 25,
          color: Theme.of(context).iconTheme.color,
        ),
        const SizedBox(
          width: 2,
        ),
        Text(
          gift.coin.toString(),
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(
          width: 25,
        ),
        Expanded(
          child: Row(
            children: [
              // const Spacer(),
              Container(
                color: Theme.of(context).primaryColor,
                child: Center(
                  child: Text(
                    gift.name.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w700, color: Colors.white),
                  ).setPadding(top: 5, bottom: 5, left: 10, right: 10),
                ),
              ).round(40),
              const Spacer(),
            ],
          ),
        ),
        // const Spacer()
      ],
    ).round(10);
  }
}

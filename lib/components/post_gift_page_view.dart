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

  const PostGiftPageView({Key? key, required this.giftSelectedCompletion,this.postId})
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
      GiftsListing(giftSelectedCompletion: widget.giftSelectedCompletion,postId: widget.postId,),
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
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                    ThemeIconWidget(
                      ThemeIcon.diamond,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      getIt<UserProfileManager>().user!.coins.toString(),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
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

  const GiftsListing({Key? key, required this.giftSelectedCompletion,this.postId})
      : super(key: key);

  @override
  State<GiftsListing> createState() => _GiftsListingState();
}

class _GiftsListingState extends State<GiftsListing> {
  // final GiftController _giftController = Get.find();
  final PostGiftController _postGiftController = Get.find();

  @override
  void initState() {
    if(widget.postId!=null){
      _postGiftController.fetchPostGift(widget.postId!);
    }else{
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
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Obx(() {
              return GridView.builder(
                  padding: const EdgeInsets.only(top: 20, bottom: 5),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      childAspectRatio: 0.6,
                      crossAxisCount: 4),
                  itemCount: _postGiftController.timelineGift.length,
                  itemBuilder: (context, index) {
                    PostGiftModel postGift =
                        _postGiftController.timelineGift[index];
                    // return Container(child: Text(postGift.name.toString()));
                    return giftBox(postGift).ripple(() {
                      widget.giftSelectedCompletion(postGift);
                    });
                  });
            }),
          ),
        ],
      ),
    );
  }

  Widget giftBox(PostGiftModel gift) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(4),
            alignment: Alignment.center,
            child: Text(gift.name.toString(),textAlign: TextAlign.center ,),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.yellow,
              width: 1
            )
          ),
        ).p4,
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ThemeIconWidget(
              ThemeIcon.diamond,
              size: 15,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(gift.coin.toString()),
          ],
        )
      ],
    ).round(10);
  }
}

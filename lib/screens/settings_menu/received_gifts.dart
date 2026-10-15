import 'package:flutter/material.dart';
import 'package:foap/components/empty_states.dart';
import 'package:foap/components/top_navigation_bar.dart';
import 'package:foap/helper/common_components.dart';
import 'package:foap/helper/extension.dart';
import 'package:foap/util/app_config_constants.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../controllers/misc/gift_controller.dart';
import '../../components/user_card.dart';
import '../../helper/localization_strings.dart';

//ignore: must_be_immutable
class ReceivedGiftsList extends StatelessWidget {
  final GiftController _giftController = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  ReceivedGiftsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.cardColor,
      child: Column(
        children: [
          backNavigationBar(title: giftsReceivedString.tr),
          Expanded(child: giftersView())
        ],
      ),
    ).topRounded(40);
  }

  Widget giftersView() {
    return Obx(() => _giftController.stickerGifts.isEmpty
        ? emptyData(title: noDataString.tr, subTitle: '')
        : ListView.separated(
            padding: EdgeInsets.only(
                left: DesignConstants.horizontalPadding,
                right: DesignConstants.horizontalPadding,
                top: 25,
                bottom: 100),
            itemCount: _giftController.stickerGifts.length,
            itemBuilder: (ctx, index) {
              return GifterUserTile(
                gift: _giftController.stickerGifts[index],
              );
            },
            separatorBuilder: (ctx, index) {
              return divider(height: 0.2).vP16;
            }).addPullToRefresh(
            refreshController: _refreshController,
            onRefresh: () {},
            onLoading: () {
              _giftController.fetchReceivedGifts();
            },
            enablePullUp: true,
            enablePullDown: false));
  }
}

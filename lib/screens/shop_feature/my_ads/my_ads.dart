import 'package:flutter/cupertino.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/controllers/shop/shop_controller.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../model/shop_model/ad_model.dart';
import '../../../segmentAndMenu/horizontal_menu.dart';
import '../components/ad_card.dart';
import '../home/ad_detail_screen.dart';
import '../post_ad/choose_category.dart';
import '../post_ad/enter_ad_detail.dart';

class MyAds extends StatefulWidget {
  const MyAds({super.key});

  @override
  State<MyAds> createState() => _MyAdsState();
}

class _MyAdsState extends State<MyAds> {
  ShopController shopController = Get.find();
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    loadData();
    super.initState();
  }

  void loadData() async {
    shopController.refreshMyAds(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      floatingActionButton: SizedBox(
        height: 40,
        width: 40,
        child: ThemeIconWidget(
          ThemeIcon.plus,
          size: 40,
          color: AppColorConstants.themeColor,
        ),
      ).ripple(() {
        Get.to(() => ChooseListingCategory(
              ad: AdModel(images: []),
            ));
      }),
      body: Column(
        children: [
          backNavigationBar(title: myProductString.tr),
          const SizedBox(
            height: 20,
          ),
          Obx(() => HorizontalMenuBar(
                menus: [
                  activeString.tr,
                  pendingString.tr,
                  rejectedString.tr,
                  expiredString.tr,
                  soldString.tr,
                  deletedString.tr
                ],
                selectedIndex: shopController.selectSegment.value,
                onSegmentChange: (selectedMenu) {
                  shopController.handleSegmentChange(selectedMenu);
                },
              )),
          Expanded(
              child: Obx(() => ListView.separated(
                  padding: EdgeInsets.only(
                      left: DesignConstants.horizontalPadding,
                      right: DesignConstants.horizontalPadding,
                      top: 25),
                  itemCount: shopController.myAds.length,
                  itemBuilder: (BuildContext context, int index) {
                    return MyAdCard(
                      ad: shopController.myAds[index],
                      actionHandler: () {
                        actionOnAd(shopController.myAds[index]);
                      },
                    ).p8.ripple(() {
                      Get.to(() => AdDetailScreen(shopController.myAds[index]));
                    });
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(height: 10);
                  }).addPullToRefresh(
                  refreshController: refreshController,
                  onRefresh: () {},
                  onLoading: () {
                    shopController.loadMoreMyAds(() {
                      refreshController.loadComplete();
                    });
                  },
                  enablePullUp: true,
                  enablePullDown: false)))
        ],
      ),
    );
  }

  actionOnAd(AdModel ad) {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => ad.status == 10
            ? CupertinoActionSheet(
                actions: <CupertinoActionSheetAction>[
                  CupertinoActionSheetAction(
                    child: BodyLargeText(markAsSoldString.tr),
                    onPressed: () {
                      updateAdStatus(4, ad);
                      Get.back();
                    },
                  ),
                  CupertinoActionSheetAction(
                    child: BodyLargeText(editString.tr),
                    onPressed: () {
                      Get.to(() => EnterAdDetail(ad));
                    },
                  ),
                  CupertinoActionSheetAction(
                    child: BodyLargeText(deleteString.tr),
                    onPressed: () {
                      updateAdStatus(0, ad);
                      Get.back();
                    },
                  ),
                  CupertinoActionSheetAction(
                    isDestructiveAction: true,
                    child: BodyLargeText(cancelString.tr),
                    onPressed: () {
                      Get.back();
                    },
                  )
                ],
              )
            : CupertinoActionSheet(
                actions: <CupertinoActionSheetAction>[
                  CupertinoActionSheetAction(
                    child: BodyLargeText(editString.tr),
                    onPressed: () {
                      Get.to(() => EnterAdDetail(ad));
                    },
                  ),
                  CupertinoActionSheetAction(
                    child: BodyLargeText(deleteString.tr),
                    onPressed: () {
                      updateAdStatus(0, ad);
                      Get.back();
                    },
                  ),
                  CupertinoActionSheetAction(
                    isDestructiveAction: true,
                    child: BodyLargeText(cancelString.tr),
                    onPressed: () {
                      Get.back();
                    },
                  )
                ],
              ));
  }

  updateAdStatus(int status, AdModel ad) {
    shopController.updateStatus(ad: ad, status: status);
  }
}

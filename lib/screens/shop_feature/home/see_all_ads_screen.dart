import 'package:foap/helper/imports/common_import.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../model/shop_model/advertisement.dart';
import 'package:foap/controllers/shop/shop_controller.dart';
import '../components/ad_card.dart';
import '../components/advertisement_card.dart';
import 'ad_detail_screen.dart';

class SeeAllAdListing extends StatefulWidget {
  final String? header;

  const SeeAllAdListing({this.header, super.key});

  @override
  SeeAllPropertyState createState() => SeeAllPropertyState();
}

class SeeAllPropertyState extends State<SeeAllAdListing> {
  ShopController shopController = Get.find();
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    loadAdvertisementsData();
  }

  void loadAdvertisementsData() async {
    shopController.refreshThirdPartyAds(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: [
            SizedBox(
              height: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                          onTap: () => Get.back(),
                          child: Icon(Icons.arrow_back_ios,
                              color: AppColorConstants.themeColor))
                      .rP4,
                  Expanded(child: SFSearchBar(
                    onSearchCompleted: (value) {
                      if (value.length > 2) {
                        shopController.setSearchText(value);
                      }
                    },
                  )),
                ],
              ).tp(50),
            ).hp(DesignConstants.horizontalPadding),
            Expanded(
                child: Obx(() => ListView.separated(
                      padding: EdgeInsets.only(
                          left: DesignConstants.horizontalPadding,
                          right: DesignConstants.horizontalPadding),
                      itemCount: shopController.ads.length,
                      itemBuilder: (BuildContext context, int index) {
                        return AdCard(
                            ad: shopController.ads[index],
                            pressed: () {
                              Get.to(() =>
                                  AdDetailScreen(shopController.ads[index]));
                            },
                            favPressed: () {
                              shopController
                                  .favUnfavAd(shopController.ads[index]);
                            });
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        if ((index %
                                    AppConfigConstants.showAdvertiesmentAfter ==
                                0 &&
                            shopController.thirdPartyAdvertisement.length >
                                (index /
                                    AppConfigConstants
                                        .showAdvertiesmentAfter))) {
                          Advertisement ad =
                              (shopController.thirdPartyAdvertisement[(index /
                                      AppConfigConstants.showAdvertiesmentAfter)
                                  .round()]);
                          shopController.addUsersThirdPartyAds(ad);
                          return getAdvertisementView(ad);
                        }
                        return const SizedBox(
                          height: 10,
                        );
                      },
                    ).addPullToRefresh(
                        refreshController: refreshController,
                        onRefresh: () {
                          shopController.refreshAds(() {
                            refreshController.refreshCompleted();
                          });
                        },
                        onLoading: () {
                          shopController.loadMoreAds(() {
                            refreshController.loadComplete();
                          });
                        },
                        enablePullUp: true,
                        enablePullDown: true))),
          ],
        ));
  }

  Widget getAdvertisementView(Advertisement ad) {
    return (ad.isVideoAd() == true)
        ? SizedBox(
            height: 250,
            child: AdvertisementCard(
                advertisement: ad,
                pressed: () {
                  // Get.to(() => VideoPlayerScreen(
                  //     videoUrl: (thirdPartyAdvertiesments[
                  //             (index / AppConfigConstants.showAdvertiesmentAfter)
                  //                 .round()] as Advertisement)
                  //         .video!));
                }),
          ).vp(10)
        : SizedBox(
                height: 250,
                child: CachedNetworkImage(imageUrl: ad.image, fit: BoxFit.cover)
                    .p8)
            .vp(10)
            .ripple(() {
            // Get.to(() => EnlargeImageViewScreen((thirdPartyAdvertiesments[
            //             (index / AppConfigConstants.showAdvertiesmentAfter).round()]
            //         as Advertisement)
            //     .image));
          });
  }
}

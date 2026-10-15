import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/shop_model/advertisement.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../model/shop_model/ad_model.dart';
import 'package:foap/controllers/shop/shop_controller.dart';
import '../components/ad_card.dart';
import '../components/advertisement_card.dart';
import '../components/category_card.dart';
import 'ad_detail_screen.dart';
import 'see_all_ads_screen.dart';

class Marketplace extends StatefulWidget {
  const Marketplace({super.key});

  @override
  State<Marketplace> createState() => _MarketplaceState();
}

class _MarketplaceState extends State<Marketplace> {
  ShopController shopController = Get.find();
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    shopController.getCategories(() {});
    shopController.loadAds(() {});
    shopController.loadMoreThirdPartyAds(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: shopString.tr),
          Expanded(
            child: SingleChildScrollView(
                child: Column(children: [
              SFSearchBar(
                  onSearchCompleted: (value) {},
                  onSearchChanged: (value) {
                    if (value.length > 2) {
                      shopController.setSearchText(value);
                    } else {
                      shopController.setSearchText(null);
                    }
                  }).round(10).p(DesignConstants.horizontalPadding),
              Obx(() => shopController.categories.isNotEmpty
                  ? categoryView()
                  : Container()),
              Obx(() => shopController.ads.isNotEmpty
                  ? adsSegment(shopController.ads)
                  : emptyData(
                      title: noProductFoundString.tr,
                      subTitle: pleaseModifyYourSearch.tr)),
            ])).addPullToRefresh(
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
                enablePullDown: true),
          ),
        ],
      ),
    );
  }

  Widget categoryView() {
    return Obx(() => SizedBox(
          height: 120,
          child: GridView.builder(
            padding: EdgeInsets.only(left: DesignConstants.horizontalPadding),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 0.35),
            scrollDirection: Axis.horizontal,
            itemCount: shopController.categories.length,
            itemBuilder: (context, index) {
              return CategoryCard(
                  category: shopController.categories[index],
                  callback: () {
                    shopController
                        .setCategoryId(shopController.categories[index].id);

                    Get.to(() => const SeeAllAdListing())!.then((value) {
                      shopController.setCategoryId(null);
                    });
                  });
            },
          ),
        ).bP8);
  }

  Widget adsSegment(
    List<AdModel> ads,
  ) {
    return SizedBox(
      height: (ads.length * 270) +
          (shopController.usedThirdPartyAdvertisement.length * 250),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.6,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10),
        padding: EdgeInsets.all(DesignConstants.horizontalPadding),
        itemCount: ads.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return AdCard(
              ad: ads[index],
              pressed: () {
                Get.to(() => AdDetailScreen(ads[index]));
              },
              favPressed: () {
                shopController.favUnfavAd(ads[index]);
              });
        },
        // separatorBuilder: (BuildContext context, int index) {
        //   if ((index % AppConfigConstants.showAdvertiesmentAfter == 0 &&
        //       shopController.thirdPartyAdvertisement.length >
        //           (index / AppConfigConstants.showAdvertiesmentAfter))) {
        //     Advertisement ad = (shopController.thirdPartyAdvertisement[
        //         (index / AppConfigConstants.showAdvertiesmentAfter).round()]);
        //     shopController.addUsersThirdPartyAds(ad);
        //     return getAdvertisementView(ad);
        //   }
        //   return const SizedBox(
        //     height: 10,
        //   );
        // }
      ),
    );
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

// Widget promoBannerView() {
//   double width = Get.width;
//   return Obx(() => SizedBox(
//         height: 200,
//         child: ListView.builder(
//           padding: const EdgeInsets.only(left: 16),
//           scrollDirection: Axis.horizontal,
//           itemCount: shopController.promoBannerPacks.length,
//           itemBuilder: (context, index) {
//             return Image.network(shopController.promoBannerPacks[index].image,
//                     fit: BoxFit.cover, width: width - 32)
//                 .round(20)
//                 .rP8
//                 .ripple(() {
//               SearchModel searchModel = SearchModel();
//               searchModel.bannerId =
//                   shopController.promoBannerPacks[index].id;
//               Get.to(() => SeeAllPropertyScreen(searchModel));
//             });
//           },
//         ),
//       ));
// }
}

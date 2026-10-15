import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/controllers/shop/shop_controller.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../components/ad_card.dart';
import 'ad_detail_screen.dart';

class FavProductsListScreen extends StatefulWidget {
  const FavProductsListScreen({super.key}) ;

  @override
  FavProductsListScreenState createState() => FavProductsListScreenState();
}

class FavProductsListScreenState extends State<FavProductsListScreen> {
  ShopController shopController = Get.find();

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    shopController.refreshFavAds(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: [
            backNavigationBar(title: favouriteString.tr),
            Expanded(
              child: Obx(() => GridView.builder(
                  padding: EdgeInsets.only(
                      top: 20,
                      left: DesignConstants.horizontalPadding,
                      right: DesignConstants.horizontalPadding),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.6,
                      crossAxisSpacing: 10),
                  itemCount: shopController.favAds.length,
                  itemBuilder: (BuildContext context, int index) {
                    return AdCard(
                      ad: shopController.favAds[index],
                      pressed: () {
                        Get.to(
                            () => AdDetailScreen(shopController.favAds[index]));
                      },
                      favPressed: () {
                        shopController.favUnfavAd(shopController.favAds[index]);
                      },
                    );
                  }).addPullToRefresh(
                  refreshController: refreshController,
                  onRefresh: () {
                    shopController.refreshFavAds(() {
                      refreshController.refreshCompleted();
                    });
                  },
                  onLoading: () {
                    shopController.loadMoreFavAds(() {
                      refreshController.loadComplete();
                    });
                  },
                  enablePullUp: true,
                  enablePullDown: true)),
            ),
          ],
        ));
  }
}

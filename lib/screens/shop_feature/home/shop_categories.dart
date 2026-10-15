import 'package:foap/controllers/shop/shop_controller.dart';
import 'package:foap/model/shop_model/category.dart';
import 'package:foap/screens/shop_feature/home/see_all_ads_screen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../helper/imports/common_import.dart';
import '../components/category_card.dart';

//ignore: must_be_immutable
class ShopCategories extends StatelessWidget {
  final ShopController shopController = Get.find();
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  ShopCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(
            title: categoriesString.tr,
          ),
          Expanded(
              child: GetBuilder<ShopController>(
                  init: shopController,
                  builder: (ctx) {
                    return GridView.builder(
                        itemCount: shopController.categories.length,
                        padding: EdgeInsets.only(
                            top: 20,
                            left: DesignConstants.horizontalPadding,
                            right: DesignConstants.horizontalPadding,
                            bottom: 50),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10.0,
                                mainAxisSpacing: 10.0,
                                childAspectRatio: 1),
                        itemBuilder: (ctx, index) {
                          ShopCategoryModel category =
                              shopController.categories[index];
                          return CategoryCard(
                            category: category,
                            callback: () {
                              shopController.setCategoryId(category.id);
                              Get.to(() => const SeeAllAdListing())!
                                  .then((value) {
                                shopController.setCategoryId(null);
                              });
                            },
                          );
                        }).addPullToRefresh(
                        refreshController: refreshController,
                        onRefresh: () {},
                        onLoading: () {
                          shopController.loadMoreCategories(() {
                            refreshController.loadComplete();
                          });
                        },
                        enablePullUp: true,
                        enablePullDown: false);
                  }))
        ],
      ),
    );
  }
}

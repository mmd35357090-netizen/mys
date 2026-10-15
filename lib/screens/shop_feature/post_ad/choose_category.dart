import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/shop_model/category.dart';
import 'package:foap/screens/shop_feature/post_ad/enter_ad_detail.dart';
import 'package:foap/controllers/shop/shop_controller.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../model/shop_model/ad_model.dart';
import '../components/category_card.dart';
import 'choose_sub_category.dart';

class ChooseListingCategory extends StatefulWidget {
  final ShopCategoryModel? category;
  final AdModel ad;

  const ChooseListingCategory({super.key, required this.ad, this.category});

  @override
  State<ChooseListingCategory> createState() => _ChooseListingCategoryState();
}

class _ChooseListingCategoryState extends State<ChooseListingCategory> {
  final ShopController shopController = Get.find();
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  ShopCategoryModel? category;
  late AdModel ad;

  @override
  void initState() {
    category = widget.category;
    ad = widget.ad;
    if (category == null) {
      loadCategories();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              backNavigationBar(
                title: chooseCategoryString.tr,
              ),
              Expanded(
                child: Obx(() => GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                      ),
                      scrollDirection: Axis.vertical,
                      itemCount: shopController.categories.length,
                      itemBuilder: (context, index) {
                        return CategoryCardForPost(
                            category: shopController.categories[index],
                            callback: () {
                              ad.categoryId =
                                  shopController.categories[index].id;
                              ad.categoryName =
                                  shopController.categories[index].name;
                              Get.to(() => ChooseListingSubCategory(
                                  ad: ad,
                                  category: shopController.categories[index]));
                            });
                      },
                    ).addPullToRefresh(
                        refreshController: refreshController,
                        onRefresh: () {},
                        onLoading: () {
                          shopController.loadMoreCategories(() {
                            refreshController.loadComplete();
                          });
                        },
                        enablePullUp: true,
                        enablePullDown: false)),
              ),
            ],
          ),
          category != null
              ? Positioned(
                  bottom: 40,
                  left: 16,
                  right: 16,
                  child: AppThemeButton(
                    text: skipString.tr,
                    onPress: () {
                      Get.to(() => EnterAdDetail(ad));
                    },
                  ))
              : Container()
        ],
      ),
    );
  }

  void loadCategories() async {
    shopController.getCategories(() {});
  }
}

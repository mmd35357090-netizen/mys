import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/shop_model/category.dart';
import 'package:foap/screens/shop_feature/post_ad/enter_ad_detail.dart';
import 'package:foap/controllers/shop/shop_controller.dart';
import '../../../model/shop_model/ad_model.dart';
import '../components/category_card.dart';

class ChooseListingSubCategory extends StatefulWidget {
  final ShopCategoryModel? category;
  final AdModel ad;

  const ChooseListingSubCategory({super.key, required this.ad, this.category})
      ;

  @override
  State<ChooseListingSubCategory> createState() =>
      _ChooseListingSubCategoryState();
}

class _ChooseListingSubCategoryState extends State<ChooseListingSubCategory> {
  final ShopController shopController = Get.find();

  ShopCategoryModel? category;
  late AdModel ad;

  @override
  void initState() {
    category = widget.category;
    ad = widget.ad;

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
                title: chooseSubCategoryString.tr,
              ),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                  ),
                  scrollDirection: Axis.vertical,
                  itemCount: category!.subCategories!.length,
                  itemBuilder: (context, index) {
                    return CategoryCardForPost(
                        category: category!.subCategories![index],
                        callback: () {
                          ad.subCategoryId = category!.subCategories![index].id;
                          ad.subCategoryName =
                              category!.subCategories![index].name;
                          Get.to(() => EnterAdDetail(ad));
                        });
                  },
                ),
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
}

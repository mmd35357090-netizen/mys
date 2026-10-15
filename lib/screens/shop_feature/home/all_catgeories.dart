import 'package:flutter/material.dart';
import 'package:foap/controllers/shop/shop_controller.dart';
import 'package:foap/helper/extension.dart';
import 'package:foap/model/shop_model/category.dart';
import 'package:foap/screens/shop_feature/home/see_all_ads_screen.dart';
import '../../../components/app_scaffold.dart';
import 'package:get/get.dart';
import '../../../util/app_config_constants.dart';
import '../components/category_card.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key}) ;

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  List<ShopCategoryModel> categories = [];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        children: [
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                    onTap: () => Get.back(),
                    child: Icon(Icons.arrow_back_ios,
                        color: AppColorConstants.themeColor)),
                InkWell(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: Container(
                      height: 50,
                      color: Colors.grey.withValues(alpha: 0.1),
                      child: Row(
                        children: [
                          Icon(Icons.bookmark_border,
                              color: AppColorConstants.themeColor),
                        ],
                      ).hp(10),
                    ).round(10)),
              ],
            ).tp(50),
          ).hP16,
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10),
              scrollDirection: Axis.vertical,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return CategoryCard(
                    category: categories[index],
                    callback: () {
                      ShopController shopController = Get.find();
                      shopController
                          .setCategoryId(shopController.categories[index].id);

                      Get.to(() => const SeeAllAdListing())!.then((value) {
                        shopController.setCategoryId(null);
                      });
                    }).rP8;
              },
            ).hP16,
          ),
        ],
      ),
    );
  }
}

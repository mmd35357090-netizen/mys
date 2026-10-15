import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/number_extension.dart';
import 'package:foap/screens/near_by_offers/explore_buisness.dart';
import 'package:foap/screens/near_by_offers/explore_offers.dart';
import '../../model/category_model.dart';

class CategoryAvatarType1 extends StatelessWidget {
  final CategoryModel category;
  final double? size;

  const CategoryAvatarType1({super.key, required this.category, this.size})
      ;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? 100,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: category.coverImage,
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black45,
          ),
          Positioned(
              bottom: 5,
              left: 5,
              right: 5,
              child: BodyMediumText(
                category.name,
                maxLines: 1,
                weight: TextWeight.semiBold,
                color: Colors.white,
              ))
        ],
      ),
    ).round(5);
  }
}

class CategoryAvatarType2 extends StatelessWidget {
  final CategoryModel category;
  final double? size;

  const CategoryAvatarType2({super.key, required this.category, this.size})
      ;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CachedNetworkImage(
          imageUrl: category.coverImage,
          fit: BoxFit.cover,
          height: 30,
          width: 30,
        ).circular,
        const SizedBox(
          width: 10,
        ),
        BodyMediumText(category.name, weight: TextWeight.semiBold)
      ],
    )
        .setPadding(left: 8, right: 8, top: 4, bottom: 4)
        .borderWithRadius(value: 1, radius: 20);
  }
}

class OfferCategoryCard extends StatelessWidget {
  final OffersCategoryModel category;
  final double? size;

  const OfferCategoryCard({super.key, required this.category, this.size})
      ;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: category.coverImage,
                  fit: BoxFit.cover,
                ),
                Container(
                  color: Colors.black45,
                ),
                Positioned(
                    bottom: 5,
                    left: 5,
                    right: 5,
                    child: BodyMediumText(
                      category.name,
                      maxLines: 1,
                      weight: TextWeight.semiBold,
                      color: Colors.white,
                    ))
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                BodyLargeText(
                  category.totalBusinesses.formatNumber,
                  color: AppColorConstants.themeColor,
                  weight: TextWeight.bold,
                ),
                const SizedBox(
                  width: 5,
                ),
                BodyLargeText(
                  businessesString.tr,
                ),
                const Spacer(),
                ThemeIconWidget(ThemeIcon.nextArrow),
              ],
            ).hP4,
          ).ripple(() {
            Get.to(() => ExploreBusiness(
                  addBackBtn: true,
                  category: category,
                ));
          }),
          divider(height: 1).vP4,
          SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      BodyLargeText(
                        category.totalOffers.formatNumber,
                        color: AppColorConstants.themeColor,
                        weight: TextWeight.bold,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      BodyLargeText(
                        offers.tr,
                      ),
                      const Spacer(),
                      ThemeIconWidget(ThemeIcon.nextArrow),
                    ],
                  ).hP4)
              .ripple(() {
            Get.to(() => ExploreOffers(
                  addBackBtn: true,
                  category: category,
                ));
          }),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    ).borderWithRadius(value: 1, radius: 10);
  }
}

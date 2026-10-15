import 'package:foap/controllers/coupons/near_by_offers.dart';
import '../../components/group_avatars/group_avatar1.dart';
import '../../helper/imports/common_import.dart';
import '../../model/category_model.dart';

class BusinessCategories extends StatelessWidget {
  final NearByOffersController _offersController = Get.find();

  BusinessCategories({super.key}) ;

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
              child: GetBuilder<NearByOffersController>(
                  init: _offersController,
                  builder: (ctx) {
                    return GridView.builder(
                        itemCount: _offersController.categories.length,
                        padding: EdgeInsets.only(
                            top: 20,
                            left: DesignConstants.horizontalPadding,
                            right: DesignConstants.horizontalPadding,
                            bottom: 50),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                crossAxisSpacing: 10.0,
                                mainAxisSpacing: 10.0,
                                childAspectRatio: 1.3),
                        itemBuilder: (ctx, index) {
                          OffersCategoryModel category =
                              _offersController.categories[index];
                          return OfferCategoryCard(category: category);
                        });
                  }))
        ],
      ),
    );
  }
}

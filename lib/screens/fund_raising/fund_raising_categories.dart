import 'package:foap/screens/fund_raising/explore_campaigns.dart';
import '../../components/group_avatars/group_avatar1.dart';
import '../../controllers/fund_raising/fund_raising_controller.dart';
import '../../helper/imports/common_import.dart';
import '../../model/category_model.dart';

class FundRaisingCategories extends StatelessWidget {
  final FundRaisingController _fundRaisingController = Get.find();

  FundRaisingCategories({super.key}) ;

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
              child: GetBuilder<FundRaisingController>(
                  init: _fundRaisingController,
                  builder: (ctx) {
                    return GridView.builder(
                        itemCount: _fundRaisingController.categories.length,
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
                          CategoryModel category =
                              _fundRaisingController.categories[index];
                          return CategoryAvatarType1(category: category)
                              .ripple(() {
                            _fundRaisingController.setCategoryId(category.id);
                            Get.to(() => const ExploreCampaigns(
                                      fromCategory: true,
                                    ))!
                                .then((value) {
                              _fundRaisingController.setCategoryId(null);
                            });
                          });
                        });
                  }))
        ],
      ),
    );
  }
}

import 'package:foap/controllers/job/job_controller.dart';
import '../../components/group_avatars/group_avatar1.dart';
import '../../helper/imports/common_import.dart';
import '../../model/category_model.dart';
import 'job_by_category.dart';

class JobCategories extends StatelessWidget {
  final JobController jobController = Get.find();

  JobCategories({super.key}) ;

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
              child: GetBuilder<JobController>(
                  init: jobController,
                  builder: (ctx) {
                    return GridView.builder(
                        itemCount: jobController.categories.length,
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
                              jobController.categories[index];
                          return CategoryAvatarType1(category: category)
                              .ripple(() {
                            jobController.setCategoryId(category.id);
                            Get.to(() => JobsByCategory(
                                      category: category,
                                    ))!
                                .then((value) {
                              jobController.setCategoryId(null);
                            });
                          });
                        });
                  }))
        ],
      ),
    );
  }
}

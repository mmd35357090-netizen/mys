import 'package:foap/components/group_avatars/group_avatar1.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/category_model.dart';
import '../../../controller/event/create_event/add_event_controller.dart'
    show AddEventController;
import 'create_event.dart';

class ChooseEventCategory extends StatefulWidget {
  const ChooseEventCategory({super.key});

  @override
  State<ChooseEventCategory> createState() => _ChooseEventCategoryState();
}

class _ChooseEventCategoryState extends State<ChooseEventCategory> {
  final AddEventController addEventController = Get.find();

  @override
  void initState() {
    super.initState();
    addEventController.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(
            title: categoriesString.tr,
          ),
          Obx(()=> Expanded(
              child: GridView.builder(
                  itemCount: addEventController.categories.length,
                  padding: EdgeInsets.only(
                      top: 20,
                      left: DesignConstants.horizontalPadding,
                      right: DesignConstants.horizontalPadding,
                      bottom: 50),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 1),
                  itemBuilder: (ctx, index) {
                    CategoryModel category =
                    addEventController.categories[index];
                    return CategoryAvatarType1(category: category)
                        .ripple(() {
                      addEventController.setCategory(category);
                      Get.to(() => EnterEventDetail());
                    });
                  })))
        ],
      ),
    );
  }
}

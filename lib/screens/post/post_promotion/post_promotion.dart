import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/post/post_promotion/promotion_audience.dart';
import 'package:foap/screens/post/post_promotion/promotion_budget.dart';
import 'package:foap/screens/post/post_promotion/promotion_goal.dart';
import 'package:foap/screens/post/post_promotion/promotion_review.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import '../../../controllers/post/promotion_controller.dart';

class PostPromotionScreen extends StatelessWidget {
  PostPromotionScreen({super.key});
  final PromotionController _promotionController = Get.find();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: GetBuilder<PromotionController>(
            init: _promotionController,
            builder: (ctx) {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    customNavigationBar(
                        title: _promotionController
                            .pageName[_promotionController.pageChanged.value],
                        action: () {
                          if (_promotionController.pageChanged.value == 0) {
                            _promotionController.clear();
                            Get.back();
                          } else {
                            _promotionController.previousButtonEvent();
                          }
                        }),
                    StepProgressIndicator(
                      totalSteps: _promotionController.pageName.length,
                      currentStep: _promotionController.pageChanged.value + 1,
                      size: 2,
                      selectedColor: AppColorConstants.themeColor,
                      unselectedColor: AppColorConstants.subHeadingTextColor,
                    ),
                    Expanded(
                      child: PageView(
                          physics: const NeverScrollableScrollPhysics(), // Disable manual scrolling
                          pageSnapping: true,
                          controller: _promotionController.pageController,
                          onPageChanged: (index) {
                            _promotionController.pageChangedEvent(index);
                          },
                          children: [
                            PromotionGoalScreen(),
                            PromotionAudienceScreen(),
                            PromotionBudgetScreen(),
                            PromotionReviewScreen(),
                          ]),
                    ),
                  ]);
            }));
  }
}

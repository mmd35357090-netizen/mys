import 'package:foap/controllers/subscription/subscription_controller.dart';
import 'package:foap/helper/imports/common_import.dart';

class CreateSubscriptionPlan extends StatefulWidget {
  const CreateSubscriptionPlan({super.key});

  @override
  State<CreateSubscriptionPlan> createState() =>
      _CreateSubscriptionPlanState();
}

class _CreateSubscriptionPlanState extends State<CreateSubscriptionPlan> {
  final UserSubscriptionController subscriptionController = Get.find();

  @override
  void initState() {
    super.initState();

    subscriptionController.getSubscriptionPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Stack(
          children: [
            Column(children: [
              backNavigationBar(
                title: subscriptionString.tr,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Obx(() => Heading4Text(
                            'Set ${subscriptionController.plans.isNotEmpty ? subscriptionController.plans.first.name : ''} subscription price',
                            weight: TextWeight.bold,
                            textAlign: TextAlign.center,
                          ).hP25),
                      const SizedBox(
                        height: 20,
                      ),
                      BodyLargeText(
                        'Select the number of coins you want to charge for your subscription',
                        weight: TextWeight.regular,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      for (int coins in subscriptionController.coinsList)
                        Obx(() => SizedBox(
                              height: 60,
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 25,
                                    width: 25,
                                    color: subscriptionController
                                                .selectedCoins.value ==
                                            coins
                                        ? AppColorConstants.themeColor
                                        : Colors.transparent,
                                    child: subscriptionController
                                                .selectedCoins.value ==
                                            coins
                                        ? ThemeIconWidget(
                                            ThemeIcon.checkMark,
                                            size: 15,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ).borderWithRadius(value: 1, radius: 15),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  BodyLargeText('$coins ${coinsString.tr}')
                                ],
                              ),
                            ).ripple(() {
                              subscriptionController
                                  .selectSubscriptionCoins(coins);
                            }))
                    ],
                  ).hp(DesignConstants.horizontalPadding),
                ),
              ),
            ]),
            Positioned(
                bottom: 20,
                left: DesignConstants.horizontalPadding,
                right: DesignConstants.horizontalPadding,
                child: AppThemeButton(
                    text: submitString.tr,
                    onPress: () {
                      subscriptionController.setSubscriptionPlanCost();
                    }))
          ],
        ));
  }
}

import 'package:foap/helper/imports/event_imports.dart';
import '../../controllers/fund_raising/fund_raising_controller.dart';
import '../../controllers/post/add_post_controller.dart';
import '../../helper/imports/common_import.dart';
import '../../model/fund_raising_campaign.dart';

class EnterDonationAmount extends StatelessWidget {
  final FundRaisingController fundRaisingController = Get.find();
  final AddPostController addPostController = Get.find();

  EnterDonationAmount({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: makePaymentString),
          Expanded(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                AppTextField(
                  controller: fundRaisingController.donationAmountTE,
                  label: enterAmountToDonate,
                ),
                const SizedBox(
                  height: 50,
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: Get.width / 2.5,
                          child: const Center(
                            child: Heading6Text('\$10'),
                          ).p25,
                        ).borderWithRadius(value: 1, radius: 10).ripple(() {
                          fundRaisingController.setDonationAmount(10);
                        }),
                        SizedBox(
                          width: Get.width / 2.5,
                          child: const Center(
                            child: Heading6Text('\$20'),
                          ).p25,
                        ).borderWithRadius(value: 1, radius: 10).ripple(() {
                          fundRaisingController.setDonationAmount(20);
                        }),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: Get.width / 2.5,
                          child: const Center(
                            child: Heading6Text('\$50'),
                          ).p25,
                        ).borderWithRadius(value: 1, radius: 10).ripple(() {
                          fundRaisingController.setDonationAmount(50);
                        }),
                        SizedBox(
                          width: Get.width / 2.5,
                          child: const Center(
                            child: Heading6Text('\$100'),
                          ).p25,
                        ).borderWithRadius(value: 1, radius: 10).ripple(() {
                          fundRaisingController.setDonationAmount(100);
                        }),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
                AppThemeButton(
                    text: makePaymentString,
                    onPress: () {
                      if (fundRaisingController
                          .donationAmountTE.text.isNotEmpty) {
                        FundraisingDonationRequest orderToPlace =
                            fundRaisingController.order;
                        Get.to(() =>
                            Checkout(
                              amountToPay: orderToPlace.totalAmount!,
                              itemName:
                              '${donationsString.tr} : ${orderToPlace
                                  .itemName}',
                              transactionCallbackHandler: (payments) {
                                orderToPlace.payments = payments;
                                fundRaisingController
                                    .makeDonation(orderToPlace);
                              },
                              shareToFeedCallback: () {
                                addPostController.shareToFeed(
                                    productId: fundRaisingController.order.campaignId!,
                                    contentType: PostContentType.donation);
                                Get.close(2);
                              },
                            ));
                      } else {
                        AppUtil.showToast(
                            message: pleaseEnterDonationAmountString,
                            isSuccess: false);
                      }
                    })
              ],
            ).hp(DesignConstants.horizontalPadding),
          ),
        ],
      ),
    );
  }
}

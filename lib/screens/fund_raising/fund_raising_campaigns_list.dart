import 'package:foap/model/fund_raising_campaign.dart';
import '../../components/fund_raising/fund_raising_card.dart';
import '../../controllers/fund_raising/fund_raising_controller.dart';
import '../../helper/imports/common_import.dart';
import 'fund_raising_campaign_detail.dart';

class FundRaisingCampaignList extends StatelessWidget {
  final FundRaisingController _fundRaisingController = Get.find();

  FundRaisingCampaignList({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FundRaisingController>(
        init: _fundRaisingController,
        builder: (ctx) {
          return SizedBox(
              height: _fundRaisingController.campaigns.length * 290,
              child: ListView.separated(
                itemCount: _fundRaisingController.campaigns.length,
                padding: EdgeInsets.only(
                    top: 0,
                    left: DesignConstants.horizontalPadding,
                    right: DesignConstants.horizontalPadding,
                    bottom: 50),
                physics: const NeverScrollableScrollPhysics(),
                // gridDelegate:
                // const SliverGridDelegateWithFixedCrossAxisCount(
                //     crossAxisCount: 2,
                //     crossAxisSpacing: 10.0,
                //     mainAxisSpacing: 10.0,
                //     childAspectRatio: 1),
                itemBuilder: (ctx, index) {
                  FundRaisingCampaign campaign =
                      _fundRaisingController.campaigns[index];
                  return FundraisingCard(campaign: campaign).ripple(() {
                    _fundRaisingController.setCurrentCampaign(campaign);
                    Get.to(() => FundRaisingCampaignDetail(
                          campaign: campaign,
                        ))!.then((value) {
                      _fundRaisingController.clearDonors();
                      _fundRaisingController.clearComments();
                    });
                  });
                },
                separatorBuilder: (ctx, index) {
                  return const SizedBox(
                    height: 20,
                  );
                },
              ));
        });
  }
}

import 'package:foap/model/fund_raising_campaign.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../components/fund_raising/fund_raising_card.dart';
import '../../controllers/fund_raising/fund_raising_controller.dart';
import '../../helper/imports/common_import.dart';
import 'fund_raising_campaign_detail.dart';

class FavFundRaisingCampaignList extends StatelessWidget {
  final FundRaisingController _fundRaisingController = Get.find();

  FavFundRaisingCampaignList({super.key});
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(
            title: favCampaignsString.tr,
          ),
          Expanded(
              child: GetBuilder<FundRaisingController>(
                  init: _fundRaisingController,
                  builder: (ctx) {
                    return ListView.separated(
                      itemCount: _fundRaisingController.favCampaigns.length,
                      padding: EdgeInsets.only(
                          top: 20,
                          left: DesignConstants.horizontalPadding,
                          right: DesignConstants.horizontalPadding,
                          bottom: 50),
                      itemBuilder: (ctx, index) {
                        FundRaisingCampaign campaign =
                            _fundRaisingController.favCampaigns[index];
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
                    ).addPullToRefresh(
                        refreshController: _refreshController,
                        onRefresh: () {},
                        onLoading: () {
                          _fundRaisingController.getFavCampaigns(() {
                            _refreshController.loadComplete();
                          });
                        },
                        enablePullUp: true,
                        enablePullDown: false);
                  }))
        ],
      ),
    );
  }
}

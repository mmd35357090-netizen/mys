import 'package:foap/screens/fund_raising/donors_list.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../components/post_card/post_card.dart';
import '../../components/sm_tab_bar.dart';
import '../../controllers/fund_raising/fund_raising_controller.dart';
import '../../helper/imports/common_import.dart';
import '../../model/fund_raising_campaign.dart';
import '../post/add_post_screen.dart';
import 'about_campaign.dart';
import 'campaign_comment_screens.dart';

class FundRaisingCampaignDetail extends StatelessWidget {
  final FundRaisingController fundRaisingController = Get.find();
  final FundRaisingCampaign campaign;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  FundRaisingCampaignDetail({super.key, required this.campaign});

  final List<String> tabs = [
    aboutString.tr,
    postsString.tr,
    commentsString.tr,
    donorsString.tr
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBarWithTrailingWidget(
              title: '',
              widget: Obx(() => Container(
                    height: 40,
                    width: 40,
                    color: AppColorConstants.themeColor.withValues(alpha: 0.2),
                    child: ThemeIconWidget(
                        fundRaisingController.currentCampaign.value!.isFavourite
                            ? ThemeIcon.favFilled
                            : ThemeIcon.fav,
                        color: fundRaisingController
                                .currentCampaign.value!.isFavourite
                            ? AppColorConstants.red
                            : AppColorConstants.iconColor),
                  ).round(10).ripple(() {
                    fundRaisingController.favUnFavCampaign(
                        fundRaisingController.currentCampaign.value!);
                  }))),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    height: Get.height - (Get.height * 0.4),
                    child: DefaultTabController(
                        length: tabs.length,
                        initialIndex: 0,
                        child: Column(
                          children: [
                            SMTabBar(tabs: tabs, canScroll: true),
                            Expanded(
                              child: TabBarView(children: [
                                AboutCampaign(
                                  campaign: campaign,
                                ).hp(DesignConstants.horizontalPadding),
                                postsView(),
                                const CampaignCommentsScreen(),
                                DonorsList()
                              ]),
                            ),
                          ],
                        )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget postsView() {
    return Stack(
      children: [
        Obx(() => ListView.separated(
                padding: const EdgeInsets.only(top: 25, bottom: 100),
                itemBuilder: (BuildContext context, index) {
                  return PostCard(
                    model: fundRaisingController.posts[index],
                    removePostHandler: () {},
                    blockUserHandler: () {},
                  );
                },
                separatorBuilder: (BuildContext context, index) {
                  return const SizedBox(
                    height: 40,
                  );
                },
                itemCount: fundRaisingController.posts.length)
            .addPullToRefresh(
                refreshController: _refreshController,
                onRefresh: () {
                  fundRaisingController.refreshPosts(
                      id: campaign.id,
                      callback: () {
                        _refreshController.refreshCompleted();
                      });
                },
                onLoading: () {
                  fundRaisingController.loadMorePosts(
                      id: campaign.id,
                      callback: () {
                        _refreshController.loadComplete();
                      });
                },
                enablePullUp: true,
                enablePullDown: true)),
        if (campaign.amIDonor)
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              height: 50,
              width: 50,
              color: AppColorConstants.themeColor,
              child: ThemeIconWidget(
                ThemeIcon.edit,
                size: 25,
                color: Colors.white,
              ),
            ).circular.ripple(() {
              Future.delayed(
                Duration.zero,
                () => showGeneralDialog(
                    context: Get.context!,
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        AddPostScreen(
                            postType: PostCategory.fundRaising,
                            postCompletionHandler: () {
                              fundRaisingController.refreshPosts(
                                  id: campaign.id, callback: () {});
                            },
                            fundRaisingCampaign: campaign)),
              );
            }),
          )
      ],
    );
  }
}

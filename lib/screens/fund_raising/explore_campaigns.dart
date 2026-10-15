import 'package:foap/helper/imports/common_import.dart';
import '../../components/category_slider.dart';
import '../../components/paging_scrollview.dart';
import '../../controllers/fund_raising/fund_raising_controller.dart';
import 'fund_raising_campaigns_list.dart';

class ExploreCampaigns extends StatefulWidget {
  final bool fromCategory;

  const ExploreCampaigns({super.key, required this.fromCategory})
      ;

  @override
  State<ExploreCampaigns> createState() => _ExploreCampaignsState();
}

class _ExploreCampaignsState extends State<ExploreCampaigns> {
  final FundRaisingController _fundRaisingController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
            children: [
              backNavigationBar(
                title: campaignsString.tr,
              ),
              Expanded(
                child: PagingScrollView(
                    child: Column(
                      children: [
                        SFSearchBar(
                                onSearchChanged: (text) {
                                  _fundRaisingController.setTitle(text);
                                },
                                onSearchCompleted: (text) {})
                            .p(DesignConstants.horizontalPadding),
                        if (widget.fromCategory == false)
                          GetBuilder<FundRaisingController>(
                              init: _fundRaisingController,
                              builder: (ctx) {
                                return CategorySlider(
                                  categories: _fundRaisingController.categories,
                                  onSelection: (category) {
                                    _fundRaisingController
                                        .setCategoryId(category?.id);
                                  },
                                );
                              }).bp(40),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() => _fundRaisingController
                                        .totalCampaignsFound.value >
                                    0
                                ? Row(
                                    children: [
                                      Container(
                                        height: 20,
                                        width: 5,
                                        color: AppColorConstants.themeColor,
                                      ).round(5),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Obx(() => BodyLargeText(
                                          '${found.tr} ${_fundRaisingController.totalCampaignsFound} ${campaignsString.tr.toLowerCase()}',
                                          weight: TextWeight.semiBold)),
                                    ],
                                  ).hp(DesignConstants.horizontalPadding)
                                : Container()),
                            const SizedBox(
                              height: 20,
                            ),
                            FundRaisingCampaignList()
                          ],
                        )
                      ],
                    ),
                    loadMoreCallback: (refreshController) {
                      _fundRaisingController.getCampaigns(() {
                        refreshController.loadComplete();
                      });
                    }),
              ),
            ],
          ),
        ));
  }
}

import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/event_imports.dart';
import '../../components/category_slider.dart';
import '../../components/paging_scrollview.dart';
import '../../controllers/coupons/near_by_offers.dart';
import 'business_list.dart';

class ExploreBusiness extends StatefulWidget {
  final bool addBackBtn;
  final OffersCategoryModel? category;

  const ExploreBusiness({super.key, required this.addBackBtn, this.category})
      ;

  @override
  State<ExploreBusiness> createState() => _ExploreBusinessState();
}

class _ExploreBusinessState extends State<ExploreBusiness> {
  final NearByOffersController _offersController = Get.find();

  @override
  void initState() {
    super.initState();
    _offersController.setBusinessCategoryId(widget.category?.id);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: [
            backNavigationBar(
              title: businessesString.tr,
            ),
            Expanded(
              child: PagingScrollView(
                  child: Column(
                    children: [
                      SFSearchBar(
                              onSearchChanged: (text) {
                                _offersController.setBusinessName(text);
                              },
                              onSearchCompleted: (text) {})
                          .p(DesignConstants.horizontalPadding),
                      if (widget.category == null)
                        GetBuilder<NearByOffersController>(
                            init: _offersController,
                            builder: (ctx) {
                              return CategorySlider(
                                categories: _offersController.categories,
                                onSelection: (category) {
                                  _offersController
                                      .setBusinessCategoryId(category?.id);
                                },
                              );
                            }).bp(40),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() =>
                              _offersController.totalBusinessFound.value > 0
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
                                            '${found.tr} ${_offersController.totalBusinessFound} ${businessesString.tr.toLowerCase()}',
                                            weight: TextWeight.semiBold)),
                                      ],
                                    ).hp(DesignConstants.horizontalPadding)
                                  : Container()),
                          const SizedBox(
                            height: 20,
                          ),
                          BusinessList()
                        ],
                      )
                    ],
                  ),
                  loadMoreCallback: (refreshController) {
                    _offersController.getBusinesses(() {
                      refreshController.loadComplete();
                    });
                  }),
            ),
          ],
        ));
  }
}

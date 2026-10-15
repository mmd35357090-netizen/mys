import 'package:foap/helper/imports/common_import.dart';
import '../../components/category_slider.dart';
import '../../components/paging_scrollview.dart';
import '../../controllers/coupons/near_by_offers.dart';
import '../../model/category_model.dart';
import 'offers_list.dart';

class ExploreOffers extends StatefulWidget {
  final bool addBackBtn;
  final OffersCategoryModel? category;

  const ExploreOffers({super.key, required this.addBackBtn, this.category})
      ;

  @override
  State<ExploreOffers> createState() => _ExploreOffersState();
}

class _ExploreOffersState extends State<ExploreOffers> {
  final NearByOffersController _offersController = Get.find();

  @override
  void initState() {
    _offersController.setOfferCategoryId(widget.category?.id);
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
                  title: offers.tr,
                ),
                Expanded(
                  child: PagingScrollView(
                      child: Column(
                        children: [
                          SFSearchBar(
                                  onSearchChanged: (text) {
                                    _offersController.setOfferName(text);
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
                                          .setOfferCategoryId(category?.id);
                                    },
                                  );
                                }).bp(40),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() =>
                                  _offersController.totalOffersFound.value > 0
                                      ? Row(
                                          children: [
                                            Container(
                                              height: 20,
                                              width: 5,
                                              color:
                                                  AppColorConstants.themeColor,
                                            ).round(5),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Obx(() => BodyLargeText(
                                                '${found.tr} ${_offersController.totalOffersFound} ${offers.tr.toLowerCase()}',
                                                weight: TextWeight.semiBold)),
                                          ],
                                        ).hp(DesignConstants.horizontalPadding)
                                      : Container()),
                              const SizedBox(
                                height: 20,
                              ),
                              OffersList(source: OfferSource.normal)
                            ],
                          )
                        ],
                      ),
                      loadMoreCallback: (refreshController) {
                        _offersController.getOffers(() {
                          refreshController.loadComplete();
                        });
                      }),
                ),
              ],
            )));
  }
}

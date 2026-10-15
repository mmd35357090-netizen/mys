import 'package:foap/helper/imports/common_import.dart';
import '../../components/category_slider.dart';
import '../../components/paging_scrollview.dart';
import '../../controllers/coupons/near_by_offers.dart';
import 'offers_list.dart';

class ExploreFavOffers extends StatefulWidget {
  const ExploreFavOffers({super.key}) ;

  @override
  State<ExploreFavOffers> createState() => _ExploreFavOffersState();
}

class _ExploreFavOffersState extends State<ExploreFavOffers> {
  final NearByOffersController _offersController = Get.find();

  @override
  void initState() {
    _offersController.getFavOffers((){});
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
                  title: favouriteOffersString.tr,
                ),
                Expanded(
                  child: PagingScrollView(
                      child: Column(
                        children: [
                          SFSearchBar(
                                  onSearchChanged: (text) {
                                    _offersController.setFavOfferName(text);
                                  },
                                  onSearchCompleted: (text) {})
                              .p(DesignConstants.horizontalPadding),
                            GetBuilder<NearByOffersController>(
                                init: _offersController,
                                builder: (ctx) {
                                  return CategorySlider(
                                    categories: _offersController.categories,
                                    onSelection: (category) {
                                      _offersController
                                          .setFavOfferCategoryId(category?.id);
                                    },
                                  );
                                }).bp(40),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() =>
                                  _offersController.totalFavOffersFound.value > 0
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
                                                '${found.tr} ${_offersController.totalFavOffersFound} ${offers.tr.toLowerCase()}',
                                                weight: TextWeight.semiBold)),
                                          ],
                                        ).hp(DesignConstants.horizontalPadding)
                                      : Container()),
                              const SizedBox(
                                height: 20,
                              ),
                              OffersList(source: OfferSource.fav)
                            ],
                          )
                        ],
                      ),
                      loadMoreCallback: (refreshController) {
                        _offersController.getFavOffers(() {
                          refreshController.loadComplete();
                        });
                      }),
                ),
              ],
            )));
  }
}

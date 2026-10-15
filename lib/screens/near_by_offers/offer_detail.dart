import 'package:foap/controllers/coupons/near_by_offers.dart';
import 'package:foap/model/offer_model.dart';
import '../../components/sm_tab_bar.dart';
import '../../helper/imports/common_import.dart';
import 'about_offer.dart';
import 'offer_comments.dart';

class OfferDetail extends StatelessWidget {
  final NearByOffersController _offersController = Get.find();
  final OfferModel offer;

  OfferDetail({super.key, required this.offer}) ;

  final List<String> tabs = [
    aboutString.tr,
    commentsString.tr,
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        children: [
          backNavigationBarWithTrailingWidget(
              title: '',
              widget: Obx(() => Container(
                    height: 40,
                    width: 40,
                    color: AppColorConstants.themeColor.withValues(alpha: 0.2),
                    child: ThemeIconWidget(
                        _offersController.currentOffer.value!.isFavourite
                            ? ThemeIcon.favFilled
                            : ThemeIcon.fav,
                        color: _offersController.currentOffer.value!.isFavourite
                            ? AppColorConstants.red
                            : AppColorConstants.iconColor),
                  ).round(10).ripple(() {
                    _offersController
                        .favUnFavOffer(_offersController.currentOffer.value!);
                  }))),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SizedBox(
                    height: Get.height - (Get.height * 0.4),
                    child: DefaultTabController(
                        length: tabs.length,
                        initialIndex: 0,
                        child: Column(
                          children: [
                            SMTabBar(tabs: tabs, canScroll: false),
                            Expanded(
                              child: TabBarView(children: [
                                AboutOffer(
                                  offer: offer,
                                ).hp(DesignConstants.horizontalPadding),
                                const OfferCommentsScreen(),
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
}

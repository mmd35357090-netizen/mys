import 'package:foap/controllers/coupons/near_by_offers.dart';
import 'package:foap/model/offer_model.dart';
import 'package:foap/screens/near_by_offers/offer_detail.dart';
import '../../components/offers/offer_card.dart';
import '../../helper/imports/common_import.dart';

class OffersList extends StatelessWidget {
  final OfferSource source;
  final NearByOffersController _nearByOffersController = Get.find();

  OffersList({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: Get.width,
        child: GetBuilder<NearByOffersController>(
            init: _nearByOffersController,
            builder: (ctx) {
              List<OfferModel> offers = source == OfferSource.fav
                  ? _nearByOffersController.favOffers
                  : _nearByOffersController.offers;
              return offers.isEmpty
                  ? emptyData(title: noDataString, subTitle: '')
                  : SizedBox(
                      height: offers.length * 270,
                      child: ListView.separated(
                        itemCount: offers.length,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.only(
                            left: DesignConstants.horizontalPadding,
                            right: DesignConstants.horizontalPadding,
                            bottom: 50),
                        itemBuilder: (ctx, index) {
                          OfferModel offer = offers[index];

                          return OfferCard(
                            offer: offer,
                          ).ripple(() {
                            _nearByOffersController.setCurrentOffer(offer);
                            Get.to(() => OfferDetail(offer: offer));
                          });
                        },
                        separatorBuilder: (ctx, index) {
                          return const SizedBox(
                            height: 20,
                          );
                        },
                      ),
                    );
            }),
      ),
    );
  }
}

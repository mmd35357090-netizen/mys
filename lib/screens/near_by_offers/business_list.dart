import 'package:foap/controllers/coupons/near_by_offers.dart';
import 'package:foap/model/business_model.dart';
import '../../components/offers/business_card.dart';
import '../../helper/imports/common_import.dart';
import 'business_detail.dart';

class BusinessList extends StatelessWidget {
  final NearByOffersController _nearByOffersController = Get.find();

  BusinessList({super.key}) ;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NearByOffersController>(
        init: _nearByOffersController,
        builder: (ctx) {
          return SizedBox(
            height: _nearByOffersController.businessList.length * 270,
            child: ListView.separated(
              itemCount: _nearByOffersController.businessList.length,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                  left: DesignConstants.horizontalPadding,
                  right: DesignConstants.horizontalPadding,
                  bottom: 50),
              itemBuilder: (ctx, index) {
                BusinessModel business =
                    _nearByOffersController.businessList[index];
                return BusinessCard(business: business).ripple(() {
                  _nearByOffersController.setCurrentBusiness(business);
                  Get.to(() => BusinessDetail(
                        business: business,
                      ));
                });
              },
              separatorBuilder: (ctx, index) {
                return const SizedBox(
                  height: 20,
                );
              },
            ),
          );
        });
  }
}

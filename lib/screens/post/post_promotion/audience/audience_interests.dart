import 'package:foap/helper/imports/common_import.dart';
import '../../../../controllers/post/promotion_controller.dart';

class AudienceInterestsScreen extends StatelessWidget {
  AudienceInterestsScreen({super.key}) ;
  final PromotionController _promotionController = Get.find();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: GestureDetector(
          onTap: (){
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: GetBuilder<PromotionController>(
              init: _promotionController,
              builder: (ctx) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      customNavigationBar(title: interestsString.tr),
                      // const EstimatedAudienceTile(),
                      SFSearchBar(
                        onSearchCompleted: (value) => {},
                        onSearchChanged: (value) =>
                            _promotionController.searchInterests(value),
                        showSearchIcon: true,
                        // backgroundColor: AppColorConstants.subHeadingTextColor,
                        radius: 15,
                      ).p(DesignConstants.horizontalPadding),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            BodyMediumText(addInterests.tr,
                                color: AppColorConstants.subHeadingTextColor),
                            ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(top: 15),
                              itemBuilder: (BuildContext context, int index) {
                                final String name = _promotionController
                                    .searchedInterests[index].name;
                                return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      BodyLargeText(name),
                                      _promotionController
                                              .searchedInterests[index].isSelected
                                          ? ThemeIconWidget(
                                              ThemeIcon.checkMarkWithCircle,
                                              color: AppColorConstants.themeColor)
                                          : ThemeIconWidget(
                                              ThemeIcon.circleOutline,
                                              color: AppColorConstants.themeColor)
                                    ]).vP16.ripple(() {
                                  _promotionController.selectInterests(
                                      _promotionController
                                          .searchedInterests[index]);
                                });
                              },
                              itemCount:
                                  _promotionController.searchedInterests.length,
                            ),
                          ]).hp(DesignConstants.horizontalPadding)),
                    ]);
              }),
        ));
  }
}

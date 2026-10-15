import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/shop_model/category.dart';
import 'package:foap/screens/shop_feature/post_ad/upload_product_images.dart';
import '../../../model/shop_model/ad_model.dart';

class EnterAdDetail extends StatefulWidget {
  final AdModel adModel;

  const EnterAdDetail(this.adModel, {super.key});

  @override
  State<EnterAdDetail> createState() => EnterAdDetailState();
}

class EnterAdDetailState extends State<EnterAdDetail> {
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController price = TextEditingController();

  List<ShopCategoryModel> categories = [];

  String currency = "\$";

  @override
  void initState() {
    super.initState();
    fillForm();
  }

  void fillForm() {
    title.text = widget.adModel.title ?? '';
    description.text = widget.adModel.description ?? '';
    price.text = widget.adModel.price == null ? '' : '${widget.adModel.price}';
    currency = widget.adModel.currency ?? '\$';
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
            backNavigationBar(title: enterProductDetailString.tr),
            Expanded(
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 25,
                            ),
                            // AppTextField(
                            //   label: 'Brand',
                            //   hintText: 'Enter brand name',
                            //   controller: brandTF,
                            //   onChanged: (value) {
                            //     widget.adModel.brandName = value;
                            //   },
                            // ).bP16,
                            AppTextField(
                              label: titleString.tr,
                              hintText: enterTitleString.tr,
                              controller: title,
                              onChanged: (value) {
                                widget.adModel.title = value;
                              },
                            ).bP16,
                            AppTextField(
                              label: descriptionString.tr,
                              hintText: enterDescriptionString.tr,
                              controller: description,
                              maxLines: 100,
                              onChanged: (value) {
                                widget.adModel.description = value;
                              },
                            ).bP16,
                            BodyExtraSmallText(
                              priceString.tr,
                              color: AppColorConstants.subHeadingTextColor,
                              weight: TextWeight.semiBold,
                            ).bP8,
                            AppPriceTextField(
                              hintText: enterPriceString.tr,
                              controller: price,
                              currency: currency,
                              onChanged: (value) {
                                widget.adModel.price = value;
                              },
                              currencyValueChanged: (value) {
                                currency = value;
                                widget.adModel.currency = value;
                              },
                            ),
                            SizedBox(height: Get.height * 0.2),
                          ]),
                    ),
                    Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: AppThemeButton(
                          text: nextString.tr,
                          onPress: () {
                            nextBtnClicked();
                          },
                        ))
                  ],
                ),
              ).hp(DesignConstants.horizontalPadding),
            ),
          ],
        ),
      ),
    );
  }

  void nextBtnClicked() {
    if (widget.adModel.categoryId == null) {
      AppUtil.showToast(message: selectAdTypeString, isSuccess: false);
    } else if (widget.adModel.title == null) {
      AppUtil.showToast(message: enterTitleString, isSuccess: false);
    } else if (widget.adModel.description == null) {
      AppUtil.showToast(message: enterDescriptionString, isSuccess: false);
    } else if (widget.adModel.price == null) {
      AppUtil.showToast(message: enterPriceString, isSuccess: false);
    } else {
      widget.adModel.currency = currency;
      Get.to(() => UploadProductImages(widget.adModel));
    }
  }

  void openBottomSheet(Widget child) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (BuildContext bc) {
          return child;
        });
  }
}

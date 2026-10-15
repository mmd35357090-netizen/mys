import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/controllers/shop/shop_controller.dart';
import '../../../model/shop_model/ad_model.dart';

class ContactDetail extends StatefulWidget {
  final AdModel adModel;

  const ContactDetail({super.key, required this.adModel});

  @override
  State<ContactDetail> createState() => _ContactDetailState();
}

class _ContactDetailState extends State<ContactDetail> {
  final ShopController shopController = Get.find();
  TextEditingController address = TextEditingController();
  TextEditingController phone = TextEditingController();

  @override
  void initState() {
    address.text = widget.adModel.locations?.customLocation ?? '';
    phone.text = widget.adModel.phone ?? '';

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: contactDetailString.tr),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 25,
                  ),
                  AppMobileTextField(
                          hintText: '1234567899',
                          label: phoneNumberString.tr,
                          countryCodeText: '+1',
                          controller: phone,
                          onChanged: (value) {
                            widget.adModel.phone = value;
                          },
                          countryCodeValueChanged: (value) {
                            // widget.adModel.ph = value;
                          })
                      .bP16,
                  AppTextField(
                    label: addressString.tr,
                    hintText:
                        'Shellway Rd, Ellesmere Port Cheshire West and Chester',
                    controller: address,
                    maxLines: 10,
                    onChanged: (value) {
                      widget.adModel.address = value;
                    },
                  ).bP16,
                  AppThemeButton(
                    text: submitString.tr,
                    onPress: () {
                      submitBtnClicked();
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ).hp(DesignConstants.horizontalPadding),
            ),
          ),
        ],
      ),
    );
  }

  void submitBtnClicked() {
    widget.adModel.address = address.text;
    shopController.postAd(ad: widget.adModel);
  }
}

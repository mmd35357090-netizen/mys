import 'package:foap/components/place_picker/entities/location_result.dart';
import 'package:foap/components/place_picker/widgets/place_picker.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/add_on/controller/event/create_event/add_event_controller.dart';
import 'package:foap/screens/add_on/ui/event/create_event/upload_event_images.dart';

class EnterEventDetail extends StatefulWidget {
  const EnterEventDetail({super.key});

  @override
  State<EnterEventDetail> createState() => EnterEventDetailState();
}

class EnterEventDetailState extends State<EnterEventDetail> {
  TextEditingController name = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController disclaimer = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController placeName = TextEditingController();

  final AddEventController addEventController = Get.find();

  @override
  void initState() {
    super.initState();
    fillForm();
  }

  void fillForm() {
    name.text = addEventController.creatingEvent.value.name ?? '';
    description.text =
        addEventController.creatingEvent.value.description ?? '';
    disclaimer.text =
        addEventController.creatingEvent.value.disclaimer ?? '';
    placeName.text =
        addEventController.creatingEvent.value.placeName ?? '';
    address.text =
        addEventController.creatingEvent.value.completeAddress ?? '';
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
            backNavigationBar(title: enterEventDetailString.tr),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 25,
                          ),
                          AppTextField(
                            label: nameString.tr,
                            hintText: enterNameString.tr,
                            controller: name,
                            onChanged: (value) {},
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          AppTextField(
                            label: descriptionString.tr,
                            hintText: typeHereString.tr,
                            controller: description,
                            maxLines: 5,
                            onChanged: (value) {},
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     BodySmallText(
                          //       eventTypeString.tr,
                          //     ).bP8,
                          //     Obx(() => Row(
                          //           children: [
                          //             Row(
                          //               children: [
                          //                 Container(
                          //                   height: 20,
                          //                   width: 20,
                          //                   color: addEventController
                          //                               .creatingEvent
                          //                               .value
                          //                               .isFree ==
                          //                           true
                          //                       ? AppColorConstants
                          //                           .themeColor
                          //                       : Colors.transparent,
                          //                   child: addEventController
                          //                               .creatingEvent
                          //                               .value
                          //                               .isFree ==
                          //                           true
                          //                       ? ThemeIconWidget(
                          //                           ThemeIcon.checkMark,
                          //                           color: Colors.white)
                          //                       : Container(),
                          //                 ).borderWithRadius(
                          //                     value: 1, radius: 5),
                          //                 const SizedBox(
                          //                   width: 10,
                          //                 ),
                          //                 BodySmallText(
                          //                   freeString.tr,
                          //                 ),
                          //               ],
                          //             ).ripple(() {
                          //               addEventController
                          //                   .setIsFreeFlag(true);
                          //             }),
                          //             const SizedBox(
                          //               width: 20,
                          //             ),
                          //             Row(
                          //               children: [
                          //                 Container(
                          //                   height: 20,
                          //                   width: 20,
                          //                   color: addEventController
                          //                               .creatingEvent
                          //                               .value
                          //                               .isFree ==
                          //                           false
                          //                       ? AppColorConstants
                          //                           .themeColor
                          //                       : Colors.transparent,
                          //                   child: addEventController
                          //                               .creatingEvent
                          //                               .value
                          //                               .isFree ==
                          //                           false
                          //                       ? ThemeIconWidget(
                          //                           ThemeIcon.checkMark,
                          //                           color: Colors.white,
                          //                         )
                          //                       : Container(),
                          //                 )
                          //                     .borderWithRadius(
                          //                         value: 1, radius: 5)
                          //                     .ripple(() {
                          //                   addEventController
                          //                       .setIsFreeFlag(false);
                          //                 }),
                          //                 const SizedBox(
                          //                   width: 10,
                          //                 ),
                          //                 BodySmallText(
                          //                   paidString.tr,
                          //                 ),
                          //               ],
                          //             )
                          //           ],
                          //         )),
                          //   ],
                          // ),
                          // const SizedBox(
                          //   height: 20,
                          // ),
                          AppTextField(
                            label: placeNameString.tr,
                            hintText: typeHereString.tr,
                            controller: placeName,
                            onChanged: (value) {},
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          AbsorbPointer(
                            absorbing: true,
                            child: AppTextField(
                              label: addressString.tr,
                              hintText:
                                  'Shellway Rd, Ellesmere Port Cheshire West and Chester',
                              controller: address,
                              maxLines: 10,
                              onChanged: (value) {},
                            ),
                          ).ripple(() {
                            openLocationPicker();
                          }),
                          const SizedBox(
                            height: 20,
                          ),
                          AppDateTextField(
                            hintText: 'yyyy-MM-dd',
                            format: 'yyyy-MM-dd',
                            minDate: addEventController
                                    .creatingEvent.value.startDate ??
                                DateTime.now(),
                            selectedDate: addEventController
                                .creatingEvent.value.startDate,
                            label: 'Start Date',
                            onChanged: (date) {
                              addEventController.setStartDate(date);
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Obx(
                            () => addEventController.creatingEvent.value
                                        .startDateInMillisecond ==
                                    null
                                ? Container()
                                : Column(
                                    children: [
                                      AppDateTextField(
                                        hintText: 'yyyy-MM-dd',
                                        format: 'yyyy-MM-dd',
                                        selectedDate: addEventController
                                            .creatingEvent.value.endDate,
                                        label: endDateString.tr,
                                        minDate: addEventController
                                            .creatingEvent.value.startDate,
                                        onChanged: (date) {
                                          addEventController
                                              .setEndDate(date);
                                        },
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                          ),
                          AppTextField(
                            label: disclaimerString.tr,
                            hintText: typeHereString.tr,
                            controller: disclaimer,
                            maxLines: 5,
                            onChanged: (value) {},
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
              ).hp(DesignConstants.horizontalPadding),
            ),
          ],
        ),
      ),
    );
  }

  void nextBtnClicked() {
    if (name.text.isEmpty) {
      AppUtil.showToast(
          message: pleaseEnterNameString.tr, isSuccess: false);
    } else if (description.text.isEmpty) {
      AppUtil.showToast(
          message: pleaseEnterDescriptionString.tr, isSuccess: false);
    } else if (addEventController.creatingEvent.value.completeAddress ==
        null) {
      AppUtil.showToast(
          message: pleaseEnterAddressString.tr, isSuccess: false);
    } else if (addEventController
            .creatingEvent.value.startDateInMillisecond ==
        null) {
      AppUtil.showToast(
          message: pleaseSelectStartDateString.tr, isSuccess: false);
    } else if (addEventController
            .creatingEvent.value.endDateInMillisecond ==
        null) {
      AppUtil.showToast(
          message: pleaseSelectEndDateString.tr, isSuccess: false);
    } else {
      addEventController.creatingEvent.value.name = name.text;
      addEventController.creatingEvent.value.description =
          description.text;
      addEventController.creatingEvent.value.disclaimer = disclaimer.text;
      addEventController.creatingEvent.value.placeName = placeName.text;

      Get.to(() => const UploadEventImages());
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

  void openLocationPicker() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) => FractionallySizedBox(
            heightFactor: 0.9,
            child: PlacePicker(
              apiKey: AppConfigConstants.googleMapApiKey,
              displayLocation: null,
            ))).then((location) {
      if (location != null) {
        LocationResult result = location as LocationResult;

        addEventController.creatingEvent.value.completeAddress =
            result.name;
        addEventController.creatingEvent.value.latitude =
            result.latLng!.latitude.toString();
        addEventController.creatingEvent.value.longitude =
            result.latLng!.longitude.toString();

        address.text = result.name ?? '';
      } else {

      }
    });
  }
}

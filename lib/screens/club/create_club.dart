import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/club_imports.dart';
import '../../model/generic_item.dart';
import '../../universal_components/rounded_input_field.dart';

class CreateClub extends StatefulWidget {
  final ClubModel club;

  const CreateClub({Key? key, required this.club}) : super(key: key);

  @override
  CreateClubState createState() => CreateClubState();
}

class CreateClubState extends State<CreateClub> {
  final CreateClubController _createClubController = CreateClubController();
  final ClubDetailController _clubDetailController = ClubDetailController();

  final TextEditingController nameText = TextEditingController();
  final TextEditingController descText = TextEditingController();

  GenericItem? selectedItem;

  @override
  void initState() {
    if (widget.club.id != null) {
      nameText.text = widget.club.name!;
      descText.text = widget.club.desc!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Stack(
        children: [
          SizedBox(
            height: Get.height,
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                backNavigationBar(
                  context: context,
                  title: widget.club.id == null
                      ? LocalizationString.createClub
                      : LocalizationString.editClubInfo,
                ),
                divider(context: context).tP8,
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Heading5Text(
                              LocalizationString.basicInfo,
                                weight: TextWeight.bold
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            InputField(
                              controller: nameText,
                              showBorder: true,
                              cornerRadius: 5,
                              hintText: LocalizationString.clubName,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            InputField(
                              controller: descText,
                              showBorder: true,
                              cornerRadius: 5,
                              maxLines: 5,
                              hintText: LocalizationString.clubDescription,
                            ),

                            if (widget.club.id == null) selectGroupPrivacyWidget(),

                            if (widget.club.id == null) chatGroupWidget(),
                            const SizedBox(height: 150,)
                            // const Spacer(),
                          ],
                        ).hP16,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color:AppColorConstants.cardColor,
                child: AppThemeButton(
                    text: widget.club.id == null
                        ? LocalizationString.next
                        : LocalizationString.update,
                    onPress: () {
                      nextBtnClicked();
                    }).setPadding(left: 16, right: 16, bottom: 25,top: 25),
              ))
        ],
      ),
    );
  }

  Widget chatGroupWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 50,
        ),
        Heading5Text(
          LocalizationString.communication,
            weight: TextWeight.bold
        ),
        const SizedBox(
          height: 20,
        ),
        Obx(() =>
            privacyTypeWidget(
                id: 4,
                title: LocalizationString.chatGroup,
                subTitle: LocalizationString.createChatGroupForDiscussion,
                isSelected: _createClubController.enableChat.value,
                icon: ThemeIcon.chat,
                callback: () {
                  _createClubController.toggleChatGroup();
                })),
      ],
    );
  }

  Widget selectGroupPrivacyWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 30,
        ),
        Heading5Text(
          LocalizationString.privacy,
            weight: TextWeight.bold
        ),
        const SizedBox(
          height: 20,
        ),
        Obx(() =>
            privacyTypeWidget(
                id: 2,
                title: LocalizationString.public,
                subTitle: LocalizationString.anyoneCanSeeClub,
                isSelected: _createClubController.privacyType.value == 1,
                icon: ThemeIcon.public,
                callback: () {
                  _createClubController.privacyTypeChange(1);
                })),
        const SizedBox(
          height: 20,
        ),
        Obx(() =>
            privacyTypeWidget(
                id: 1,
                title: LocalizationString.private,
                subTitle: LocalizationString.onlyMembersCanSeeClub,
                isSelected: _createClubController.privacyType.value == 2,
                icon: ThemeIcon.lock,
                callback: () {
                  _createClubController.privacyTypeChange(2);
                })),
        const SizedBox(
          height: 20,
        ),
        Obx(() =>
            privacyTypeWidget(
                id: 3,
                title: LocalizationString.onRequest,
                subTitle: LocalizationString.onClubRequestJoin,
                isSelected: _createClubController.privacyType.value == 3,
                icon: ThemeIcon.request,
                callback: () {
                  _createClubController.privacyTypeChange(3);
                })),
      ],
    );
  }

  Widget privacyTypeWidget({required int id,
    required ThemeIcon icon,
    required String title,
    required String subTitle,
    required bool isSelected,
    required VoidCallback callback}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
            color: AppColorConstants.themeColor,
            child: ThemeIconWidget(
              icon,
              color: AppColorConstants.iconColor,
            ).p4)
            .circular,
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyLargeText(
                title,
              weight: TextWeight.semiBold

              ),
              const SizedBox(
                height: 5,
              ),
              BodySmallText(
                subTitle,

              ),
            ],
          ),
        ),
        // Spacer(),
        ThemeIconWidget(
          isSelected ? ThemeIcon.selectedCheckbox : ThemeIcon.emptyCheckbox,
          size: 25,
          color: isSelected
              ? AppColorConstants.themeColor
              : AppColorConstants.iconColor,
        )
      ],
    ).ripple(() {
      callback();
    });
  }


  nextBtnClicked() {
    if (nameText.text.isEmpty) {
      AppUtil.showToast(
          message: LocalizationString.pleaseEnterClubName,
          isSuccess: false);
      return;
    }
    if (descText.text.isEmpty) {
      AppUtil.showToast(
          message: LocalizationString.pleaseEnterClubDesc,
          isSuccess: false);
      return;
    }

    widget.club.name = nameText.text;
    widget.club.desc = descText.text;

    if (widget.club.id == null) {
      widget.club.enableChat = _createClubController.enableChat.value ? 1 : 0;
      Get.to(() =>
          ChooseClubCoverPhoto(
            club: widget.club,
          ));
    } else {
      _createClubController.updateClubInfo(
          club: widget.club,
          callback: () {
            _clubDetailController.setEvent(widget.club);
          });
    }
  }
}

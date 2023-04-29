import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/club_imports.dart';
import 'package:image_picker/image_picker.dart';

class ChooseClubCoverPhoto extends StatefulWidget {
  final ClubModel club;

  const ChooseClubCoverPhoto(
      {Key? key, required this.club})
      : super(key: key);

  @override
  ChooseClubCoverPhotoState createState() => ChooseClubCoverPhotoState();
}

class ChooseClubCoverPhotoState extends State<ChooseClubCoverPhoto> {
  final CreateClubController _createClubsController = CreateClubController();
  final ClubDetailController _clubDetailController = ClubDetailController();

  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 50,
          ),
          backNavigationBar(
            context: context,
            title: LocalizationString.addClubCoverPhoto,
          ),
          divider(context: context).tP8,
          const SizedBox(
            height: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Heading4Text(
                LocalizationString.addClubPhoto,
                weight: TextWeight.semiBold,
              ),
              BodyMediumText(
                LocalizationString.addClubPhotoSubHeading,
                color: AppColorConstants.grayscale500,
              ),
              const SizedBox(
                height: 20,
              ),
              Heading6Text(
                LocalizationString.coverPhoto,
              ),
            ],
          ).hP16,
          Obx(() => SizedBox(
                height: 250,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _createClubsController.imageFile.value == null
                        ? widget.club.image == null
                            ? Container(
                                child: const ThemeIconWidget(
                                  ThemeIcon.gallery,
                                  size: 100,
                                ).round(5),
                              ).borderWithRadius(
                                value: 2, radius: 10)
                            : CachedNetworkImage(
                                imageUrl: widget.club.image!,
                                fit: BoxFit.cover,
                              ).round(5)
                        : Image.file(
                            _createClubsController.imageFile.value!,
                            fit: BoxFit.cover,
                          ).round(5),
                    Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          color: AppColorConstants.cardColor,
                          child: Row(
                            children: [
                              ThemeIconWidget(
                                ThemeIcon.edit,
                                size: 20,
                                color: AppColorConstants.iconColor,
                              ),
                              BodyLargeText(
                                LocalizationString.edit,
                              )
                            ],
                          )
                              .setPadding(left: 8, right: 8, top: 4, bottom: 4)
                              .borderWithRadius(
                                  value: 2, radius: 5),
                        ).ripple(() {
                          picker
                              .pickImage(source: ImageSource.gallery)
                              .then((pickedFile) {
                            if (pickedFile != null) {
                              _createClubsController.editClubImageAction(
                                  pickedFile, context);
                            } else {}
                          });
                        }))
                  ],
                ),
              )).p16,
          const Spacer(),
          AppThemeButton(
              text: widget.club.id == null
                  ? LocalizationString.createClub
                  : LocalizationString.update,
              onPress: () {
                if (widget.club.id == null) {
                  createBtnClicked();
                } else {
                  updateBtnClicked();
                }
              }).hP16,
          const SizedBox(
            height: 50,
          )
        ],
      ),
    );
  }

  createBtnClicked() {
    if (_createClubsController.imageFile.value == null) {
      AppUtil.showToast(
          message: LocalizationString.pleaseEnterSelectCubImage,
          isSuccess: false);
      return;
    }
    _createClubsController.createClub(widget.club, context, () {
    });
  }

  updateBtnClicked() {
    _createClubsController.updateClubImage(widget.club, context, (club) {
      // widget.submittedCallback(widget.club);
      _clubDetailController.setEvent(widget.club);

    });
  }
}

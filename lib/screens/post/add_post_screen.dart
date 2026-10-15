import 'package:foap/components/smart_text_field.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/models.dart';
import 'package:foap/helper/imports/setting_imports.dart';
import 'package:foap/model/fund_raising_campaign.dart';
import 'package:foap/screens/post/post_option_popup.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/place_picker/entities/location_result.dart';
import '../../components/place_picker/widgets/place_picker.dart';
import '../../components/post_card/video_widget.dart';
import '../../controllers/post/add_post_controller.dart';
import '../../controllers/post/select_post_media_controller.dart';
import '../../util/constant_util.dart';
import '../dashboard/dashboard_screen.dart';
import 'add_collaboratots.dart';
import 'create_poll.dart';
import 'tag_hashtag_view.dart';
import 'tag_users_view.dart';
import '../chat/media.dart';
import 'audio_file_player.dart';
import 'dart:io';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:giphy_get/giphy_get.dart';
import '../chat/drawing_screen.dart';
import '../chat/voice_record.dart';

class AddPostScreen extends StatefulWidget {
  final PostCategory postType;

  final List<Media>? items;
  final CompetitionModel? competition;
  final ClubModel? club;
  final EventModel? event;
  final FundRaisingCampaign? fundRaisingCampaign;

  final bool? isReel;
  final int? audioId;
  final double? audioStartTime;
  final double? audioEndTime;
  final VoidCallback postCompletionHandler;

  const AddPostScreen(
      {super.key,
      required this.postType,
      required this.postCompletionHandler,
      this.items,
      this.competition,
      this.club,
      this.event,
      this.fundRaisingCampaign,
      this.isReel,
      this.audioId,
      this.audioStartTime,
      this.audioEndTime});

  @override
  AddPostState createState() => AddPostState();
}

class AddPostState extends State<AddPostScreen> {
  final SelectPostMediaController _selectPostMediaController =
      SelectPostMediaController();
  final SmartTextFieldController _smartTextFieldController = Get.find();
  final SettingsController settingController = Get.find();
  final AddPostController addPostController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();
  final ImagePicker _picker = ImagePicker();
  final SettingsController _settingsController = Get.find();

  @override
  void initState() {
    _smartTextFieldController.clear();
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
      body: GetBuilder<AddPostController>(
          init: addPostController,
          builder: (ctx) {
            return Stack(
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(
                        height: 55,
                      ),
                      Row(
                        children: [
                          InkWell(
                              onTap: () {
                                Get.back();
                                addPostController.clear();

                                if (!settingsController
                                    .setting.value!.enableReel) {
                                  DashboardController dashboardController =
                                      Get.find();

                                  dashboardController.indexChanged(0);
                                }
                              },
                              child: ThemeIconWidget(ThemeIcon.backArrow)),
                          const Spacer(),
                          Container(
                                  color: AppColorConstants.themeColor,
                                  child: BodyLargeText(
                                    widget.competition == null
                                        ? postString.tr
                                        : submitString.tr,
                                    weight: TextWeight.medium,
                                    color: Colors.white,
                                  ).setPadding(
                                      left: 8,
                                      right: 8,
                                      top: 5,
                                      bottom: 5))
                              .round(10)
                              .ripple(() {
                            if ((widget.items ??
                                        _selectPostMediaController
                                            .selectedMediaList)
                                    .isNotEmpty ||
                                _smartTextFieldController
                                    .textField.value.text.isNotEmpty) {
                              addPostController.submitPost(
                                  allowComments: addPostController
                                      .enableComments.value,
                                  postType: widget.postType,
                                  isPaidContent: addPostController
                                      .isPaidContent.value,
                                  isReel: widget.isReel ?? false,
                                  audioId: widget.audioId,
                                  audioStartTime: widget.audioStartTime,
                                  audioEndTime: widget.audioEndTime,
                                  items: widget.items ??
                                      _selectPostMediaController
                                          .selectedMediaList,
                                  title: _smartTextFieldController
                                      .textField.value.text,
                                  competitionId: widget.competition?.id,
                                  clubId: widget.club?.id,
                                  eventId: widget.event?.id,
                                  fundRaisingCampaignId:
                                      widget.fundRaisingCampaign?.id,
                                  postCompletionHandler:
                                      widget.postCompletionHandler);
                            }
                          }),
                        ],
                      ).hp(DesignConstants.horizontalPadding),
                      const SizedBox(
                        height: 30,
                      ),
                      postSourceWidget(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          media().ripple(() {
                            showModalBottomSheet<void>(
                                backgroundColor: Colors.transparent,
                                context: context,
                                enableDrag: true,
                                isDismissible: true,
                                isScrollControlled: true,
                                builder: (BuildContext context) {
                                  return FractionallySizedBox(
                                      heightFactor: 1,
                                      child: Container(
                                        color: AppColorConstants
                                            .backgroundColor,
                                        child: AddedMediaList(
                                          selectPostMediaController:
                                              _selectPostMediaController,
                                        ),
                                      ));
                                });
                          }),
                          Expanded(child: addDescriptionView()),
                        ],
                      ).hp(DesignConstants.horizontalPadding),
                      if (widget.isReel != true)
                        PostOptionsPopup(
                          callbackHandler: (option) {
                            postOptionSelected(option);
                          },
                        ).vP25,
                      SizedBox(
                        height: 50,
                        child: Row(
                          children: [
                            ThemeIconWidget(ThemeIcon.message),
                            const SizedBox(
                              width: 10,
                            ),
                            BodyMediumText(allowCommentsString),
                            const Spacer(),
                            Obx(() => ThemeIconWidget(addPostController
                                            .enableComments.value
                                        ? ThemeIcon.selectedCheckbox
                                        : ThemeIcon.emptyCheckbox)
                                    .ripple(() {
                                  addPostController.toggleEnableComments();
                                })),
                          ],
                        ),
                      ).hp(DesignConstants.horizontalPadding),
                      if (_userProfileManager
                          .user.value!.subscriptionPlans.isNotEmpty)
                        SizedBox(
                          height: 50,
                          child: Row(
                            children: [
                              ThemeIconWidget(ThemeIcon.diamond),
                              const SizedBox(
                                width: 10,
                              ),
                              BodyMediumText(forSubscribersOnlyString),
                              const Spacer(),
                              Obx(() => ThemeIconWidget(addPostController
                                              .isPaidContent.value
                                          ? ThemeIcon.selectedCheckbox
                                          : ThemeIcon.emptyCheckbox)
                                      .ripple(() {
                                    addPostController
                                        .togglePaidContentMode();
                                  })),
                            ],
                          ),
                        ).hp(DesignConstants.horizontalPadding),
                      divider(height: 0.5),
                      SizedBox(
                        height: 50,
                        child: Row(
                          children: [
                            ThemeIconWidget(ThemeIcon.location),
                            const SizedBox(
                              width: 10,
                            ),
                            Obx(() =>
                                addPostController.taggedLocation.value ==
                                        null
                                    ? BodyMediumText(addLocationString)
                                    : BodyLargeText(addPostController
                                        .taggedLocation.value!.name)),
                            const Spacer(),
                            Obx(() =>
                                addPostController.taggedLocation.value ==
                                        null
                                    ? ThemeIconWidget(ThemeIcon.nextArrow)
                                    : ThemeIconWidget(ThemeIcon.close)
                                        .ripple(() {
                                        addPostController
                                            .setTaggedLocation(null);
                                      })),
                          ],
                        ),
                      ).hp(DesignConstants.horizontalPadding).ripple(() {
                        openLocationPicker();
                      }),
                      divider(height: 0.5),
                      SizedBox(
                        height: 50,
                        child: Row(
                          children: [
                            ThemeIconWidget(ThemeIcon.account),
                            const SizedBox(
                              width: 10,
                            ),
                            Obx(() => Wrap(
                                  children: [
                                    BodyMediumText(addCollaboratorString),
                                    if (addPostController
                                        .collaborators.isNotEmpty)
                                      BodyMediumText(
                                          '(${addPostController.collaborators.length} $collaboratorsString)'),
                                  ],
                                )),
                            const Spacer(),
                            ThemeIconWidget(ThemeIcon.nextArrow),
                          ],
                        ),
                      ).hp(DesignConstants.horizontalPadding).ripple(() {
                        Get.to(() => const AddCollaborators(),
                            fullscreenDialog: true);
                      }),
                      divider(height: 0.5),
                      const SizedBox(
                        height: 10,
                      ),
                      Obx(() {
                        return _smartTextFieldController.isEditing.value ==
                                1
                            ? Expanded(
                                child: Container(
                                  // height: 500,
                                  width: double.infinity,
                                  color: AppColorConstants.disabledColor
                                      .withValues(alpha: 0.1),
                                  child: _smartTextFieldController
                                          .currentHashtag.isNotEmpty
                                      ? TagHashtagView()
                                      : _smartTextFieldController
                                              .currentUserTag.isNotEmpty
                                          ? TagUsersView()
                                          : Container().ripple(() {
                                              FocusManager
                                                  .instance.primaryFocus
                                                  ?.unfocus();
                                            }),
                                ),
                              )
                            : Container();
                      }),
                      Obx(() =>
                          _smartTextFieldController.isEditing.value == 0
                              ? const Spacer()
                              : Container()),
                    ]),
              ],
            );
          }),
    );
  }

  postOptionSelected(PostOptionType type) {
    if (type == PostOptionType.camera) {
      selectPhoto(
        source: ImageSource.camera,
      );
    } else if (type == PostOptionType.gallery) {
      selectPhoto(
        source: ImageSource.gallery,
      );
    } else if (type == PostOptionType.video) {
      selectVideo(
        source: ImageSource.gallery,
      );
    } else if (type == PostOptionType.drawing) {
      openDrawingBoard();
    } else if (type == PostOptionType.audio) {
      openVoiceRecord();
    } else if (type == PostOptionType.gif) {
      openGify();
    } else if (type == PostOptionType.poll) {
      Get.to(() => CreatePoll(), fullscreenDialog: true);
    }
  }

  Widget postSourceWidget() {
    String image = '';
    String name = '';
    if (widget.club != null) {
      image = widget.club!.image!;
      name = widget.club!.name!;
    } else if (widget.event != null) {
      image = widget.event!.image;
      name = widget.event!.name;
    } else if (widget.fundRaisingCampaign != null) {
      image = widget.fundRaisingCampaign!.coverImage;
      name = widget.fundRaisingCampaign!.title;
    }
    if (image.isNotEmpty && name.isNotEmpty) {
      return Container(
        color: AppColorConstants.cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 20,
                  width: 5,
                  color: AppColorConstants.themeColor,
                ).round(10),
                const SizedBox(
                  width: 5,
                ),
                BodyLargeText(postingInString.tr),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                CachedNetworkImage(
                  height: 40,
                  width: 40,
                  imageUrl: image,
                  fit: BoxFit.cover,
                ).round(10),
                const SizedBox(
                  width: 10,
                ),
                BodyLargeText(name),
              ],
            )
          ],
        ).p16,
      ).round(15).setPadding(
          left: DesignConstants.horizontalPadding,
          right: DesignConstants.horizontalPadding,
          bottom: DesignConstants.horizontalPadding);
    }
    return Container();
  }

  Widget media() {
    return Obx(() {
      if (_selectPostMediaController.selectedMediaList.isNotEmpty) {
        Media media = _selectPostMediaController.selectedMediaList.first;
        return Container(
          height: 70,
          width: 70,
          color: AppColorConstants.cardColor,
          child: media.mediaType == GalleryMediaType.photo
              ? Image.file(
                  media.file!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                )
              : media.mediaType == GalleryMediaType.gif
                  ? CachedNetworkImage(
                      fit: BoxFit.cover, imageUrl: media.filePath!)
                  : media.mediaType == GalleryMediaType.video
                      ? Stack(
                          children: [
                            Image.memory(
                              media.thumbnail!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                            Container(
                              color: Colors.black45,
                            ),
                            Center(
                              child: ThemeIconWidget(
                                ThemeIcon.play,
                                size: 50,
                                color: Colors.white,
                              ),
                            )
                          ],
                        )
                      : ThemeIconWidget(ThemeIcon.mic),
        ).round(10).rP8;
      } else {
        return Container();
      }
    });
  }

  Widget addDescriptionView() {
    return SizedBox(
      height: 70,
      child: Obx(() {
        return Container(
          color: AppColorConstants.cardColor,
          child: SmartTextField(
              maxLine: 5,
              controller: _smartTextFieldController.textField.value,
              onTextChangeActionHandler: (text, offset) {
                _smartTextFieldController.textChanged(text, offset);
              },
              onFocusChangeActionHandler: (status) {
                if (status == true) {
                  _smartTextFieldController.startedEditing();
                } else {
                  _smartTextFieldController.stoppedEditing();
                }
              }),
        ).round(5);
      }),
    );
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
        LocationModel locationModel = LocationModel(
            latitude: result.latLng!.latitude,
            longitude: result.latLng!.longitude,
            name: result.name!);
        addPostController.setTaggedLocation(locationModel);
      }
    });
  }

  selectPhoto({
    required ImageSource source,
  }) async {
    if (source == ImageSource.camera) {
      XFile? image = await _picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        convertToMedias(files: [image], mediaType: GalleryMediaType.photo);
      }
    } else {
      List<XFile> images = await _picker.pickMultiImage();
      // print('images ${images.length}');
      convertToMedias(files: images, mediaType: GalleryMediaType.photo);
    }
  }

  selectVideo({
    required ImageSource source,
  }) async {
    XFile? file = await _picker.pickVideo(source: source);

    if (file != null) {
      convertToMedias(files: [file], mediaType: GalleryMediaType.video);
    }
  }

  convertToMedias(
      {required List<XFile> files,
      required GalleryMediaType mediaType}) async {
    List<Media> medias = [];
    for (XFile mediaFile in files) {
      Media media = Media();
      media.mediaType = mediaType;
      File file = File(mediaFile.path);
      media.file = file;

      if (mediaType == GalleryMediaType.video) {
        final videoInfo = await VideoCompress.getMediaInfo(mediaFile.path);

        media.size = Size(
            videoInfo.width!.toDouble(), videoInfo.height!.toDouble());

        media.thumbnail = await VideoThumbnail.thumbnailData(
          video: mediaFile.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 500,
          // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
          quality: 25,
        );
      }

      media.id = randomId();
      medias.add(media);
    }

    _selectPostMediaController.mediaSelected(medias);
  }

  void openVoiceRecord() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: Get.context!,
        builder: (context) => FractionallySizedBox(
              heightFactor: 0.7,
              child: VoiceRecord(
                recordingCallback: (media) async {
                  _selectPostMediaController.mediaSelected([media]);
                },
              ),
            ));
  }

  void openGify() async {
    String randomId = 'hsvcewd78djhbejkd';

    GiphyGif? gif = await GiphyGet.getGif(
      context: Get.context!,
      //Required
      apiKey: _settingsController.setting.value!.giphyApiKey!,
      //Required.
      lang: GiphyLanguage.english,
      //Optional - Language for query.
      randomID: randomId,
      // Optional - An ID/proxy for a specific user.
      tabColor: Colors.teal, // Optional- default accent color.
    );

    if (gif != null) {
      Media media = Media();
      media.filePath = 'https://i.giphy.com/media/${gif.id}/200.gif';
      media.mediaType = GalleryMediaType.gif;
      _selectPostMediaController.mediaSelected([media]);
    }
  }

  void openDrawingBoard() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: Get.context!,
        // isDismissible: false,
        isScrollControlled: true,
        // enableDrag: false,
        builder: (context) => FractionallySizedBox(
            heightFactor: 0.9,
            child: DrawingScreen(
              drawingCompleted: (media) {
                Loader.show(status: loadingString);
                Future.delayed(const Duration(milliseconds: 200), () {
                  Loader.dismiss();
                  _selectPostMediaController.mediaSelected([media]);
                });
              },
            )));
  }
}

class AddedMediaList extends StatelessWidget {
  final SelectPostMediaController selectPostMediaController;
  final SettingsController settingController = Get.find();

  AddedMediaList({super.key, required this.selectPostMediaController});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 40,
            ),
            Row(
              children: [
                SizedBox(
                  width: DesignConstants.horizontalPadding,
                ),
                Container(
                    height: 40,
                    width: 40,
                    color: AppColorConstants.themeColor,
                    child: ThemeIconWidget(
                      ThemeIcon.close,
                      color: Colors.white,
                    )).circular.ripple(() {
                  Navigator.pop(context);
                })
              ],
            ),
            SizedBox(
              height: Get.height * 0.5,
              child: Stack(
                children: [
                  Obx(() {
                    return WKCarouselSlider(
                      items: [
                        for (Media media
                            in selectPostMediaController.selectedMediaList)
                          media.mediaType == GalleryMediaType.photo
                              ? Image.file(
                                  media.file!,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                ).ripple(() {
                                  // if (settingController
                                  //     .setting.value!.canEditPhotoVideo) {
                                  //   openImageEditor(media);
                                  // }
                                })
                              : media.mediaType == GalleryMediaType.gif
                                  ? CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: media.filePath!)
                                  : media.mediaType ==
                                          GalleryMediaType.video
                                      ? VideoPostTile(
                                          width: Get.width,
                                          url: media.file!.path,
                                          isLocalFile: true,
                                          play: true,
                                          onTapActionHandler: () {
                                            // if (settingController
                                            //     .setting
                                            //     .value!
                                            //     .canEditPhotoVideo) {
                                            //   openVideoEditor(media);
                                            // }
                                          },
                                        )
                                      : audioPostTile(media)
                      ],
                      // aspectRatio: 1,
                      enlargeCenterPage: false,
                      enableInfiniteScroll: false,
                      height: double.infinity,
                      viewportFraction: 1,
                      onPageChanged: (index) {
                        selectPostMediaController
                            .updateGallerySlider(index);
                      },
                    );
                  }),
                  Obx(() {
                    return selectPostMediaController
                                .selectedMediaList.length >
                            1
                        ? Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Align(
                                alignment: Alignment.center,
                                child: Container(
                                        height: 25,
                                        color: AppColorConstants.cardColor,
                                        child: WKIndicator1(
                                          dotsCount:
                                              selectPostMediaController
                                                  .selectedMediaList
                                                  .length,
                                          position:
                                              selectPostMediaController
                                                  .currentIndex.value,
                                          activeDotColor:
                                              AppColorConstants.themeColor,
                                          dotColor: AppColorConstants
                                              .disabledColor,
                                        ).hP8)
                                    .round(20)),
                          )
                        : Container();
                  })
                ],
              ).p16,
            ),
            const SizedBox(
              height: 20,
            ),
            if (selectPostMediaController.selectedMediaList.isNotEmpty &&
                settingController.setting.value!.canEditPhotoVideo &&
                selectPostMediaController.canEditMedia)
              Heading2Text(
                tapToEditString.tr,
                weight: TextWeight.bold,
              ),
          ],
        ),
      ],
    );
  }

  Widget audioPostTile(Media media) {
    return AudioFilePlayer(
      path: media.filePath!,
    );
  }

// openImageEditor(Media media) async {
//   // PESDK.unlockWithLicense("assets/pesdk_license");
//
//   final result = await PESDK.openEditor(image: media.file!.path);
//
//   if (result != null) {
//     // The user exported a new photo successfully and the newly generated photo is located at `result.image`.
//     Media editedMedia = media.copy;
//     editedMedia.file = File(result.image.replaceAll('file://', ''));
//     selectPostMediaController.replaceMediaWithEditedMedia(
//         originalMedia: media, editedMedia: editedMedia);
//   } else {
//     // The user exported a new photo successfully and the newly generated photo is located at `result.image`.
//     return;
//   }
// }
//
// openVideoEditor(Media media) async {
//   // PESDK.unlockWithLicense("assets/pesdk_license");
//
//   final video = Video(media.file!.path);
//   final result = await VESDK.openEditor(video);
//
//   if (result != null) {
//     // The user exported a new photo successfully and the newly generated photo is located at `result.image`.
//     Media editedMedia = media.copy;
//     editedMedia.file = File(result.video.replaceAll('file://', ''));
//     selectPostMediaController.replaceMediaWithEditedMedia(
//         originalMedia: media, editedMedia: editedMedia);
//   } else {
//     // The user exported a new photo successfully and the newly generated photo is located at `result.image`.
//     return;
//   }
// }
}

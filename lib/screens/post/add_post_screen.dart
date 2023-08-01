import 'package:carousel_slider/carousel_slider.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../components/hashtag_tile.dart';
import '../../components/user_card.dart';
import '../../controllers/post/add_post_controller.dart';
import '../chat/media.dart';

class AddPostScreen extends StatefulWidget {
  final List<Media> items;
  final int? competitionId;
  final int? clubId;
  final bool? isReel;
  final int? audioId;
  final double? audioStartTime;
  final double? audioEndTime;

  const AddPostScreen(
      {Key? key,
        required this.items,
        this.competitionId,
        this.clubId,
        this.isReel,
        this.audioId,
        this.audioStartTime,
        this.audioEndTime})
      : super(key: key);

  @override
  AddPostState createState() => AddPostState();
}

class AddPostState extends State<AddPostScreen> {
  TextEditingController descriptionText = TextEditingController();

  final AddPostController addPostController = Get.find();

  final RefreshController _usersRefreshController =
  RefreshController(initialRefresh: false);
  final RefreshController _hashtagRefreshController =
  RefreshController(initialRefresh: false);

  // RateMyApp rateMyApp = RateMyApp(
  //   preferencesPrefix: 'rateMyApp_',
  //   minDays: 0, // Show rate popup on first day of install.
  //   minLaunches:
  //       0, // Show rate popup after 5 launches of app after minDays is passed.
  // );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await rateMyApp.init();
      // if (mounted && rateMyApp.shouldOpenDialog) {
      //   rateMyApp.showRateDialog(context);
      // }
    });
  }

  @override
  void dispose() {
    descriptionText.text = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                              onTap: () => Get.back(),
                              child:
                              const ThemeIconWidget(ThemeIcon.backArrow)),
                          const Spacer(),
                          Heading5Text(
                            widget.competitionId == null
                                ? shareString.tr
                                : submitString.tr,
                            weight: TextWeight.medium,
                            color: AppColorConstants.themeColor,
                          ).ripple(() {
                            addPostController.uploadAllPostFiles(
                                isReel: widget.isReel ?? false,
                                audioId: widget.audioId,
                                audioStartTime: widget.audioStartTime,
                                audioEndTime: widget.audioEndTime,
                                items: widget.items,
                                title: descriptionText.text,
                                competitionId: widget.competitionId,
                                clubId: widget.clubId);
                          })
                        ],
                      ).hp(DesignConstants.horizontalPadding),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          mediaListView(isLarge: false).ripple(() {
                            addPostController.togglePreviewMode();
                          }),
                          Expanded(child: addDescriptionView()),
                        ],
                      ).hp(DesignConstants.horizontalPadding),
                      Obx(() {
                        return addPostController.isEditing.value == 1
                            ? Expanded(
                          child: Container(
                            // height: 500,
                            width: double.infinity,
                            color: AppColorConstants.disabledColor
                                .withOpacity(0.1),
                            child: addPostController
                                .currentHashtag.isNotEmpty
                                ? hashTagView()
                                : addPostController
                                .currentUserTag.isNotEmpty
                                ? usersView()
                                : Container(),
                          ),
                        )
                            : Container();
                      }),
                      const SizedBox(
                        height: 20,
                      ),
                    ]),
                addPostController.isPreviewMode.value
                    ? Stack(
                  children: [
                    Container(
                      height: Get.height,
                      width: Get.width,
                      color: AppColorConstants.backgroundColor
                          .withOpacity(0.2),
                      child: mediaListView(isLarge: true),
                    ),
                    Positioned(
                        top: 50,
                        left: DesignConstants.horizontalPadding,
                        child: const ThemeIconWidget(
                          ThemeIcon.close,
                          size: 20,
                        ).ripple(() {
                          addPostController.togglePreviewMode();
                        }))
                  ],
                )
                    : Container()
              ],
            );
          }),
    );
  }

  Widget mediaListView({required bool isLarge}) {
    return SizedBox(
      width: isLarge ? Get.width : 80,
      height: isLarge ? Get.height : 80,
      child: Stack(
        children: [
          CarouselSlider(
            items: [
              for (Media media in widget.items)
                isLarge
                    ? Image.file(media.file!,
                    fit: BoxFit.cover, width: double.infinity)
                    : Image.memory(
                  media.thumbnail!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ).round(5)
            ],
            options: CarouselOptions(
              enlargeCenterPage: false,
              enableInfiniteScroll: false,
              height: double.infinity,
              viewportFraction: 1,
              onPageChanged: (index, reason) {
                addPostController.updateGallerySlider(index);
              },
            ),
          ),
          widget.items.length > 1 && isLarge == false
              ? Positioned(
            right: 5,
            top: 5,
            child: Container(
                height: 30,
                width: 30,
                color: AppColorConstants.backgroundColor,
                child: const ThemeIconWidget(ThemeIcon.multiplePosts))
                .circular,
          )
              : Container()
        ],
      ),
    );
  }

  Widget addDescriptionView() {
    return SizedBox(
      height: 100,
      child: Obx(() {
        descriptionText.value = TextEditingValue(
            text: addPostController.searchText.value,
            selection: TextSelection.fromPosition(
                TextPosition(offset: addPostController.position.value)));

        return Focus(
          child: TextField(
            controller: descriptionText,
            textAlign: TextAlign.left,
            style: TextStyle(
                fontSize: FontSizes.h5, color: AppColorConstants.grayscale900),
            maxLines: 5,
            onChanged: (text) {
              addPostController.textChanged(
                  text, descriptionText.selection.baseOffset);
            },
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(left: 10, right: 10),
                counterText: "",
                labelStyle: TextStyle(
                    fontSize: FontSizes.b2,
                    color: AppColorConstants.themeColor),
                hintStyle: TextStyle(
                    fontSize: FontSizes.h5,
                    color: AppColorConstants.themeColor),
                hintText: addSomethingAboutPostString.tr),
          ),
          onFocusChange: (hasFocus) {
            if (hasFocus == true) {
              addPostController.startedEditing();
            } else {
              addPostController.stoppedEditing();
            }
          },
        );
      }),
    );
  }

  usersView() {
    return GetBuilder<AddPostController>(
        init: addPostController,
        builder: (ctx) {
          return ListView.separated(
              padding: EdgeInsets.only(top:20,left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding),
              itemCount: addPostController.searchedUsers.length,
              itemBuilder: (BuildContext ctx, int index) {
                return UserTile(
                  profile: addPostController.searchedUsers[index],
                  viewCallback: () {
                    addPostController.addUserTag(
                        addPostController.searchedUsers[index].userName);
                  },
                );
              },
              separatorBuilder: (BuildContext ctx, int index) {
                return const SizedBox(
                  height: 20,
                );
              }).addPullToRefresh(
              refreshController: _usersRefreshController,
              onRefresh: () {},
              onLoading: () {
                addPostController.searchUsers(
                    text: addPostController.currentUserTag.value,callBackHandler: (){
                  _usersRefreshController.loadComplete();
                });
              },
              enablePullUp: true,
              enablePullDown: false);
        });
  }

  hashTagView() {
    return GetBuilder<AddPostController>(
        init: addPostController,
        builder: (ctx) {
          return ListView.builder(
            padding:  EdgeInsets.only(left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding),
            itemCount: addPostController.hashTags.length,
            itemBuilder: (BuildContext ctx, int index) {
              return HashTagTile(
                hashtag: addPostController.hashTags[index],
                onItemCallback: () {
                  addPostController
                      .addHashTag(addPostController.hashTags[index].name);
                },
              );
            },
          ).addPullToRefresh(
              refreshController: _hashtagRefreshController,
              onRefresh: () {},
              onLoading: () {
                addPostController.searchHashTags(
                    text: addPostController.currentHashtag.value,callBackHandler: (){
                  _hashtagRefreshController.loadComplete();
                });
              },
              enablePullUp: true,
              enablePullDown: false);
        });
  }
}

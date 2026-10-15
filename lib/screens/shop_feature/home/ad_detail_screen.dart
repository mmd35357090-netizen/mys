import 'package:foap/controllers/shop/shop_controller.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/profile_imports.dart';
import '../../../model/shop_model/ad_model.dart';
import 'enlarge_imageview.dart';

class AdDetailScreen extends StatefulWidget {
  final AdModel adModel;

  const AdDetailScreen(this.adModel, {super.key});

  @override
  AdDetailState createState() => AdDetailState();
}

class AdDetailState extends State<AdDetailScreen> {
  ShopController shopController = Get.find();
  final ChatDetailController _chatDetailController = Get.find();

  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: [
            const SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                    onTap: () => Get.back(),
                    child: Icon(Icons.arrow_back_ios,
                        color: AppColorConstants.themeColor)),
                Row(
                  children: [
                    InkWell(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: Container(
                          height: 50,
                          color: Colors.grey.withValues(alpha: 0.1),
                          child: IconButton(
                              onPressed: () {
                                favBtnClicked();
                              },
                              icon: Icon(Icons.favorite,
                                  color: widget.adModel.isFavorite == 1
                                      ? AppColorConstants.themeColor
                                      : Colors.grey.withValues(alpha: 0.5))),
                        ).round(10)),
                  ],
                ),
              ],
            ).p(DesignConstants.horizontalPadding),
            Expanded(
              child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    (widget.adModel.images).isNotEmpty
                        ? addCarousalView()
                        : Container(),
                    widget.adModel.isDeal == 1
                        ? Container(
                            color: AppColorConstants.red,
                            width: 170,
                            height: 40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.local_offer,
                                  color: AppColorConstants.backgroundColor,
                                  size: 20,
                                ).rP4,
                                BodyLargeText(
                                  widget.adModel.actualPriceString,
                                  color: AppColorConstants.subHeadingTextColor,
                                ).rP16,
                                BodyLargeText(
                                  widget.adModel.dealPriceString,
                                  color: AppColorConstants.themeColor,
                                ).rP4
                              ],
                            ).hP16,
                          ).round(5).hP16.tP16
                        : Center(
                            child: BodyLargeText(
                              ' ${widget.adModel.currency!} ${widget.adModel.price!}',
                              weight: TextWeight.bold,
                            ),
                          ),
                    widget.adModel.featured == 1
                        ? Container(
                            width: 120,
                            color: Colors.yellow,
                            child: Center(
                                child: BodyLargeText(
                              'Featured',
                              weight: TextWeight.bold,
                            )).p8,
                          ).hP16.tP16
                        : Container(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BodyLargeText(widget.adModel.title!,
                                weight: TextWeight.bold)
                            .vP16,
                        // Row(
                        //   children: [
                        //     Icon(Icons.location_on,
                        //             color: AppColorConstants.themeColor,
                        //             size: 18)
                        //         .rP4,
                        //     BodySmallText(
                        //       widget.adModel.locations!.customLocation!,
                        //     ),
                        //   ],
                        // ).bp(15),
                        BodyLargeText(
                          aboutString.tr,
                          weight: TextWeight.bold,
                          color: AppColorConstants.mainTextColor,
                        ).vP16,
                        BodySmallText(
                          widget.adModel.description!,
                        ).bp(10),
                        BodyLargeText(
                          addressString.tr,
                          weight: TextWeight.bold,
                          color: AppColorConstants.mainTextColor,
                        ).vP16,
                        BodySmallText(
                          widget.adModel.locations?.customLocation ?? '',
                        ).bp(10)
                      ],
                    ).hp(25),
                    GestureDetector(
                            onTap: () => {
                                  Get.to(() => OtherUserProfile(
                                        user: widget.adModel.user!,
                                        userId: widget.adModel.user!.id,
                                      ))
                                },
                            child: Container(
                              color: Colors.grey.withValues(alpha: 0.1),
                              height: 110,
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                BodyLargeText(
                                                  sellerString.tr,
                                                  weight: TextWeight.bold,
                                                  color: AppColorConstants
                                                      .themeColor,
                                                ),
                                                const SizedBox(height: 15),
                                                BodyLargeText(
                                                  widget.adModel.user!.name!,
                                                  weight: TextWeight.bold,
                                                ),
                                                const SizedBox(height: 5),
                                                BodySmallText(
                                                  viewProfileString.tr,
                                                )
                                              ]),
                                          Container(
                                            height: 50,
                                            color: AppColorConstants.cardColor,
                                            child: Row(
                                              children: [
                                                IconButton(
                                                    onPressed: () {
                                                      _chatDetailController
                                                          .getChatRoomWithUser(
                                                              userId: widget
                                                                  .adModel
                                                                  .user!
                                                                  .id,
                                                              callback: (room) =>
                                                                  Get.to(() =>
                                                                      ChatDetail(
                                                                          chatRoom:
                                                                              room)));
                                                    },
                                                    icon: Icon(Icons.chat,
                                                        color: AppColorConstants
                                                            .themeColor)),
                                              ],
                                            ),
                                          ).round(10)
                                        ],
                                      ).hP16,
                                    )
                                  ]),
                            ).round(10).hp(25))
                        .vp(50),
                  ])),
            ),
          ],
        ));
  }

  addInfoView(String header, String infoValue) {
    return Container(
      color: Colors.grey.withValues(alpha: 0.1),
      height: 65,
      child: Center(
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Icon(Icons.person,
                  color: AppColorConstants.themeColor.withValues(alpha: 0.8))
              .rP8,
          Flexible(child: BodySmallText(infoValue, maxLines: 1)),
        ]),
      ).hP16.vP8,
    ).round(10).bP8;
  }

  addUtilityView(String icon, String header, String infoValue) {
    return Container(
      color: Colors.grey.withValues(alpha: 0.1),
      height: 65,
      child: Center(
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.person,
                          color: AppColorConstants.themeColor.withValues(alpha: 0.8))
                      .rP8,
                  BodySmallText(
                    header,
                    maxLines: 1,
                  )
                ],
              ),
              Flexible(
                  child: BodySmallText(
                infoValue,
                maxLines: 1,
                color: AppColorConstants.subHeadingTextColor,
              )),
            ]),
      ).hP16.vP8,
    ).round(10).bP8;
  }

  Widget addCarousalView() {
    return Column(children: [
      WKCarouselSlider(
        items: (widget.adModel.images)
            .map((item) => InkWell(
                  onTap: () async {
                    Get.to(() => EnlargeImageViewScreen(item));
                  },
                  child: SizedBox(
                      width: Get.width,
                      child: CachedNetworkImage(
                        imageUrl: item,
                        fit: BoxFit.fitWidth,
                        width: double.infinity,
                        placeholder: (context, url) =>
                            AppUtil.addProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      )).round(15).hP16,
                ))
            .toList(),
          enlargeCenterPage: false,
          enableInfiniteScroll: false,
          viewportFraction: 1,
          height: 180,
          onPageChanged: (index) {
            setState(() {
              _current = index;
            });
          }
      ),
      (widget.adModel.images).length > 1
          ? SizedBox(
              width: Get.width,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Row(
                    children: (widget.adModel.images)
                        .asMap()
                        .map((index, element) => MapEntry(
                            index,
                            Container(
                              width: 8.0,
                              height: 8.0,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 20.0, horizontal: 2.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _current == index
                                    ? AppColorConstants.themeColor
                                    : const Color.fromRGBO(0, 0, 0, 0.2),
                              ),
                            )))
                        .values
                        .toList()),
              ]),
            )
          : const SizedBox(height: 25),
    ]);
  }

  favBtnClicked() {
    if (widget.adModel.isFavorite == 1) {
      widget.adModel.isFavorite = 0;
    } else {
      widget.adModel.isFavorite = 1;
    }

    setState(() {});

    shopController.favUnfavAd(widget.adModel);
  }
}

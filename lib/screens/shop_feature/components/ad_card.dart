import 'package:foap/helper/imports/common_import.dart';
import '../../../model/shop_model/ad_model.dart';

class AdCard extends StatefulWidget {
  final AdModel ad;
  final VoidCallback pressed;
  final VoidCallback favPressed;

  const AdCard(
      {super.key,
      required this.ad,
      required this.pressed,
      required this.favPressed});

  @override
  State<AdCard> createState() => _AdCardState();
}

class _AdCardState extends State<AdCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.pressed(),
      child: Container(
        height: 250,
        color: AppColorConstants.cardColor,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Stack(
                children: [
                  SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: (widget.ad.images).isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: widget.ad.images.first,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      AppUtil.addProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ).round(15)
                              : const Icon(Icons.error))
                      .bP16,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.ad.isDeal == 1
                          ? Container(
                              color: AppColorConstants.red,
                              width: 140,
                              height: 30,
                              child: Row(
                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    Icons.local_offer,
                                    color: AppColorConstants.iconColor,
                                    size: 18,
                                  ).rP4,
                                  BodySmallText(
                                    widget.ad.actualPriceString,
                                  ).rP4,
                                  BodyLargeText(
                                    widget.ad.dealPriceString,
                                    weight: TextWeight.bold,
                                  ).rP4
                                ],
                              ).hP16,
                            ).round(25).bP8
                          : Container(),
                      widget.ad.featured == 1
                          ? Container(
                              width: 120,
                              color: Colors.yellow,
                              child: Center(
                                  child: BodySmallText(
                                'Featured',
                                weight: TextWeight.bold,
                              )).p8,
                            )
                          : Container()
                    ],
                  )
                ],
              )),
              BodyLargeText(widget.ad.title!,
                      maxLines: 1, weight: TextWeight.bold)
                  .bP4,
              BodyExtraSmallText(
                widget.ad.locations!.customLocation!,
                weight: TextWeight.semiBold,
                color: AppColorConstants.subHeadingTextColor,
                maxLines: 1,
              ).bP4,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BodyExtraSmallText(
                    widget.ad.finalPriceString,
                    weight: TextWeight.bold,
                    color: AppColorConstants.red,
                  ),
                  Icon(Icons.favorite,
                          color: widget.ad.isFavorite == 1
                              ? AppColorConstants.red
                              : AppColorConstants.mainTextColor)
                      .ripple(() {
                    if (widget.ad.isFavorite == 0) {
                      widget.ad.isFavorite = 1;
                    } else {
                      widget.ad.isFavorite = 0;
                    }
                    widget.favPressed();
                    setState(() {});
                  })
                ],
              )
            ]).p16,
      ).round(10),
    );
  }
}

class HorizontalAdCard extends StatefulWidget {
  final AdModel ad;
  final VoidCallback pressed;
  final VoidCallback favPressed;

  const HorizontalAdCard(
      {super.key,
      required this.ad,
      required this.pressed,
      required this.favPressed});

  @override
  State<HorizontalAdCard> createState() => _HorizontalAdCardState();
}

class _HorizontalAdCardState extends State<HorizontalAdCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.pressed(),
      child: SizedBox(
        width: Get.width * 0.8,
        child:
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 100,
              child: (widget.ad.images).isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: widget.ad.images.first,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          AppUtil.addProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ).round(10)
                  : const Icon(Icons.error)),
          Flexible(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyExtraSmallText(
                'Resort',
                maxLines: 2,
                weight: TextWeight.bold,
                color: AppColorConstants.red,
              ).bP4,
              BodySmallText(
                widget.ad.title!,
                maxLines: 2,
                weight: TextWeight.semiBold,
              ).bP4,
              BodyExtraSmallText(
                widget.ad.locations!.customLocation!,
                weight: TextWeight.semiBold,
                color: AppColorConstants.subHeadingTextColor,
              ).bP4,
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BodyExtraSmallText(
                    '${widget.ad.currency ?? '\$'} ${widget.ad.price}',
                    weight: TextWeight.bold,
                    color: AppColorConstants.red,
                  ),
                  Icon(Icons.favorite,
                          color: widget.ad.isFavorite == 1
                              ? AppColorConstants.red
                              : AppColorConstants.subHeadingTextColor)
                      .ripple(() {
                    if (widget.ad.isFavorite == 0) {
                      widget.ad.isFavorite = 1;
                    } else {
                      widget.ad.isFavorite = 0;
                    }
                    widget.favPressed();
                    setState(() {});
                  })
                ],
              ).bP4
            ],
          ).hP8.tP8),
        ]),
      ),
    );
  }
}

class MyAdCard extends StatefulWidget {
  final AdModel ad;
  final Function actionHandler;

  const MyAdCard(
      {super.key, required this.ad, required this.actionHandler});

  @override
  State<MyAdCard> createState() => _MyAdCardState();
}

class _MyAdCardState extends State<MyAdCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width * 0.8,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            height: 100,
            width: 100,
            child: (widget.ad.images).isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: widget.ad.images.first,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        AppUtil.addProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ).round(10)
                : const Icon(Icons.error)),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodySmallText(
                widget.ad.categoryName!,
                maxLines: 2,
                weight: TextWeight.bold,
                color: AppColorConstants.themeColor,
              ).bP8,
              BodyLargeText(
                widget.ad.title!,
                maxLines: 2,
                weight: TextWeight.semiBold,
              ).bP4,
              // BodyExtraSmallText(
              //   widget.ad.locations!.customLocation!,
              //   weight: TextWeight.semiBold,
              //   color: AppColorConstants.subHeadingTextColor,
              // ).bP4,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BodySmallText(
                    '${widget.ad.currency ?? '\$'} ${widget.ad.price}',
                    weight: TextWeight.bold,
                    color: AppColorConstants.themeColor,
                  ),
                  widget.ad.canEdit() == true
                      ? ThemeIconWidget(ThemeIcon.moreVertical)
                          .ripple(widget.actionHandler)
                      : Container()
                ],
              )
            ],
          ).hP8.tP8,
        ),
      ]),
    );
  }
}

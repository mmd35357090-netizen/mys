import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foap/helper/extension.dart';
import '../../../model/shop_model/advertisement.dart';
import '../../../util/app_util.dart';

class AdvertisementCard extends StatefulWidget {
  final Advertisement advertisement;
  final VoidCallback pressed;

  const AdvertisementCard(
      {super.key, required this.advertisement, required this.pressed});

  @override
  State<AdvertisementCard> createState() => _AdvertisementCardState();
}

class _AdvertisementCardState extends State<AdvertisementCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.pressed(),
      child: SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              Center(
                child: CachedNetworkImage(
                  imageUrl: widget.advertisement.image,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => AppUtil.addProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              widget.advertisement.isVideoAd() == true
                  ? const SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: Icon(Icons.play_circle_fill,
                          color: Colors.red, size: 70),
                    )
                  : Container()
            ],
          )).p8,
    );
  }
}

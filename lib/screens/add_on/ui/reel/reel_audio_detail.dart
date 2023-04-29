import 'package:cached_network_image/cached_network_image.dart';
import 'package:foap/components/custom_texts.dart';
import 'package:foap/components/top_navigation_bar.dart';
import 'package:foap/helper/common_components.dart';
import 'package:foap/helper/extension.dart';
import 'package:foap/helper/imports/reel_imports.dart';
import 'package:foap/helper/localization_strings.dart';
import 'package:foap/helper/number_extension.dart';
import 'package:foap/screens/add_on/controller/reel/reels_controller.dart';
import 'package:foap/screens/add_on/model/reel_music_model.dart';
import 'package:foap/screens/add_on/ui/reel/reels_list.dart';
import 'package:foap/util/app_config_constants.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ReelAudioDetail extends StatefulWidget {
  final ReelMusicModel audio;

  const ReelAudioDetail({Key? key, required this.audio}) : super(key: key);

  @override
  State<ReelAudioDetail> createState() => _ReelAudioDetailState();
}

class _ReelAudioDetailState extends State<ReelAudioDetail> {
  final ReelsController _reelsController = Get.find();

  @override
  void initState() {
    _reelsController.getReelsWithAudio(widget.audio.id);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _reelsController.clearReelsWithAudio();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(children: [
          const SizedBox(
            height: 50,
          ),
          backNavigationBar(context: context, title: LocalizationString.audio),
          divider(context: context).tP8,
          Row(
            children: [
              CachedNetworkImage(
                  height: 70, width: 70, imageUrl: widget.audio.thumbnail)
                  .round(10),
              const SizedBox(
                width: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyLargeText(widget.audio.name, weight: TextWeight.semiBold),
                  const SizedBox(
                    height: 5,
                  ),
                  BodyLargeText(
                      widget.audio.artists,
                      weight: TextWeight.regular
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  BodyMediumText(
                    '${widget.audio.numberOfReelsMade.formatNumber} ${LocalizationString.reels}',
                    weight: TextWeight.regular,
                  )
                ],
              )
            ],
          ).p16,
          Expanded(
              child: GetBuilder<ReelsController>(
                  init: _reelsController,
                  builder: (ctx) {
                    return GridView.builder(
                        itemCount: _reelsController.filteredMoments.length,
                        padding: const EdgeInsets.only(top: 20, bottom: 50),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 2.0,
                            mainAxisSpacing: 2.0,
                            childAspectRatio: 0.7),
                        itemBuilder: (ctx, index) {
                          PostModel reel =
                          _reelsController.filteredMoments[index];
                          return CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: reel.gallery.first.thumbnail)
                              .ripple(() {
                            Get.to(() => ReelsList(
                                audioId: widget.audio.id, index: index));
                          });
                        });
                  }))
        ]));
  }
}

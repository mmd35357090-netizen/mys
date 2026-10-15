import 'package:foap/screens/add_on/ui/podcast/podcast_detail.dart';
import '../../../../components/media_card.dart';
import '../../../../controllers/podcast/podcast_streaming_controller.dart';
import '../../../../helper/imports/common_import.dart';

class PodcastList extends StatelessWidget {
  final PodcastStreamingController _podcastStreamingController = Get.find();

  PodcastList({super.key}) ;

  @override
  Widget build(BuildContext context) {
    return Obx(() => SizedBox(
          height: ((_podcastStreamingController.podcasts.length / 2) + 1) * 210,
          child: GetBuilder<PodcastStreamingController>(
              init: _podcastStreamingController,
              builder: (ctx) {
                return GridView.builder(
                    itemCount: _podcastStreamingController.podcasts.length,
                    padding: const EdgeInsets.only(top: 20),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                            mainAxisExtent: 180),
                    itemBuilder: (context, index) {
                      MediaModel model = MediaModel(
                          _podcastStreamingController.podcasts[index].name,
                          _podcastStreamingController.podcasts[index].image,
                          _podcastStreamingController.podcasts[index].showTime);
                      return MediaCard(model: model).ripple(() {
                        Get.to(() => PodcastDetail(
                              podcastModel:
                                  _podcastStreamingController.podcasts[index],
                            ));
                      });
                    }).setPadding(left: 15, right: 15, bottom: 50);
              }),
        ));
  }
}

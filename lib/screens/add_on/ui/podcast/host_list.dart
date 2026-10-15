import 'package:foap/screens/add_on/ui/podcast/podcast_host_detail.dart';

import '../../../../controllers/podcast/podcast_streaming_controller.dart';
import '../../../../helper/imports/common_import.dart';

class HostList extends StatelessWidget {
  final PodcastStreamingController _podcastStreamingController = Get.find();

  HostList({super.key}) ;

  @override
  Widget build(BuildContext context) {
    return Obx(() => SizedBox(
          height: ((_podcastStreamingController.hosts.length / 2) + 1) * 210,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              mainAxisExtent: 200,
            ),
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _podcastStreamingController.hosts.length,
            itemBuilder: (BuildContext context, int index) => Column(
              children: [
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: _podcastStreamingController.hosts[index].image,
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                  ).round(10),
                ),
                const SizedBox(
                  height: 10,
                ),
                BodyLargeText(
                  _podcastStreamingController.hosts[index].name,
                  weight: TextWeight.semiBold,
                  maxLines: 1,
                )
              ],
            ).ripple(() {
              Get.to(() => PodcastHostDetail(
                    host: _podcastStreamingController.hosts[index],
                  ));
            }),
          ),
        ));
  }
}

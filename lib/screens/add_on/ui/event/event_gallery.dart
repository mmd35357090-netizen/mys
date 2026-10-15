import 'package:foap/components/photos_view/photo_view.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/event_imports.dart';

class EventGallery extends StatefulWidget {
  final List<String> eventGallery;

  const EventGallery({super.key, required this.eventGallery});

  @override
  State<EventGallery> createState() => _EventGalleryState();
}

class _EventGalleryState extends State<EventGallery> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: galleryString.tr),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1,
                        crossAxisCount: 3),
                itemCount: widget.eventGallery.length,
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: widget.eventGallery[index],
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                  ).round(15).ripple(() {
                    Get.to(() => PhotoView(
                        photos: widget.eventGallery,
                        startPosition: index));
                  });
                }).hp(DesignConstants.horizontalPadding),
          )
        ],
      ),
    );
  }
}

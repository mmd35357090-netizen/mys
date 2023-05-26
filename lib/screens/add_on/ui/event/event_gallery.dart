import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/event_imports.dart';

class EventGallery extends StatefulWidget {
  final EventModel event;

  const EventGallery({Key? key, required this.event}) : super(key: key);

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
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [

          backNavigationBar(
               title: galleryString.tr),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                    crossAxisCount: 3),
                itemCount: widget.event.gallery.length,
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: widget.event.gallery[index],
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                  ).round(15).ripple(() {});
                }).hP16,
          )
        ],
      ),
    );
  }
}

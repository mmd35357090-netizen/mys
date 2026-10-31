import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/models.dart';

class EventPostTile extends StatefulWidget {
  final PostModel post;
  final bool isResharedPost;

  const EventPostTile(
      {super.key, required this.post, required this.isResharedPost});

  @override
  State<EventPostTile> createState() => _EventPostTileState();
}

class _EventPostTileState extends State<EventPostTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.post.event;
    // Event data missing or event has no image (e.g. added from admin panel).
    if (event == null || event.image.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        color: AppColorConstants.cardColor,
        alignment: Alignment.center,
        child: BodyMediumText(event?.name ?? ''),
      );
    }
    return CachedNetworkImage(
      imageUrl: event.image,
      fit: BoxFit.cover,
      errorWidget: (context, url, error) => Container(
        height: 200,
        color: AppColorConstants.cardColor,
        child: Icon(Icons.broken_image_outlined,
            color: AppColorConstants.disabledColor),
      ),
    );
  }
}

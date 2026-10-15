import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/models.dart';

class EventPostTile extends StatefulWidget {
  final PostModel post;
  final bool isResharedPost;

  const EventPostTile(
      {super.key, required this.post, required this.isResharedPost})
      ;

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
    return CachedNetworkImage(
      imageUrl: widget.post.event!.image,
      fit: BoxFit.cover,
    );
  }
}

import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/models.dart';

class OfferPostTile extends StatefulWidget {
  final PostModel post;
  final bool isResharedPost;

  const OfferPostTile(
      {super.key, required this.post, required this.isResharedPost});

  @override
  State<OfferPostTile> createState() => _OfferPostTileState();
}

class _OfferPostTileState extends State<OfferPostTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.post.offer!.coverImage,
      fit: BoxFit.cover,
      width: double.infinity,
    );
  }
}

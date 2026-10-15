import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/models.dart';

class ClassifiedProductPostTile extends StatefulWidget {
  final PostModel post;
  final bool isResharedPost;

  const ClassifiedProductPostTile(
      {super.key, required this.post, required this.isResharedPost});

  @override
  State<ClassifiedProductPostTile> createState() =>
      _ClassifiedProductPostTileState();
}

class _ClassifiedProductPostTileState extends State<ClassifiedProductPostTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.post.product!.images.first,
      fit: BoxFit.cover,
      width: double.infinity,
    );
  }
}

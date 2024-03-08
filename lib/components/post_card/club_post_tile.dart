import 'package:foap/helper/imports/club_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/models.dart';

class ClubPostTile extends StatefulWidget {
  final PostModel post;
  final bool isResharedPost;

  const ClubPostTile(
      {super.key, required this.post, required this.isResharedPost});

  @override
  State<ClubPostTile> createState() => _ClubPostTileState();
}

class _ClubPostTileState extends State<ClubPostTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.post.createdClub!.image!,
      fit: BoxFit.cover,
      width: double.infinity,
    );
  }
}

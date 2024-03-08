import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/models.dart';

class CompetitionPostTile extends StatefulWidget {
  final PostModel post;
  final bool isResharedPost;

  const CompetitionPostTile(
      {super.key, required this.post, required this.isResharedPost});

  @override
  State<CompetitionPostTile> createState() => _CompetitionPostTileState();
}

class _CompetitionPostTileState extends State<CompetitionPostTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.post.competition!.photo,
      fit: BoxFit.cover,
      width: double.infinity,
    );
  }
}

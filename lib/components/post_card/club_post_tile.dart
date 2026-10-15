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
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: widget.post.createdClub!.image!,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
        // if (widget.post.createdClub!.isJoined == false)
        //   Positioned(
        //       right: 20,
        //       bottom: 20,
        //       child: Container(
        //         color: AppColorConstants.backgroundColor.withValues(alpha: 0.8),
        //         child: BodyLargeText(joinString.tr).p8,
        //       ).round(10).ripple((() {
        //         Get.to(() => ClubDetail(
        //               club: widget.post.createdClub!,
        //               needRefreshCallback: () {},
        //               deleteCallback: (club) {},
        //             ));
        //       }))),
      ],
    );
  }
}

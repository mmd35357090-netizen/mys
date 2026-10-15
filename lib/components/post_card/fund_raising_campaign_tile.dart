import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/models.dart';

class FundRaisingCampaignPostTile extends StatefulWidget {
  final PostModel post;
  final bool isResharedPost;

  const FundRaisingCampaignPostTile(
      {super.key, required this.post, required this.isResharedPost});

  @override
  State<FundRaisingCampaignPostTile> createState() =>
      _FundRaisingCampaignPostTileState();
}

class _FundRaisingCampaignPostTileState
    extends State<FundRaisingCampaignPostTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.post.fundRaisingCampaign!.coverImage,
      fit: BoxFit.cover,
      width: double.infinity,
    );
  }
}

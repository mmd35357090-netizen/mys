import 'package:flutter_polls/flutter_polls.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/models.dart';
import '../../controllers/home/home_controller.dart';

class PollPostTile extends StatefulWidget {
  final PostModel post;
  final bool isResharedPost;

  const PollPostTile(
      {super.key, required this.post, required this.isResharedPost});

  @override
  State<PollPostTile> createState() => _PollPostTileState();
}

class _PollPostTileState extends State<PollPostTile> {
  final HomeController _homeController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.cardColor,
      child: FlutterPolls(
        pollId: widget.post.poll!.id.toString(),
        hasVoted: widget.post.poll!.isVote! > 0,
        userVotedOptionId: widget.post.poll!.isVote! > 0
            ? widget.post.poll!.isVote.toString()
            : null,
        onVoted: (PollOption pollOption, int newTotalVotes) async {
          await Future.delayed(const Duration(seconds: 1));
          _homeController.postPollAnswer(
              widget.post.poll!.id!, int.parse(pollOption.id!));

          return true;
        },
        pollEnded: false,
        pollOptionsSplashColor: Colors.white,
        votedProgressColor: Colors.grey.withValues(alpha: 0.3),
        votedBackgroundColor: Colors.grey.withValues(alpha: 0.2),
        votesTextStyle: TextStyle(
            fontSize: FontSizes.b2, color: AppColorConstants.mainTextColor),
        votedPercentageTextStyle: TextStyle(fontSize: FontSizes.b2).copyWith(
          color: Colors.black,
        ),
        votedCheckmark: const Icon(
          Icons.check_circle,
          color: Colors.black,
        ),
        pollTitle: Align(
          alignment: Alignment.centerLeft,
          child: BodyLargeText(
            widget.post.poll!.title ?? "",
            weight: TextWeight.medium,
          ),
        ),
        pollOptions: List<PollOption>.from(
          (widget.post.poll!.pollOptions ?? []).map(
            (option) {
              var a = PollOption(
                id: option.id.toString(),
                title: BodyLargeText(option.title ?? '',
                    weight: TextWeight.medium),
                votes: option.totalOptionVoteCount ?? 0,
              );
              return a;
            },
          ),
        ),
      ).p16,
    ).round(15).p16;
  }
}

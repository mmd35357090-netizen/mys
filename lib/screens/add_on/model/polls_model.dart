class PollModel {
  int? id;
  String? title;
  int? totalVoteCount;
  int? isVote;

  List<SayHiPollOption>? pollOptions;

  PollModel(
      {this.id,
      this.title,
      this.totalVoteCount,
      this.isVote,
      this.pollOptions});

  PollModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    totalVoteCount = json['total_vote_count'];
    isVote = json['is_vote'];

    if (json['pollOptions'] != null) {
      pollOptions = <SayHiPollOption>[];
      json['pollOptions'].forEach((v) {
        pollOptions!.add(SayHiPollOption.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['total_vote_count'] = totalVoteCount;
    data['is_vote'] = isVote;

    if (pollOptions != null) {
      data['pollQuestionOption'] = pollOptions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SayHiPollOption {
  int? id;
  String? title;
  int? totalOptionVoteCount;

  SayHiPollOption({this.id, this.title, this.totalOptionVoteCount});

  SayHiPollOption.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    totalOptionVoteCount = json['total_option_vote_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['total_option_vote_count'] = totalOptionVoteCount;
    return data;
  }
}

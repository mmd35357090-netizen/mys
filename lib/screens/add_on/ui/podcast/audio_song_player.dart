import 'package:foap/screens/add_on/model/podcast_model.dart';
import 'package:foap/screens/add_on/ui/podcast/seekbar_data.dart';
import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:rxdart/rxdart.dart' as rxdart;
import 'package:foap/helper/imports/common_import.dart';

//ignore: must_be_immutable
class AudioSongPlayer extends StatefulWidget {
  final List<PodcastEpisodeModel>? songsArray;
  final PodcastModel? show;
  int currentSongIndex;

  AudioSongPlayer(
      {super.key, this.songsArray, this.show, required this.currentSongIndex})
      ;

  @override
  State<AudioSongPlayer> createState() => _AudioSongPlayerState();
}

class _AudioSongPlayerState extends State<AudioSongPlayer> {
  just_audio.AudioPlayer audioPlayer = just_audio.AudioPlayer();
  bool _favorite = false;
  bool _showList = false;

  @override
  void initState() {
    super.initState();
    List<just_audio.AudioSource> audios = widget.songsArray
            ?.map((e) => just_audio.AudioSource.uri(Uri.parse(e.audioUrl)))
            .toList() ??
        [];
    audioPlayer
        .setAudioSource(just_audio.ConcatenatingAudioSource(children: audios));
    audioPlayer.seek(Duration.zero,
        index: widget.currentSongIndex);
    audioPlayer.play();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Stream<SeekbarData> get _seekbarDataStream =>
      rxdart.Rx.combineLatest2<Duration, Duration?, SeekbarData>(
          audioPlayer.positionStream, audioPlayer.durationStream, (
        Duration position,
        Duration? duration,
      ) {
        return SeekbarData(position, duration ?? Duration.zero);
      });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      // ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          backNavigationBar(title: ''),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl:
                      widget.songsArray?[widget.currentSongIndex].imageUrl ??
                          "",
                  fit: BoxFit.cover,
                  width: Get.width,
                  // height: 230,
                ),
                Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                        Colors.black,
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.1),
                      ])),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Heading3Text(
                      widget.songsArray?[widget.currentSongIndex].name ?? '',
                      weight: TextWeight.bold,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    BodySmallText(
                      widget.show?.name ?? '',
                      maxLines: 2,
                      color: Colors.white60,
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<SeekbarData>(
                        stream: _seekbarDataStream,
                        builder: (context, snapshot) {
                          final positionData = snapshot.data;
                          return SeekBar(
                              position: positionData?.position ?? Duration.zero,
                              duration: positionData?.duration ?? Duration.zero,
                              onChangedEnd: audioPlayer.seek);
                        }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: IconButton(
                              onPressed: () => setState(() {
                                    _favorite = !_favorite;
                                  }),
                              iconSize: 30,
                              icon: Icon(
                                _favorite
                                    ? Icons.favorite
                                    : Icons.favorite_border_outlined,
                                color: _favorite
                                    ? AppColorConstants.themeColor
                                    : Colors.white,
                              )),
                        ),
                        StreamBuilder<just_audio.SequenceState?>(
                            stream: audioPlayer.sequenceStateStream,
                            builder: (context, index) {
                              return IconButton(
                                  onPressed: () {
                                    if (audioPlayer.hasPrevious) {
                                      widget.currentSongIndex =
                                          widget.currentSongIndex - 1;
                                      audioPlayer.seek(Duration.zero,
                                          index: widget.currentSongIndex);
                                      setState(() {});
                                      // audioPlayer.seekToPrevious;
                                    }
                                  },
                                  iconSize: 45,
                                  icon: const Icon(
                                    Icons.skip_previous,
                                    color: Colors.white,
                                  ));
                            }),
                        StreamBuilder(
                            stream: audioPlayer.playerStateStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final playerState = snapshot.data;
                                final processingState =
                                    (playerState! as just_audio.PlayerState)
                                        .processingState;

                                if (processingState ==
                                        just_audio.ProcessingState.loading ||
                                    processingState ==
                                        just_audio.ProcessingState.buffering) {
                                  return Container(
                                    width: 64.0,
                                    height: 64.0,
                                    margin: const EdgeInsets.all(10.0),
                                    child: const CircularProgressIndicator(),
                                  );
                                } else if (!audioPlayer.playing) {
                                  return IconButton(
                                      onPressed: audioPlayer.play,
                                      iconSize: 75,
                                      icon: const Icon(
                                        Icons.play_circle,
                                        color: Colors.white,
                                      ));
                                } else if (processingState !=
                                    just_audio.ProcessingState.completed) {
                                  return IconButton(
                                      onPressed: audioPlayer.pause,
                                      iconSize: 75,
                                      icon: const Icon(
                                        Icons.pause_circle,
                                        color: Colors.white,
                                      ));
                                } else {
                                  return IconButton(
                                      onPressed: () {
                                        widget.currentSongIndex = 0;
                                        audioPlayer.seek(Duration.zero,
                                            index: widget.currentSongIndex);
                                        setState(() {});
                                      },
                                      iconSize: 75,
                                      icon: const Icon(
                                        Icons.replay_circle_filled_outlined,
                                        color: Colors.white,
                                      ));
                                }
                              } else {
                                return const CircularProgressIndicator();
                              }
                            }),
                        StreamBuilder<just_audio.SequenceState?>(
                            stream: audioPlayer.sequenceStateStream,
                            builder: (context, index) {
                              return IconButton(
                                  onPressed: () {
                                    if (audioPlayer.hasNext) {
                                      widget.currentSongIndex =
                                          widget.currentSongIndex + 1;
                                      audioPlayer.seek(Duration.zero,
                                          index: widget.currentSongIndex);
                                      setState(() {});
                                    }
                                  },
                                  iconSize: 45,
                                  icon: const Icon(
                                    Icons.skip_next,
                                    color: Colors.white,
                                  ));
                            }),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: IconButton(
                              onPressed: () => setState(() {
                                    _showList = !_showList;
                                  }),
                              iconSize: 30,
                              icon: const Icon(
                                Icons.list,
                                color: Colors.white,
                              )),
                        )
                      ],
                    ),
                    addSongList()
                  ],
                ).p(DesignConstants.horizontalPadding),
              ],
            ),
          ),
        ],
      ),
    );
  }

  addSongList() {
    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _showList
            ? MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: SizedBox(
                  height: Get.height / 2 - 100,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.songsArray?.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Transform.translate(
                              offset: const Offset(0, 3),
                              child: BodyLargeText(
                                (index + 1).toString(),
                                color: Colors.white,
                              )),
                          title: Transform.translate(
                              offset: const Offset(-30, 0),
                              child: BodyLargeText(
                                widget.songsArray?[index].name ?? '',
                                color: Colors.white,
                              )),
                          // trailing: const Icon(Icons.play_arrow),
                          // selected: true,
                          // onTap: () {
                          //   // currentSongIndex = index;
                          //   // setState(() {});
                          //   // audioPlayer.seek(Duration.zero,
                          //   //     index: currentSongIndex);
                          // },
                        ).ripple(() {
                          setState(() {
                            widget.currentSongIndex = index;
                            audioPlayer.seek(Duration.zero,
                                index: widget.currentSongIndex);
                          });
                        });
                      }),
                ))
            : null);
  }
}

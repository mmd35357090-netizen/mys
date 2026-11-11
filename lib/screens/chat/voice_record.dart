import 'dart:async';
import 'dart:io';
export 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import '../../util/constant_util.dart';
import 'package:audio_session/audio_session.dart';
import 'package:record/record.dart';

class VoiceRecord extends StatefulWidget {
  final Function(Media) recordingCallback;

  const VoiceRecord({super.key, required this.recordingCallback})
      ;

  @override
  State<VoiceRecord> createState() => _VoiceRecordState();
}

class _VoiceRecordState extends State<VoiceRecord> {
  bool isRecorded = false;
  String? recordingPath;

  // final FlutterSoundRecorder recorder = FlutterSoundRecorder();
  final record = AudioRecorder();

  int _seconds = 0;
  late Timer _timer;

  // final FlutterSoundRecorderSettings settings = FlutterSoundRecorderSettings();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startRecording();
    });
    super.initState();
  }

  startRecording() async {
    Directory tempDir = await getTemporaryDirectory();
    recordingPath = '${tempDir.path}/${randomId()}.m4a';
    File audioFile = File(recordingPath!);
    if (!audioFile.existsSync()) {
      audioFile.createSync();
    }

    if (await record.hasPermission()) {
      await record.start(
        const RecordConfig(bitRate: 128000, encoder: AudioEncoder.aacLc),
        path: recordingPath!, // by default
      );
      _startTimer();
    } else {
      AppUtil.showToast(
          message: 'Recording permissions are not provided', isSuccess: false);
    }

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds += 1;
      });
    });
  }

  void _stopTimer() {
    _timer.cancel();
  }

  @override
  void dispose() async {
    bool isRecording = await record.isRecording();
    if (isRecording) {
      await record.stop();
    }
    // setState(() {
    //   _seconds = 0;
    // });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            height: 4,
            width: 40,
            color: AppColorConstants.dividerColor,
          ).round(2),
          const SizedBox(height: 24),
          Container(
            height: 84,
            width: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isRecorded
                      ? AppColorConstants.themeColor
                      : AppColorConstants.red)
                  .withValues(alpha: 0.12),
            ),
            child: Center(
              child: ThemeIconWidget(
                ThemeIcon.mic,
                color: isRecorded
                    ? AppColorConstants.themeColor
                    : AppColorConstants.red,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${_seconds ~/ 60}:${(_seconds % 60).toString().padLeft(2, '0')}',
            style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w800,
                color: AppColorConstants.mainTextColor),
          ),
          const SizedBox(height: 4),
          BodySmallText(
            isRecorded ? 'Ready to send' : 'Recording…',
            color: AppColorConstants.subHeadingTextColor,
            weight: TextWeight.semiBold,
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColorConstants.cardColor,
                  border: Border.all(
                      color: AppColorConstants.dividerColor, width: 0.8),
                ),
                child: Center(
                  child: ThemeIconWidget(
                    ThemeIcon.close,
                    color: AppColorConstants.iconColor,
                    size: 22,
                  ),
                ),
              ).ripple(() {
                Get.back();
              }),
              const SizedBox(width: 36),
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [
                    AppColorConstants.themeColor,
                    AppColorConstants.themeColor.withValues(alpha: 0.75)
                  ]),
                  boxShadow: [
                    BoxShadow(
                        color: AppColorConstants.themeColor
                            .withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: Center(
                  child: ThemeIconWidget(
                    isRecorded == true ? ThemeIcon.send : ThemeIcon.stop,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ).ripple(() {
                setState(() {
                  if (isRecorded == true) {
                    sendRecording();
                  } else {
                    stopRecording();
                    isRecorded = true;
                  }
                });
              }),
            ],
          ),
          const SizedBox(height: 36),
        ],
      ),
    ).topRounded(32);
  }

  stopRecording() async {
    // await recorder.stopRecorder();
    // await recorder.closeRecorder();
    await record.stop();

    _stopTimer();
  }

  sendRecording() {
    // print(recordingPath);
    File file = File(recordingPath!);
    // print(recordingPath);

    Uint8List data = file.readAsBytesSync();

    if (recordingPath != null) {
      Media media = Media(
        file: File(recordingPath!),
        filePath: recordingPath!,
        fileSize: data.length,
        mainFileBytes: data,
        duration: _seconds,
        id: randomId(),
        creationTime: DateTime.now(),
        mediaType: GalleryMediaType.audio,
      );
      widget.recordingCallback(media);
    }
    Get.back();
  }
}

import 'dart:async';
import 'dart:io';
export 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:typed_data';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../util/constant_util.dart';

class VoiceRecord extends StatefulWidget {
  final Function(Media) recordingCallback;

  const VoiceRecord({Key? key, required this.recordingCallback})
      : super(key: key);

  @override
  State<VoiceRecord> createState() => _VoiceRecordState();
}

class _VoiceRecordState extends State<VoiceRecord> {
  bool isRecorded = false;
  String? recordingPath;
  final FlutterSoundRecorder recorder = FlutterSoundRecorder();

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
    recordingPath = '${tempDir.path}/${randomId()}.wav';
    File audioFile = File(recordingPath!);
    if (!audioFile.existsSync()) {
      audioFile.createSync();
    }

    Map<Permission, PermissionStatus> statuses =
        await [Permission.microphone].request();

    if (statuses[Permission.microphone] == PermissionStatus.granted) {
      await recorder.openRecorder();
      await recorder.startRecorder(toFile: recordingPath);
      _startTimer();
    } else {
      AppUtil.showToast(
          message: 'Recording permissions are not provided', isSuccess: false);
    }
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
  void dispose() {
    recorder.stopRecorder();
    setState(() {
      _seconds = 0;
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.backgroundColor,
      child: Column(
        children: [
          // const Spacer(),
          Container(
            height: 200,
            color: AppColorConstants.backgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ThemeIconWidget(
                  ThemeIcon.mic,
                  color: AppColorConstants.themeColor,
                  size: 60,
                ),
                // const SizedBox(
                //   width: 10,
                // ),
                SizedBox(
                  width: 150,
                  child: Heading1Text(
                    '${_seconds ~/ 60}:${(_seconds % 60).toString().padLeft(2, '0')}',
                    weight: TextWeight.regular,
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ).round(20).p16,
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  color: AppColorConstants.cardColor,
                  child: Center(
                    child: ThemeIconWidget(
                      isRecorded == true ? ThemeIcon.send : ThemeIcon.stop,
                      size: 25,
                    ),
                  ),
                ).circular.ripple(() {
                  setState(() {
                    if (isRecorded == true) {
                      sendRecording();
                    } else {
                      stopRecording();
                      isRecorded = true;
                    }
                  });
                }),
                const SizedBox(
                  width: 50,
                ),
                Container(
                  height: 50,
                  width: 50,
                  color: AppColorConstants.cardColor,
                  child: Center(
                    child: ThemeIconWidget(
                      ThemeIcon.close,
                      color: AppColorConstants.iconColor,
                      size: 25,
                    ),
                  ),
                ).circular.ripple(() {
                  Get.back();
                })
              ],
            ),
          ),
          const SizedBox(
            height: 40,
          ),
        ],
      ),
    ).topRounded(40);
  }

  stopRecording() async {
    await recorder.stopRecorder();
    await recorder.closeRecorder();
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
        fileUrl: recordingPath!,
        fileSize: data.length,
        mediaByte: data,
        id: randomId(),
        creationTime: DateTime.now(),
        mediaType: GalleryMediaType.audio,
      );
      widget.recordingCallback(media);
    }
    Get.back();
  }
}

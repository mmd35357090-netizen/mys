import 'dart:io';
import 'package:camera/camera.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:foap/api_handler/apis/reel_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/manager/player_manager.dart';
import 'package:foap/model/category_model.dart';
import 'package:foap/screens/add_on/model/reel_music_model.dart';
import 'package:foap/screens/add_on/ui/reel/preview_reel_screen.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:video_compress/video_compress.dart';

class CreateReelController extends GetxController {
  final PlayerManager _playerManager = Get.find();

  RxList<CategoryModel> categories = <CategoryModel>[].obs;
  RxList<ReelMusicModel> audios = <ReelMusicModel>[].obs;

  Rx<ReelMusicModel?> selectedAudio = Rx<ReelMusicModel?>(null);
  double? audioStartTime;
  double? audioEndTime;
  double? selectedAudioStartTime;
  double? selectedAudioEndTime;
  File? croppedAudioFile;

  RxString searchText = ''.obs;
  int selectedSegment = 0;

  RxBool isLoadingAudios = false.obs;
  int audiosCurrentPage = 1;
  bool canLoadMoreAudios = true;
  final player = AudioPlayer(); // Create a player

  RxBool isRecording = false.obs;

  RxBool enableRecord = false.obs;
  DateTime? startDateTime;
  DateTime? endDateTime;
  RxBool flashSetting = false.obs;
  RxInt recordingLength = 15.obs;

  RxDouble currentProgressValue = (0.0).obs;

  // late SimpleDownloader _downloader;

  void turnOnFlash() {
    flashSetting.value = true;
    update();
  }

  void turnOffFlash() {
    flashSetting.value = false;
    update();
  }

  searchTextChanged(String text) {
    if (searchText.value != text) {
      clear();
      searchText.value = text;

      audios.clear();
      getReelAudios();
    }
  }

  clear() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      audios.clear();
      isLoadingAudios.value = false;
      isRecording.value = false;
      audiosCurrentPage = 1;
      canLoadMoreAudios = true;
      selectedAudio.value = null;
      debugPrint('selectedAudio.value = null');
      stopPlayingAudio();
    });
  }

  closeSearch() {
    searchText.value = '';
    update();
  }

  segmentChanged(int index) {
    if (selectedSegment != index) {
      clear();
      selectedSegment = index;
      getReelAudios();
      update();
    }
  }

  getReelCategories() {
    isLoadingAudios.value = true;
    ReelApi.getReelCategories(resultCallback: (result) {
      categories.value = result;
      getReelAudios();
      update();
    });
  }

  getReelAudios() {
    CategoryModel category = categories[selectedSegment];

    if (canLoadMoreAudios == true) {
      isLoadingAudios.value = true;
      ReelApi.getAudios(
          categoryId: category.id,
          title: searchText.value.isNotEmpty ? searchText.value : null,
          resultCallback: (result, metadata) {
            isLoadingAudios.value = false;
            audios.value = result;

            audiosCurrentPage += 1;

            if (result.length == metadata.pageCount) {
              canLoadMoreAudios = true;
            } else {
              canLoadMoreAudios = false;
            }

            update();
          });
    }
  }

  selectReelAudio(ReelMusicModel audio) {
    selectedAudio.value = audio;
    debugPrint('selectReelAudio $selectedAudio');
  }

  setCroppedAudio(File audioFile) {
    croppedAudioFile = audioFile;
    debugPrint('croppedAudioFile $audioFile');
  }

  clearAudioCropperTime() {
    selectedAudioStartTime = null;
    selectedAudioEndTime = null;
  }

  setAudioCropperTime(double startTime, double endTime) {
    audioStartTime = startTime;
    audioEndTime = endTime;
  }

  playAudio(ReelMusicModel reelAudio) async {
    Audio audio = Audio(id: reelAudio.id.toString(), url: reelAudio.url);
    _playerManager.playNetworkAudio(audio);

    update();
  }

  playAudioFile(File reelAudio) async {
    _playerManager.playAudioFile(reelAudio);
    update();
  }

  playAudioFileUntil(ReelMusicModel reelAudio, double startDuration,
      double endDuration) async {
    _playerManager.playAudioFileTimeIntervalBased(
        reelAudio, startDuration, endDuration);
    update();
  }

  stopPlayingAudio() {
    debugPrint('end at:: ${_playerManager.currentPosition}');
    _playerManager.stopAudio();
    update();
  }

  void stopRecording() {
    endDateTime = DateTime.now();
    isRecording.value = false;
    stopPlayingAudio();
    update();
  }

  void startRecording() {
    isRecording.value = true;
    startDateTime = DateTime.now();
    if (croppedAudioFile != null) {
      playAudioFile(croppedAudioFile!);
    }

    update();
  }

  enableRecording() {
    enableRecord.value = true;
    update();
  }

  disableRecording() {
    enableRecord.value = false;
    update();
  }

  void createReel(File? selectedAudioFile, XFile videoFile) async {
    final directory = await getTemporaryDirectory();
    var finalFile = File(
        '${directory.path}/REEL_${DateTime.now().millisecondsSinceEpoch}.mp4');

    if (selectedAudioFile != null) {
      try {
        // Get video duration in SECONDS
        final mediaInfo = await VideoCompress.getMediaInfo(videoFile.path);
        final videoDurationSeconds = mediaInfo.duration! / 1000; // Convert ms to seconds

        Loader.show(status: preparingString.tr);

        final command = [
          '-y', // Overwrite output
          '-i', videoFile.path,
          '-i', selectedAudioFile.path,
          '-filter_complex',
          '[1:a]atrim=0:$videoDurationSeconds,asetpts=PTS-STARTPTS,apad=whole_dur=$videoDurationSeconds[aout]',
          '-map', '0:v',
          '-map', '[aout]',
          '-c:v', 'copy',
          '-c:a', 'aac', // Required for MP4 container
          '-movflags', '+faststart',
          finalFile.path
        ];

        FFmpegKitConfig.enableLogCallback((log) {
          debugPrint('FFmpeg log: ${log.getMessage()}');
        });

        FFmpegKit.executeWithArguments(command).then((session) async {
          final returnCode = await session.getReturnCode();
          Loader.dismiss();

          if (ReturnCode.isSuccess(returnCode)) {
            debugPrint('Success! Video duration: $videoDurationSeconds seconds');
            Get.to(() => PreviewReelsScreen(
              reel: finalFile,
              audioId: selectedAudio.value?.id,
              audioStartTime: audioStartTime,
              audioEndTime: audioEndTime,
            ));
          } else {
            debugPrint('Failed with code: $returnCode');
            AppUtil.showToast(message: 'Error creating reel', isSuccess: false);
          }
        });
      } catch (e) {
        Loader.dismiss();
        debugPrint('Error: $e');
        AppUtil.showToast(message: 'Processing failed', isSuccess: false);
      }
    } else {
      Get.to(() => PreviewReelsScreen(reel: File(videoFile.path)));
    }
  }

  downloadAudio(Function(bool) callback) async {
    final response = await http.get(Uri.parse(selectedAudio.value!.url));
    final bytes = response.bodyBytes;

    final dir = await Directory.systemTemp.createTemp();
    final file = File('${dir.path}/${selectedAudio.value!.id}.mp3');
    await file.writeAsBytes(bytes);
    croppedAudioFile = file;
    callback(true);
  }

  // downloadAudio(Function(bool) callback) async {
  //   // **** Download the audio file *******//
  //   DownloaderTask task = DownloaderTask(
  //     url: selectedAudio.value!.url,
  //     fileName: "${selectedAudio.value!.id}.mp3",
  //     bufferSize:
  //         1024, // if bufferSize value not set, default value is 64 ( 64 Kb )
  //   );
  //
  //   final pathFile = (await path.getTemporaryDirectory()).path;
  //   // if (!mounted) return;
  //
  //   task = task.copyWith(
  //     downloadPath: pathFile,
  //   );
  //
  //   _downloader = SimpleDownloader.init(task: task);
  //   _downloader.download();
  //   _downloader.callback.addListener(() {
  //     if (_downloader.callback.status == DownloadStatus.completed) {
  //       croppedAudioFile = File("$pathFile/${selectedAudio.value!.id}.mp3");
  //
  //       callback(true);
  //     } else if (_downloader.callback.status == DownloadStatus.failed ||
  //         _downloader.callback.status == DownloadStatus.canceled ||
  //         _downloader.callback.status == DownloadStatus.deleted) {
  //       callback(false);
  //     }
  //   });
  // }

  void trimAudio() async {
    if ((audioEndTime ?? 0 - (audioStartTime ?? 0)) <
        recordingLength.toDouble()) {
      AppUtil.showToast(
          message: 'Audio Clip is shorter than ${recordingLength}seconds ',
          isSuccess: false);
      return;
    }
    selectedAudioStartTime = audioStartTime;
    selectedAudioEndTime = audioEndTime;

    Loader.show(status:loadingString.tr);
    downloadAudio((status) async {
      if (status) {
        if (croppedAudioFile != null) {
          double duration = audioEndTime! - audioStartTime!;
          stopPlayingAudio();

          final directory = await getTemporaryDirectory();
          var finalAudioFile = File(
              '${directory.path}/AUD_${DateTime.now().millisecondsSinceEpoch}.mp3');

          var audioTrimCommand =
              '-ss ${audioStartTime!} -i ${croppedAudioFile!.path} -t $duration -c copy ${finalAudioFile.path}';
          FFmpegKit.executeAsync(
            audioTrimCommand,
                (session) async {
              final returnCode = await session.getReturnCode();

              Loader.dismiss();
              if (ReturnCode.isSuccess(returnCode)) {
                debugPrint('Audio Trimmed at: ${finalAudioFile.path}');
                // SUCCESS
                Get.back(result: finalAudioFile);
              } else if (ReturnCode.isCancel(returnCode)) {
                debugPrint('Audio Trim failed :: Cancelled');
                // CANCEL
              } else {
                debugPrint('Audio Trim failed :: $returnCode');
                // ERROR
              }
            },
          );
        }
      }
    });
  }

  void updateProgress() {
    currentProgressValue.value = currentProgressValue.value + 1;
    update();
  }

  void resetProgress() {
    currentProgressValue.value = 0.0;
    update();
  }

  void updateRecordingLength(int recordingTime) {
    recordingLength.value = recordingTime;
    update();
  }
}

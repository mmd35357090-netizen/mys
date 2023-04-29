import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/number_extension.dart';
import 'package:path/path.dart' as p;
import 'package:percent_indicator/circular_percent_indicator.dart';

class FileChatTile extends StatefulWidget {
  final ChatMessageModel message;

  const FileChatTile({Key? key, required this.message}) : super(key: key);

  @override
  State<FileChatTile> createState() => _FileChatTileState();
}

class _FileChatTileState extends State<FileChatTile> {
  late TaskInfo _task;
  late String _localPath;
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    if (widget.message.isMineMessage == false) {
      _task = TaskInfo(name: '', link: widget.message.mediaContent.file!.path);

      _bindBackgroundIsolate();
      _prepareSaveDir();
      FlutterDownloader.registerCallback(downloadCallback, step: 1);
    }

    super.initState();
  }

  @override
  void dispose() {
    // _unbindBackgroundIsolate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Heading5Text(
                LocalizationString.file,
                weight: TextWeight.bold,
              ),
              const SizedBox(
                height: 5,
              ),
              widget.message.media != null
                  ? BodyLargeText(
                      widget.message.media!.title!,
                  weight: TextWeight.semiBold

              )
                  : BodyLargeText(
                      widget.message.mediaContent.file!.name,
                  weight: TextWeight.semiBold

              ),
              const SizedBox(
                height: 5,
              ),
              widget.message.media != null
                  ? BodySmallText(
                      widget.message.media!.fileSize!.fileSizeSpecifier,
                    )
                  : BodySmallText(
                      widget.message.mediaContent.file!.size.fileSizeSpecifier,
                    ),
            ],
          ),
        ),
        if (widget.message.isMineMessage == false)
          FutureBuilder<String?>(
              future:
                  getIt<FileManager>().localFilePathForMessage(widget.message),
              // a previously-obtained Future<String> or null
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data != null) {
                    return Container();
                  } else {
                    return _buildTrailing();
                  }
                } else {
                  return Container();
                }
              }),
        widget.message.messageStatusType == MessageStatus.sending
            ? Positioned(
                right: 16,
                child: Center(child: AppUtil.addProgressIndicator(size: 40)))
            : Container()
      ],
    ).bP8;
  }

  Widget _buildTrailing() {
    if (_task.status == DownloadTaskStatus.running) {
      return Row(
        children: [
          Text('${(_task.progress ?? 0) / 100}%'),
          CircularPercentIndicator(
            radius: 20.0,
            lineWidth: 5.0,
            percent: ((_task.progress ?? 0) / 100).toDouble(),
            center: Text('${_task.progress}%'),
            progressColor: Colors.green,
          ),
          IconButton(
            onPressed: () => onActionTap(),
            constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
            icon: const Icon(Icons.pause, color: Colors.yellow),
            tooltip: 'Pause',
          ),
        ],
      );
    } else if (_task.status == DownloadTaskStatus.paused) {
      return Row(
        children: [
          Text('${_task.progress}%'),
          IconButton(
            onPressed: () => onActionTap(),
            constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
            icon: const Icon(Icons.play_arrow, color: Colors.green),
            tooltip: 'Resume',
          ),
          IconButton(
            onPressed: () => () async {
              await FlutterDownloader.remove(
                taskId: _task.taskId!,
                shouldDeleteContent: true,
              );
            },
            constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
            icon: const Icon(Icons.cancel, color: Colors.red),
            tooltip: 'Cancel',
          ),
        ],
      );
    } else if (_task.status == DownloadTaskStatus.complete) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text('Ready', style: TextStyle(color: Colors.green)),
          IconButton(
            onPressed: () => onActionTap(),
            constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
            icon: const Icon(Icons.delete),
            tooltip: 'Delete',
          )
        ],
      );
    } else if (_task.status == DownloadTaskStatus.canceled) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text('Canceled', style: TextStyle(color: Colors.red)),
          IconButton(
            onPressed: () => onActionTap(),
            constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
            icon: const Icon(Icons.cancel),
            tooltip: 'Cancel',
          )
        ],
      );
    } else if (_task.status == DownloadTaskStatus.failed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text('Failed', style: TextStyle(color: Colors.red)),
          IconButton(
            onPressed: () => onActionTap(),
            constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
            icon: const Icon(Icons.refresh, color: Colors.green),
            tooltip: 'Refresh',
          )
        ],
      );
    } else if (_task.status == DownloadTaskStatus.enqueued) {
      return const Text('Pending', style: TextStyle(color: Colors.orange));
    } else {
      return IconButton(
        onPressed: () => onActionTap(),
        constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
        icon: const Icon(Icons.file_download),
        tooltip: 'Start',
      );
    }
  }

  onActionTap() {
    if (_task.status == DownloadTaskStatus.undefined) {
      _requestDownload(_task);
    } else if (_task.status == DownloadTaskStatus.running) {
      _pauseDownload(_task);
    } else if (_task.status == DownloadTaskStatus.paused) {
      _resumeDownload(_task);
    } else if (_task.status == DownloadTaskStatus.complete ||
        _task.status == DownloadTaskStatus.canceled) {
      _delete(_task);
    } else if (_task.status == DownloadTaskStatus.failed) {
      _retryDownload(_task);
    }
  }

  Future<void> _prepareSaveDir() async {
    _localPath = await FileManager.messageMediaDirectory(
        widget.message.localMessageId, widget.message.roomId);
  }

  Future<void> _requestDownload(TaskInfo task) async {
    String extension = p.extension(task.link!);
    task.taskId = await FlutterDownloader.enqueue(
        url: task.link!,
        headers: {'auth': 'test_for_sql_encoding'},
        savedDir: _localPath,
        saveInPublicStorage: true,
        fileName: '${widget.message.localMessageId.toString()}$extension');
  }

  Future<void> _pauseDownload(TaskInfo task) async {
    await FlutterDownloader.pause(taskId: task.taskId!);
  }

  Future<void> _resumeDownload(TaskInfo task) async {
    final newTaskId = await FlutterDownloader.resume(taskId: task.taskId!);
    task.taskId = newTaskId;
  }

  Future<void> _retryDownload(TaskInfo task) async {
    final newTaskId = await FlutterDownloader.retry(taskId: task.taskId!);
    task.taskId = newTaskId;
  }

  // Future<bool> _openDownloadedFile(TaskInfo? task) {
  //   if (task != null) {
  //     return FlutterDownloader.open(taskId: task.taskId!);
  //   } else {
  //     return Future.value(false);
  //   }
  // }

  Future<void> _delete(TaskInfo task) async {
    await FlutterDownloader.remove(
      taskId: task.taskId!,
      shouldDeleteContent: true,
    );
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
    String id,
    DownloadTaskStatus status,
    int progress,
  ) {
// print(
//   'Callback on background isolate: '
//   'task ($id) is in status ($status) and process ($progress)',
// );

    IsolateNameServer.lookupPortByName('downloader_send_port')
        ?.send([id, status, progress]);
  }

  void _bindBackgroundIsolate() {
    final isSuccess = IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      // final taskId = (data as List<dynamic>)[0] as String;
      final status = data[1] as DownloadTaskStatus;
      final progress = data[2] as int;

      // print(
      //   'Callback on UI isolate: '
      //   'task ($taskId) is in status ($status) and process ($progress)',
      // );

      setState(() {
        _task.status = status;
        _task.progress = progress;
      });
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }
}

class ItemHolder {
  ItemHolder({this.name, this.task});

  final String? name;
  final TaskInfo? task;
}

class TaskInfo {
  TaskInfo({this.name, this.link});

  final String? name;
  final String? link;

  String? taskId;
  int? progress = 0;
  DownloadTaskStatus? status = DownloadTaskStatus.undefined;
}

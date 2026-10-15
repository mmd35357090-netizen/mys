import 'dart:async';
import 'package:foap/controllers/chat_and_call/voip_controller.dart';
import 'package:foap/manager/file_manager.dart';
import 'package:foap/manager/socket_manager.dart';
import 'package:get_it/get_it.dart';
import 'db_manager_realm.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerLazySingleton<RealmDBManager>(() => RealmDBManager());
  getIt.registerLazySingleton<FileManager>(() => FileManager());
  getIt.registerLazySingleton<VoipController>(() => VoipController());
  getIt.registerLazySingleton<SocketManager>(() => SocketManager());
}


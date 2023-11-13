import 'package:cache_systems/src/model/cache_file_adapter.dart';
import 'package:dio/dio.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';

enum CacheFileType { image, video, audio, pdf }

class CacheSystem {
  static final CacheSystem _instance = CacheSystem._();
  factory CacheSystem() => _instance;
  CacheSystem._();
  final Dio _dio = Dio();
  final String _cacheName = 'cache';
  late Box<CacheFile> _cacheDB;
  Duration? _stalePeriod;

  Future<void> init({Duration? stalePeriod}) async {
    await Hive.initFlutter();
    Hive.registerAdapter(CacheFileAdapter());
    _cacheDB = await Hive.openBox<CacheFile>(_cacheName);
    _stalePeriod = stalePeriod;
  }

  String getFileType({CacheFileType? fileType, String? name}) {
    if (fileType != null) {
      switch (fileType) {
        case CacheFileType.image:
          return 'image/*';
        case CacheFileType.video:
          return 'video/*';
        case CacheFileType.audio:
          return 'audio/*';
        case CacheFileType.pdf:
          return 'application/pdf';
        default:
          return '*/*';
      }
    } else if (name != null) {
      final ext = name.split('.').last;
      if (ext.length < 2) return 'file';
      switch (ext) {
        case 'jpg':
        case 'jpeg':
        case 'png':
        case 'gif':
          return 'image/*';
        case 'mp4':
        case 'avi':
        case 'mov':
        case 'wmv':
        case 'flv':
        case 'webm':
          return 'video/*';
        case 'mp3':
        case 'wav':
        case 'ogg':
        case 'flac':
          return 'audio/*';
        case 'pdf':
          return 'application/pdf';
        default:
          return '*/*';
      }
    } else {
      return 'file';
    }
  }

  Future<XFile?> getFile(
    Uri url, {
    void Function(int, int)? process,
    String? name,
    CacheFileType? fileType,
  }) async {
    CacheFile? file = _cacheDB.get(url.toString());
    if (file != null) {
      if (file.expiration != null &&
          file.expiration!.isBefore(DateTime.now())) {
        _cacheDB.delete(url.toString());
        return await getFile(url, process: process, name: name);
      }
      return XFile(file.path);
    } else {
      final tmpDirectory = await getApplicationDocumentsDirectory();
      final String newPath = '${tmpDirectory.path}/${name ?? url.toString()}';
      final res =
          await _dio.downloadUri(url, newPath, onReceiveProgress: process);
      if (res.statusCode != 200) {
        throw Exception("download file error");
      }
      await _cacheDB.put(
        url.toString(),
        CacheFile(
          newPath,
          getFileType(fileType: fileType, name: name),
          expiration:
              _stalePeriod != null ? DateTime.now().add(_stalePeriod!) : null,
        ),
      );

      return XFile(newPath);
    }
  }

  Future<void> deleteFile(Uri url) async {
    if (kIsWeb) return;
    CacheFile? file = _cacheDB.get(url.toString());
    if (file != null) {
      await _cacheDB.delete(url.toString());
      await File(file.path).delete();
    }
  }

  Future<void> clear() async {
    if (kIsWeb) return;
    await _cacheDB.clear();
    final tmpDirectory = await getApplicationDocumentsDirectory();
    final dir = Directory(tmpDirectory.path);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<void> close() async {
    await _cacheDB.close();
  }

  Future<void> delete() async {
    if (kIsWeb) return;
    await _cacheDB.deleteFromDisk();
  }

  Future<List<XFile?>> getAllFile() async {
    if (kIsWeb) return [];
    return _cacheDB.values
        .map((e) => XFile(e.path, mimeType: e.fileType))
        .toList();
  }
}

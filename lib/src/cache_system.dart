import 'dart:io';
import 'package:cache_systems/src/model/cache_file_adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

enum CacheFileType {
  image,
  video,
  audio,
  pdf
}

const String _cacheName = 'cache';

class CacheSystem {
  static final CacheSystem _instance = CacheSystem._();
  factory CacheSystem() => _instance;
  CacheSystem._();
  final Dio _dio = Dio();
  late Box<CacheFile> _cacheDB;
  Duration? _stalePeriod;

  Future<void> init({Duration? stalePeriod}) async {
    if ((kIsWeb)) {
      throw Exception('CacheSystem is not supported on web platform');
    }
    final path = (await getApplicationDocumentsDirectory()).path;
    Hive.init(path);
    Hive.registerAdapter(CacheFileAdapter());
    _cacheDB = await Hive.openBox<CacheFile>(_cacheName);
    _stalePeriod = stalePeriod;
  }

  String _getFileType({CacheFileType? fileType, String? name}) {
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

  Future<File?> get(
    Uri url, {
    void Function(int, int)? process,
    String? name,
    CacheFileType? fileType,
  }) async {
    CacheFile? file = _cacheDB.get(url.toString());
    if (file != null) {
      if (file.expiration != null && file.expiration!.isBefore(DateTime.now())) {
        _cacheDB.delete(url.toString());
        return await get(url, process: process, name: name);
      }
      return File(file.path);
    } else {
      final tmpDirectory = await getApplicationDocumentsDirectory();
      final String newPath = '${tmpDirectory.path}/${name ?? url.toString()}';
      final res = await _dio.downloadUri(url, newPath, onReceiveProgress: process);
      if (res.statusCode != 200) {
        throw Exception('Failed to download file');
      }
      await _cacheDB.put(
        url.toString(),
        CacheFile(
          newPath,
          _getFileType(fileType: fileType, name: name),
          expiration: _stalePeriod != null ? DateTime.now().add(_stalePeriod!) : null,
        ),
      );

      return File(newPath);
    }
  }

  Future<ImageProvider> getImageProvider(
    Uri url, {
    void Function(int, int)? process,
    String? name,
  }) async {
    final file = await get(
      url,
      process: process,
      name: name,
      fileType: CacheFileType.image,
    );
    return FileImage(file!);
  }

  Future<void> deleteFile(Uri url) async {
    CacheFile? file = _cacheDB.get(url.toString());
    if (file != null) {
      await _cacheDB.delete(url.toString());
      await File(file.path).delete();
    }
  }

  Future<void> clear() async {
    await _cacheDB.clear();
    final tmpDirectory = await getApplicationDocumentsDirectory();
    final dir = Directory(tmpDirectory.path);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<List<File?>> getAllFile() async {
    return _cacheDB.values.map((e) => File(e.path)).toList();
  }
}

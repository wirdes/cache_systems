import 'package:hive/hive.dart';

part 'cache_file_adapter.g.dart';

@HiveType(typeId: 0)
class CacheFile {
  @HiveField(0)
  String path;
  @HiveField(1)
  DateTime? expiration;
  @HiveField(2)
  String fileType;
  CacheFile(
    this.path,
    this.fileType, {
    this.expiration,
  });
}

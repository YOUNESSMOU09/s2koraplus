import 'dart:io';
import 'dart:isolate';

import 'package:marma/app/app_env.dart';
import 'package:marma/data/parsing/day_bucket_parser.dart';
import 'package:marma/domain/entities/day_bucket.dart';
import 'package:marma/domain/entities/match_status.dart';

/// Reads/writes the parsed day buckets as plain JSON files in
/// `<ApplicationSupport>/marma_cache_v1/`.
///
/// Blobs of this size (hundreds of KB) must not live in `shared_preferences` —
/// its backing plist is loaded whole into memory on every launch.
class BucketCache {
  BucketCache(this._supportDir);

  final Directory _supportDir;

  Directory get _dir => Directory('${_supportDir.path}/${AppEnv.cacheDirName}');

  File _file(String name) => File('${_dir.path}/$name.json');

  /// Deletes stale `marma_cache_v*` siblings so a schema bump self-cleans, and
  /// the pre-rename `terrace_cache_v*` directory so the rename orphans nothing.
  Future<void> prepare() async {
    try {
      if (!await _dir.exists()) {
        await _dir.create(recursive: true);
      }
      await for (final FileSystemEntity entity in _supportDir.list()) {
        if (entity is! Directory) continue;
        final String name = entity.path.split(Platform.pathSeparator).last;
        final bool isStaleSchema =
            name.startsWith(AppEnv.cacheDirPrefix) && name != AppEnv.cacheDirName;
        final bool isPreRename = name.startsWith(AppEnv.legacyCacheDirPrefix);
        if (isStaleSchema || isPreRename) {
          await entity.delete(recursive: true);
        }
      }
    } on FileSystemException {
      // A cache we cannot prepare is a cache miss, never a crash.
    }
  }

  Future<DayBucket?> readDay(DayKey day) async {
    final File file = _file(day.name);
    try {
      if (!await file.exists()) return null;
      final String raw = await file.readAsString();
      return await Isolate.run(() => decodeBucketIsolate(
            CacheDecodeRequest(rawBody: raw, schemaVersion: AppEnv.cacheSchemaVersion),
          ));
    } on Object {
      await _safeDelete(file);
      return null;
    }
  }

  Future<void> writeDay(DayBucket bucket) async {
    try {
      if (!await _dir.exists()) await _dir.create(recursive: true);
      final String encoded = encodeBucket(bucket, AppEnv.cacheSchemaVersion);
      await _atomicWrite(_file(bucket.day.name), encoded);
    } on Object {
      // A failed cache write is not a user-visible failure.
    }
  }

  Future<LiveSnapshot?> readLive() async {
    final File file = _file('live');
    try {
      if (!await file.exists()) return null;
      final String raw = await file.readAsString();
      return await Isolate.run(() => decodeLiveIsolate(
            CacheDecodeRequest(rawBody: raw, schemaVersion: AppEnv.cacheSchemaVersion),
          ));
    } on Object {
      await _safeDelete(file);
      return null;
    }
  }

  Future<void> writeLive(LiveSnapshot snapshot) async {
    try {
      if (!await _dir.exists()) await _dir.create(recursive: true);
      await _atomicWrite(_file('live'), encodeLive(snapshot, AppEnv.cacheSchemaVersion));
    } on Object {
      // ignored — see writeDay
    }
  }

  Future<void> clear() async {
    try {
      if (await _dir.exists()) await _dir.delete(recursive: true);
      await _dir.create(recursive: true);
    } on FileSystemException {
      // ignored
    }
  }

  /// Total bytes on disk, for the About screen.
  Future<int> sizeInBytes() async {
    int total = 0;
    try {
      if (!await _dir.exists()) return 0;
      await for (final FileSystemEntity e in _dir.list()) {
        if (e is File) total += await e.length();
      }
    } on FileSystemException {
      return total;
    }
    return total;
  }

  Future<void> _atomicWrite(File target, String contents) async {
    final File tmp = File('${target.path}.tmp');
    await tmp.writeAsString(contents, flush: true);
    await tmp.rename(target.path);
  }

  Future<void> _safeDelete(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      // ignored
    }
  }
}

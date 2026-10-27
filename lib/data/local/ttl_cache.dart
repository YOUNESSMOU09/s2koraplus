import 'dart:convert';
import 'dart:io';

/// Small JSON file cache with a time-to-live, for GOAL responses that are not
/// day buckets (standings, squads, the league catalog).
///
/// A corrupt or unreadable file is a cache miss, never a crash. Expired entries
/// are still returned by [readStale] so a failed refresh can fall back to them.
class TtlCache {
  TtlCache(this._dir, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final Directory _dir;
  final DateTime Function() _clock;

  File _file(String key) =>
      File('${_dir.path}/${key.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_')}.json');

  /// The cached value if it is younger than [ttl].
  Future<Object?> read(String key, Duration ttl) async {
    final (DateTime, Object?)? entry = await _read(key);
    if (entry == null) return null;
    return _clock().difference(entry.$1) <= ttl ? entry.$2 : null;
  }

  /// The cached value at any age.
  Future<Object?> readStale(String key) async => (await _read(key))?.$2;

  Future<void> write(String key, Object? value) async {
    try {
      await _dir.create(recursive: true);
      final File file = _file(key);
      final File tmp = File('${file.path}.tmp');
      await tmp.writeAsString(jsonEncode(<String, Object?>{
        'at': _clock().millisecondsSinceEpoch,
        'v': value,
      }));
      await tmp.rename(file.path);
    } on FileSystemException {
      // Not caching is acceptable; failing the request is not.
    }
  }

  Future<void> clear() async {
    try {
      if (await _dir.exists()) await _dir.delete(recursive: true);
    } on FileSystemException {
      // Best effort.
    }
  }

  Future<(DateTime, Object?)?> _read(String key) async {
    final File file = _file(key);
    try {
      if (!await file.exists()) return null;
      final Object? decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) return null;
      final int? at = (decoded['at'] as num?)?.toInt();
      if (at == null) return null;
      return (DateTime.fromMillisecondsSinceEpoch(at), decoded['v']);
    } on Object {
      try {
        await file.delete();
      } on FileSystemException {
        // Ignore.
      }
      return null;
    }
  }
}

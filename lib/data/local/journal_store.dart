import 'dart:convert';
import 'dart:io';

import 'package:marma/domain/entities/journal/football_note.dart';
import 'package:marma/domain/entities/journal/journal_enums.dart';

/// Journals on disk: one JSON file per target under
/// `<ApplicationSupport>/marma_journal_v1/<type>_<id>.json`.
///
/// A file per note, rather than one blob, is the mechanical guarantee behind
/// §21: a write for `match_215662` physically cannot touch `match_215663`, and
/// a corrupt file costs exactly one journal.
///
/// This is USER-AUTHORED data — unlike the fixture cache it can never be
/// re-fetched — so nothing here deletes on a read failure, and the directory is
/// never included in "clear cache".
class JournalStore {
  JournalStore(this._supportDir);

  final Directory _supportDir;

  static const String dirName = 'marma_journal_v1';

  Directory get directory => Directory('${_supportDir.path}/$dirName');

  File fileFor(JournalTargetType type, String id) =>
      File('${directory.path}/${FootballNote.keyFor(type, id)}.json');

  Future<void> prepare() async {
    try {
      if (!await directory.exists()) await directory.create(recursive: true);
    } on FileSystemException {
      // A journal directory we cannot create means reads miss and writes fail
      // quietly; it must never take the app down on launch.
    }
  }

  Future<FootballNote?> read(JournalTargetType type, String id) async {
    final File file = fileFor(type, id);
    try {
      if (!await file.exists()) return null;
      final String raw = await file.readAsString();
      if (raw.trim().isEmpty) return null;
      final Object? decoded = json.decode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return FootballNote.fromJson(decoded);
    } on Object {
      // Corrupt or unreadable: surface "no journal" rather than an error, but
      // KEEP the file — a user's own words are never deleted by a parser.
      return null;
    }
  }

  /// Atomic: the reader either sees the previous journal or the new one, never
  /// a half-written file, however the app dies mid-save.
  Future<void> write(FootballNote note) async {
    try {
      if (!await directory.exists()) await directory.create(recursive: true);
      final File target = fileFor(note.targetType, note.targetId);
      final File tmp = File('${target.path}.tmp');
      await tmp.writeAsString(json.encode(note.toJson()), flush: true);
      await tmp.rename(target.path);
    } on Object {
      // Deliberately swallowed: the in-memory journal is still correct, and the
      // next autosave tick retries. Throwing here would put a system error in
      // front of someone mid-sentence.
    }
  }

  Future<void> delete(JournalTargetType type, String id) async {
    try {
      final File file = fileFor(type, id);
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      // ignored
    }
  }

  /// Every journal on disk, newest edit first. Cheap enough to call on a list
  /// screen: these files are kilobytes.
  Future<List<FootballNote>> readAll() async {
    final List<FootballNote> notes = <FootballNote>[];
    try {
      if (!await directory.exists()) return notes;
      await for (final FileSystemEntity entity in directory.list()) {
        if (entity is! File || !entity.path.endsWith('.json')) continue;
        try {
          final Object? decoded = json.decode(await entity.readAsString());
          if (decoded is Map<String, dynamic>) {
            notes.add(FootballNote.fromJson(decoded));
          }
        } on Object {
          continue;
        }
      }
    } on FileSystemException {
      return notes;
    }
    notes.sort((FootballNote a, FootballNote b) =>
        b.updatedAtMillis.compareTo(a.updatedAtMillis));
    return notes;
  }

  Future<int> sizeInBytes() async {
    int total = 0;
    try {
      if (!await directory.exists()) return 0;
      await for (final FileSystemEntity e in directory.list()) {
        if (e is File) total += await e.length();
      }
    } on FileSystemException {
      return total;
    }
    return total;
  }
}

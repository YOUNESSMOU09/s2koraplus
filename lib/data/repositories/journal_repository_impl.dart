import 'package:marma/data/local/journal_store.dart';
import 'package:marma/domain/entities/journal/football_note.dart';
import 'package:marma/domain/entities/journal/journal_enums.dart';
import 'package:marma/domain/repositories/repositories.dart';

class JournalRepositoryImpl implements JournalRepository {
  JournalRepositoryImpl(this._store);

  final JournalStore _store;

  @override
  Future<FootballNote?> read(JournalTargetType type, String id) => _store.read(type, id);

  @override
  Future<void> write(FootballNote note) => _store.write(note);

  @override
  Future<void> delete(JournalTargetType type, String id) => _store.delete(type, id);

  @override
  Future<List<FootballNote>> readAll() => _store.readAll();

  @override
  Future<int> sizeInBytes() => _store.sizeInBytes();
}

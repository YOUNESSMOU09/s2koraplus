import 'package:marma/domain/entities/app_settings.dart';
import 'package:marma/domain/entities/catalog.dart';
import 'package:marma/domain/entities/day_bucket.dart';
import 'package:marma/domain/entities/journal/football_note.dart';
import 'package:marma/domain/entities/journal/journal_enums.dart';
import 'package:marma/domain/entities/match_status.dart';

/// Cache-then-network access to the three day buckets and the live snapshot.
abstract class FixtureRepository {
  /// Parsed bucket from disk, or null on a cache miss / corrupt file.
  Future<DayBucket?> readCachedDay(DayKey day);

  /// Conditional GET. Returns the previous bucket (with a bumped `checkedAt`)
  /// on a 304. Throws [AppFailure] on failure — never a raw exception.
  Future<DayBucket> refreshDay(DayKey day, {DayBucket? previous});

  Future<LiveSnapshot?> readCachedLive();

  Future<LiveSnapshot> refreshLive({LiveSnapshot? previous});

  Future<Health> fetchHealth();

  Future<void> clearCache();

  Future<int> cacheSizeBytes();
}

/// GOAL data beyond the day buckets. Every call is cached with a TTL; none is
/// made at app start.
abstract class CatalogRepository {
  /// Sorted by position; goal difference computed.
  Future<List<StandingRow>> standings(String leagueId);

  /// Goalkeepers to forwards, then by shirt number.
  Future<List<SquadPlayer>> squad(String teamId);

  /// Every active competition (~1019), most popular first. Large: load lazily.
  Future<List<LeagueSummary>> leagues();

  Future<void> clear();
}

abstract class FavouritesRepository {
  Favourites read();
  Future<void> write(Favourites favourites);
}

abstract class SettingsRepository {
  AppSettings read();
  Future<void> write(AppSettings settings);
}

/// The Football Journal. Local-only and offline by construction: nothing a user
/// writes here is ever uploaded, so there is no sync, no conflict and no
/// account.
abstract class JournalRepository {
  /// The journal for one target, or null when none has been started.
  Future<FootballNote?> read(JournalTargetType type, String id);

  Future<void> write(FootballNote note);

  Future<void> delete(JournalTargetType type, String id);

  /// Every journal, most recently edited first.
  Future<List<FootballNote>> readAll();

  Future<int> sizeInBytes();
}

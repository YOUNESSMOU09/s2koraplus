import 'package:marma/data/local/prefs_store.dart';
import 'package:marma/domain/entities/app_settings.dart';
import 'package:marma/domain/repositories/repositories.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._prefs);
  final PrefsStore _prefs;

  @override
  AppSettings read() => _prefs.readSettings();

  @override
  Future<void> write(AppSettings settings) => _prefs.writeSettings(settings);
}

class FavouritesRepositoryImpl implements FavouritesRepository {
  FavouritesRepositoryImpl(this._prefs);
  final PrefsStore _prefs;

  @override
  Favourites read() => _prefs.readFavourites();

  @override
  Future<void> write(Favourites favourites) => _prefs.writeFavourites(favourites);
}

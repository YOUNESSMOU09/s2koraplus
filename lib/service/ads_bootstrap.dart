import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:marma/ads/multi_ads.dart';
import 'package:marma/const.dart';
import 'package:marma/core/failures.dart';
import 'package:marma/core/utils/dev_log.dart';

/// The one-shot remote-config + ads bootstrap that runs behind the splash gate.
///
/// It is the ONLY writer of the three `late` globals in `const.dart`
/// (`configApp`, `gAds`, `isInterShowed`), so nothing may read them before
/// [run] has completed once — which is exactly what the splash gate enforces:
/// the router cannot leave `/splash` until this succeeds.
///
/// The remote document is fetched, not bundled, so ad units and the kill
/// switches in `config` can be changed without shipping a build.
class AdsBootstrap {
  const AdsBootstrap._();

  static const Duration _connectTimeout = Duration(seconds: 8);
  static const Duration _receiveTimeout = Duration(seconds: 10);

  static bool _ready = false;

  /// True once the globals are safe to read.
  static bool get isReady => _ready;

  /// Fetches the config, publishes the globals, then initialises the ad
  /// networks. Idempotent: a second call after success is a no-op, so a retry
  /// never re-creates [gAds] under a live banner.
  ///
  /// Throws an [AppFailure] when the document cannot be fetched or parsed —
  /// the splash renders that as a designed offline state with a retry.
  static Future<void> run() async {
    if (_ready) return;

    final String body = await _fetchConfig();

    final Map<String, dynamic> document;
    try {
      document = json.decode(body) as Map<String, dynamic>;
    } on Object catch (error) {
      throw AppFailure.badResponse('config decode: $error');
    }

    final Object? config = document['config'];
    if (config is! Map) {
      throw const AppFailure.badResponse('config: missing "config" object');
    }

    final MultiAds ads;
    try {
      ads = MultiAds(body);
    } on Object catch (error) {
      throw AppFailure.badResponse('config: unreadable "ads" object ($error)');
    }

    configApp = Map<String, dynamic>.from(config);
    gAds = ads;
    isInterShowed = false;
    _ready = true;

    // Network SDK init and the first ad fill are best-effort: a house that
    // can't be filled must never keep the user out of the app. Every ad
    // surface already renders nothing when it has no ad.
    try {
      await gAds.init();
      await gAds.loadAds();
    } on Object catch (error) {
      devLog('ads', 'init/load failed, continuing adless: $error');
    }
  }

  static Future<String> _fetchConfig() async {
    final Dio dio = Dio(
      BaseOptions(
        connectTimeout: _connectTimeout,
        receiveTimeout: _receiveTimeout,
        responseType: ResponseType.plain,
        // The config is hosted on a Drive share link, which answers with a 3xx
        // to the real file host; dio follows it by default.
        followRedirects: true,
      ),
    );
    try {
      final Response<String> response = await dio.get<String>(Constants.jsonConfigUrl);
      final String? body = response.data;
      if (body == null || body.isEmpty) {
        throw const AppFailure.badResponse('config: empty body');
      }
      return body;
    } on Object catch (error) {
      devLog('ads', 'config fetch failed: $error');
      throw _configFailure(error);
    } finally {
      dio.close();
    }
  }
}

/// Transport error → the designed failure taxonomy, for the config fetch.
AppFailure _configFailure(Object? error) {
  if (error is AppFailure) return error;
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.transformTimeout:
        return AppFailure.timeout(error.message);
      case DioExceptionType.connectionError:
        return AppFailure.noConnection(error.message);
      case DioExceptionType.cancel:
        return AppFailure.cancelled(error.message);
      case DioExceptionType.badCertificate:
      case DioExceptionType.badResponse:
        final int? status = error.response?.statusCode;
        if (status != null && status >= 500) {
          return AppFailure.server('HTTP $status');
        }
        return AppFailure.badResponse('HTTP $status');
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return AppFailure.noConnection(error.message);
        }
        return AppFailure.unknown(error.message);
    }
  }
  if (error is SocketException) return AppFailure.noConnection(error.message);
  if (error is TimeoutException) return const AppFailure.timeout();
  return AppFailure.unknown(error?.toString());
}

/// The complete set of user-facing failure kinds. Every error that reaches the
/// presentation layer is one of these — a raw exception must never surface.
enum FailureKind {
  noConnection,
  timeout,
  server,
  badResponse,
  cancelled,
  emptyDay,
  notFound,

  /// The provider's request quota is spent for now.
  rateLimited,
  unknown,
}

class AppFailure implements Exception {
  const AppFailure(this.kind, {this.debugMessage});

  final FailureKind kind;

  /// Never rendered to the user — logs and About-screen diagnostics only.
  final String? debugMessage;

  const AppFailure.noConnection([String? m])
      : kind = FailureKind.noConnection,
        debugMessage = m;
  const AppFailure.timeout([String? m])
      : kind = FailureKind.timeout,
        debugMessage = m;
  const AppFailure.server([String? m])
      : kind = FailureKind.server,
        debugMessage = m;
  const AppFailure.badResponse([String? m])
      : kind = FailureKind.badResponse,
        debugMessage = m;
  const AppFailure.cancelled([String? m])
      : kind = FailureKind.cancelled,
        debugMessage = m;
  const AppFailure.notFound([String? m])
      : kind = FailureKind.notFound,
        debugMessage = m;
  const AppFailure.rateLimited([String? m])
      : kind = FailureKind.rateLimited,
        debugMessage = m;
  const AppFailure.unknown([String? m])
      : kind = FailureKind.unknown,
        debugMessage = m;

  @override
  String toString() => 'AppFailure(${kind.name}${debugMessage == null ? '' : ': $debugMessage'})';
}

/// Coerces anything thrown anywhere into an [AppFailure].
AppFailure asAppFailure(Object error) {
  if (error is AppFailure) return error;
  return AppFailure.unknown(error.toString());
}

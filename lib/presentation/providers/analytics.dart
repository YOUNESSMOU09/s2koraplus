/// Analytics seam for step 6 (monetization). v1 wires the no-op implementation
/// and sends nothing anywhere — "Data Not Collected" on the privacy label.
abstract class AnalyticsSink {
  const AnalyticsSink();
  void event(String name, [Map<String, Object?> parameters]);
  void screen(String name);
}

class NoopAnalytics extends AnalyticsSink {
  const NoopAnalytics();

  @override
  void event(String name, [Map<String, Object?> parameters = const <String, Object?>{}]) {}

  @override
  void screen(String name) {}
}

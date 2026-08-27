import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/analytics/analytics_service.dart';

/// Single shared [AnalyticsService] — fans every event out to GA4 + Meta.
/// Read it anywhere there is a `ref`: `ref.read(analyticsServiceProvider)`.
final analyticsServiceProvider =
    Provider<AnalyticsService>((ref) => AnalyticsService());

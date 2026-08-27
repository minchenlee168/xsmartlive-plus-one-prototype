import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// App version string sourced from the build config (`pubspec.yaml` →
/// platform bundle), e.g. `1.1.1`. UI should render `v$version` rather
/// than hardcoding a version literal.
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

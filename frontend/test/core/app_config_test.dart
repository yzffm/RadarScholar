import 'package:flutter_test/flutter_test.dart';
import 'package:radarscholar/core/app_config.dart';

void main() {
  test('development localhost API URL is allowed', () {
    expect(AppConfig.isApiBaseUrlSecure, isTrue);
  });

  test('app config exposes a stable application version', () {
    expect(AppConfig.version, isNotEmpty);
  });
}

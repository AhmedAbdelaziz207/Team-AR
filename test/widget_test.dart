import 'package:flutter_test/flutter_test.dart';
import 'package:team_ar/core/utils/weight_utils.dart';

void main() {
  test('App smoke test - Weight utilities verify correctly', () {
    expect(WeightUtils.toKg(100, 'kg'), equals(100.0));
    expect(WeightUtils.format(50, 'kg'), equals('50 kg'));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:team_ar/core/utils/weight_utils.dart';

void main() {
  group('WeightUtils Tests', () {
    test('toKg should return exact value when unit is kg', () {
      expect(WeightUtils.toKg(100.0, 'kg'), equals(100.0));
      expect(WeightUtils.toKg(0.0, 'kg'), equals(0.0));
    });

    test('toKg should convert lbs to kg correctly', () {
      final kg = WeightUtils.toKg(100.0, 'lbs');
      expect(kg, closeTo(45.3592, 0.001));
    });

    test('fromKg should return exact value when unit is kg', () {
      expect(WeightUtils.fromKg(80.0, 'kg'), equals(80.0));
    });

    test('fromKg should convert kg to lbs correctly', () {
      final lbs = WeightUtils.fromKg(45.3592, 'lbs');
      expect(lbs, closeTo(100.0, 0.01));
    });

    test('format should format correctly for integer and decimal weights', () {
      expect(WeightUtils.format(80.0, 'kg'), equals('80 kg'));
      expect(WeightUtils.format(82.5, 'kg'), equals('82.5 kg'));
      expect(WeightUtils.format(100.0, 'lbs'), contains('lbs'));
    });
  });
}

import 'package:addady/domain/app_data.dart';
import 'package:addady/domain/models.dart';
import 'package:addady/domain/tariff.dart';
import 'package:flutter_test/flutter_test.dart';

const _tiers = [
  TariffTier(upTo: 100, price: 0.5),
  TariffTier(upTo: 300, price: 0.75),
  TariffTier(price: 1.25),
];

void main() {
  group('estimate', () {
    const t = Tariff(currency: 'EGP', fixedFee: 10, tiers: _tiers);
    test('inside the first tier', () => expect(t.estimate(50), closeTo(10 + 25, 1e-9)));
    test('crossing into the second tier', () => expect(t.estimate(150), closeTo(10 + 50 + 37.5, 1e-9)));
    test('crossing every tier', () => expect(t.estimate(350), closeTo(10 + 50 + 150 + 62.5, 1e-9)));
    test('exactly on a tier boundary', () => expect(t.estimate(100), closeTo(10 + 50, 1e-9)));
    test('zero consumption still pays the fixed fee', () => expect(t.estimate(0), closeTo(10, 1e-9)));
    test('negative consumption is treated as zero', () => expect(t.estimate(-5), closeTo(10, 1e-9)));
    test('a single open tier is a flat price', () {
      const flat = Tariff(currency: 'EGP', tiers: [TariffTier(price: 2)]);
      expect(flat.estimate(40), closeTo(80, 1e-9));
    });
  });

  group('validate', () {
    test('a good tariff is valid', () => expect(const Tariff(currency: 'EGP', tiers: _tiers).validate(), isNull));
    test('needs at least one tier', () {
      expect(const Tariff(currency: 'EGP', tiers: []).validate() == TariffProblem.noTiers, isTrue);
    });
    test('negative price or fee is refused', () {
      expect(const Tariff(currency: 'EGP', tiers: [TariffTier(price: -1)]).validate() == TariffProblem.invalidPrice, isTrue);
      expect(const Tariff(currency: 'EGP', fixedFee: -1, tiers: [TariffTier(price: 1)]).validate() == TariffProblem.invalidFee, isTrue);
    });
    test('limits must increase and only the last tier is open', () {
      expect(const Tariff(currency: 'EGP', tiers: [TariffTier(upTo: 200, price: 1), TariffTier(upTo: 100, price: 2), TariffTier(price: 3)]).validate() == TariffProblem.limitsNotIncreasing, isTrue);
      expect(const Tariff(currency: 'EGP', tiers: [TariffTier(price: 1), TariffTier(price: 2)]).validate() == TariffProblem.invalidLimit, isTrue);
      expect(const Tariff(currency: 'EGP', tiers: [TariffTier(upTo: 100, price: 1)]).validate() == TariffProblem.lastTierMustBeOpen, isTrue);
      expect(const Tariff(currency: 'EGP', tiers: [TariffTier(upTo: 0, price: 1), TariffTier(price: 2)]).validate() == TariffProblem.invalidLimit, isTrue);
    });
  });

  group('persistence', () {
    test('a meter with a tariff survives encode/decode; one without stays null', () {
      final data = AppData(meters: const [
        Meter(id: '1', type: UtilityType.electricity, place: 'home', unit: 'kWh', tariff: Tariff(currency: 'EGP', fixedFee: 5, tiers: _tiers)),
        Meter(id: '2', type: UtilityType.water, place: '', unit: 'm³'),
      ]);
      final back = AppData.decode(data.encode());
      expect(back.meters.first.tariff!.tiers.length, equals(3));
      expect(back.meters.first.tariff!.tiers.last.upTo, isNull);
      expect(back.meters.first.tariff!.fixedFee, equals(5.0));
      expect(back.meters.last.tariff, isNull);
    });
    test('copyWith keeps or clears the tariff', () {
      const m = Meter(id: '1', type: UtilityType.gas, place: 'a', unit: 'm³', tariff: Tariff(currency: 'EGP', tiers: [TariffTier(price: 1)]));
      expect(m.copyWith(place: 'b').tariff != null, isTrue);
      expect(m.copyWith(clearTariff: true).tariff, isNull);
    });
  });
}

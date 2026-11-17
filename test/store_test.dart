import 'package:addady/data/app_store.dart';
import 'package:addady/data/storage.dart';
import 'package:addady/domain/models.dart';
import 'package:addady/domain/tariff.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('updateMeter changes place, unit and tariff, keeps the readings, and survives a reload', () async {
    final storage = MemoryStorage();
    final store = await AppStore.load(storage);
    final meter = await store.addMeter(type: UtilityType.electricity, place: 'old', unit: 'kWh');
    await store.addReading(meterId: meter.id, value: 100, at: DateTime(2026, 1, 1), isReset: false);

    const tariff = Tariff(currency: 'EGP', fixedFee: 3, tiers: [TariffTier(upTo: 100, price: 1), TariffTier(price: 2)]);
    await store.updateMeter(meterId: meter.id, place: ' new ', unit: ' kWh ', tariff: tariff);

    final updated = store.meterById(meter.id)!;
    expect(updated.place, equals('new'));
    expect(updated.unit, equals('kWh'));
    expect(updated.tariff!.estimate(150), closeTo(3 + 100 + 100, 1e-9));
    expect(store.readingsOf(meter.id).length, equals(1));

    final reloaded = await AppStore.load(storage);
    expect(reloaded.meterById(meter.id)!.tariff!.tiers.length, equals(2));
  });

  test('updateMeter with no tariff clears it; an empty unit keeps the old one', () async {
    final store = await AppStore.load(MemoryStorage());
    final meter = await store.addMeter(type: UtilityType.water, place: '', unit: 'm³');
    await store.updateMeter(
      meterId: meter.id,
      place: '',
      unit: 'm³',
      tariff: const Tariff(currency: 'EGP', tiers: [TariffTier(price: 1)]),
    );
    expect(store.meterById(meter.id)!.tariff != null, isTrue);
    await store.updateMeter(meterId: meter.id, place: '', unit: '   ');
    expect(store.meterById(meter.id)!.tariff, isNull);
    expect(store.meterById(meter.id)!.unit, equals('m³'));
  });
}

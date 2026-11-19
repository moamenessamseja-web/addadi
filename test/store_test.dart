import 'package:addady/data/app_store.dart';
import 'package:addady/data/storage.dart';
import 'package:addady/domain/csv_export.dart';
import 'package:addady/domain/models.dart';
import 'package:addady/domain/tariff.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSink implements ExportSink {
  String? filename;
  String? content;
  String? mime;
  bool fail = false;

  @override
  Future<void> shareFile({required String filename, required String content, required String mimeType}) async {
    if (fail) throw StateError('share failed');
    this.filename = filename;
    this.content = content;
    mime = mimeType;
  }
}

const _headers = ['meter', 'unit', 'date', 'time', 'reading', 'reset', 'consumption'];

void main() {
  test('exportCsv shares one row per reading with a dated file name', () async {
    final sink = _FakeSink();
    final store = await AppStore.load(MemoryStorage(), exportSink: sink);
    final meter = await store.addMeter(type: UtilityType.electricity, place: 'Flat', unit: 'kWh');
    await store.addReading(meterId: meter.id, value: 100, at: DateTime(2026, 1, 1), isReset: false);
    await store.addReading(meterId: meter.id, value: 160, at: DateTime(2026, 2, 1), isReset: false);

    final outcome = await store.exportCsv(headers: _headers, now: DateTime(2026, 3, 9));
    expect(outcome == ExportOutcome.shared, isTrue);
    expect(sink.filename, equals('addady-readings-20260309.csv'));
    expect(sink.mime, equals('text/csv'));
    expect(sink.content!.trim().split('\r\n').length, equals(3));
  });

  test('exportCsv: nothing to export, failing sink, and no sink', () async {
    final sink = _FakeSink();
    final store = await AppStore.load(MemoryStorage(), exportSink: sink);
    expect(await store.exportCsv(headers: _headers) == ExportOutcome.nothingToExport, isTrue);

    final meter = await store.addMeter(type: UtilityType.water, place: '', unit: 'm³');
    await store.addReading(meterId: meter.id, value: 5, at: DateTime(2026, 1, 1), isReset: false);
    sink.fail = true;
    expect(await store.exportCsv(headers: _headers) == ExportOutcome.failed, isTrue);

    final noSink = await AppStore.load(MemoryStorage());
    expect(await noSink.exportCsv(headers: _headers) == ExportOutcome.failed, isTrue);
  });

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

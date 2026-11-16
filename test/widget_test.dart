import 'package:addady/app.dart';
import 'package:addady/data/app_store.dart';
import 'package:addady/data/storage.dart';
import 'package:addady/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('empty state: Arabic, right-to-left, three destinations', (tester) async {
    final store = await AppStore.load(MemoryStorage());
    await tester.pumpWidget(EaddadyApp(store: store));
    await tester.pumpAndSettle();

    expect(find.text('عداداتي'), findsOneWidget);
    expect(find.text('لم تضف أي عداد بعد'), findsOneWidget);
    expect(find.text('العدادات'), findsOneWidget);
    expect(find.text('إضافة قراءة'), findsOneWidget);
    expect(find.text('التحليل'), findsOneWidget);
    expect(Directionality.of(tester.element(find.text('عداداتي'))), TextDirection.rtl);
  });

  testWidgets('a saved reading appears on the meter card and survives a reload', (tester) async {
    final storage = MemoryStorage();
    final store = await AppStore.load(storage);
    final meter = await store.addMeter(type: UtilityType.electricity, place: 'الشقة', unit: 'kWh');
    final problem = await store.addReading(meterId: meter.id, value: 12480, at: DateTime(2026, 11, 9), isReset: false);
    expect(problem, isNull);

    await tester.pumpWidget(EaddadyApp(store: store));
    await tester.pumpAndSettle();
    expect(find.text('كهرباء — الشقة'), findsOneWidget);
    expect(find.text('12,480 kWh'), findsOneWidget);
    expect(find.text('2026/11/09'), findsOneWidget);

    final reloaded = await AppStore.load(storage);
    expect(reloaded.meters.length, 1);
    expect(reloaded.readingsOf(meter.id).single.value, 12480);
  });

  testWidgets('a lower reading without the reset tag is refused and not saved', (tester) async {
    final store = await AppStore.load(MemoryStorage());
    final meter = await store.addMeter(type: UtilityType.water, place: '', unit: 'm³');
    await store.addReading(meterId: meter.id, value: 500, at: DateTime(2026, 10, 1), isReset: false);
    final problem = await store.addReading(meterId: meter.id, value: 100, at: DateTime(2026, 11, 1), isReset: false);
    expect(problem, isNotNull);
    expect(store.readingsOf(meter.id).length, 1);
  });
}

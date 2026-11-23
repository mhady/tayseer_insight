import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tayseer_insight/main.dart';
import 'package:tayseer_insight/services/favorites_store.dart';
import 'package:tayseer_insight/widgets/app_back_button.dart';
import 'package:tayseer_insight/widgets/app_button.dart';
import 'package:tayseer_insight/widgets/app_dialog.dart';
import 'package:tayseer_insight/widgets/app_scaffold.dart';
import 'package:tayseer_insight/widgets/loading_view.dart';

Widget _wrap(Widget child, {double textScale = 1.0}) {
  return MaterialApp(
    locale: const Locale('ar'),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
      child: Directionality(textDirection: TextDirection.rtl, child: child!),
    ),
    home: child,
  );
}

/// Boots the app and waits (in real time) for Home to finish loading its
/// bundled JSON, which `pumpAndSettle` alone does not wait for.
Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const TayseerApp());
  for (var i = 0; i < 100; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
    if (find.text('المفضلات').evaluate().isNotEmpty) break;
  }
  await tester.pumpAndSettle();
  expect(find.text('المفضلات'), findsOneWidget, reason: 'Home did not finish loading');
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('shared widgets', () {
    testWidgets('AppBackButton is a real button, labelled, >= 48dp', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const Scaffold(body: Center(child: AppBackButton()))));

      expect(find.bySemanticsLabel('الرجوع'), findsOneWidget);
      final size = tester.getSize(find.byType(TextButton));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
      expect(
        tester.getSemantics(find.byType(TextButton)),
        matchesSemantics(
          label: 'الرجوع',
          isButton: true,
          isEnabled: true,
          isFocusable: true,
          hasEnabledState: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('AppButton uses semanticLabel for speech but shows its label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(Scaffold(
        body: AppButton(label: 'الفاتحة', semanticLabel: 'سورة الفاتحة', onPressed: () {}),
      )));
      expect(find.text('الفاتحة'), findsOneWidget);
      expect(find.bySemanticsLabel('سورة الفاتحة'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('AppScaffold screen meets Android tap-target and label guidelines',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(AppScaffold(
        title: 'اختبار',
        body: Center(child: AppButton(label: 'زر', onPressed: () {})),
        bottomBar: AppBottomBar(children: [
          AppButton(label: 'أ', minHeight: 70, onPressed: () {}),
          AppButton(label: 'ب', minHeight: 70, onPressed: () {}),
        ]),
      )));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    testWidgets('AppButtonWrap uses 2 columns normally and 1 at large text', (tester) async {
      Widget build(double scale) => _wrap(
            Scaffold(
              body: AppButtonWrap(children: [
                AppButton(label: 'أ', onPressed: () {}),
                AppButton(label: 'ب', onPressed: () {}),
              ]),
            ),
            textScale: scale,
          );
      await tester.pumpWidget(build(1.0));
      final a1 = tester.getTopLeft(find.text('أ'));
      final b1 = tester.getTopLeft(find.text('ب'));
      expect(a1.dy, b1.dy, reason: 'same row at normal size');

      await tester.pumpWidget(build(2.0));
      final a2 = tester.getTopLeft(find.text('أ'));
      final b2 = tester.getTopLeft(find.text('ب'));
      expect(b2.dy, greaterThan(a2.dy), reason: 'stacked at 200% text');
    });

    testWidgets('LoadingView announces a live region and hides the GIF', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const LoadingView()));
      expect(find.text('جاري التحميل'), findsOneWidget);
      expect(
        tester.getSemantics(find.text('جاري التحميل')),
        matchesSemantics(label: 'جاري التحميل', isLiveRegion: true),
      );
      handle.dispose();
    });

    testWidgets('ErrorView offers a working retry button', (tester) async {
      var retried = 0;
      await tester.pumpWidget(_wrap(ErrorView(onRetry: () => retried++)));
      await tester.tap(find.text('إعادة المحاولة'));
      expect(retried, 1);
    });

    testWidgets('text dialog copies inline instead of opening a second dialog',
        (tester) async {
      final copied = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        },
      );
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null));

      final controller = TextEditingController(text: 'نص تجريبي');
      late BuildContext ctx;
      await tester.pumpWidget(_wrap(Builder(builder: (context) {
        ctx = context;
        return const Scaffold();
      })));
      showTextActionsDialog(ctx, title: 'التفسير', source: controller);
      await tester.pumpAndSettle();

      expect(find.text('التفسير'), findsOneWidget);
      expect(find.text('نص تجريبي'), findsOneWidget);
      expect(find.text('تم النسخ'), findsNothing);

      await tester.tap(find.text('نسخ'));
      await tester.pumpAndSettle();

      expect(copied, ['نص تجريبي']);
      expect(find.text('تم النسخ'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget, reason: 'no nested dialog');

      // Text that finishes loading later still shows up.
      controller.text = 'نص محدّث';
      await tester.pump();
      expect(find.text('نص محدّث'), findsOneWidget);

      await tester.tap(find.text('خروج'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  group('FavoritesStore', () {
    test('round-trips and keeps the existing storage format', () async {
      SharedPreferences.setMockInitialValues({
        'favorite2': ['2', '255', 'البقرة(255) الله لا إله'],
      });
      var entries = await FavoritesStore.load();
      expect(entries[0], isNull);
      expect(entries[1]!.sora, 2);
      expect(entries[1]!.aya, 255);
      expect(FavoritesStore.labelFor(entries, 0), 'المفضلة الأولى');
      expect(FavoritesStore.labelFor(entries, 1), 'البقرة(255) الله لا إله');

      await FavoritesStore.save(4, sora: 36, aya: 1, label: 'يس(1) يس');
      entries = await FavoritesStore.load();
      expect(entries[4]!.label, 'يس(1) يس');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('favorite5'), ['36', '1', 'يس(1) يس']);
    });

    test('ignores corrupt entries instead of crashing', () async {
      SharedPreferences.setMockInitialValues({
        'favorite1': ['x'],
        'favorite3': ['a', 'b', 'c'],
      });
      final entries = await FavoritesStore.load();
      expect(entries[0], isNull);
      expect(entries[2], isNull);
    });
  });

  // NOTE: everything that boots the real Home screen lives in ONE test on
  // purpose. Home loads a ~4.5 MB bundled JSON via rootBundle, and under
  // flutter_test a second large-asset load in the same process never
  // completes (reproducible with a bare `rootBundle.loadString`, unrelated to
  // app code). Booting once avoids that harness quirk.
  testWidgets('app: RTL, Home content, large text, Favorites and back navigation',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'favorite1': ['2', '255', 'البقرة(255) الله لا إله'],
    });
    final handle = tester.ensureSemantics();
    tester.view.physicalSize = const Size(360 * 3, 740 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    await _pumpApp(tester);

    // --- Arabic / right-to-left ---
    final context = tester.element(find.byType(Scaffold).first);
    expect(Directionality.of(context), TextDirection.rtl);
    expect(Localizations.localeOf(context).languageCode, 'ar');

    // --- Home content and spoken labels ---
    expect(find.byType(ElevatedButton), findsNWidgets(12 + 4)); // 12 groups + 4 nav
    expect(find.bySemanticsLabel('من سورة الفاتحة إلى سورة الأنفال'), findsOneWidget);
    expect(find.bySemanticsLabel('من سورة العصر إلى سورة الناس'), findsOneWidget);
    expect(find.text('الخدمات'), findsOneWidget);
    // First group sits on the right in RTL.
    expect(tester.getTopRight(find.byType(ElevatedButton).first).dx,
        greaterThan(tester.getTopRight(find.byType(ElevatedButton).at(1)).dx));

    // --- Every screen survives large system text without overflow ---
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    for (final scale in [1.0, 1.5, 2.0, 3.0]) {
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Home overflow at ${scale}x');
      expect(find.text('المفضلات'), findsOneWidget);
      for (final route in ['settings', 'favorites']) {
        navigator.pushNamed(route);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$route overflow at ${scale}x');
        expect(find.text('الرجوع'), findsOneWidget, reason: 'back button at ${scale}x');
        final back = tester.getSize(find.widgetWithText(TextButton, 'الرجوع'));
        expect(back.height, greaterThanOrEqualTo(48));
        navigator.pop();
        await tester.pumpAndSettle();
      }
    }
    tester.platformDispatcher.clearAllTestValues();
    await tester.pumpAndSettle();

    // --- Favorites: saved + empty slots, back returns Home ---
    await tester.tap(find.text('المفضلات'));
    await tester.pumpAndSettle();
    expect(find.text('البقرة(255) الله لا إله'), findsOneWidget);
    expect(find.text('المفضلة الثانية'), findsOneWidget);
    expect(find.text('المفضلة الخامسة'), findsOneWidget);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    await tester.tap(find.text('الرجوع'));
    await tester.pumpAndSettle();
    expect(find.text('تيسير القراءات'), findsOneWidget);
    handle.dispose();
  });
}

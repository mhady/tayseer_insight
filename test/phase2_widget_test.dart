import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tayseer_insight/audioPlayerQuraat.dart';
import 'package:tayseer_insight/globals.dart';
import 'package:tayseer_insight/screens/extraspage.dart';
import 'package:tayseer_insight/screens/khatamat.dart';
import 'package:tayseer_insight/screens/sura_subpage.dart';
import 'package:tayseer_insight/widgets/choice_list.dart';
import 'package:tayseer_insight/widgets/track_player_panel.dart';

/// App shell with Arabic/RTL and a simple routing table; the routes in
/// [routes] get the real screens, anything else shows a stub that records its
/// arguments.
class _Harness {
  _Harness(this.routes);
  final Map<String, WidgetBuilder> routes;
  final navigatorKey = GlobalKey<NavigatorState>();
  final pushed = <String, Object?>{};

  Widget get app => MaterialApp(
        navigatorKey: navigatorKey,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Scaffold(body: Text('الرئيسية-stub')),
        onGenerateRoute: (settings) => MaterialPageRoute(
          settings: settings,
          builder: (context) {
            final real = routes[settings.name];
            if (real != null) return real(context);
            pushed[settings.name!] = settings.arguments;
            return Scaffold(body: Text('stub:${settings.name}'));
          },
        ),
      );

  Future<void> open(WidgetTester tester, String route, {Object? arguments}) async {
    navigatorKey.currentState!.pushNamed(route, arguments: arguments);
    await tester.pumpAndSettle();
  }
}

Widget _plain(Widget child) => MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // flutter_test stalls repeated asset loads in later tests unless the
    // bundle's cache is cleared between tests.
    rootBundle.clear();
  });

  group('audio player controls', () {
    Widget host(audioPlayerQuraat p) => _plain(SingleChildScrollView(
          child: Builder(builder: (c) => p.player_buttons(MediaQuery.of(c))),
        ));

    testWidgets('long recording: labelled buttons, skip buttons, spoken slider',
        (tester) async {
      final handle = tester.ensureSemantics();
      final p = audioPlayerQuraat(onStateChanged: () {}, oncompeleted: () {});
      p.debugSetProgress(
        position: const Duration(seconds: 65),
        duration: const Duration(seconds: 3725),
      );
      await tester.pumpWidget(host(p));

      expect(find.text('تشغيل'), findsOneWidget);
      expect(find.text('إيقاف تام'), findsOneWidget);
      expect(find.text('تقديم 10 ثوان'), findsOneWidget);
      expect(find.text('رجوع 10 ثوان'), findsOneWidget);

      // The slider is spoken as a time, not as "50%".
      final node = tester.getSemantics(find.byType(Slider));
      final value = node.toStringDeep(); // includes the merged value text
      expect(value, contains('موضع التشغيل'));
      expect(value, contains('الموضع 1 دقيقة و5 ثانية'));
      expect(value, contains('من 1 ساعة و2 دقيقة و5 ثانية'));
      handle.dispose();
    });

    testWidgets('single ayah: no skip buttons; slider disabled until length known',
        (tester) async {
      final p = audioPlayerQuraat(onStateChanged: () {}, oncompeleted: () {});
      await tester.pumpWidget(host(p));
      expect(find.text('تقديم 10 ثوان'), findsNothing);
      expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);

      p.debugSetProgress(
          position: const Duration(seconds: 2), duration: const Duration(seconds: 6));
      await tester.pumpWidget(host(p));
      expect(find.text('تقديم 10 ثوان'), findsNothing);
      expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNotNull);
    });

    testWidgets('position past the end can no longer break the slider', (tester) async {
      final p = audioPlayerQuraat(onStateChanged: () {}, oncompeleted: () {});
      p.debugSetProgress(
          position: const Duration(seconds: 9), duration: const Duration(seconds: 6));
      await tester.pumpWidget(host(p));
      expect(tester.takeException(), isNull);
      expect(tester.widget<Slider>(find.byType(Slider)).value, 6);
    });

    testWidgets('failure to start playback is reported, not swallowed', (tester) async {
      final errors = <String>[];
      final p = audioPlayerQuraat(
        onStateChanged: () {},
        oncompeleted: () {},
        onError: errors.add,
      );
      p.setPlayUrl('https://example.invalid/a.mp3');
      // No native audio plugin exists in unit tests, so opening the player fails.
      await tester.runAsync(() => p.play());
      expect(errors, [audioErrorMessage]);
      expect(p.errorMessage, audioErrorMessage);
      expect(p.isStarted, isFalse);
    });

    testWidgets('dispose is idempotent and stops later calls', (tester) async {
      final errors = <String>[];
      final p = audioPlayerQuraat(
          onStateChanged: () {}, oncompeleted: () {}, onError: errors.add);
      p.setPlayUrl('https://example.invalid/a.mp3');
      p.dispose();
      p.dispose();
      await tester.runAsync(() => p.play());
      expect(errors, isEmpty);
    });
  });

  group('ChoiceList and TrackPlayerPanel', () {
    testWidgets('ChoiceList shows subtitles, reports taps and stacks in one column',
        (tester) async {
      int? tapped;
      await tester.pumpWidget(_plain(ChoiceList(
        labels: const ['ختمة 1', 'ختمة 2'],
        subtitles: const ['القارئ: أحمد', null],
        onSelected: (i) => tapped = i,
      )));
      expect(find.text('القارئ: أحمد'), findsOneWidget);
      final first = tester.getTopLeft(find.text('ختمة 1'));
      final second = tester.getTopLeft(find.text('ختمة 2'));
      expect(second.dy, greaterThan(first.dy), reason: 'one column on a phone');
      await tester.tap(find.text('ختمة 2'));
      expect(tapped, 1);
    });

    testWidgets('TrackPlayerPanel: live-region title, people, next/previous',
        (tester) async {
      final handle = tester.ensureSemantics();
      var next = 0, previous = 0;
      final p = audioPlayerQuraat(onStateChanged: () {}, oncompeleted: () {});
      await tester.pumpWidget(_plain(TrackPlayerPanel(
        title: 'سورة البقرة',
        reader: 'أحمد',
        reviewer: 'علي',
        player: p,
        onNext: () => next++,
        onPrevious: () => previous++,
      )));
      expect(find.text('القارئ: أحمد'), findsOneWidget);
      expect(find.text('المراجع: علي'), findsOneWidget);
      expect(
        tester.getSemantics(find.text('سورة البقرة')),
        matchesSemantics(label: 'سورة البقرة', isHeader: true, isLiveRegion: true),
      );
      await tester.tap(find.text('التالي'));
      await tester.tap(find.text('السابق'));
      expect([next, previous], [1, 1]);
      handle.dispose();
    });
  });

  group('ayah number dialog', () {
    Future<_Harness> openDialog(WidgetTester tester) async {
      final h = _Harness({'suras': (_) => const SuraPage()});
      await tester.pumpWidget(h.app);
      await h.open(tester, 'suras', arguments: RequiredSura(id: 1));
      // Real asset I/O: give it time, then settle.
      for (var i = 0; i < 40 && find.text('البقرة').evaluate().isEmpty; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
        await tester.pump();
      }
      await tester.pumpAndSettle();
      await tester.tap(find.text('البقرة'));
      await tester.pumpAndSettle();
      return h;
    }

    testWidgets('shows a real label with the valid range', (tester) async {
      await openDialog(tester);
      expect(find.text('رقم الآية (من 1 إلى 286)'), findsOneWidget);
    });

    testWidgets('empty, zero and too-large input give a spoken error, not a crash',
        (tester) async {
      await openDialog(tester);

      await tester.tap(find.text('ذهاب'));
      await tester.pumpAndSettle();
      expect(find.text('من فضلك أدخل رقم الآية'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '0');
      await tester.tap(find.text('ذهاب'));
      await tester.pumpAndSettle();
      expect(find.text('رقم الآية غير صحيح'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '999');
      await tester.tap(find.text('ذهاب'));
      await tester.pumpAndSettle();
      expect(find.text('رقم الآية يجب أن يكون بين 1 و 286'), findsOneWidget);

      expect(tester.takeException(), isNull);
      expect(find.byType(AlertDialog), findsOneWidget, reason: 'dialog stays open');
    });

    testWidgets('Arabic-Indic digits are accepted and open that ayah', (tester) async {
      final h = await openDialog(tester);
      await tester.enterText(find.byType(TextField), '٢٥٥');
      await tester.tap(find.text('ذهاب'));
      await tester.pumpAndSettle();

      final args = h.pushed['subPage'] as AyaSoraNumber;
      expect(args.aya, '255');
      expect(args.sora, '002');
    });

    testWidgets('typing anything but digits is filtered out', (tester) async {
      await openDialog(tester);
      await tester.enterText(find.byType(TextField), 'a1b2-3');
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '123');
    });

    testWidgets('cancel returns without navigating', (tester) async {
      final h = await openDialog(tester);
      await tester.tap(find.text('الغاء'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(h.pushed.containsKey('subPage'), isFalse);
    });
  });

  group('network failure screens (flutter_test blocks real HTTP)', () {
    for (final entry in <String, WidgetBuilder>{
      'Khadamat': (_) => const Extras(),
      'Khatamat': (_) => const Khatamat(),
    }.entries) {
      testWidgets('${entry.key}: error + retry instead of endless loading',
          (tester) async {
        final handle = tester.ensureSemantics();
        final h = _Harness({'screen': entry.value});
        await tester.pumpWidget(h.app);
        await h.open(tester, 'screen');
        for (var i = 0; i < 20 && find.text('إعادة المحاولة').evaluate().isEmpty; i++) {
          await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 50)));
          await tester.pump();
        }
        await tester.pumpAndSettle();

        expect(find.text('إعادة المحاولة'), findsOneWidget);
        expect(find.text('جاري التحميل'), findsNothing);
        expect(
          tester.getSemantics(find.text('تعذر التحميل. تأكد من الاتصال بالإنترنت.')),
          matchesSemantics(
              label: 'تعذر التحميل. تأكد من الاتصال بالإنترنت.', isLiveRegion: true),
        );

        // Retry goes back to loading, then to the error again (still offline).
        await tester.tap(find.text('إعادة المحاولة'));
        await tester.pump();
        for (var i = 0; i < 20 && find.text('إعادة المحاولة').evaluate().isEmpty; i++) {
          await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 50)));
          await tester.pump();
        }
        await tester.pumpAndSettle();
        expect(find.text('إعادة المحاولة'), findsOneWidget);

        // Back always works, also from the error state.
        await tester.tap(find.text('الرجوع'));
        await tester.pumpAndSettle();
        expect(find.text('الرئيسية-stub'), findsOneWidget);
        handle.dispose();
      });
    }
  });
}

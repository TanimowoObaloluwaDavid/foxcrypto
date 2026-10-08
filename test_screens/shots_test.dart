// Renders every screen to PNG for side-by-side comparison with the Figma design.
// Run:  flutter test test_screens --update-goldens
// Output: test_screens/out/*.png
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:foxcrypto/main.dart';
import 'package:foxcrypto/screens/auth_screens.dart';
import 'package:foxcrypto/screens/home_screen.dart';
import 'package:foxcrypto/screens/onboarding_screen.dart';
import 'package:foxcrypto/screens/verify_screens.dart';

Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    loader.addFont(Future.value(ByteData.sublistView(File(f).readAsBytesSync())));
  }
  await loader.load();
}

Future<void> _precache(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (final e in find.byType(Image).evaluate()) {
      await precacheImage((e.widget as Image).image, e);
    }
  });
  await tester.pump();
}

Future<void> shot(
  WidgetTester tester,
  String name,
  Widget home, {
  Future<void> Function()? then,
  Size size = const Size(375, 812),
}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(FoxcryptoApp(home: home));
  await tester.pump(const Duration(seconds: 1));
  await _precache(tester);
  if (then != null) await then();
  await _precache(tester);
  await tester.pump(const Duration(seconds: 3));
  await expectLater(find.byType(MaterialApp), matchesGoldenFile('out/$name.png'));
}

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    final sdk = Platform.environment['FLUTTER_ROOT'] ?? 'C:/flutter';
    await _loadFont('MaterialIcons', ['$sdk/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
  });

  testWidgets('onboarding', (t) => shot(t, 'onboarding', const OnboardingScreen()));
  for (final n in [2, 3, 4]) {
    testWidgets(
      'onboarding$n',
      (t) => shot(
        t,
        'onboarding$n',
        const OnboardingScreen(),
        then: () async {
          for (var i = 1; i < n; i++) {
            await t.tap(find.byIcon(Icons.chevron_right_rounded));
            await t.pumpAndSettle();
          }
        },
      ),
    );
  }
  testWidgets('login', (t) => shot(t, 'login', const LoginScreen()));
  testWidgets('signup', (t) => shot(t, 'signup', const SignUpScreen()));
  testWidgets('otp', (t) => shot(t, 'otp', const OtpScreen(email: 'you@example.com')));
  testWidgets('verify_document', (t) => shot(t, 'verify_document', const VerifyDocumentScreen()));
  testWidgets('verify_id', (t) => shot(t, 'verify_id', const VerifyIdUploadScreen(docType: DocType.idCard)));
  testWidgets('verify_selfie', (t) => shot(t, 'verify_selfie', const VerifySelfieScreen()));
  testWidgets('verified', (t) => shot(t, 'verified', const VerifiedScreen()));
  testWidgets('home', (t) => shot(t, 'home', const HomeScreen()));
  testWidgets(
    'market',
    (t) => shot(
      t,
      'market',
      const HomeScreen(),
      then: () async {
        await t.tap(find.text('Market'));
        await t.pump(const Duration(seconds: 1));
      },
    ),
  );
  testWidgets(
    'actions',
    (t) => shot(
      t,
      'actions',
      const HomeScreen(),
      then: () async {
        await t.tap(find.byIcon(Icons.add_rounded));
        await t.pumpAndSettle();
      },
    ),
  );
  testWidgets('portfolio', (t) => shot(t, 'portfolio', const HomeScreen(), then: () async {
    await t.tap(find.text('Portfolio'));
    await t.pump(const Duration(seconds: 1));
  }));
  testWidgets('setting', (t) => shot(t, 'setting', const HomeScreen(), then: () async {
    await t.tap(find.text('Setting'));
    await t.pump(const Duration(seconds: 1));
  }));
}

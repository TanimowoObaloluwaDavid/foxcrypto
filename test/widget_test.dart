import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foxcrypto/main.dart';
import 'package:foxcrypto/screens/auth_screens.dart';
import 'package:foxcrypto/screens/home_screen.dart';
import 'package:foxcrypto/screens/verify_screens.dart';
import 'package:foxcrypto/theme.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(375 * 3, 812 * 3); // iPhone-sized
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(theme: AppTheme.dark, home: screen));
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('Onboarding: Skip jumps to the Sign up / Log in page', (tester) async {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const FoxcryptoApp());
    await tester.pump();
    expect(find.text('Skip'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
  });

  testWidgets('Sign up validates email and password', (tester) async {
    await pumpScreen(tester, const SignUpScreen());
    await tester.tap(find.widgetWithText(FilledButton, 'Sign up'));
    await tester.pump();
    expect(find.text('Enter a valid email address'), findsOneWidget);
  });

  testWidgets('Code screen enables Verify after 4 digits', (tester) async {
    await pumpScreen(tester, const OtpScreen(email: 'johny@gmail.com'));
    FilledButton verify() => tester.widget(find.widgetWithText(FilledButton, 'Verify'));
    expect(verify().onPressed, isNull);
    for (final d in ['1', '3', '6', '8']) {
      await tester.tap(find.text(d).last);
      await tester.pump();
    }
    expect(verify().onPressed, isNotNull);
  });

  testWidgets('Verification screens render without overflow', (tester) async {
    await pumpScreen(tester, const VerifyDocumentScreen());
    expect(find.text('Select Country of Resident'), findsOneWidget);
    await pumpScreen(tester, const VerifyIdUploadScreen(docType: DocType.idCard));
    expect(find.text('Upload back page'), findsOneWidget);
    await pumpScreen(tester, const VerifySelfieScreen());
    expect(find.text('Take Selfie Photo'), findsOneWidget);
    await pumpScreen(tester, const VerifiedScreen());
    expect(find.text("You're verified"), findsOneWidget);
  });

  testWidgets('Home renders dashboard and switches tabs', (tester) async {
    await pumpScreen(tester, const HomeScreen());
    expect(find.text('\$18,368.11'), findsOneWidget);
    expect(find.text('Top Coins'), findsOneWidget);
    await tester.tap(find.text('Market'));
    await tester.pump();
    expect(find.text('Solana'), findsWidgets);
  });
}

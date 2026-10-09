// Renders the Foxcrypto brand lockup (fox roundel + wordmark) to a transparent PNG.
// Run:  flutter test test_screens --update-goldens
// Output: test_screens/out/logo.png
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _bg = Color(0xFF16171D);
const _yellow = Color(0xFFF5C249);
const _white = Color(0xFFFFFFFF);

Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    loader.addFont(
      Future.value(ByteData.sublistView(File(f).readAsBytesSync())),
    );
  }
  await loader.load();
}

class _FoxMark extends StatelessWidget {
  const _FoxMark({this.size = 300});
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: const _FoxPainter());
  }
}

class _FoxPainter extends CustomPainter {
  const _FoxPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 300;
    canvas.scale(s, s);

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..color = _yellow;
    final fill = Paint()..style = PaintingStyle.fill;

    canvas.drawCircle(const Offset(150, 150), 138, fill..color = _bg);
    canvas.drawCircle(const Offset(150, 150), 138, ring);

    final face = Path()
      ..moveTo(150, 62)
      ..lineTo(112, 18)
      ..lineTo(128, 118)
      ..lineTo(116, 196)
      ..lineTo(150, 238)
      ..lineTo(184, 196)
      ..lineTo(172, 118)
      ..lineTo(188, 18)
      ..close();
    canvas.drawPath(face, fill..color = _yellow);

    final innerL = Path()
      ..moveTo(150, 62)
      ..lineTo(124, 34)
      ..lineTo(133, 88)
      ..close();
    final innerR = Path()
      ..moveTo(150, 62)
      ..lineTo(176, 34)
      ..lineTo(167, 88)
      ..close();
    canvas.drawPath(innerL, fill..color = _bg);
    canvas.drawPath(innerR, fill..color = _bg);

    final muzzle = Path()
      ..moveTo(121, 190)
      ..lineTo(115, 196)
      ..lineTo(150, 238)
      ..lineTo(185, 196)
      ..lineTo(179, 190)
      ..lineTo(160, 166)
      ..lineTo(140, 166)
      ..close();
    canvas.drawPath(muzzle, fill..color = _white);

    final nose = Path()
      ..moveTo(139, 208)
      ..lineTo(161, 208)
      ..lineTo(150, 238)
      ..close();
    canvas.drawPath(nose, fill..color = _bg);

    canvas.drawCircle(const Offset(122, 150), 5, fill..color = _bg);
    canvas.drawCircle(const Offset(178, 150), 5, fill..color = _bg);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void main() {
  setUpAll(() async {
    final base = '${Directory.current.path}/assets/fonts';
    await _loadFont('PoppinsBold', ['$base/Poppins-Bold.ttf']);
  });

  testWidgets('logo', (tester) async {
    tester.view.physicalSize = const Size(1024, 512);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _FoxMark(size: 300),
              const SizedBox(width: 30),
              const Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 88,
                    height: 1,
                    fontFamily: 'PoppinsBold',
                  ),
                  children: [
                    TextSpan(
                      text: 'fox',
                      style: TextStyle(color: _yellow),
                    ),
                    TextSpan(
                      text: 'crypto',
                      style: TextStyle(color: _white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await expectLater(find.byType(Row), matchesGoldenFile('out/logo.png'));
  });
}

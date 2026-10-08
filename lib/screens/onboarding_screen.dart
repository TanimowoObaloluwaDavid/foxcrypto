import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';
import 'auth_screens.dart';

class _Slide {
  const _Slide(this.image, this.title);

  final String image;
  final InlineSpan title;
}

const _yellow = TextStyle(color: AppColors.primary);

final _slides = <_Slide>[
  const _Slide(
    'assets/images/ill_welcome.png',
    TextSpan(text: 'Welcome To\nFox', children: [TextSpan(text: 'crypto', style: _yellow)]),
  ),
  const _Slide('assets/images/ill_security.png', TextSpan(text: 'Transaction\nSecurity')),
  const _Slide('assets/images/ill_market.png', TextSpan(text: 'Fast And Reliable\nMarket Updated')),
  const _Slide('assets/images/ill_trading.png', TextSpan(text: 'Fast And Flexible\nTrading')),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  bool get _isLast => _page == _slides.length - 1;

  void _goTo(int page) =>
      _controller.animateToPage(page, duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            SizedBox(
              height: 48,
              child: Align(
                alignment: Alignment.centerRight,
                child: AnimatedOpacity(
                  opacity: _isLast ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(
                    onPressed: _isLast ? null : () => _goTo(_slides.length - 1),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                    child: const Text('Skip', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => _SlideView(slide: _slides[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(kPagePadding, 0, kPagePadding, 32),
              child: SizedBox(
                height: 48,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _isLast
                      ? Row(
                          key: const ValueKey('auth'),
                          children: [
                            Expanded(
                              child: SecondaryButton(
                                label: 'Sign up',
                                onPressed: () => Navigator.push(context, fadeRoute(const SignUpScreen())),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: PrimaryButton(
                                label: 'Log in',
                                onPressed: () => Navigator.push(context, fadeRoute(const LoginScreen())),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          key: const ValueKey('nav'),
                          children: [
                            _PageDots(count: _slides.length, index: _page),
                            const Spacer(),
                            Material(
                              color: AppColors.primary,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => _goTo(_page + 1),
                                child: const SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: Icon(Icons.chevron_right_rounded, color: AppColors.background, size: 26),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final maxSize = c.maxWidth > 160.0 ? c.maxWidth : 160.0;
        final imageSize = (c.maxHeight - 200).clamp(0.0, maxSize);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Center(child: Image.asset(slide.image, width: imageSize, height: imageSize, fit: BoxFit.contain)),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kPagePadding),
              child: Text.rich(
                slide.title,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, height: 1.55),
              ),
            ),
            const Spacer(),
          ],
        );
      },
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(right: 5),
          width: active ? 20 : 6,
          height: 4,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.stroke,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

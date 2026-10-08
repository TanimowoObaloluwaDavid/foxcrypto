import 'dart:async';

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';
import 'home_screen.dart';
import 'verify_screens.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? _validateEmail(String? v) =>
    (v == null || !_emailPattern.hasMatch(v.trim())) ? 'Enter a valid email address' : null;

/// "New to Foxcrypto? Create an account" style footer.
class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.prefix, required this.action, required this.onTap});

  final String prefix;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, top: 12),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Text('$prefix ', style: const TextStyle(color: AppColors.dim, fontSize: 14)),
          GestureDetector(
            onTap: onTap,
            child: Text(action,
                style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();

  void _submit() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pushAndRemoveUntil(fadeRoute(const HomeScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const FoxHeader(title: 'Log in'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(kPagePadding, 16, kPagePadding, 24),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LabeledField(
                        label: 'Email Address',
                        hint: 'Enter your email address',
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 20),
                      LabeledField(
                        label: 'Password',
                        hint: 'Enter your password',
                        obscure: true,
                        validator: (v) => (v == null || v.isEmpty) ? 'Enter your password' : null,
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('A password reset link has been sent to your email.')),
                        ),
                        child: const Text('Forgot password?', style: TextStyle(color: AppColors.primary, fontSize: 14)),
                      ),
                      const SizedBox(height: 60),
                      PrimaryButton(label: 'Log in', onPressed: _submit),
                    ],
                  ),
                ),
              ),
            ),
            _FooterLink(
              prefix: 'New to Foxcrypto?',
              action: 'Create an account',
              onTap: () => Navigator.of(context).pushReplacement(fadeRoute(const SignUpScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _accepted = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    if (!_accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms of Use & Privacy Policy.')),
      );
      return;
    }
    Navigator.of(context).push(fadeRoute(OtpScreen(email: _email.text.trim())));
  }

  @override
  Widget build(BuildContext context) {
    const link = TextStyle(color: AppColors.primary);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const FoxHeader(title: 'Sign up'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(kPagePadding, 16, kPagePadding, 24),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabeledField(
                        label: 'Email Address',
                        hint: 'Enter your email address',
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 20),
                      LabeledField(
                        label: 'Password',
                        hint: 'Enter your password',
                        obscure: true,
                        helper: 'At least 8 characters with uppercase letters and numbers',
                        validator: (v) {
                          final p = v ?? '';
                          if (p.length < 8 || !p.contains(RegExp('[A-Z]')) || !p.contains(RegExp('[0-9]'))) {
                            return 'At least 8 characters with uppercase letters and numbers';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      FoxCheckbox(
                        value: _accepted,
                        onChanged: (v) => setState(() => _accepted = v),
                        child: const Text.rich(
                          TextSpan(
                            text: 'Accept ',
                            style: TextStyle(fontSize: 14, color: AppColors.muted),
                            children: [
                              TextSpan(text: 'Terms of Use', style: link),
                              TextSpan(text: ' & '),
                              TextSpan(text: 'Privacy Policy', style: link),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      PrimaryButton(label: 'Sign up', onPressed: _submit),
                    ],
                  ),
                ),
              ),
            ),
            _FooterLink(
              prefix: 'Already have an account?',
              action: 'Log in!',
              onTap: () => Navigator.of(context).pushReplacement(fadeRoute(const LoginScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

/// Email code verification with the on-screen number pad from the design.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.email});

  final String email;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _length = 4;
  static const _resendSeconds = 30;

  String _code = '';
  int _secondsLeft = _resendSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) t.cancel();
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _press(String key) {
    setState(() {
      if (key == '<') {
        if (_code.isNotEmpty) _code = _code.substring(0, _code.length - 1);
      } else if (_code.length < _length) {
        _code += key;
      }
    });
  }

  void _verify() => Navigator.of(context).push(fadeRoute(const VerifyDocumentScreen()));

  @override
  Widget build(BuildContext context) {
    final canResend = _secondsLeft <= 0;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const FoxHeader(title: 'Verification'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(kPagePadding, 12, kPagePadding, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Code have been sent to your email', style: TextStyle(color: AppColors.dim, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(widget.email, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(_length, (i) {
                        final filled = i < _code.length;
                        final active = i == _code.length;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 64,
                          height: 64,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: filled || active ? AppColors.primary : AppColors.stroke,
                              width: active ? 1.6 : 1,
                            ),
                          ),
                          child: Text(filled ? _code[i] : '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        '00 : ${_secondsLeft.clamp(0, 99).toString().padLeft(2, '0')}',
                        style: const TextStyle(color: AppColors.dim, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: TextButton(
                        onPressed: canResend
                            ? () {
                                _startTimer();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('A new code was sent to ${widget.email}')),
                                );
                              }
                            : null,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          disabledForegroundColor: AppColors.primary.withValues(alpha: 0.45),
                        ),
                        child: const Text('Resend Code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(label: 'Verify', onPressed: _code.length == _length ? _verify : null),
                  ],
                ),
              ),
            ),
            _NumberPad(onKey: _press),
          ],
        ),
      ),
    );
  }
}

class _NumberPad extends StatelessWidget {
  const _NumberPad({required this.onKey});

  final ValueChanged<String> onKey;

  static const _letters = {
    '2': 'ABC', '3': 'DEF', '4': 'GHI', '5': 'JKL',
    '6': 'MNO', '7': 'PQRS', '8': 'TUV', '9': 'WXYZ',
  };

  Widget _key(String digit) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Material(
          color: AppColors.stroke,
          borderRadius: BorderRadius.circular(5),
          child: InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () => onKey(digit),
            child: SizedBox(
              height: 46,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(digit, style: const TextStyle(fontSize: 22, height: 1.1)),
                  if (_letters[digit] != null)
                    Text(_letters[digit]!,
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 1.5, height: 1)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 8),
      child: Column(
        children: [
          Row(children: [_key('1'), _key('2'), _key('3')]),
          Row(children: [_key('4'), _key('5'), _key('6')]),
          Row(children: [_key('7'), _key('8'), _key('9')]),
          Row(
            children: [
              const Expanded(
                child: SizedBox(
                  height: 52,
                  child: Center(child: Text('+ * #', style: TextStyle(fontSize: 18, color: AppColors.muted))),
                ),
              ),
              _key('0'),
              Expanded(
                child: IconButton(
                  onPressed: () => onKey('<'),
                  icon: const Icon(Icons.backspace_outlined, color: AppColors.text, size: 22),
                  tooltip: 'Delete',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

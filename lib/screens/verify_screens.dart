import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';
import 'home_screen.dart';

const _countries = [
  'Australia', 'Brazil', 'Canada', 'China', 'Egypt', 'France', 'Germany', 'Ghana', 'India',
  'Indonesia', 'Italy', 'Japan', 'Kenya', 'Mexico', 'Netherlands', 'Nigeria', 'Pakistan',
  'Philippines', 'Poland', 'Saudi Arabia', 'Singapore', 'South Africa', 'South Korea', 'Spain',
  'Sweden', 'Switzerland', 'Turkey', 'United Arab Emirates', 'United Kingdom', 'United States', 'Vietnam',
];

/// Shared layout for the "Verify account" steps: header, scrollable body,
/// consent checkbox and Continue pinned to the bottom.
class _VerifyScaffold extends StatefulWidget {
  const _VerifyScaffold({required this.children, required this.canContinue, required this.onContinue});

  final List<Widget> children;
  final bool canContinue;
  final VoidCallback onContinue;

  @override
  State<_VerifyScaffold> createState() => _VerifyScaffoldState();
}

class _VerifyScaffoldState extends State<_VerifyScaffold> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const FoxHeader(title: 'Verify account'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(kPagePadding, 16, kPagePadding, 16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: widget.children),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(kPagePadding, 0, kPagePadding, 24),
              child: Column(
                children: [
                  SecureInfoCheckbox(value: _agreed, onChanged: (v) => setState(() => _agreed = v)),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Continue',
                    onPressed: _agreed && widget.canContinue ? widget.onContinue : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.5));
}

// ---------------------------------------------------------------------------
// Step 1: country + document type
// ---------------------------------------------------------------------------

enum DocType {
  idCard('Identify Card', Icons.badge_outlined),
  passport('Passport', Icons.menu_book_outlined),
  license("Driver's License", Icons.directions_car_outlined);

  const DocType(this.label, this.icon);

  final String label;
  final IconData icon;
}

class VerifyDocumentScreen extends StatefulWidget {
  const VerifyDocumentScreen({super.key});

  @override
  State<VerifyDocumentScreen> createState() => _VerifyDocumentScreenState();
}

class _VerifyDocumentScreenState extends State<VerifyDocumentScreen> {
  String? _country;
  DocType _doc = DocType.idCard;

  Future<void> _pickCountry() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => _CountrySheet(selected: _country),
    );
    if (picked != null) setState(() => _country = picked);
  }

  @override
  Widget build(BuildContext context) {
    return _VerifyScaffold(
      canContinue: _country != null,
      onContinue: () => Navigator.push(context, fadeRoute(VerifyIdUploadScreen(docType: _doc))),
      children: [
        const _Label('Select Country of Resident'),
        const SizedBox(height: 14),
        InkWell(
          onTap: _pickCountry,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.stroke, width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _country ?? 'Select country',
                    style: TextStyle(fontSize: 15, color: _country == null ? AppColors.hint : AppColors.text),
                  ),
                ),
                const Icon(Icons.arrow_drop_down_rounded, color: AppColors.muted),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        const _Label('Select a valid Government-issued document'),
        const SizedBox(height: 16),
        for (final d in DocType.values) ...[
          _DocOption(type: d, selected: d == _doc, onTap: () => setState(() => _doc = d)),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _DocOption extends StatelessWidget {
  const _DocOption({required this.type, required this.selected, required this.onTap});

  final DocType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.muted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? Colors.transparent : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppColors.primary : AppColors.surface),
        ),
        child: Row(
          children: [
            Icon(type.icon, size: 18, color: color),
            const SizedBox(width: 10),
            Text(type.label, style: TextStyle(fontSize: 14, color: color)),
          ],
        ),
      ),
    );
  }
}

class _CountrySheet extends StatefulWidget {
  const _CountrySheet({this.selected});

  final String? selected;

  @override
  State<_CountrySheet> createState() => _CountrySheetState();
}

class _CountrySheetState extends State<_CountrySheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final list = _countries.where((c) => c.toLowerCase().contains(_query.toLowerCase())).toList();
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.75,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.stroke, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: false,
              onChanged: (v) => setState(() => _query = v),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: 'Search country',
                hintStyle: const TextStyle(color: AppColors.hint),
                prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                filled: true,
                fillColor: AppColors.background,
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                final c = list[i];
                final sel = c == widget.selected;
                return ListTile(
                  title: Text(c, style: TextStyle(color: sel ? AppColors.primary : AppColors.text)),
                  trailing: sel ? const Icon(Icons.check, color: AppColors.primary) : null,
                  onTap: () => Navigator.pop(context, c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2: ID card photos
// ---------------------------------------------------------------------------

class VerifyIdUploadScreen extends StatefulWidget {
  const VerifyIdUploadScreen({super.key, required this.docType});

  final DocType docType;

  @override
  State<VerifyIdUploadScreen> createState() => _VerifyIdUploadScreenState();
}

class _VerifyIdUploadScreenState extends State<VerifyIdUploadScreen> {
  Uint8List? _front;
  Uint8List? _back;

  // A passport only needs the photo page.
  bool get _needsBack => widget.docType != DocType.passport;

  @override
  Widget build(BuildContext context) {
    final name = widget.docType == DocType.idCard ? 'ID Card' : widget.docType.label;
    return _VerifyScaffold(
      canContinue: _front != null && (!_needsBack || _back != null),
      onContinue: () => Navigator.push(context, fadeRoute(const VerifySelfieScreen())),
      children: [
        _Label('Upload Image of $name'),
        const SizedBox(height: 16),
        UploadCard(
          label: _needsBack ? 'Upload front page' : 'Upload photo page',
          image: _front,
          onPicked: (b) => setState(() => _front = b),
        ),
        if (_needsBack) ...[
          const SizedBox(height: 16),
          UploadCard(label: 'Upload back page', image: _back, onPicked: (b) => setState(() => _back = b)),
        ],
        const SizedBox(height: 24),
        const NoteItem('Goverment-issued'),
        const NoteItem('Original full-size, unedited document'),
        const NoteItem('Place documents against a single-coloured background'),
        const NoteItem('Readable, well-lit, coloured images'),
        const NoteItem('No black and white images', ok: false),
        const NoteItem('No edited or expired documents', ok: false),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Step 3: selfie
// ---------------------------------------------------------------------------

class VerifySelfieScreen extends StatefulWidget {
  const VerifySelfieScreen({super.key});

  @override
  State<VerifySelfieScreen> createState() => _VerifySelfieScreenState();
}

class _VerifySelfieScreenState extends State<VerifySelfieScreen> {
  Uint8List? _selfie;

  @override
  Widget build(BuildContext context) {
    return _VerifyScaffold(
      canContinue: _selfie != null,
      onContinue: () => Navigator.push(context, fadeRoute(const VerifiedScreen())),
      children: [
        const _Label('Take Selfie Photo'),
        const SizedBox(height: 16),
        UploadCard(
          label: 'Upload portrait photo',
          image: _selfie,
          height: _selfie == null ? 120 : 220,
          onPicked: (b) => setState(() => _selfie = b),
        ),
        const SizedBox(height: 24),
        const NoteItem('Take a selfie of yourself with a neutral expression'),
        const NoteItem('Make sure your whole face is visible, centred, and your eyes are open'),
        const NoteItem('Do not crop your ID or screenshots of your ID', ok: false),
        const NoteItem('Do not hide or alter parts of your face (No hats/ beauty images/ filters/ headgear)', ok: false),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Step 4: done
// ---------------------------------------------------------------------------

class VerifiedScreen extends StatelessWidget {
  const VerifiedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const FoxHeader(),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: kPagePadding),
                  child: Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.6, end: 1),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutBack,
                        builder: (context, s, child) => Transform.scale(scale: s, child: child),
                        child: Image.asset('assets/images/ill_verified.png', height: 200),
                      ),
                      const SizedBox(height: 28),
                      const Text("You're verified", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      const Text(
                        'You have been verified your information completely. Let\'s make transactions!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.dim, fontSize: 14, height: 1.6),
                      ),
                      const SizedBox(height: 40),
                      PrimaryButton(
                        label: 'Back to Home',
                        onPressed: () => Navigator.of(context).pushAndRemoveUntil(fadeRoute(const HomeScreen()), (_) => false),
                      ),
                      const SizedBox(height: 60),
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

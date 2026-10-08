import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';

// Sample data shown on the dashboard (replace with a real market API later).
class Coin {
  const Coin(this.name, this.symbol, this.price, this.change, this.color, this.glyph, this.spark);

  final String name;
  final String symbol;
  final String price;
  final double change;
  final Color color;
  final String glyph;
  final List<double> spark;
}

const _coins = [
  Coin('Bitcoin', 'BTC', '\$ 45.898,16', 24.55, Color(0xFFF7931A), '₿',
      [3, 4, 3.5, 5, 4.6, 6, 4.8, 9, 5, 3.8, 7.5, 8.4, 5.2, 4.4, 7.8, 6.2]),
  Coin('Ethereum', 'ETH', '\$ 5.898,16', 2.55, Color(0xFFECEFF4), 'Ξ',
      [2.8, 4.2, 3.4, 5.2, 4.4, 6.4, 5, 9.2, 5.4, 4, 8, 8.8, 5, 4.2, 8.1, 6.4]),
  Coin('Solana', 'SOL', '\$ 142,37', -1.12, Color(0xFF9B6BFF), 'S',
      [7, 6.5, 7.2, 6, 5.4, 5.8, 4.9, 5.2, 4.4, 4.7, 4.1, 4.5]),
  Coin('Cardano', 'ADA', '\$ 0,61', 3.08, Color(0xFF3B82F6), 'A',
      [3, 3.4, 3.1, 3.9, 4.2, 4.0, 4.6, 4.3, 5.1, 5.4, 5.2, 5.9]),
];

const _news = [
  ('Analysts project 32% upside for Coinbase stock despite market dip', '2 hours ago'),
  ('Bitcoin holds above \$45K as trading volume climbs', '5 hours ago'),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  void _showActions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        Widget action(IconData icon, String label) => Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text('$label is coming soon')));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.14),
                        child: Icon(icon, color: AppColors.primary),
                      ),
                      const SizedBox(height: 8),
                      Text(label, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ),
            );
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Row(
              children: [
                action(Icons.add_shopping_cart_rounded, 'Buy'),
                action(Icons.sell_outlined, 'Sell'),
                action(Icons.north_east_rounded, 'Send'),
                action(Icons.south_west_rounded, 'Receive'),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _Dashboard(),
      const _MarketTab(),
      const _Placeholder(icon: Icons.pie_chart_outline_rounded, title: 'Portfolio'),
      const _Placeholder(icon: Icons.settings_outlined, title: 'Settings'),
    ];
    return Scaffold(
      extendBody: true,
      body: SafeArea(bottom: false, child: IndexedStack(index: _tab, children: pages)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _showActions,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 34),
      ),
      bottomNavigationBar: _TabBar(index: _tab, onTap: (i) => setState(() => _tab = i)),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    Widget item(int i, IconData icon, String label) {
      final active = i == index;
      final color = active ? AppColors.primary : AppColors.dim;
      return Expanded(
        child: InkResponse(
          onTap: () => onTap(i),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 12, color: color)),
            ],
          ),
        ),
      );
    }

    return BottomAppBar(
      color: AppColors.tabBar,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      height: 72,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          item(0, Icons.home_outlined, 'Home'),
          item(1, Icons.bar_chart_rounded, 'Market'),
          const SizedBox(width: 72),
          item(2, Icons.pie_chart_outline_rounded, 'Portfolio'),
          item(3, Icons.settings_outlined, 'Setting'),
        ],
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(kPagePadding, 4, kPagePadding, 120),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded), tooltip: 'Search'),
            IconButton(
              onPressed: () {},
              icon: const Badge(
                smallSize: 8,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.notifications_none_rounded),
              ),
              tooltip: 'Notifications',
            ),
          ],
        ),
        const SizedBox(height: 4),
        const _BalanceCard(),
        const SizedBox(height: 24),
        const SectionHeader('Top Coins'),
        const SizedBox(height: 14),
        SizedBox(
          height: 196,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: _coins.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, i) => _CoinCard(coin: _coins[i]),
          ),
        ),
        const SizedBox(height: 28),
        const SectionHeader('News'),
        const SizedBox(height: 14),
        for (final (title, time) in _news) ...[
          _NewsCard(title: title, time: time),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

/// Uses the card artwork from the design and draws live text on top of it.
class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final s = c.maxWidth / 375; // artwork is 375 x 242
        const ink = Color(0xFF16171D);
        return SizedBox(
          height: 242 * s,
          child: Stack(
            children: [
              Positioned.fill(child: Image.asset('assets/images/balance_card.png', fit: BoxFit.fill)),
              Positioned(
                left: 30 * s,
                top: 70 * s,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Balance', style: TextStyle(fontSize: 15 * s, color: ink.withValues(alpha: 0.7))),
                    SizedBox(height: 2 * s),
                    Text('\$18,368.11',
                        style: TextStyle(fontSize: 34 * s, fontWeight: FontWeight.w600, color: ink, height: 1.25)),
                  ],
                ),
              ),
              Positioned(
                left: 30 * s,
                top: 192 * s,
                child: Row(
                  children: [
                    Icon(Icons.trending_up_rounded, size: 18 * s, color: AppColors.success),
                    SizedBox(width: 6 * s),
                    Text('\$1,816', style: TextStyle(fontSize: 15 * s, color: ink, fontWeight: FontWeight.w500)),
                    SizedBox(width: 10 * s),
                    Text("Today's Profit", style: TextStyle(fontSize: 14 * s, color: ink.withValues(alpha: 0.6))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CoinIcon extends StatelessWidget {
  const _CoinIcon(this.coin, {this.size = 24});

  final Coin coin;
  final double size;

  @override
  Widget build(BuildContext context) {
    final dark = coin.color.computeLuminance() > 0.6;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: coin.color, shape: BoxShape.circle),
      child: Text(
        coin.glyph,
        style: TextStyle(
          fontSize: size * 0.58,
          fontWeight: FontWeight.w700,
          height: 1,
          color: dark ? AppColors.background : Colors.white,
        ),
      ),
    );
  }
}

class _CoinCard extends StatelessWidget {
  const _CoinCard({required this.coin});

  final Coin coin;

  @override
  Widget build(BuildContext context) {
    final up = coin.change >= 0;
    final trend = up ? AppColors.success : AppColors.danger;
    return Container(
      width: 156,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CoinIcon(coin),
              const SizedBox(width: 10),
              Expanded(
                child: Text(coin.name,
                    overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(coin.price,
              maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, color: AppColors.muted)),
          Row(
            children: [
              Text('${coin.change.abs().toStringAsFixed(2).replaceAll('.', ',')}%',
                  style: TextStyle(fontSize: 11, color: trend)),
              Icon(up ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded, size: 16, color: trend),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SizedBox(width: double.infinity, child: CustomPaint(painter: _SparklinePainter(coin.spark, trend))),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.values, this.color);

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV) == 0 ? 1 : maxV - minV;
    final pts = [
      for (var i = 0; i < values.length; i++)
        Offset(i / (values.length - 1) * size.width, size.height - (values[i] - minV) / range * (size.height - 4) - 2),
    ];
    // Smooth curve through the points.
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = pts[i], p1 = pts[i + 1];
      final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
    }
    path.lineTo(pts.last.dx, pts.last.dy);

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.values != values || old.color != color;
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.title, required this.time});

  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset('assets/images/news.png', width: 96, height: 72, fit: BoxFit.cover),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4)),
                const SizedBox(height: 6),
                Text(time, style: const TextStyle(fontSize: 12, color: AppColors.dim)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketTab extends StatelessWidget {
  const _MarketTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(kPagePadding, 16, kPagePadding, 120),
      children: [
        const Text('Market', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        for (final c in _coins)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                _CoinIcon(c, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      Text(c.symbol, style: const TextStyle(fontSize: 12, color: AppColors.dim)),
                    ],
                  ),
                ),
                SizedBox(
                  width: 70,
                  height: 32,
                  child: CustomPaint(
                    painter: _SparklinePainter(c.spark, c.change >= 0 ? AppColors.success : AppColors.danger),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(c.price, style: const TextStyle(fontSize: 14)),
                    Text(
                      '${c.change >= 0 ? '+' : '-'}${c.change.abs().toStringAsFixed(2)}%',
                      style: TextStyle(fontSize: 12, color: c.change >= 0 ? AppColors.success : AppColors.danger),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: AppColors.stroke),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Coming soon', style: TextStyle(color: AppColors.dim)),
        ],
      ),
    );
  }
}

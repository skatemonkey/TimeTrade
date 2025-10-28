import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_vault/data/dao/leisure_ledger_dao.dart';
import 'package:time_vault/data/dao/points_ledger_dao.dart';
import 'package:time_vault/data/models/leisure_ledger.dart';
import 'package:time_vault/page/template_page.dart';

import '../data/models/points_ledger.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  double _points = 0.0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _refreshPoints();
  }

  Future<void> _refreshPoints() async {
    final v = await PointsLedgerDao.instance.getAvailablePoints();
    if (!mounted) return;
    setState(() => _points = v); // already 2-decimal rounded from SQL
  }

  Future<void> _buyOneHour() async {
    const price = 240.0; // 1 point -> 1 hour (3600 sec)

    if (_points < price) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Not enough points')));
      }
      return;
    }

    setState(() => _loading = true);

    try {
      // 2) Credit entertainment wallet (+3600 sec)
      final leisureLedger = LeisureLedger(
        ts: DateTime.now().millisecondsSinceEpoch,
        deltaSec: 3600,
      );
      final timewalletid = await LeisureLedgerDao.instance.insert(
        leisureLedger,
      );

      // 1) Spend a point (points_ledger: -1.0)
      final spend = PointsLedger(
        ts: DateTime.now().millisecondsSinceEpoch,
        source: 'spend',
        refType: 'entertainment',
        refId: timewalletid,
        delta: -price,
      );
      await PointsLedgerDao.instance.insert(spend);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Purchased 1 hour 🎉')));
      }

      await _refreshPoints();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Purchase failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canBuy = !_loading && _points >= 1.0;

    return TemplatePage(
      title: "Shop",
      actions: [
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 180, maxWidth: 220),
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.only(left: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              title: const Text(
                'Your Points',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              subtitle: Text(
                _loading ? 'Updating…' : _points.toStringAsFixed(2),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: _loading ? null : _refreshPoints,
              ),
            ),
          ),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: _refreshPoints,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Card(
            //   child: ListTile(
            //     title: const Text('Your Points'),
            //     subtitle: Text(
            //       _loading ? 'Updating…' : _points.toStringAsFixed(2),
            //     ),
            //     trailing: IconButton(
            //       icon: const Icon(Icons.refresh),
            //       onPressed: _loading ? null : _refreshPoints,
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: const Text('1 Hour Entertainment Time'),
                subtitle: const Text(
                  'Price: 240.00 point • Adds +3600s to wallet',
                ),
                trailing: ElevatedButton(
                  onPressed: canBuy ? _buyOneHour : null,
                  child: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Buy'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

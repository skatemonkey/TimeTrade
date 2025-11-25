import 'package:flutter/material.dart';
import 'package:time_vault/core/constants.dart';
import 'package:time_vault/data/dao/leisure_ledger_dao.dart';
import 'package:time_vault/data/dao/points_ledger_dao.dart';
import 'package:time_vault/data/models/leisure_ledger.dart';
import 'package:time_vault/page/template_page.dart';

import '../app_colors.dart';
import '../data/models/points_ledger.dart';

// add these
import 'package:time_vault/data/dao/item_dao.dart';
import 'package:time_vault/data/models/item.dart';

import '../widgets/edit_item_price_dialog.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  double _points = 0.0;
  bool _loading = false;

  Item? _item1Hour;
  Item? _item1Day;
  bool _itemsLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshPoints();
    _loadItems();
  }

  Future<void> _refreshPoints() async {
    final v = await PointsLedgerDao.instance.getAvailablePoints();
    if (!mounted) return;
    setState(() => _points = v); // already 2-decimal rounded from SQL
  }

  Future<void> _loadItems() async {
    try {
      final itemHour =
      await ItemDao.instance.getByKey(Constants().leisureOneHour);
      final itemDay =
      await ItemDao.instance.getByKey(Constants().leisureOneDay);

      if (!mounted) return;
      setState(() {
        _item1Hour = itemHour;
        _item1Day = itemDay;
        _itemsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _itemsLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load shop items: $e')),
      );
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _refreshPoints(),
      _loadItems(),
    ]);
  }

  Future<void> _buyOneHour() async {
    if (_item1Hour == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item not loaded yet')),
      );
      return;
    }

    final price = _item1Hour!.costPoints;

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
      // credit entertainment wallet (+3600 sec)
      final leisureLedger = LeisureLedger(
        ts: DateTime.now().millisecondsSinceEpoch,
        deltaSec: 3600,
      );
      final timewalletid = await LeisureLedgerDao.instance.insert(
        leisureLedger,
      );

      // spend points
      final spend = PointsLedger(
        ts: DateTime.now().millisecondsSinceEpoch,
        source: 'spend',
        refType: 'entertainment_1h',
        refId: timewalletid,
        delta: -price,
      );
      await PointsLedgerDao.instance.insert(spend);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(
          content: Text('Purchased ${_item1Hour!.name} 🎉'),
        ));
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

  Future<void> _buyOneDay() async {
    if (_item1Day == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item not loaded yet')),
      );
      return;
    }

    final price = _item1Day!.costPoints;

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
      // spend points
      final spend = PointsLedger(
        ts: DateTime.now().millisecondsSinceEpoch,
        source: 'spend',
        refType: 'entertainment_1day',
        refId: null,
        delta: -price,
      );
      await PointsLedgerDao.instance.insert(spend);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(
          content: Text('Purchased ${_item1Day!.name} 🎉'),
        ));
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

  Future<void> _editItemPrice(Item item) async {
    final newPrice = await showDialog<double>(
      context: context,
      builder: (ctx) => EditItemPriceDialog(item: item),
    );

    if (newPrice == null) return;

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final updated = Item(
        id: item.id,
        key: item.key,
        name: item.name,
        description: item.description,
        costPoints: newPrice,
        createdTs: item.createdTs,
        updatedTs: now,
      );

      await ItemDao.instance.update(updated);

      setState(() {
        if (item.key == Constants().leisureOneHour) {
          _item1Hour = updated;
        } else if (item.key == Constants().leisureOneDay) {
          _item1Day = updated;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Price updated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update price: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final canBuyHour = !_loading &&
        !_itemsLoading &&
        _item1Hour != null &&
        _points >= _item1Hour!.costPoints;

    final canBuyDay = !_loading &&
        !_itemsLoading &&
        _item1Day != null &&
        _points >= _item1Day!.costPoints;

    return TemplatePage(
      title: "Shop",
      actionsTopOffset: 30,
      actions: [
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 180, maxWidth: 220),
          child: Card(
            color: AppColors.white,
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
                onPressed: _loading ? null : _refreshAll,
              ),
            ),
          ),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: _refreshAll,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: AppColors.bg,
              child: ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: Text(
                  _item1Hour?.name ?? '1 Hour Entertainment Time',
                ),
                subtitle: Text(
                  _itemsLoading || _item1Hour == null
                      ? 'Loading item...'
                      : 'Price: ${_item1Hour!.costPoints.toStringAsFixed(2)} points • Adds +3600s to wallet',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit price',
                      onPressed: (_itemsLoading || _item1Hour == null)
                          ? null
                          : () => _editItemPrice(_item1Hour!),
                    ),
                    ElevatedButton(
                      onPressed: canBuyHour ? _buyOneHour : null,
                      child: _loading
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child:
                        CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text('Buy'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: AppColors.bg,
              child: ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(
                  _item1Day?.name ?? '1 Day Entertainment Time',
                ),
                subtitle: Text(
                  _itemsLoading || _item1Day == null
                      ? 'Loading item...'
                      : 'Price: ${_item1Day!.costPoints.toStringAsFixed(2)} points • Adds 1 day to placeholder',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit price',
                      onPressed: (_itemsLoading || _item1Day == null)
                          ? null
                          : () => _editItemPrice(_item1Day!),
                    ),
                    ElevatedButton(
                      onPressed: canBuyDay ? _buyOneDay : null,
                      child: _loading
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child:
                        CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text('Buy'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

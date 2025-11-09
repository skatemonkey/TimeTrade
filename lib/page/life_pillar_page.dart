import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_table/flutter_advanced_table.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Import the library
import 'package:time_vault/page/template_page.dart';

import '../app_colors.dart';
import '../core/date_utils.dart';
import '../data/dao/life_pillar_dao.dart';
import '../data/models/life_pillar.dart';
import '../widgets/add_pillar_dialog.dart';
import '../widgets/action_menu_button.dart';
import '../widgets/add_button.dart';
import '../widgets/confirm_dialog.dart';

class LifePillarPage extends StatefulWidget {
  const LifePillarPage({super.key});

  @override
  State<LifePillarPage> createState() => _LifePillarPageState();
}

class _LifePillarPageState extends State<LifePillarPage> {
  final ValueNotifier<bool> _isLoadingAll = ValueNotifier(false);
  final ValueNotifier<bool> _isLoadingMore = ValueNotifier(false);
  late List<LifePillar> _pillars = const [];
  final int _initialLoad = 10;
  final int _loadMoreCount = 5;

  @override
  void initState() {
    super.initState();
    _loadLifePillars();
  }

  Future<void> _loadLifePillars() async {
    _isLoadingAll.value = true; // start loading
    final pillars = await LifePillarDao.instance.getAll();
    if (!mounted) return;

    setState(() {
      _pillars = pillars;
    });
    _isLoadingAll.value = false; // stop loading
  }

  Widget rowBuilder(
    BuildContext context,
    int rowIndex,
    Widget row,
    bool isHover,
    int length,
  ) {
    // _loadMore(rowIndex); // For lazy loading
    return AnimatedScale(
      duration: const Duration(milliseconds: 300),
      scale: isHover ? 1.02 : 1,
      child: row.animate(
        delay: length < 10 ? (rowIndex.milliseconds * 300) : null,
        effects: [
          SlideEffect(
            duration: 500.milliseconds,
            curve: Curves.easeInOut,
            begin: const Offset(0, -0.1),
          ),
          FadeEffect(),
        ],
      ),
    );
  }

  BoxDecoration rowDecorationBuilder(
    BuildContext context,
    int index,
    bool isHover,
  ) {
    final isOdd = index % 2 == 0;
    return BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(7.0)),
      // Consistent rounding
      color: isHover
          ? Theme.of(context).primaryColor.withAlpha(100)
          : isOdd
          ? Colors.transparent
          : Theme.of(context).primaryColor.withOpacity(0.1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TemplatePage(
      title: "Life Pillar",
      actions: [
        AddButton<LifePillar>(
          showDialogFn: (context) => showDialog<LifePillar>(
            context: context,
            builder: (_) => const AddPillarDialog(isEdit: false),
          ),
          onInsert: (pillar) => LifePillarDao.instance.insert(pillar),
          onReload: () => setState(() => _loadLifePillars()),
        ),
      ],

      child: AdvancedTableWidget(
        isLoadingAll: _isLoadingAll,
        isLoadingMore: _isLoadingMore,
        items: _pillars,
        headerItems: const [
          'Order',
          'Life Pillar',
          'Score Weight',
          'Is Active',
          'Time Status',
          'Created At',
          'Last Updated',
        ],
        onEmptyState: const Center(child: Text('No pillars yet!')),
        fullLoadingPlaceHolder: const Center(
          child: CircularProgressIndicator(),
        ),
        loadingMorePlaceHolder: const LinearProgressIndicator(),
        headerBuilder: (context, header) => Container(
          width: header.defualtWidth, // Use provided width
          padding: const EdgeInsets.all(8.0),
          alignment: header.index == 0
              ? Alignment.centerLeft
              : Alignment.center, // Example alignment
          child: Text(
            header.value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        rowElementsBuilder: (context, rowParams) {
          final pillar = _pillars[rowParams.index];
          return [
            SizedBox(
              width: rowParams.defualtWidth,
              child: Text(pillar.sortOrder.toString()),
            ),
            SizedBox(
              width: rowParams.defualtWidth,
              child: Center(child: Text(pillar.name)),
            ),
            SizedBox(
              width: rowParams.defualtWidth,
              child: Center(child: Text(pillar.scoreWeight.toString())),
            ),
            SizedBox(
              width: rowParams.defualtWidth,
              child: Center(child: Text(pillar.isActive.toString())),
            ),
            SizedBox(
              width: rowParams.defualtWidth,
              child: Center(child: Text(formatTimestamp(pillar.createdTs))),
            ),
            SizedBox(
              width: rowParams.defualtWidth,
              child: Center(child: Text(formatTimestamp(pillar.createdTs))),
            ),
            SizedBox(
              width: rowParams.defualtWidth,
              child: Center(child: Text(formatTimestamp(pillar.updatedTs))),
            ),
          ];
        },
        actionBuilder: (context, actionParams) {
          return ActionMenuButton(
            onEdit: () async {
              final updated = await showDialog<LifePillar>(
                context: context,
                builder: (_) => AddPillarDialog(
                  isEdit: true,
                  existingItem: _pillars[actionParams.rowIndex],
                ),
              );

              if (updated != null) {
                await LifePillarDao.instance.update(updated);
                setState(() {
                  _loadLifePillars(); // refresh table
                });
              }
            },
            onDelete: () async {
              final pillar = _pillars[actionParams.rowIndex];
              final confirmed = await showConfirmDialog(
                context: context,
                title: 'Delete Pillar',
                content: 'Are you sure you want to delete this life pillar?',
                confirmText: 'Delete',
                confirmColor: Colors.red,
              );

              if (confirmed == true) {
                // perform the delete
                await LifePillarDao.instance.delete(pillar.id!);
                _loadLifePillars();
              }
            },
          );

          // return IconButton(
          //   icon: const Icon(Icons.more_vert),
          //   onPressed: () {
          //     // Do something exciting!
          //     print(
          //       'Action on row ${actionParams.rowIndex}, item ${actionParams.index}',
          //     );
          //   },
          // );
        },
        actions: [
          {"label": "view"},
        ],
        rowDecorationBuilder: (index, isHovered) =>
            rowDecorationBuilder(context, index, isHovered),
        rowBuilder: (context, index, row, isHover) =>
            rowBuilder(context, index, row, isHover, _pillars.length),
        onRowTap: (index) {
          print('Row $index tapped!');
        },
        // Add more customizations here!
      ),
    );
  }
}

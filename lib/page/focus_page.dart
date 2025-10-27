import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/dao/life_pillar_dao.dart';
import '../data/models/life_pillar.dart';
import '../services/TimerService.dart';
import '../core/date_utils.dart';

class FocusPage extends StatefulWidget {
  const FocusPage({super.key});

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  bool _lifePillarLoading = true;

  @override
  void initState() {
    super.initState();
    // load once; survives navigation because it's in TimerService
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimerService>().ensurePillarsLoaded();
    });
    _lifePillarLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<TimerService>();
    final isRunning = svc.isFocusRunning;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatDate1(svc.elapsed),
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () async {
              if (isRunning) {
                svc.stopFocusAndReset(); // stop + persist
              } else {
                // ensure a pillar is selected before starting
                if (svc.selectedLifePillarId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add a Life Pillar first.')),
                  );
                  return;
                }
                svc.startFocus(); // start
              }
            },
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE6D9FF),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 12,
                    offset: Offset(0, 6),
                    color: Color(0x22000000),
                  ),
                ],
              ),
              child: Icon(
                isRunning ? Icons.stop : Icons.play_arrow,
                size: 32,
                color: const Color(0xFF2B134D),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // DropdownMenu (Material 3)
          if (_lifePillarLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            // Segment/Chip selector — pretty and stateful
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  // <— center in row
                  runAlignment: WrapAlignment.center,
                  // <— center when wrapping
                  spacing: 8,
                  runSpacing: 8,
                  children: svc.pillars.map((p) {
                    final selected = p.id == svc.selectedLifePillarId;
                    return ChoiceChip(
                      label: Text(p.name),
                      selected: selected,
                      onSelected: (_) => svc.setLifePillar(p.id!),
                      labelStyle: TextStyle(
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      selectedColor: const Color(0xFFE6D9FF),
                      backgroundColor: const Color(0xFFF7F4FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: selected
                            ? const Color(0xFF2B134D)
                            : Colors.transparent,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/dao/life_pillar_dao.dart';
import '../data/models/life_pillar.dart';
import '../services/TimerService.dart';
import '../core/date_utils.dart';
import '../widgets/timer_section.dart';

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
    final bool isRunning = svc.isFocusRunning;
    final String timeText = formatDate1(svc.elapsed); // you already use this    // ✅ elapsed, not shownRemaining

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TimerSection(
            timeText: timeText,
            isRunning: isRunning,
            onPressed: () {
              if (isRunning) {
                svc.stopFocusAndReset();           // stop + persist
              } else {
                // (optional) ensure pillar chosen here if you require it
                svc.startFocus();                  // start
              }
            },
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

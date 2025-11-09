import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/TimerService.dart';

class ActiveTimerBar extends StatelessWidget {
  /// Optional hook to persist a focus session when stopped from the bar.
  /// If you pass this, it should save to DB then call `svc.stopFocusAndReset()`.
  final Future<void> Function(BuildContext context)? onStopFocus;

  const ActiveTimerBar({super.key, this.onStopFocus});

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = two(d.inHours);
    final m = two(d.inMinutes % 60);
    final s = two(d.inSeconds % 60);
    return '$h:$m:$s';
  }

  String _fmtHmsFromSec(int totalSec) {
    final h = totalSec ~/ 3600;
    final m = (totalSec % 3600) ~/ 60;
    final s = totalSec % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:'
          '${m.toString().padLeft(2, '0')}:'
          '${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<TimerService>();

    final isFocus = svc.isFocusRunning;
    final isEnt   = svc.isEntertainmentRunning;

    // Hide the bar if nothing is active
    if (!isFocus && !isEnt) return const SizedBox.shrink();

    // Display values
    final title = isFocus ? 'Focus session running'
        : 'Entertainment time remaining';
    final timeText = isFocus ? _fmt(svc.elapsed)
        : _fmtHmsFromSec(svc.entertainmentLeftSec);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF1EAF9),
        boxShadow: [BoxShadow(blurRadius: 6, color: Color(0x22000000))],
      ),
      child: Row(
        children: [
          Icon(isFocus ? Icons.timer_outlined : Icons.hourglass_bottom),
          const SizedBox(width: 8),
          Text(
            timeText,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 12),
          Text(title),
          const Spacer(),

          if (isFocus) ...[
            FilledButton.icon(
              onPressed: () async {
                if (onStopFocus != null) {
                  await onStopFocus!(context);      // caller persists, then resets
                } else {
                  svc.stopFocusAndReset();
                }
              },
              icon: const Icon(Icons.stop),
              label: const Text('Stop'),
            ),
          ],

          if (isEnt) ...[
            // Entertainment is countdown only; we allow stop (commit) here.
            FilledButton.icon(
              onPressed: () async {
                svc.stopEntertainmentAndGetUsed();
              },
              icon: const Icon(Icons.stop),
              label: const Text('Stop'),
            ),
          ],
        ],
      ),
    );
  }
}

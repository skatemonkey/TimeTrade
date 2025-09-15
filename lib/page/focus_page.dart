import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/TimerService.dart';
import '../core/date_utils.dart';

class FocusPage extends StatefulWidget {
  const FocusPage({super.key});

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
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
        ],
      ),
    );
  }
}

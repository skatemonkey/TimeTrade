import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/date_utils.dart';
import '../data/dao/leisure_ledger_dao.dart';
import '../services/TimerService.dart';

class LeisurePage extends StatefulWidget {
  const LeisurePage({super.key});

  @override
  State<LeisurePage> createState() => _LeisurePageState();
}

class _LeisurePageState extends State<LeisurePage> {
  int _remainingSec = 0; // balance from DB

  @override
  void initState() {
    super.initState();
    _loadRemaining();
  }

  Future<void> _loadRemaining() async {
    final sec = await LeisureLedgerDao.instance
        .getAvailableTime(); // SELECT SUM(deltaSec)
    if (mounted) setState(() => _remainingSec = sec);
  }

  Future<void> _toggle() async {
    final svc = context.read<TimerService>();
    if (!svc.isEntertainmentRunning) {
      // start countdown using current DB balance
      if (_remainingSec > 0) {
        svc.startEntertainment(_remainingSec);
        setState(() {}); // update button immediately
      }
    } else {
      // stop + commit used seconds to DB, then refresh balance
      svc.stopEntertainmentAndGetUsed();
      await _loadRemaining();
    }
  }


  @override
  Widget build(BuildContext context) {
    final svc = context.watch<TimerService>();

    final isRunning = svc.isEntertainmentRunning;
    final shownRemaining = isRunning ? svc.entertainmentLeftSec : _remainingSec;
    final display = formatHMS(shownRemaining);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            display,
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: (shownRemaining > 0 || isRunning) ? _toggle : null,
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
          const SizedBox(height: 12),
          if (!isRunning && shownRemaining <= 0)
            const Text(
              "No time left — earn more by focusing",
              style: TextStyle(color: Colors.grey),
            ),
        ],
      ),
    );
  }
}

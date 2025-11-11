import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/date_utils.dart';
import '../data/dao/leisure_ledger_dao.dart';
import '../services/TimerService.dart';
import '../widgets/timer_section.dart';

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

  String _getRandomQuote() {
    final quotes = [
      "Rest is earned, not given.",
      "Balance work and play — both shape you.",
      "Enjoy the calm; you’ve earned it.",
      "Recharge so you can rise stronger.",
      "Use your time; don’t let it use you.",
    ];
    quotes.shuffle();
    return quotes.first;
  }


  @override
  Widget build(BuildContext context) {
    final svc = context.watch<TimerService>();

    final bool isRunning = svc.isEntertainmentRunning;
    final shownRemaining = isRunning ? svc.entertainmentLeftSec : _remainingSec;
    final String timeText = formatHMS(shownRemaining);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          TimerSection(
            timeText: timeText,
            isRunning: isRunning,
            onPressed: (shownRemaining > 0 || isRunning) ? _toggle : () {},
          ),

          const SizedBox(height: 25),
          if (!isRunning && shownRemaining <= 0)
            const Text(
              "No time left — earn more by focusing",
              style: TextStyle(color: Colors.grey),
            )
          else
            Text(
              _getRandomQuote(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),

        ],
      ),
    );
  }
}

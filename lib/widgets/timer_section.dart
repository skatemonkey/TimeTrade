import 'package:flutter/material.dart';

class TimerSection extends StatelessWidget {
  final String timeText;
  final bool isRunning;
  final VoidCallback onPressed;

  const TimerSection({
    super.key,
    required this.timeText,
    required this.isRunning,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(timeText, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFE6D9FF),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [BoxShadow(blurRadius: 12, offset: Offset(0, 6), color: Color(0x22000000))],
            ),
            child: Icon(isRunning ? Icons.stop : Icons.play_arrow, size: 32, color: const Color(0xFF2B134D)),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../data/dao/focus_log_dao.dart';
import '../data/dao/points_ledger_dao.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Stats
  double totalFocusHours = 0;
  int totalSessions = 0;
  double avgSessionMin = 0;

  double totalPointsEarned = 0;
  double totalPointsSpent  = 0;
  double netPoints         = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      // Run queries in parallel
      final results = await Future.wait([
        FocusLogDao.instance.getTotalTimeTracked(),        // double (hours, 2dp)
        FocusLogDao.instance.getTotalSessions(),           // int
        FocusLogDao.instance.getAvgSessionLengthMin(),     // double (min, 2dp)
        PointsLedgerDao.instance.getTotalPointsSummary(),  // Map<String,double>
      ]);

      final totalHours = results[0] as double;
      final sessions   = results[1] as int;
      final avgMin     = results[2] as double;
      final points     = results[3] as Map<String, double>;

      if (!mounted) return;
      setState(() {
        totalFocusHours   = totalHours;
        totalSessions     = sessions;
        avgSessionMin     = avgMin;

        // Pick which “earned” you want to show
        // Use earnedNet if you want earns minus undo; fallback to earnedGross/earned
        totalPointsEarned = points['earnedNet'] ?? points['earnedGross'] ?? points['earned'] ?? 0;
        totalPointsSpent  = points['spent'] ?? 0;
        netPoints         = points['net'] ?? 0;
      });
    } catch (e) {
      // optional: handle/log error
      if (!mounted) return;
      setState(() {/* keep previous values */});
    }
  }


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Analytics Overview",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),

              // --- Pastel Stat Cards ---
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.4,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _StatCard(
                    title: "Total Focus Time",
                    value: "${totalFocusHours.toStringAsFixed(2)}h",
                    color: const Color(0xFFFFE4C4),
                  ),
                  _StatCard(
                    title: "Total Points Earned",
                    value: totalPointsEarned.toStringAsFixed(0),
                    color: const Color(0xFFDFF6DD),
                  ),
                  _StatCard(
                    title: "Total Points Spent",
                    value: totalPointsSpent.toStringAsFixed(0),
                    color: const Color(0xFFDDE9F9),
                  ),
                  _StatCard(
                    title: "Net Points",
                    value: netPoints.toStringAsFixed(0),
                    color: const Color(0xFF222222),
                    textColor: Colors.white,
                    isDark: true,
                  ),
                  _StatCard(
                    title: "Total Sessions",
                    value: "$totalSessions",
                    color: Color(0xFFE8E8E8),
                  ),
                  _StatCard(
                    title: "Avg Session Length",
                    value: "${avgSessionMin.toStringAsFixed(2)} min",
                    color: Color(0xFFF8DDEB),
                  ),
                  _StatCard(
                    title: "Longest Streak",
                    value: "o0o days",
                    color: Color(0xFFEAF3FF), // sky blue tint
                  ),
                  _StatCard(
                    title: "Consistency Rate",
                    value: "o0o%",
                    color: Color(0xFFDFF5EE),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // --- Chart section placeholders ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _ChartPlaceholder(
                      title: "Time by Pillar (All-Time)",
                      subtitle: "Pie chart placeholder",
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _ChartPlaceholder(
                      title: "Points by Pillar (All-Time)",
                      subtitle: "Bar chart placeholder",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // --- Bottom section: summaries / achievements ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _ChartPlaceholder(
                      title: "Top Pillars by Time",
                      subtitle: "List or chart placeholder",
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _ChartPlaceholder(
                      title: "Achievements & Milestones",
                      subtitle: "Badges or icons placeholder",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Stat Card widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final Color? textColor;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    this.textColor,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: 13,
      color: isDark ? Colors.white70 : Colors.grey[700],
    );

    final valueStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: textColor ?? Colors.black87,
    );

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: valueStyle),
          const SizedBox(height: 6),
          Text(title, style: titleStyle),
        ],
      ),
    );
  }
}

// Placeholder for charts / sections
class _ChartPlaceholder extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ChartPlaceholder({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: Text(subtitle, style: TextStyle(color: Colors.grey[400])),
            ),
          ),
        ],
      ),
    );
  }
}

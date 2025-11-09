import 'package:flutter/material.dart';

import '../app_colors.dart';

class SideNav extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const SideNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<SideNav> createState() => _SideNavState();
}

class _SideNavState extends State<SideNav> {

  @override
  Widget build(BuildContext context) {
    // base colors from your reference

    return Container(
      width: 88,
      color: AppColors.bg,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // first icon group
            _Pill(
              child: Column(
                children: [
                  _SideIcon(
                    icon: Icons.timer_outlined,
                    tooltip: "Focus",
                    selected: widget.selectedIndex == 0,
                    onTap: () => widget.onItemSelected(0),
                  ),
                  const SizedBox(height: 12),
                  _SideIcon(
                    icon: Icons.videogame_asset_outlined,
                    tooltip: "Leisure",
                    selected: widget.selectedIndex == 1,
                    onTap: () => widget.onItemSelected(1),
                  ),
                  const SizedBox(height: 12),
                  _SideIcon(
                    icon: Icons.shopping_bag_outlined,
                    tooltip: "Shop",
                    selected: widget.selectedIndex == 2,
                    onTap: () => widget.onItemSelected(2),
                  ),
                  const SizedBox(height: 12),
                  _SideIcon(
                    icon: Icons.history_outlined,
                    tooltip: "Timeline",
                    selected: widget.selectedIndex == 3,
                    onTap: () => widget.onItemSelected(3),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // second icon group (two)
            _Pill(
              child: Column(
                children: [
                  _SideIcon(
                    icon: Icons.account_balance_outlined,
                    tooltip: "Life Pillar",
                    selected: widget.selectedIndex == 4,
                    onTap: () => widget.onItemSelected(4),
                  ),
                  const SizedBox(height: 12),
                  _SideIcon(
                    icon: Icons.autorenew_outlined,
                    tooltip: "Habits",
                    selected: widget.selectedIndex == 5,
                    onTap: () => widget.onItemSelected(5),
                  ),
                  const SizedBox(height: 12),
                  _SideIcon(
                    icon: Icons.construction_outlined,
                    tooltip: "Placeholder",
                    selected: widget.selectedIndex == 6,
                    onTap: () => widget.onItemSelected(6),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // bottom group: mic + avatar
            _Pill(
              child: Column(
                children: [
                  _SideIcon(
                    icon: Icons.settings_outlined,
                    tooltip: "Settings",
                    selected: widget.selectedIndex == 7,
                    onTap: () => widget.onItemSelected(7),
                  ),
                  const SizedBox(height: 12),
                  const CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage('assets/avatar.jpg'),
                    // replace if you have one
                    backgroundColor: AppColors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Side Pill
class _Pill extends StatelessWidget {
  const _Pill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: child,
    );
  }
}

// Side ICON
class _SideIcon extends StatefulWidget {
  const _SideIcon({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_SideIcon> createState() => _SideIconState();
}

class _SideIconState extends State<_SideIcon> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.selected
        ? AppColors.dark
        : (_hover ? AppColors.black.withValues(alpha: 0.06) : AppColors.white);

    final color = widget.selected ? AppColors.accent : AppColors.dark;

    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 250),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: InkWell(
          onTap: widget.onTap,
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            height: 44,
            width: 44,
            decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
            child: Icon(widget.icon, size: 22, color: color),
          ),
        ),
      ),
    );
  }
}

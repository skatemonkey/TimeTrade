import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:time_vault/page/focus_page.dart';
import 'package:time_vault/page/leisure_page.dart';
import 'package:time_vault/page/shop_page.dart';

import '../services/TimerService.dart';
import '../widgets/ActiveTimeBar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [FocusPage(), LeisurePage(), ShopPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Focus'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Leisure'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Shop'),
              ),
            ],
          ),

          const VerticalDivider(thickness: 1, width: 1),

          Expanded(
            child: Column(
              children: [
                // Show only when running; rebuilds from TimerService
                Consumer<TimerService>(
                  builder: (context, svc, _) => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: (svc.isFocusRunning || svc.isEntertainmentRunning)
                        ? ActiveTimerBar(
                            key: const ValueKey('bar'),
                            // Optional: persist focus session when stopping from the bar
                          )
                        : const SizedBox.shrink(key: ValueKey('empty')),
                  ),
                ),

                // The selected page fills the rest
                Expanded(child: _pages[_selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

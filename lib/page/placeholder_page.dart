import 'package:flutter/material.dart';
import 'template_page.dart';

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TemplatePage(
      title: 'Focus',
      actions: [
        IconButton(
          tooltip: 'New Session',
          onPressed: () {},
          icon: const Icon(Icons.add),
        ),
      ],
      // make true if your content can overflow vertically
      scroll: true,
      // keep your sidebar gap & paddings consistent app-wide
      sidebarWidth: 72,
      // optionally limit inner width for nicer reading columns
      maxContentWidth: 1100,
      child: const Center(
        child: Text(
          'Your Focus content here',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }
}

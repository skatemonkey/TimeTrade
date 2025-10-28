import 'package:flutter/material.dart';
import '../../app_colors.dart';

/// A reusable parent template for all “content pages” in your app.
///
/// Slots:
/// - [title]            : page title on the top-left
/// - [actions]          : optional widgets on the top-right (e.g., buttons)
/// - [child]            : the main content inside the white card
/// - [scroll]           : wrap [child] in SingleChildScrollView if true
/// - [sidebarWidth]     : left gap to avoid your sidebar
/// - [cardPadding]      : padding inside the white card
/// - [pagePadding]      : outer padding of the whole page
/// - [maxContentWidth]  : optional max width for the white card content
/// - [floatingActionButton] : optional FAB passed straight to Scaffold
class TemplatePage extends StatelessWidget {
  const TemplatePage({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.scroll = false,
    this.sidebarWidth = 72,
    this.pagePadding = const EdgeInsets.fromLTRB(45, 45, 45, 45),
    this.cardPadding = const EdgeInsets.all(24),
    this.maxContentWidth,
    this.floatingActionButton,
    this.backgroundColor,
  });

  final String title;
  final List<Widget>? actions;
  final Widget child;

  final bool scroll;
  final double sidebarWidth;
  final EdgeInsets pagePadding;
  final EdgeInsets cardPadding;
  final double? maxContentWidth;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.bg;

    Widget content = Padding(
      padding: cardPadding,
      child: child,
    );

    if (maxContentWidth != null) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth!),
          child: content,
        ),
      );
    }

    if (scroll) {
      content = SingleChildScrollView(child: content);
    }

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Padding(
          padding: pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row (title + optional actions)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (actions != null) ...[
                    const SizedBox(width: 12),
                    Row(mainAxisSize: MainAxisSize.min, children: actions!),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: content,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

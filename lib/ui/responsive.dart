import 'dart:math' as math;

import 'package:flutter/material.dart';

abstract final class AppBreakpoints {
  static const double mobile = 600;
  static const double desktop = 1024;
}

extension ResponsiveContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  bool get isMobile => screenSize.width < AppBreakpoints.mobile;
  bool get isTablet =>
      screenSize.width >= AppBreakpoints.mobile &&
      screenSize.width < AppBreakpoints.desktop;
  bool get isDesktop => screenSize.width >= AppBreakpoints.desktop;
  bool get isShort => screenSize.height < 520;

  double get pagePadding => isMobile ? 12 : (isTablet ? 20 : 28);
}

class ResponsivePage extends StatelessWidget {
  const ResponsivePage({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.all(context.pagePadding),
          child: child,
        ),
      ),
    );
  }
}

class ResponsiveFormCard extends StatelessWidget {
  const ResponsiveFormCard({
    super.key,
    required this.child,
    this.maxWidth = 960,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.pagePadding),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: EdgeInsets.all(context.isMobile ? 16 : 28),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class ResponsiveToolbar extends StatelessWidget {
  const ResponsiveToolbar({
    super.key,
    required this.search,
    required this.primaryAction,
  });

  final Widget search;
  final Widget primaryAction;

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [search, const SizedBox(height: 12), primaryAction],
      );
    }
    return Row(
      children: [
        Expanded(child: search),
        const SizedBox(width: 16),
        primaryAction,
      ],
    );
  }
}

class MobileRecordCard extends StatelessWidget {
  const MobileRecordCard({
    super.key,
    required this.title,
    required this.fields,
    required this.onTap,
    this.status,
  });

  final String title;
  final Map<String, String> fields;
  final VoidCallback onTap;
  final String? status;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  if (status != null) _StatusChip(status!),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 10),
              for (final entry in fields.entries)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${entry.key}: ',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(text: entry.value),
                      ],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.status);

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color = normalized == 'aprobado'
        ? Colors.green
        : normalized == 'rechazado'
            ? Colors.red
            : Colors.orange;
    return Container(
      constraints: const BoxConstraints(maxWidth: 100),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: color.shade700, fontSize: 12),
      ),
    );
  }
}

double responsiveTitleSize(BuildContext context) {
  return math.max(20, math.min(34, MediaQuery.sizeOf(context).width * .026));
}

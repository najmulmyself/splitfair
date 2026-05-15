// sf_empty_state.dart — UI implementation pending.
import 'package:flutter/material.dart';

/// Reusable empty state widget. Full implementation pending.
class SFEmptyState extends StatelessWidget {
  const SFEmptyState({super.key, required this.title, this.body, this.action});

  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        if (body != null) Text(body!),
        if (action != null) action!,
      ],
    ),
  );
}

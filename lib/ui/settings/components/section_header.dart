import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}

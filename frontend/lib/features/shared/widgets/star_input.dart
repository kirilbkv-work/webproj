import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';

const Map<int, String> _words = {
  0: 'Not rated',
  1: 'Poor',
  2: 'Fair',
  3: 'Good',
  4: 'Very good',
  5: 'Excellent',
};

/// Интерактивный выбор оценки заказа: звёзды плюс словесная подпись.
class StarInput extends StatefulWidget {
  const StarInput({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  State<StarInput> createState() => _StarInputState();
}

class _StarInputState extends State<StarInput> {
  int? _hovered;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final shown = _hovered ?? widget.value;

    return Row(
      children: [
        for (var star = 1; star <= 5; star++)
          MouseRegion(
            onEnter: (_) => setState(() => _hovered = star),
            onExit: (_) => setState(() => _hovered = null),
            child: Semantics(
              button: true,
              selected: widget.value == star,
              label: '$star out of 5',
              child: GestureDetector(
                onTap: () => widget.onChanged(star),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    Icons.star_rounded,
                    size: 34,
                    color: star <= shown ? palette.accent : palette.lineStrong,
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(width: 12),
        Text(
          _words[shown] ?? _words[0]!,
          style: context.texts.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: palette.inkSoft,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme.dart';

/// Ограничивает контент по ширине и задаёт единые отступы страницы.
class PageBody extends StatelessWidget {
  const PageBody({
    super.key,
    required this.child,
    this.maxWidth = AppTheme.contentMaxWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 64),
          child: child,
        ),
      ),
    );
  }
}

/// Карточка-панель с рамкой — базовый контейнер разделов.
class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.flat = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Приглушённый вариант без белой заливки.
  final bool flat;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: flat ? palette.surfaceAlt : palette.surface,
        border: Border.all(color: palette.line),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: child,
    );
  }
}

/// Мелкий заголовок над крупным — «THE COLLECTION».
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
        color: context.palette.inkMuted,
      ),
    );
  }
}

/// Нейтральная метка (тип товара, служебная подпись).
class Tag extends StatelessWidget {
  const Tag(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        border: Border.all(color: palette.line),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: palette.inkSoft,
        ),
      ),
    );
  }
}

/// Переключаемая «таблетка» — критерии поиска, фильтры статусов.
class SelectableChip extends StatelessWidget {
  const SelectableChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: selected ? palette.brand : palette.surface,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? palette.brand : palette.lineStrong,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? Colors.white : palette.inkSoft,
            ),
          ),
        ),
      ),
    );
  }
}

/// Цветная информационная плашка.
class Notice extends StatelessWidget {
  const Notice({super.key, required this.text, this.tone = NoticeTone.neutral});

  final String text;
  final NoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (background, foreground) = switch (tone) {
      NoticeTone.neutral => (palette.surfaceAlt, palette.inkSoft),
      NoticeTone.info => (palette.infoTint, palette.info),
      NoticeTone.success => (palette.brandTint, palette.brand),
      NoticeTone.error => (palette.dangerTint, palette.danger),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Text(
        text,
        style: context.texts.bodyMedium?.copyWith(color: foreground),
      ),
    );
  }
}

enum NoticeTone { neutral, info, success, error }

/// Пара «подпись — значение» в сетке характеристик.
class SpecEntry {
  const SpecEntry(this.label, this.value);

  final String label;
  final String value;
}

/// Сетка характеристик товара или заказа.
class SpecGrid extends StatelessWidget {
  const SpecGrid({super.key, required this.entries, this.minColumnWidth = 140});

  final List<SpecEntry> entries;
  final double minColumnWidth;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 20.0;
        final columns = (constraints.maxWidth / (minColumnWidth + gap))
            .floor()
            .clamp(1, entries.isEmpty ? 1 : entries.length);
        final width = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: 16,
          children: [
            for (final entry in entries)
              SizedBox(
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: palette.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      entry.value,
                      style: context.texts.bodyMedium?.copyWith(
                        color: palette.ink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Единое оформление пустых списков.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message = '',
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: palette.lineStrong, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(icon, size: 34, color: palette.inkMuted),
          const SizedBox(height: 12),
          Text(title, style: context.texts.headlineSmall),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: context.texts.bodyMedium,
              ),
            ),
          ],
          if (action != null) ...[const SizedBox(height: 18), action!],
        ],
      ),
    );
  }
}

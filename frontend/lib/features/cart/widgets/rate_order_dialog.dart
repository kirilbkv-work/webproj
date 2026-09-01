import 'package:flutter/material.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_palette.dart';
import '../../shared/widgets/star_input.dart';
import '../../shared/widgets/ui_kit.dart';

/// result of the rating dialog
class RatingResult {
  const RatingResult({required this.rating, required this.comment});

  final int rating;
  final String comment;
}

/// rates an arrived order; the rating is published as a review
class RateOrderDialog extends StatefulWidget {
  const RateOrderDialog({
    super.key,
    required this.line,
    required this.initialComment,
  });

  final CartLine line;

  /// text of an existing review, if any
  final String initialComment;

  static Future<RatingResult?> show(
    BuildContext context, {
    required CartLine line,
    required String initialComment,
  }) {
    return showDialog<RatingResult>(
      context: context,
      builder: (_) =>
          RateOrderDialog(line: line, initialComment: initialComment),
    );
  }

  @override
  State<RateOrderDialog> createState() => _RateOrderDialogState();
}

class _RateOrderDialogState extends State<RateOrderDialog> {
  late int _rating;
  late final TextEditingController _comment;
  String? _error;

  @override
  void initState() {
    super.initState();
    _rating = widget.line.order.rating ?? 0;
    _comment = TextEditingController(text: widget.initialComment);
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating < 1) {
      setState(() => _error = 'Please choose a rating between 1 and 5 stars.');
      return;
    }
    Navigator.of(
      context,
    ).pop(RatingResult(rating: _rating, comment: _comment.text));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
      contentPadding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rate your order', style: context.texts.headlineSmall),
          Text(widget.line.item.name, style: context.texts.bodySmall),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null) ...[
              Notice(text: _error!, tone: NoticeTone.error),
              const SizedBox(height: 14),
            ],
            Text(
              'Only arrived orders can be rated. Your rating is published as '
              'a review on the item page.',
              style: context.texts.bodySmall,
            ),
            const SizedBox(height: 14),
            StarInput(
              value: _rating,
              onChanged: (value) => setState(() {
                _rating = value;
                _error = null;
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _comment,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Comment (optional)',
                hintText: 'How did the item fit? Would you order it again?',
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save rating')),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_palette.dart';
import '../../shared/widgets/ui_kit.dart';

/// Диалог изменения данных заказа.
///
/// Доступен только для статусов «in progress» и «canceled».
/// Возвращает новый [OrderDraft] либо `null`, если изменения отменены.
class EditOrderDialog extends StatefulWidget {
  const EditOrderDialog({super.key, required this.line});

  final CartLine line;

  static Future<OrderDraft?> show(BuildContext context, CartLine line) {
    return showDialog<OrderDraft>(
      context: context,
      builder: (_) => EditOrderDialog(line: line),
    );
  }

  @override
  State<EditOrderDialog> createState() => _EditOrderDialogState();
}

class _EditOrderDialogState extends State<EditOrderDialog> {
  late ClothingSize _size;
  late final TextEditingController _quantity;
  late final TextEditingController _address;
  late final TextEditingController _note;
  String? _error;

  @override
  void initState() {
    super.initState();
    final order = widget.line.order;
    _size = widget.line.item.availableSizes.contains(order.size)
        ? order.size
        : widget.line.item.availableSizes.first;
    _quantity = TextEditingController(text: '${order.quantity}');
    _address = TextEditingController(text: order.deliveryAddress);
    _note = TextEditingController(text: order.note);
  }

  @override
  void dispose() {
    _quantity.dispose();
    _address.dispose();
    _note.dispose();
    super.dispose();
  }

  void _submit() {
    final draft = OrderDraft(
      size: _size,
      quantity: int.tryParse(_quantity.text.trim()) ?? 0,
      deliveryAddress: _address.text,
      note: _note.text,
    );
    final invalid = draft.validate();
    if (invalid != null) {
      setState(() => _error = invalid);
      return;
    }
    Navigator.of(context).pop(draft);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
      contentPadding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edit order details', style: context.texts.headlineSmall),
          Text(
            '${widget.line.item.name} · ${widget.line.order.status.label}',
            style: context.texts.bodySmall,
          ),
        ],
      ),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null) ...[
                Notice(text: _error!, tone: NoticeTone.error),
                const SizedBox(height: 14),
              ],
              const Notice(
                tone: NoticeTone.info,
                text:
                    'Order details can be changed while the order is in '
                    'progress or canceled.',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<ClothingSize>(
                      value: _size,
                      decoration: const InputDecoration(labelText: 'Size'),
                      items: [
                        for (final size in widget.line.item.availableSizes)
                          DropdownMenuItem(
                            value: size,
                            child: Text(size.label),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _size = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: _quantity,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _address,
                decoration: const InputDecoration(
                  labelText: 'Delivery address',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _note,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save changes')),
      ],
    );
  }
}

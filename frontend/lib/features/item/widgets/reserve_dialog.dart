import 'package:flutter/material.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../shared/widgets/ui_kit.dart';

/// Диалог резервирования товара.
///
/// Возвращает заполненный [OrderDraft] либо `null`, если покупатель отменил
/// резервирование.
class ReserveDialog extends StatefulWidget {
  const ReserveDialog({
    super.key,
    required this.item,
    required this.defaultAddress,
  });

  final Item item;

  /// Адрес из профиля — подставляется как значение по умолчанию.
  final String defaultAddress;

  static Future<OrderDraft?> show(
    BuildContext context, {
    required Item item,
    required String defaultAddress,
  }) {
    return showDialog<OrderDraft>(
      context: context,
      builder: (_) => ReserveDialog(item: item, defaultAddress: defaultAddress),
    );
  }

  @override
  State<ReserveDialog> createState() => _ReserveDialogState();
}

class _ReserveDialogState extends State<ReserveDialog> {
  late ClothingSize _size;
  late final TextEditingController _quantity;
  late final TextEditingController _address;
  final TextEditingController _note = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _size = widget.item.availableSizes.contains(widget.item.size)
        ? widget.item.size
        : widget.item.availableSizes.first;
    _quantity = TextEditingController(text: '1');
    _address = TextEditingController(text: widget.defaultAddress);
  }

  @override
  void dispose() {
    _quantity.dispose();
    _address.dispose();
    _note.dispose();
    super.dispose();
  }

  int get _quantityValue => int.tryParse(_quantity.text.trim()) ?? 0;

  OrderDraft get _draft => OrderDraft(
    size: _size,
    quantity: _quantityValue,
    deliveryAddress: _address.text,
    note: _note.text,
  );

  void _submit() {
    final invalid = _draft.validate();
    if (invalid != null) {
      setState(() => _error = invalid);
      return;
    }
    Navigator.of(context).pop(_draft);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
      contentPadding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reserve item', style: context.texts.headlineSmall),
          Text(
            '${widget.item.name} · ${widget.item.manufacturer}',
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
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<ClothingSize>(
                      value: _size,
                      decoration: const InputDecoration(labelText: 'Size'),
                      items: [
                        for (final size in widget.item.availableSizes)
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
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _address,
                decoration: const InputDecoration(
                  labelText: 'Delivery address',
                  helperText:
                      'Prefilled from your profile — you can change it.',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _note,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Note for the courier (optional)',
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: palette.brandTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total for this reservation',
                        style: context.texts.bodyMedium?.copyWith(
                          color: palette.brand,
                        ),
                      ),
                    ),
                    Text(
                      Formatters.money(
                        widget.item.price *
                            (_quantityValue < 0 ? 0 : _quantityValue),
                      ),
                      style: context.texts.bodyLarge?.copyWith(
                        color: palette.brand,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
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
        FilledButton(
          onPressed: _submit,
          child: const Text('Confirm reservation'),
        ),
      ],
    );
  }
}

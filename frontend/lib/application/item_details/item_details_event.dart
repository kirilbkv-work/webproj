part of 'item_details_bloc.dart';

sealed class ItemDetailsEvent extends Equatable {
  const ItemDetailsEvent();

  @override
  List<Object?> get props => const [];
}

/// Внутреннее событие: изменились каталог, отзывы, заказы или сессия.
class _ItemDetailsDataChanged extends ItemDetailsEvent {
  const _ItemDetailsDataChanged();
}

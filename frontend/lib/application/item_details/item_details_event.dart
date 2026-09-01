part of 'item_details_bloc.dart';

sealed class ItemDetailsEvent extends Equatable {
  const ItemDetailsEvent();

  @override
  List<Object?> get props => const [];
}

/// internal: catalog, reviews, orders or session changed
class _ItemDetailsDataChanged extends ItemDetailsEvent {
  const _ItemDetailsDataChanged();
}

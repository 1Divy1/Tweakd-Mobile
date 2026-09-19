import 'package:equatable/equatable.dart';

import 'business_pin_entity.dart';

/// One page of the map's business search, nearest to the searched-around
/// centre first.
///
/// The cursor is opaque and only valid against the *same* centre: echo it back
/// with the query and centre that produced it. A null [nextCursor] is the only
/// end-of-list signal — a short page is not one.
class BusinessSearchPageEntity extends Equatable {
  final List<BusinessPinEntity> items;
  final String? nextCursor;

  const BusinessSearchPageEntity({required this.items, this.nextCursor});

  bool get hasMore => nextCursor != null;

  @override
  List<Object?> get props => [items, nextCursor];
}

import 'package:equatable/equatable.dart';

/// One page of a cursor-paginated `/map-events/*` list.
///
/// The cursor is opaque: it is echoed back verbatim and never parsed. A null
/// [nextCursor] is the *only* end-of-list signal — a short page is not one.
class MapEventPageEntity<T> extends Equatable {
  final List<T> items;
  final String? nextCursor;

  const MapEventPageEntity({required this.items, this.nextCursor});

  bool get hasMore => nextCursor != null;

  @override
  List<Object?> get props => [items, nextCursor];
}

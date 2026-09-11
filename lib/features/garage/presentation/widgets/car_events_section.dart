import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/features/map_events/domain/entities/car_event_history.dart';
import 'package:tweakd/features/map_events/presentation/bloc/car_event_history/bloc.dart';
import 'package:tweakd/features/map_events/presentation/bloc/car_event_history/state.dart';
import 'package:tweakd/features/map_events/presentation/utils/contest_formatting.dart';
import 'package:tweakd/features/map_events/presentation/utils/map_event_formatting.dart';
import 'package:tweakd/features/map_events/presentation/widgets/contests/contest_category_icon.dart';
import 'package:tweakd/features/map_events/presentation/widgets/contests/contest_rank_badge.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'car_image.dart';

/// The car's event history on its About page: a strip of contest badges
/// (rank plates drawn from its podium places), then the events it attended
/// with the placement chips on each. Renders nothing while loading, when the
/// car has never attended anything, or when the read failed — a car page
/// must never look broken because the events API blipped.
class CarEventsSection extends StatelessWidget {
  const CarEventsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CarEventHistoryBloc, CarEventHistoryState>(
      builder: (context, state) {
        if (state.status != CarEventHistoryStatus.loaded || state.isEmpty) {
          return const SizedBox.shrink();
        }
        final l10n = AppLocalizations.of(context)!;
        final placements = state.placements;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (placements.isNotEmpty) ...[
                _Label(l10n.carEventsContestBadges),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final p in placements)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: ContestRankBadge(
                              icon: p.category.icon,
                              rank: p.finalRank,
                              label: p.title,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              _Label(l10n.carEventsAttended),
              const SizedBox(height: 10),
              for (final item in state.items) ...[
                _EventRow(item: item),
                const SizedBox(height: 8),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: AppColors.mute,
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final CarEventHistoryItemEntity item;

  const _EventRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final event = item.event;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => context.push('/map-events/${event.id}'),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CarImage(
                    imageUrl: event.coverImageUrl,
                    width: 44,
                    height: 44,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          event.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${MapEventFormat.dayAndMonth(context, event.startsAt)} · '
                          '${event.locationName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11.5, color: AppColors.mute),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.muteSoft),
                ],
              ),
              if (item.placements.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final p in item.placements) _PlacementChip(placement: p),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PlacementChip extends StatelessWidget {
  final CarEventPlacementEntity placement;

  const _PlacementChip({required this.placement});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final win = placement.isWin;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: win ? AppColors.accent : AppColors.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ContestCategoryGlyph(
            icon: placement.category.icon,
            color: win ? Colors.white : AppColors.ink2,
            size: 12,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              l10n.carEventsPlacement(
                ContestFormat.rank(l10n, placement.finalRank),
                placement.title,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: win ? Colors.white : AppColors.ink2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

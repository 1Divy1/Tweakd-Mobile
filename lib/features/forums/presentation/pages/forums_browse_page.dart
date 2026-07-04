import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:car_social_media_app/features/garage/domain/entities/reference_data.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/forum_filter.dart';
import '../../domain/entities/forum_topic.dart';
import '../bloc/browse/bloc.dart';
import '../bloc/browse/event.dart';
import '../bloc/browse/state.dart';
import '../utils/forum_error_mapper.dart';
import '../widgets/browse/browse_tab_toggle.dart';
import '../widgets/browse/forum_brand_card.dart';
import '../widgets/browse/forum_topic_card.dart';
import '../widgets/shared/forum_error_view.dart';
import '../widgets/shared/forum_section_label.dart';
import '../widgets/shared/forum_sub_top_bar.dart';

class ForumsBrowsePage extends StatefulWidget {
  const ForumsBrowsePage({super.key});

  @override
  State<ForumsBrowsePage> createState() => _ForumsBrowsePageState();
}

class _ForumsBrowsePageState extends State<ForumsBrowsePage> {
  bool _showByCar = true;

  void _openBrand(CarBrandEntity brand) {
    context.push('/forums/hub', extra: ForumFilter(brand: brand));
  }

  void _openTopic(ForumTopicEntity topic) {
    context.push('/forums/hub', extra: ForumFilter(topic: topic));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            ForumSubTopBar(title: l10n.forumsBrowseTitle),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: BrowseTabToggle(
                showByCar: _showByCar,
                onChanged: (byCar) => setState(() => _showByCar = byCar),
              ),
            ),
            Expanded(
              child: BlocBuilder<ForumBrowseBloc, ForumBrowseState>(
                builder: (context, state) {
                  return switch (state) {
                    ForumBrowseInitial() || ForumBrowseLoading() =>
                      const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.accent),
                      ),
                    ForumBrowseError(:final code) => ForumErrorView(
                        message: forumErrorMessage(l10n, code),
                        onRetry: () => context
                            .read<ForumBrowseBloc>()
                            .add(const LoadForumBrowse()),
                      ),
                    ForumBrowseLoaded() => _showByCar
                        ? _ByCarGrid(state: state, onOpen: _openBrand)
                        : _ByTopicGrid(state: state, onOpen: _openTopic),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ByCarGrid extends StatelessWidget {
  final ForumBrowseLoaded state;
  final ValueChanged<CarBrandEntity> onOpen;

  const _ByCarGrid({required this.state, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        ForumSectionLabel(label: l10n.forumsBrandsCount(state.brands.length)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.55,
          ),
          itemCount: state.brands.length,
          itemBuilder: (context, index) {
            final brand = state.brands[index];
            return ForumBrandCard(
              brand: brand,
              threadCount: brand.threadCount,
              onTap: () => onOpen(brand),
            );
          },
        ),
      ],
    );
  }
}

class _ByTopicGrid extends StatelessWidget {
  final ForumBrowseLoaded state;
  final ValueChanged<ForumTopicEntity> onOpen;

  const _ByTopicGrid({required this.state, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    List<ForumTopicEntity> topicsOf(ForumTopicKind kind) => [
          for (final group in state.topicGroups)
            if (group.kind == kind) ...group.topics,
        ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    Widget grid(List<ForumTopicEntity> topics) => GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
          ),
          itemCount: topics.length,
          itemBuilder: (context, index) {
            final topic = topics[index];
            return ForumTopicCard(topic: topic, onTap: () => onOpen(topic));
          },
        );

    final components = topicsOf(ForumTopicKind.component);
    final formats = topicsOf(ForumTopicKind.format);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (components.isNotEmpty) ...[
          ForumSectionLabel(label: l10n.forumsByComponent),
          const SizedBox(height: 12),
          grid(components),
          const SizedBox(height: 24),
        ],
        if (formats.isNotEmpty) ...[
          ForumSectionLabel(label: l10n.forumsByFormat),
          const SizedBox(height: 12),
          grid(formats),
        ],
      ],
    );
  }
}

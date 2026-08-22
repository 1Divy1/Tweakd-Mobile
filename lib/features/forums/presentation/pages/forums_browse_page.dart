import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:tweakd/features/garage/domain/entities/reference_data.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/forum_filter.dart';
import '../bloc/browse/bloc.dart';
import '../bloc/browse/event.dart';
import '../bloc/browse/state.dart';
import '../utils/forum_error_mapper.dart';
import '../widgets/browse/forum_brand_grid.dart';
import '../widgets/shared/forum_error_view.dart';
import '../widgets/shared/forum_sub_top_bar.dart';

/// Forum categories are cars: a brand hub, and from there a model hub. Topics
/// are refine chips inside a hub, never a category of their own.
class ForumsBrowsePage extends StatelessWidget {
  const ForumsBrowsePage({super.key});

  void _openBrand(BuildContext context, CarBrandEntity brand) {
    context.push('/forums/hub', extra: ForumFilter(brand: brand));
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
                    ForumBrowseLoaded(:final brands) => ForumBrandGrid(
                        brands: brands,
                        onOpen: (brand) => _openBrand(context, brand),
                      ),
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

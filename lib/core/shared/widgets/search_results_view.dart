import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tweakd/l10n/app_localizations.dart';

import '../../theme/app_colors.dart';
import '../entities/search_result.dart';
import 'search_result_card.dart';
import '../layout/app_layout.dart';

class SearchResultsView extends StatelessWidget {
  final String query;
  final List<SearchResultEntity> results;

  const SearchResultsView({
    super.key,
    required this.query,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return _NoResults(query: query);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ResultsHeader(count: results.length, query: query),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            padding:
                const EdgeInsets.fromLTRB(20, 0, 20, 16) +
                AppLayout.inset(context),
            itemCount: results.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final result = results[index];
              return SearchResultCard(
                result: result,
                query: query,
                onTap: () =>
                    context.push('/users/${result.username}', extra: result.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  final int count;
  final String query;

  const _ResultsHeader({required this.count, required this.query});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(24, 4, 24, 0) + AppLayout.inset(context),
      child: Row(
        children: [
          Text(
            l10n.searchResultsDrivers(count),
            style: TextStyle(
              color: AppColors.muteSoft,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const Spacer(),
          Text(
            l10n.searchForQuery(query),
            style: TextStyle(
              color: AppColors.muteSoft,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;

  const _NoResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 36, color: AppColors.muteSoft),
            const SizedBox(height: 14),
            Text(
              AppLocalizations.of(context)!.searchNoResults(query),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mute,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

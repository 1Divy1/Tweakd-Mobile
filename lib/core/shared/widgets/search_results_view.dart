import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../entities/search_result.dart';
import 'search_result_card.dart';

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
            padding: const EdgeInsets.only(bottom: 16),
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
    final label = count == 1 ? 'DRIVER' : 'DRIVERS';
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: Row(
        children: [
          Text(
            '$count $label',
            style: const TextStyle(
              color: AppColors.muteSoft,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const Spacer(),
          Text(
            'FOR "$query"',
            style: const TextStyle(
              color: AppColors.muteSoft,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
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
            const Icon(Icons.search_off, size: 36, color: AppColors.muteSoft),
            const SizedBox(height: 14),
            Text(
              'No drivers found for "$query"',
              textAlign: TextAlign.center,
              style: const TextStyle(
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

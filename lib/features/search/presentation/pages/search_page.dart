import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/shared/widgets/app_bottom_nav.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/bloc.dart';
import '../bloc/event.dart';
import '../bloc/state.dart';
import '../utils/search_error_mapper.dart';
import '../../../../core/shared/widgets/search_empty_view.dart';
import '../../../../core/shared/widgets/search_error_view.dart';
import '../../../../core/shared/widgets/search_input.dart';
import '../../../../core/shared/widgets/search_loading_view.dart';
import '../../../../core/shared/widgets/search_results_view.dart';
import '../../../../core/shared/widgets/search_top_bar.dart';
import '../../../../core/shared/layout/app_layout.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SearchTopBar(),
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 16, 20, 12) +
                  AppLayout.inset(context),
              child: SearchInput(
                controller: _controller,
                onChanged: (value) =>
                    context.read<SearchBloc>().add(SearchQueryChanged(value)),
                onClear: () {
                  _controller.clear();
                  context.read<SearchBloc>().add(const SearchCleared());
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchInitial) {
                    return const SearchEmptyView();
                  }
                  if (state is SearchLoading) {
                    return const SearchLoadingView();
                  }
                  if (state is SearchError) {
                    return SearchErrorView(
                      message: searchErrorMessage(
                        AppLocalizations.of(context)!,
                        state.code,
                      ),
                    );
                  }
                  if (state is SearchSuccess) {
                    return SearchResultsView(
                      query: state.query,
                      results: state.results,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            const AppBottomNav(activeTab: AppBottomNavTab.search),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../bloc/bloc.dart';
import '../bloc/event.dart';
import '../bloc/state.dart';
import '../widgets/search_empty_view.dart';
import '../widgets/search_error_view.dart';
import '../widgets/search_input.dart';
import '../widgets/search_loading_view.dart';
import '../widgets/search_results_view.dart';
import '../widgets/search_top_bar.dart';

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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state is SearchInitial) {
                      return const SearchEmptyView();
                    }
                    if (state is SearchLoading) {
                      return const SearchLoadingView();
                    }
                    if (state is SearchError) {
                      return SearchErrorView(message: state.message);
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
            ),
            const AppBottomNav(activeTab: AppBottomNavTab.search),
          ],
        ),
      ),
    );
  }
}

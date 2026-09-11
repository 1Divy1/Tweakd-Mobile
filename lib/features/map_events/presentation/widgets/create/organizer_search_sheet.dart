import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:tweakd/core/di/injection.dart';
import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/map_event_enums.dart';
import '../../../domain/entities/organizer_candidate.dart';
import '../../../domain/usecases/map_event_organizers.dart';
import '../shared/map_event_chips.dart';

/// Search sheet for adding a co-organizer, over
/// `GET /map-events/organizers/search`.
///
/// Deliberately **stateful-widget-local rather than a bloc**: it's one
/// debounced call with no state that outlives the sheet, nothing else consumes
/// the results, and a bloc would have to be provided, disposed and routed for
/// no gain. The use case is pulled straight from `getIt`, the same way
/// `NavigationLauncherService` is.
///
/// Returns the chosen candidate, or null if dismissed.
Future<OrganizerCandidateEntity?> showOrganizerSearchSheet(
  BuildContext context,
) {
  return showModalBottomSheet<OrganizerCandidateEntity>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _OrganizerSearchSheet(),
  );
}

/// Fully rounded (pill) field outline, applied to every state so a themed
/// square `enabledBorder`/`focusedBorder` can't win once the field is focused.
final _fieldBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(20),
  borderSide: BorderSide.none,
);

class _OrganizerSearchSheet extends StatefulWidget {
  const _OrganizerSearchSheet();

  @override
  State<_OrganizerSearchSheet> createState() => _OrganizerSearchSheetState();
}

class _OrganizerSearchSheetState extends State<_OrganizerSearchSheet> {
  final _controller = TextEditingController();
  final _search = getIt<SearchOrganizerCandidatesUseCase>();

  Timer? _debounce;
  CancelToken? _cancelToken;

  List<OrganizerCandidateEntity> _results = const [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _cancelToken?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();

    if (query.isEmpty) {
      _cancelToken?.cancel();
      setState(() {
        _results = const [];
        _isSearching = false;
        _hasSearched = false;
      });
      return;
    }

    // 300ms is long enough that typing a name is one request, short enough
    // that the list doesn't feel late.
    _debounce = Timer(const Duration(milliseconds: 300), () => _run(query));
  }

  Future<void> _run(String query) async {
    _cancelToken?.cancel();
    final cancelToken = CancelToken();
    _cancelToken = cancelToken;

    setState(() => _isSearching = true);

    final result = await _search(
      SearchOrganizerCandidatesParams(query: query, cancelToken: cancelToken),
    );

    // A superseded search: its answer is stale by definition.
    if (!mounted || cancelToken != _cancelToken) return;

    setState(() {
      _isSearching = false;
      _hasSearched = true;
      _results = result.getOrElse(() => const []);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Text(
              l10n.mapEventsSearchOrganizersTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 15, color: AppColors.ink),
              decoration: InputDecoration(
                hintText: l10n.mapEventsSearchOrganizersHint,
                hintStyle: const TextStyle(
                  fontSize: 15,
                  color: AppColors.muteSoft,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: AppColors.muteSoft,
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: _fieldBorder,
                enabledBorder: _fieldBorder,
                focusedBorder: _fieldBorder,
                disabledBorder: _fieldBorder,
                errorBorder: _fieldBorder,
                focusedErrorBorder: _fieldBorder,
              ),
            ),
          ),
          Flexible(child: _body(l10n)),
          SizedBox(height: MediaQuery.paddingOf(context).bottom + 12),
        ],
      ),
    );
  }

  Widget _body(AppLocalizations l10n) {
    if (_isSearching && _results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 34),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      itemCount: _results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _CandidateRow(
        candidate: _results[index],
        onTap: () => Navigator.of(context).pop(_results[index]),
      ),
    );
  }
}

class _CandidateRow extends StatelessWidget {
  final OrganizerCandidateEntity candidate;
  final VoidCallback onTap;

  const _CandidateRow({required this.candidate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final url = candidate.imageUrl;
    final radius = candidate.isBusiness ? 10.0 : 19.0;
    final username = candidate.username;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(radius),
                ),
                clipBehavior: Clip.antiAlias,
                child: (url == null || url.isEmpty)
                    ? Icon(
                        candidate.isBusiness
                            ? Icons.storefront_rounded
                            : Icons.person_rounded,
                        size: 19,
                        color: AppColors.accent,
                      )
                    : CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            candidate.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        if (candidate.isBusiness) ...[
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.verified_rounded,
                            size: 15,
                            color: Colors.blue,
                          ),
                        ],
                      ],
                    ),
                    // Businesses have no handle; two people can share a display
                    // name, so the line matters for telling them apart.
                    if (username != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '@$username',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mute,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              MapEventOrganizerTypeChip(
                type: candidate.isBusiness
                    ? MapEventOrganizerType.business
                    : MapEventOrganizerType.individual,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;

  const _Message({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 20, 32, 34),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13.5,
          height: 1.4,
          color: AppColors.mute,
        ),
      ),
    );
  }
}

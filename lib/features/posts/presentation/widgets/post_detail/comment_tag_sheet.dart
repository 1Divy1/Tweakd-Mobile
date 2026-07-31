import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:car_social_media_app/core/shared/bloc/tag_picker/bloc.dart';
import 'package:car_social_media_app/core/shared/widgets/tagging/tag_editor.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../bloc/comments/bloc.dart';
import '../../bloc/comments/event.dart';
import '../../bloc/comments/state.dart';

/// Tag sheet for the comment composer — the same "mention people, then pick
/// cars from their garage" flow the forum reply composer uses. The selection
/// lives in [CommentsBloc] (so it survives the sheet closing and is sent with
/// the comment), which is why both blocs are handed down to the modal route.
Future<void> showCommentTagSheet(BuildContext context) {
  final commentsBloc = context.read<CommentsBloc>();
  final tagBloc = context.read<TagPickerBloc>();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider<CommentsBloc>.value(value: commentsBloc),
        BlocProvider<TagPickerBloc>.value(value: tagBloc),
      ],
      child: const _CommentTagSheet(),
    ),
  );
}

class _CommentTagSheet extends StatefulWidget {
  const _CommentTagSheet();

  @override
  State<_CommentTagSheet> createState() => _CommentTagSheetState();
}

class _CommentTagSheetState extends State<_CommentTagSheet> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<CommentsBloc>();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.forumsTagsSheetTitle,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    l10n.forumsTagsDone,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l10n.forumsTagHelper,
              style: const TextStyle(
                color: AppColors.muteSoft,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<CommentsBloc, CommentsState>(
              buildWhen: (a, b) =>
                  a.pendingTaggedPeople != b.pendingTaggedPeople ||
                  a.pendingTaggedCars != b.pendingTaggedCars,
              builder: (context, state) => TagEditor(
                people: state.pendingTaggedPeople,
                cars: state.pendingTaggedCars,
                peopleSearchController: _searchController,
                showHeader: false,
                onAddPerson: (person) => bloc.add(AddCommentTagPerson(person)),
                onRemovePerson: (id) => bloc.add(RemoveCommentTagPerson(id)),
                onAddCar: (car) => bloc.add(AddCommentTagCar(car)),
                onRemoveCar: (id) => bloc.add(RemoveCommentTagCar(id)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

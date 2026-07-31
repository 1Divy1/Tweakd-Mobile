import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:car_social_media_app/core/shared/bloc/tag_picker/bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../bloc/thread/bloc.dart';
import '../../bloc/thread/event.dart';
import '../../bloc/thread/state.dart';
import 'package:car_social_media_app/core/shared/widgets/tagging/tag_editor.dart';

/// Tag sheet for the reply composer. The selection lives in [ForumThreadBloc]
/// (so it survives the sheet closing and is sent with the reply), which is why
/// both blocs are handed down to the modal route.
Future<void> showForumReplyTagSheet(BuildContext context) {
  final threadBloc = context.read<ForumThreadBloc>();
  final tagBloc = context.read<TagPickerBloc>();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider<ForumThreadBloc>.value(value: threadBloc),
        BlocProvider<TagPickerBloc>.value(value: tagBloc),
      ],
      child: const _ReplyTagSheet(),
    ),
  );
}

class _ReplyTagSheet extends StatefulWidget {
  const _ReplyTagSheet();

  @override
  State<_ReplyTagSheet> createState() => _ReplyTagSheetState();
}

class _ReplyTagSheetState extends State<_ReplyTagSheet> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<ForumThreadBloc>();

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
            BlocBuilder<ForumThreadBloc, ForumThreadState>(
              buildWhen: (a, b) =>
                  a.replyTaggedPeople != b.replyTaggedPeople ||
                  a.replyTaggedCars != b.replyTaggedCars,
              builder: (context, state) => TagEditor(
                people: state.replyTaggedPeople,
                cars: state.replyTaggedCars,
                peopleSearchController: _searchController,
                showHeader: false,
                onAddPerson: (person) => bloc.add(AddReplyTagPerson(person)),
                onRemovePerson: (id) => bloc.add(RemoveReplyTagPerson(id)),
                onAddCar: (car) => bloc.add(AddReplyTagCar(car)),
                onRemoveCar: (id) => bloc.add(RemoveReplyTagCar(id)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/profile.dart';
import '../bloc/edit_profile/bloc.dart';
import '../bloc/edit_profile/event.dart';
import '../bloc/edit_profile/state.dart';
import '../utils/profile_error_mapper.dart';
import '../widgets/edit_profile/edit_profile_field.dart';
import '../widgets/edit_profile/edit_profile_save_button.dart';
import '../widgets/edit_profile/editable_avatar.dart';
import '../widgets/shared/profile_top_bar.dart';

/// Backend limits (trimmed for name).
const int kProfileNameMaxLength = 80;
const int kProfileBioMaxLength = 500;

class EditProfilePage extends StatefulWidget {
  final ProfileEntity profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;

  // Guards a second image_picker request from firing before the first finishes.
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _bioCtrl = TextEditingController(text: widget.profile.bio);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  bool get _isDirty =>
      _nameCtrl.text.trim() != widget.profile.name ||
      _bioCtrl.text.trim() != widget.profile.bio;

  Future<void> _pickAvatar(BuildContext context) async {
    if (_isPicking) return;
    _isPicking = true;
    // Capture the bloc before the async gap so no BuildContext is used after it.
    final bloc = context.read<EditProfileBloc>();
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file == null || !mounted) return;
      bloc.add(EditProfileAvatarSelected(file.path));
    } on PlatformException {
      // A pick was already in progress (e.g. a double tap) — safe to ignore.
    } finally {
      _isPicking = false;
    }
  }

  void _save(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<EditProfileBloc>().add(
          EditProfileSaved(name: _nameCtrl.text, bio: _bioCtrl.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: BlocConsumer<EditProfileBloc, EditProfileState>(
          listenWhen: (prev, curr) =>
              curr.phase == EditProfilePhase.saved ||
              curr.errorNonce != prev.errorNonce,
          listener: (context, state) {
            if (state.phase == EditProfilePhase.saved) {
              // Pop with a flag so the profile page refreshes on return.
              context.pop(state.changed);
              return;
            }
            if (state.errorCode != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Text(profileErrorMessage(l10n, state.errorCode!)),
                ));
            }
          },
          builder: (context, state) {
            final isSaving = state.phase == EditProfilePhase.savingProfile;
            final isUploading =
                state.phase == EditProfilePhase.uploadingAvatar;
            return Column(
              children: [
                ProfileTopBar(title: l10n.editProfileTitle),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        EditableAvatar(
                          avatarUrl: state.profile.avatarUrl,
                          localPreviewPath: state.pendingAvatarPath,
                          isUploading: isUploading,
                          onTap: () => _pickAvatar(context),
                        ),
                        const SizedBox(height: 28),
                        EditProfileField(
                          label: l10n.editProfileNameLabel,
                          hint: l10n.editProfileNameHint,
                          controller: _nameCtrl,
                          maxLength: kProfileNameMaxLength,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 20),
                        EditProfileField(
                          label: l10n.editProfileBioLabel,
                          hint: l10n.editProfileBioHint,
                          controller: _bioCtrl,
                          maxLength: kProfileBioMaxLength,
                          minLines: 4,
                          maxLines: 6,
                          textInputAction: TextInputAction.newline,
                        ),
                        const SizedBox(height: 28),
                        // Rebuild the CTA on every keystroke so the enabled
                        // state tracks the dirty check.
                        ListenableBuilder(
                          listenable: Listenable.merge([_nameCtrl, _bioCtrl]),
                          builder: (context, _) => EditProfileSaveButton(
                            label: l10n.editProfileSave,
                            enabled: _isDirty && !isUploading,
                            isLoading: isSaving,
                            onTap: () => _save(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

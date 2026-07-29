import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../bloc/bloc.dart';
import '../bloc/event.dart';
import '../bloc/locale/cubit.dart';
import '../bloc/state.dart';
import '../utils/profile_error_mapper.dart';
import '../widgets/my_profile/my_profile_data_view.dart';
import '../widgets/profile_error_view.dart';
import '../widgets/profile_loading_view.dart';

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<ProfileBloc, ProfileState>(
          // The backend is the cross-device source of truth for the app
          // language: whenever the own profile is (re)fetched, adopt its
          // `app_language` if it differs from the active locale. Public
          // profile fetches (`FetchProfileByUsername`) intentionally don't
          // get this treatment — their `app_language` belongs to a different
          // user and is irrelevant to the viewer's locale.
          listener: (context, state) {
            if (state is ProfileLoaded) {
              context
                  .read<LocaleCubit>()
                  .syncFromBackend(state.profile.appLanguage);
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const ProfileLoadingView();
            }
            if (state is ProfileError) {
              return ProfileErrorView(
                message: profileErrorMessage(
                  AppLocalizations.of(context)!,
                  state.code,
                ),
                onRetry: () => context.read<ProfileBloc>().add(
                  FetchUserProfileData(),
                ),
              );
            }
            if (state is ProfileLoaded) {
              return MyProfileDataView(profile: state.profile);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

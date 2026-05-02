import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bloc.dart';
import '../bloc/event.dart';
import '../bloc/state.dart';
import '../widgets/profile_data_view.dart';
import '../widgets/profile_error_view.dart';
import '../widgets/profile_loading_view.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const ProfileLoadingView();
            }
            if (state is ProfileError) {
              return ProfileErrorView(
                message: state.message,
                onRetry: () => context.read<ProfileBloc>().add(
                  FetchUserProfileData(),
                ),
              );
            }
            if (state is ProfileLoaded) {
              return ProfileDataView(profile: state.profile);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

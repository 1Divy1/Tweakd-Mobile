import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/follow/presentation/bloc/bloc.dart';
import '../../../../features/follow/presentation/bloc/state.dart';
import '../bloc/bloc.dart';
import '../bloc/event.dart';
import '../bloc/state.dart';
import '../widgets/profile_error_view.dart';
import '../widgets/profile_loading_view.dart';
import '../widgets/public_profile/public_profile_data_view.dart';

class PublicProfilePage extends StatelessWidget {
  final String username;

  const PublicProfilePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<FollowBloc, FollowState>(
          listenWhen: (previous, current) =>
              previous is FollowStatusLoaded &&
              previous.isUpdating &&
              current is FollowStatusLoaded &&
              !current.isUpdating,
          listener: (context, _) {
            context.read<ProfileBloc>().add(FetchProfileByUsername(username));
          },
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const ProfileLoadingView();
              }
              if (state is ProfileError) {
                return ProfileErrorView(
                  message: state.message,
                  onRetry: () => context.read<ProfileBloc>().add(
                    FetchProfileByUsername(username),
                  ),
                );
              }
              if (state is ProfileLoaded) {
                return PublicProfileDataView(profile: state.profile);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

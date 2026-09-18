import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/block_user.dart';
import '../../utils/block_error_mapper.dart';
import 'state.dart';
import 'package:tweakd/core/analytics/analytics_events.dart';
import 'package:tweakd/core/analytics/analytics_service.dart';

/// Blocks the account shown on a public profile (the "⋯" menu → Block).
@injectable
class BlockUserCubit extends Cubit<BlockUserState> {
  final BlockUserUseCase blockUser;
  final AnalyticsService analytics;

  BlockUserCubit({required this.blockUser,
    this.analytics = const NoopAnalyticsService(),
  }) : super(const BlockUserIdle());

  Future<void> block(String username) async {
    if (state is BlockUserInProgress) return;
    emit(const BlockUserInProgress());
    final result = await blockUser(BlockUserParams(username: username));
    result.fold(
      (failure) => emit(BlockUserFailure(BlockErrorMapper.getCode(failure))),
      (_) {
        analytics.track(AnalyticsEvents.userBlocked);
        emit(BlockUserSuccess(username));
      },
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/block_user.dart';
import '../../utils/block_error_mapper.dart';
import 'state.dart';

/// Blocks the account shown on a public profile (the "⋯" menu → Block).
@injectable
class BlockUserCubit extends Cubit<BlockUserState> {
  final BlockUserUseCase blockUser;

  BlockUserCubit({required this.blockUser}) : super(const BlockUserIdle());

  Future<void> block(String username) async {
    if (state is BlockUserInProgress) return;
    emit(const BlockUserInProgress());
    final result = await blockUser(BlockUserParams(username: username));
    result.fold(
      (failure) => emit(BlockUserFailure(BlockErrorMapper.getCode(failure))),
      (_) => emit(BlockUserSuccess(username)),
    );
  }
}

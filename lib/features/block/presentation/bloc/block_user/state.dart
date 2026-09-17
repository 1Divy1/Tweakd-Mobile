import 'package:equatable/equatable.dart';

import '../../utils/block_error_mapper.dart';

sealed class BlockUserState extends Equatable {
  const BlockUserState();

  @override
  List<Object?> get props => [];
}

class BlockUserIdle extends BlockUserState {
  const BlockUserIdle();
}

class BlockUserInProgress extends BlockUserState {
  const BlockUserInProgress();
}

class BlockUserSuccess extends BlockUserState {
  final String username;
  const BlockUserSuccess(this.username);

  @override
  List<Object?> get props => [username];
}

class BlockUserFailure extends BlockUserState {
  final BlockErrorCode code;
  const BlockUserFailure(this.code);

  @override
  List<Object?> get props => [code];
}

import '../../../../core/error/base_failures.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/failures/block_failures.dart';

/// User-facing error situations of blocking / unblocking. Blocs emit these
/// codes (never strings); the UI maps them to localized copy via
/// [blockErrorMessage].
enum BlockErrorCode { selfBlock, notFound, network, generic }

class BlockErrorMapper {
  static BlockErrorCode getCode(Failure failure) {
    if (failure is CannotBlockSelfFailure) return BlockErrorCode.selfBlock;
    if (failure is BlockTargetNotFoundFailure) return BlockErrorCode.notFound;
    if (failure is NetworkFailure) return BlockErrorCode.network;
    return BlockErrorCode.generic;
  }
}

String blockErrorMessage(AppLocalizations l10n, BlockErrorCode code) =>
    switch (code) {
      BlockErrorCode.selfBlock => l10n.blockErrorSelf,
      BlockErrorCode.notFound => l10n.blockErrorNotFound,
      BlockErrorCode.network => l10n.blockErrorNetwork,
      BlockErrorCode.generic => l10n.blockErrorGeneric,
    };

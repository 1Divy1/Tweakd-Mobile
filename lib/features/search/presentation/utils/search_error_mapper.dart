import 'package:tweakd/l10n/app_localizations.dart';

import '../../../../core/error/base_failures.dart';

/// User-facing error situations the search flow can surface. Search has no
/// failure-specific copy today, so everything maps to [SearchErrorCode.generic];
/// the enum keeps the bloc string-free and leaves room to grow.
enum SearchErrorCode { generic }

class SearchErrorMapper {
  static SearchErrorCode getCode(Failure failure) => SearchErrorCode.generic;
}

/// Turns a [SearchErrorCode] into localized copy. Lives in the presentation
/// layer because it needs an [AppLocalizations] from a widget.
String searchErrorMessage(AppLocalizations l10n, SearchErrorCode code) =>
    switch (code) {
      SearchErrorCode.generic => l10n.searchErrorGeneric,
    };

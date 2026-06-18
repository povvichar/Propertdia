import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

/// Ergonomic accessor: `context.l10n.someKey` instead of
/// `AppLocalizations.of(context).someKey`.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../create/create_event_fields.dart';

/// The mini-form the location picker opens with: city, street, house number.
///
/// All three are required before [onSearch] is offered — the backend accepts
/// any subset, but a partial address returns candidates too vague to be worth
/// showing, and the search costs a billable Mapbox call either way.
class AddressFormSheet extends StatelessWidget {
  final TextEditingController cityController;
  final TextEditingController streetController;
  final TextEditingController numberController;

  /// Re-evaluated on every keystroke so the CTA can enable itself the moment
  /// the third field is filled.
  final ValueChanged<String> onChanged;

  final bool canSearch;
  final bool isSearching;
  final String? error;
  final VoidCallback onSearch;

  const AddressFormSheet({
    super.key,
    required this.cityController,
    required this.streetController,
    required this.numberController,
    required this.onChanged,
    required this.canSearch,
    required this.isSearching,
    required this.error,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final errorText = error;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.mapEventsLocationFormTitle,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.mapEventsLocationFormSubtitle,
          style: const TextStyle(
            fontSize: 12.5,
            height: 1.35,
            color: AppColors.mute,
          ),
        ),
        const SizedBox(height: 14),
        EventTextField(
          label: l10n.mapEventsLocationCity,
          hint: l10n.mapEventsLocationCityHint,
          controller: cityController,
          maxLength: 80,
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
        EventTextField(
          label: l10n.mapEventsLocationStreet,
          hint: l10n.mapEventsLocationStreetHint,
          controller: streetController,
          maxLength: 120,
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
        EventTextField(
          label: l10n.mapEventsLocationNumber,
          hint: l10n.mapEventsLocationNumberHint,
          controller: numberController,
          maxLength: 12,
          // Not a number field: house numbers carry letters and separators
          // ("28B", "12-14", "3/A") in most of the countries this ships to.
          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
          onChanged: onChanged,
        ),
        if (errorText != null) ...[
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 16,
                color: AppColors.accent,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  errorText,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    color: AppColors.ink2,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: canSearch && !isSearching ? onSearch : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              disabledBackgroundColor: AppColors.line,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
            child: isSearching
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.surface,
                    ),
                  )
                : Text(
                    canSearch
                        ? l10n.mapEventsLocationSearchButton
                        : l10n.mapEventsLocationSearchIncomplete,
                  ),
          ),
        ),
      ],
    );
  }
}

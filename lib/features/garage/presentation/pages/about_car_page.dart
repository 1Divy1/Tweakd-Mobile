import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/entities/image_ref.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/car.dart';
import '../../domain/entities/car_modification.dart';
import '../bloc/car_detail/bloc.dart';
import '../bloc/car_detail/event.dart';
import '../bloc/car_detail/state.dart';
import '../utils/garage_error_mapper.dart';
import '../widgets/car_events_section.dart';
import '../widgets/car_image.dart';
import '../widgets/share/share_build_sheet.dart';
import 'fullscreen_image_page.dart';
import '../../../../core/shared/layout/app_layout.dart';

class AboutCarPage extends StatelessWidget {
  final bool isOwner;

  const AboutCarPage({super.key, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CarDetailBloc, CarDetailState>(
      listener: (context, state) {
        if (state is CarDetailDeleted) context.pop();
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: switch (state) {
            CarDetailLoading() => const _LoadingView(),
            CarDetailLoaded(:final car, :final isDeleting) => _AboutCarView(
              car: car,
              isOwner: isOwner,
              isDeleting: isDeleting,
            ),
            CarDetailError(:final code) => _ErrorView(
              message: garageErrorMessage(AppLocalizations.of(context)!, code),
            ),
            CarDetailDeleted() => const SizedBox.shrink(),
            _ => const _LoadingView(),
          },
        );
      },
    );
  }
}

// ── Loading / Error ──────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: AppColors.accent),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _TopBar(isOwner: false, carId: '', isDeleting: false),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.mute, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── About car view ────────────────────────────────────────────────────────

class _AboutCarView extends StatelessWidget {
  final CarEntity car;
  final bool isOwner;
  final bool isDeleting;

  const _AboutCarView({
    required this.car,
    required this.isOwner,
    required this.isDeleting,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: _TopBar(
            isOwner: isOwner,
            carId: car.id,
            isDeleting: isDeleting,
            car: car,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: AppLayout.inset(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CoverImage(car: car),
                const SizedBox(height: 20),
                _SpecGrid(car: car),
                const SizedBox(height: 12),
                _InfoTable(car: car),
                if (car.story != null && car.story!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _StorySection(story: car.story!),
                ],
                if (car.gallery.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _GallerySection(
                    carId: car.id,
                    gallery: car.gallery,
                    isOwner: isOwner,
                  ),
                ],
                // Attended events and contest badges. Paints only when the
                // car has a history; nothing while loading or on failure.
                const CarEventsSection(),
                if (isOwner) ...[
                  const SizedBox(height: 20),
                  _AddModButton(carId: car.id),
                ],
                if (car.modifications.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _ModificationsList(
                    carId: car.id,
                    mods: car.modifications,
                    isOwner: isOwner,
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final bool isOwner;
  final String carId;
  final bool isDeleting;

  /// The full car, needed to pre-populate the edit wizard. Null on the error
  /// view, where the menu is never shown (isOwner is false there).
  final CarEntity? car;

  const _TopBar({
    required this.isOwner,
    required this.carId,
    required this.isDeleting,
    this.car,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8) + AppLayout.inset(context),
      child: Row(
        children: [
          _PillButton(
            onTap: () => context.pop(),
            child: Icon(
              Icons.chevron_left,
              color: AppColors.ink,
              size: 20,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.garageAboutTitle,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          if (isOwner) ...[
            _PillButton(
              onTap: car == null ? null : () => _openShare(context, car!),
              child: Icon(
                Icons.ios_share,
                color: AppColors.ink,
                size: 19,
              ),
            ),
            const SizedBox(width: 8),
            _PillButton(
              onTap: isDeleting ? null : () => _showMenu(context),
              child: isDeleting
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.ink,
                      ),
                    )
                  : Icon(
                      Icons.more_horiz,
                      color: AppColors.ink,
                      size: 20,
                    ),
            ),
          ] else
            const SizedBox(width: 44),
        ],
      ),
    );
  }

  /// The share surface is owner-only by design: whether a car is shared, what
  /// its code is and how often it has been scanned are the owner's business.
  /// It gets its own pill rather than a row in the overflow menu — sharing is
  /// the growth action here, and burying it costs taps it can't afford.
  void _openShare(BuildContext context, CarEntity car) {
    showShareBuildSheet(
      context,
      carId: car.id,
      carTitle: '${car.brandName} ${car.modelName}',
    );
  }

  void _showMenu(BuildContext context) {
    final bloc = context.read<CarDetailBloc>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            if (car != null)
              ListTile(
                leading: Icon(Icons.edit_outlined, color: AppColors.ink),
                title: Text(
                  AppLocalizations.of(context)!.garageEditCar,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _openEdit(context, bloc);
                },
              ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.danger),
              title: Text(
                AppLocalizations.of(context)!.garageDeleteCar,
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _confirmDelete(context, carId);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Opens the edit wizard pre-populated with this car, then reloads the detail
  /// so the page reflects any saved changes when the wizard pops back.
  Future<void> _openEdit(BuildContext context, CarDetailBloc bloc) async {
    await context.push('/garage/cars/$carId/edit', extra: car);
    bloc.add(LoadCar(carId));
  }

  Future<void> _confirmDelete(BuildContext context, String carId) async {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<CarDetailBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.garageDeleteMachineTitle,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.garageDeleteMachineBody,
                style: TextStyle(
                  color: AppColors.mute,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _DialogButton(
                      label: l10n.garageDialogCancel,
                      onTap: () => Navigator.of(dialogContext).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DialogButton(
                      label: l10n.garageDialogDelete,
                      isDestructive: true,
                      onTap: () => Navigator.of(dialogContext).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      bloc.add(DeleteCarFromDetail(carId));
    }
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DialogButton({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDestructive ? AppColors.danger : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive ? AppColors.danger : AppColors.line,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isDestructive ? AppColors.onDanger : AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _PillButton({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ── Cover image ─────────────────────────────────────────────────────────────────

class _CoverImage extends StatelessWidget {
  final CarEntity car;
  const _CoverImage({required this.car});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (car.chassisCode != null && car.chassisCode!.isNotEmpty) ...[
            Text(
              AppLocalizations.of(context)!
                  .garageBuildIdentifier(car.chassisCode!),
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            '${car.brandName} ${car.modelName}',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => context.push('/full-screen-image', extra: car.coverImage?.url),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 11,
                  child: CarImage(
                    imageUrl: car.coverImage?.url,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(20),
                    enableZoom: true,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${car.year} · ${car.colorName}'.toUpperCase(),
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Spec grid ─────────────────────────────────────────────────────────────────

class _SpecGrid extends StatelessWidget {
  final CarEntity car;
  const _SpecGrid({required this.car});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SpecCard(
                  label: l10n.garageSpecPower,
                  value: '${car.horsepower}',
                  unit: 'HP',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SpecCard(
                  label: l10n.garageSpecTorque,
                  value: '${car.torque}',
                  unit: 'NM',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SpecCard(
                  label: '0-100',
                  value: car.zeroToOneHundred != null
                      ? car.zeroToOneHundred!.toStringAsFixed(1)
                      : '—',
                  unit: 'SEC',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SpecCard(
                  label: l10n.garageSpecWeight,
                  value: '${car.weight}',
                  unit: 'KG',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpecCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _SpecCard({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.mute,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                unit,
                style: TextStyle(
                  color: AppColors.mute,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Info table ────────────────────────────────────────────────────────────────

class _InfoTable extends StatelessWidget {
  final CarEntity car;
  const _InfoTable({required this.car});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rows = [
      (l10n.garageInfoDrivetrain, car.drivetrainName.toUpperCase()),
      if (car.mileage != null)
        (l10n.garageInfoMileage,
            '${car.mileage} ${car.mileageUnitName.toUpperCase()}'),
      if (car.modelCode != null && car.modelCode!.isNotEmpty)
        (l10n.garageInfoModelCode, car.modelCode!.toUpperCase()),
      if (car.engineCode != null && car.engineCode!.isNotEmpty)
        (l10n.garageInfoEngineCode, car.engineCode!.toUpperCase()),
      (l10n.garageInfoDisplacement,
          '${car.engineDisplacement.toStringAsFixed(1)}L'),
      (l10n.garageInfoFuelType, car.fuelTypeName.toUpperCase()),
      (l10n.garageInfoStatus, car.status.type.toUpperCase()),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Divider(height: 1, thickness: 1, color: AppColors.line),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Text(
                    rows[i].$1,
                    style: TextStyle(
                      color: AppColors.mute,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    rows[i].$2,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Story ─────────────────────────────────────────────────────────────────────

class _StorySection extends StatelessWidget {
  final String story;
  const _StorySection({required this.story});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.garageStoryHeading,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              story,
              style: TextStyle(
                color: AppColors.ink2,
                fontSize: 15,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Gallery ───────────────────────────────────────────────────────────────────

class _GallerySection extends StatelessWidget {
  final String carId;
  final List<ImageRef> gallery;
  final bool isOwner;

  const _GallerySection({
    required this.carId,
    required this.gallery,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.garageGalleryHeading,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: gallery.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 16 / 10,
            ),
            itemBuilder: (context, i) {
              final image = gallery[i];
              return GestureDetector(
                onLongPress: isOwner
                    ? () => _confirmDelete(context, image.key)
                    : null,
                onTap: () => context.push(
                  '/full-screen-image',
                  extra: FullscreenImageArgs(
                    images: gallery.map((e) => e.url).toList(),
                    initialIndex: i,
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CarImage(
                      imageUrl: image.url,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    if (isOwner)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => _confirmDelete(context, image.key),
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(140),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(Icons.close_rounded,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String imageKey) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<CarDetailBloc>();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.garageDeletePhotoTitle),
        content: Text(l10n.garageDeletePhotoBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(l10n.garageDialogCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              bloc.add(DeleteGalleryImage(carId: carId, imageKey: imageKey));
            },
            child: Text(l10n.garageDialogDelete,
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

// ── Add modification button ───────────────────────────────────────────────────

class _AddModButton extends StatelessWidget {
  final String carId;
  const _AddModButton({required this.carId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () async {
          final added = await context
              .push<bool>('/garage/cars/$carId/modifications/add');
          // Reload so the new entry shows in the build log straight away.
          if (added == true && context.mounted) {
            context.read<CarDetailBloc>().add(LoadCar(carId));
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.garageLogBuildIteration,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Modifications list ────────────────────────────────────────────────────────

class _ModificationsList extends StatelessWidget {
  final String carId;
  final List<CarModificationEntity> mods;
  final bool isOwner;

  const _ModificationsList({
    required this.carId,
    required this.mods,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.garageModLogHeading,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < mods.length; i++)
            _TimelineEntry(
              carId: carId,
              mod: mods[i],
              isOwner: isOwner,
              isLast: i == mods.length - 1,
            ),
        ],
      ),
    );
  }
}

/// A single modification rendered next to a chronological timeline rail:
/// a continuous vertical line with a hollow circle marking each card.
class _TimelineEntry extends StatelessWidget {
  final String carId;
  final CarModificationEntity mod;
  final bool isOwner;
  final bool isLast;

  const _TimelineEntry({
    required this.carId,
    required this.mod,
    required this.isOwner,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    // A Stack overlay (rather than IntrinsicHeight) so the rail stretches to
    // match the card's height: IntrinsicHeight forces every descendant to
    // answer an intrinsic-dimensions query, which the card's LayoutBuilder
    // (in _ModMediaStrip) cannot support.
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 32),
            Expanded(
              child: _ModCard(carId: carId, mod: mod, isOwner: isOwner),
            ),
          ],
        ),
        // Continuous rail. Stops short of the bottom on the last entry.
        Positioned(
          left: 11,
          top: 6,
          bottom: isLast ? null : 0,
          height: isLast ? 18 : null,
          child: Container(width: 2, color: AppColors.accent),
        ),
        // Marker aligned with the date label.
        Positioned(
          left: 4,
          top: 6,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bg,
              border: Border.all(color: AppColors.accent, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModCard extends StatelessWidget {
  final String carId;
  final CarModificationEntity mod;
  final bool isOwner;
  const _ModCard({
    required this.carId,
    required this.mod,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    final beforeMedia = mod.beforeMedia;
    final afterMedia = mod.afterMedia;
    final date = mod.installationDate;

    return GestureDetector(
      onLongPress: isOwner ? () => _showModMenu(context) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _formatModDate(date),
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                if (mod.price != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _formatPrice(mod.price!),
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                if (isOwner) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showModMenu(context),
                    child: Icon(
                      Icons.more_horiz,
                      color: AppColors.mute,
                      size: 20,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              mod.title,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (beforeMedia.isNotEmpty || afterMedia.isNotEmpty) ...[
              const SizedBox(height: 10),
              _ModMediaStrip(
                beforeMedia: beforeMedia,
                afterMedia: afterMedia,
              ),
            ],
            if (mod.description != null && mod.description!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                mod.description!,
                style: TextStyle(
                  color: AppColors.mute,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showModMenu(BuildContext context) {
    final bloc = context.read<CarDetailBloc>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.danger),
              title: Text(
                AppLocalizations.of(context)!.garageDeleteModMenu,
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _confirmDelete(context, bloc);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, CarDetailBloc bloc) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.garageDeleteModTitle,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.garageDeleteModBody,
                style: TextStyle(
                  color: AppColors.mute,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _DialogButton(
                      label: l10n.garageDialogCancel,
                      onTap: () => Navigator.of(dialogContext).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DialogButton(
                      label: l10n.garageDialogDelete,
                      isDestructive: true,
                      onTap: () => Navigator.of(dialogContext).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      bloc.add(DeleteModificationFromDetail(carId: carId, modId: mod.id));
    }
  }
}

/// A modification's before/after shots: one labelled row per phase, every
/// photo in it visible at once.
///
/// A phase holds up to three photos and the point of the card is the
/// comparison, so nothing is hidden behind a swipe — the tiles share the card
/// width and both rows use one tile size (taken from the fuller phase) so the
/// befores line up with the afters. Tapping one opens the whole set in the
/// fullscreen viewer.
class _ModMediaStrip extends StatelessWidget {
  final List<ModificationMediaEntity> beforeMedia;
  final List<ModificationMediaEntity> afterMedia;

  const _ModMediaStrip({required this.beforeMedia, required this.afterMedia});

  static const _gap = 8.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Befores first, then afters — the order the fullscreen viewer pages in.
    final urls = [
      for (final m in beforeMedia) m.url,
      for (final m in afterMedia) m.url,
    ];
    final perRow = beforeMedia.length > afterMedia.length
        ? beforeMedia.length
        : afterMedia.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth =
            (constraints.maxWidth - _gap * (perRow - 1)) / perRow;
        // Three tiles across get squarer crops so they stay tall enough to
        // read; one or two keep the cinematic 16:9.
        final tileHeight = tileWidth * (perRow >= 3 ? 3 / 4 : 9 / 16);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (beforeMedia.isNotEmpty)
              _PhaseRow(
                label: l10n.garageModBefore,
                media: beforeMedia,
                tileWidth: tileWidth,
                tileHeight: tileHeight,
                urls: urls,
                firstIndex: 0,
              ),
            if (beforeMedia.isNotEmpty && afterMedia.isNotEmpty)
              const SizedBox(height: 10),
            if (afterMedia.isNotEmpty)
              _PhaseRow(
                label: l10n.garageModAfter,
                media: afterMedia,
                tileWidth: tileWidth,
                tileHeight: tileHeight,
                urls: urls,
                firstIndex: beforeMedia.length,
              ),
          ],
        );
      },
    );
  }
}

/// One phase's caption and its photos, left-aligned so a single "after" sits
/// under the first "before" rather than stretching across the card.
class _PhaseRow extends StatelessWidget {
  final String label;
  final List<ModificationMediaEntity> media;
  final double tileWidth;
  final double tileHeight;

  /// The whole mod's photos and where this phase starts in them, so a tap
  /// opens the viewer on the right page.
  final List<String> urls;
  final int firstIndex;

  const _PhaseRow({
    required this.label,
    required this.media,
    required this.tileWidth,
    required this.tileHeight,
    required this.urls,
    required this.firstIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.mute,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (var i = 0; i < media.length; i++) ...[
              if (i > 0) const SizedBox(width: _ModMediaStrip._gap),
              SizedBox(
                width: tileWidth,
                height: tileHeight,
                child: _ModImage(
                  url: media[i].url,
                  pairUrls: urls,
                  pairIndex: firstIndex + i,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ModImage extends StatelessWidget {
  final String url;
  final List<String> pairUrls;
  final int pairIndex;

  const _ModImage({
    required this.url,
    required this.pairUrls,
    required this.pairIndex,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        '/full-screen-image',
        extra: FullscreenImageArgs(images: pairUrls, initialIndex: pairIndex),
      ),
      child: CarImage(
        imageUrl: url,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String _formatModDate(DateTime date) =>
    '${date.day} ${_monthNames[date.month - 1]} ${date.year}';

String _formatPrice(double price) =>
    '€${price.toStringAsFixed(price % 1 == 0 ? 0 : 2)}';

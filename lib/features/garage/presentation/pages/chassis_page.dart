import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/car.dart';
import '../../domain/entities/car_image.dart';
import '../../domain/entities/car_modification.dart';
import '../bloc/car_detail/bloc.dart';
import '../bloc/car_detail/event.dart';
import '../bloc/car_detail/state.dart';
import '../widgets/resolved_image.dart';

class ChassisPage extends StatelessWidget {
  final bool isOwner;

  const ChassisPage({super.key, required this.isOwner});

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
            CarDetailLoaded(:final car, :final gallery, :final isDeleting) =>
              _ChassisView(
                car: car,
                gallery: gallery,
                isOwner: isOwner,
                isDeleting: isDeleting,
              ),
            CarDetailError(:final message) => _ErrorView(message: message),
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
    return const Center(child: CircularProgressIndicator(color: AppColors.accent));
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
          _ChassisTopBar(isOwner: false, carId: '', isDeleting: false),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.mute, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Main chassis view ────────────────────────────────────────────────────────

class _ChassisView extends StatelessWidget {
  final CarEntity car;
  final List<CarImageEntity> gallery;
  final bool isOwner;
  final bool isDeleting;

  const _ChassisView({
    required this.car,
    required this.gallery,
    required this.isOwner,
    required this.isDeleting,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: _ChassisTopBar(
            isOwner: isOwner,
            carId: car.id,
            isDeleting: isDeleting,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroImage(car: car),
                const SizedBox(height: 20),
                _SpecGrid(car: car),
                const SizedBox(height: 12),
                _InfoTable(car: car),
                if (gallery.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _GallerySection(
                    carId: car.id,
                    gallery: gallery,
                    isOwner: isOwner,
                  ),
                ],
                if (isOwner) ...[
                  const SizedBox(height: 20),
                  _AddModButton(carId: car.id),
                ],
                if (car.modifications.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _ModificationsList(carId: car.id, mods: car.modifications, isOwner: isOwner),
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

class _ChassisTopBar extends StatelessWidget {
  final bool isOwner;
  final String carId;
  final bool isDeleting;

  const _ChassisTopBar({
    required this.isOwner,
    required this.carId,
    required this.isDeleting,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          _PillButton(
            onTap: () => context.pop(),
            child: const Icon(Icons.chevron_left, color: AppColors.ink, size: 20),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'CHASSIS',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                ),
              ),
            ),
          ),
          if (isOwner)
            _PillButton(
              onTap: isDeleting ? null : () => _showMenu(context, carId),
              child: isDeleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.ink,
                      ),
                    )
                  : const Icon(Icons.more_horiz, color: AppColors.ink, size: 20),
            )
          else
            const SizedBox(width: 44),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context, String carId) {
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
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Delete machine',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.of(context).pop();
                context.read<CarDetailBloc>().add(DeleteCarFromDetail(carId));
              },
            ),
            const SizedBox(height: 8),
          ],
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line),
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ── Hero image ─────────────────────────────────────────────────────────────────

class _HeroImage extends StatelessWidget {
  final CarEntity car;
  const _HeroImage({required this.car});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: ResolvedImage(
            storagePath: car.coverImagePath,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (car.chassisCode != null && car.chassisCode!.isNotEmpty)
                      Text(
                        'BUILD IDENTIFIER: ${car.chassisCode}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        '${car.year} · ${car.colorName.toUpperCase()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${car.brandName} ${car.modelName}'.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Spec grid ─────────────────────────────────────────────────────────────────

class _SpecGrid extends StatelessWidget {
  final CarEntity car;
  const _SpecGrid({required this.car});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SpecCard(
                  label: 'POWER',
                  value: '${car.horsepower}',
                  unit: 'HP',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SpecCard(
                  label: 'TORQUE',
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
                  label: 'WEIGHT',
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

  const _SpecCard({required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
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
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                unit,
                style: const TextStyle(
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
    final rows = [
      ('DRIVETRAIN', car.drivetrainName.toUpperCase()),
      ('MILEAGE UNIT', car.mileageUnitName.toUpperCase()),
      if (car.engineCode != null && car.engineCode!.isNotEmpty)
        ('ENGINE CODE', car.engineCode!.toUpperCase()),
      ('DISPLACEMENT', '${car.engineDisplacement.toStringAsFixed(1)}L'),
      if (car.status != null) ('STATUS', car.status!.type.toUpperCase()),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: AppColors.line),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Text(
                    rows[i].$1,
                    style: const TextStyle(
                      color: AppColors.mute,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    rows[i].$2,
                    style: const TextStyle(
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

// ── Gallery ───────────────────────────────────────────────────────────────────

class _GallerySection extends StatelessWidget {
  final String carId;
  final List<CarImageEntity> gallery;
  final bool isOwner;

  const _GallerySection({
    required this.carId,
    required this.gallery,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = [...gallery]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GALLERY',
            style: TextStyle(
              color: AppColors.mute,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sorted.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 16 / 10,
            ),
            itemBuilder: (context, i) {
              final image = sorted[i];
              return GestureDetector(
                onLongPress: isOwner
                    ? () => _confirmDelete(context, image.id)
                    : null,
                child: ResolvedImage(
                  storagePath: image.storagePath,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String imageId) {
    final bloc = context.read<CarDetailBloc>();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete photo?'),
        content: const Text('This gallery photo will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              bloc.add(DeleteGalleryImage(carId: carId, imageId: imageId));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
        onTap: () => context.push('/garage/cars/$carId/modifications/add'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text(
              '+ LOG BUILD ITERATION',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
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
  const _ModificationsList({required this.carId, required this.mods, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BUILD LOG',
            style: TextStyle(
              color: AppColors.mute,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${mods.length} ${mods.length == 1 ? 'Modification' : 'Modifications'}',
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          for (final mod in mods) _ModCard(carId: carId, mod: mod, isOwner: isOwner),
        ],
      ),
    );
  }
}

class _ModCard extends StatelessWidget {
  final String carId;
  final CarModificationEntity mod;
  final bool isOwner;
  const _ModCard({required this.carId, required this.mod, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: isOwner ? () => _showModMenu(context) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    mod.categoryName.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const Spacer(),
                if (isOwner)
                  GestureDetector(
                    onTap: () => _showModMenu(context),
                    child: const Icon(Icons.more_horiz, color: AppColors.mute, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              mod.title,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (mod.description != null && mod.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                mod.description!,
                style: const TextStyle(
                  color: AppColors.mute,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (mod.beforeImagePath != null || mod.afterImagePath != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  if (mod.beforeImagePath != null)
                    Expanded(
                        child: _ModImage(
                            path: mod.beforeImagePath!, label: 'BEFORE')),
                  if (mod.beforeImagePath != null && mod.afterImagePath != null)
                    const SizedBox(width: 8),
                  if (mod.afterImagePath != null)
                    Expanded(
                        child:
                            _ModImage(path: mod.afterImagePath!, label: 'AFTER')),
                ],
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
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Delete modification',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.of(context).pop();
                bloc.add(DeleteModificationFromDetail(carId: carId, modId: mod.id));
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ModImage extends StatelessWidget {
  final String path;
  final String label;
  const _ModImage({required this.path, required this.label});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ResolvedImage(
            storagePath: path,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        Positioned(
          top: 6,
          left: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.ink.withAlpha(180),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../garage/presentation/widgets/car_image.dart';
import '../../../domain/entities/message.dart';

/// A horizontal strip of staged car chips shown above the composer input.
/// Each chip is a small cover thumb + "Brand Model" + a × to remove it.
class TaggedCarChips extends StatelessWidget {
  final List<DmTaggedCarEntity> cars;
  final ValueChanged<DmTaggedCarEntity> onRemove;

  const TaggedCarChips({
    super.key,
    required this.cars,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: cars.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) =>
              _CarChip(car: cars[index], onRemove: () => onRemove(cars[index])),
        ),
      ),
    );
  }
}

class _CarChip extends StatelessWidget {
  final DmTaggedCarEntity car;
  final VoidCallback onRemove;

  const _CarChip({required this.car, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      padding: const EdgeInsets.only(left: 6, right: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CarImage(
            imageUrl: car.coverImageUrl,
            width: 28,
            height: 28,
            borderRadius: BorderRadius.circular(14),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 130),
            child: Text(
              '${car.brand} ${car.model}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.close_rounded, size: 16, color: AppColors.mute),
            ),
          ),
        ],
      ),
    );
  }
}

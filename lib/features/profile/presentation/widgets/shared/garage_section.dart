import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class GarageSection extends StatelessWidget {
  const GarageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 36,
              color: AppColors.mute,
            ),
            SizedBox(height: 10),
            Text(
              'Garage coming soon...',
              style: TextStyle(
                color: AppColors.mute,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

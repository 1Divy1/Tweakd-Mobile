import 'package:flutter/material.dart';

import '../../domain/entities/profile.dart';

class ProfileDataView extends StatelessWidget {
  final ProfileEntity profile;

  const ProfileDataView({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('id', profile.id),
          _row('role', profile.role),
          _row('name', profile.name),
          _row('username', profile.username),
          _row('avatarUrl', profile.avatarUrl),
          _row('bio', profile.bio),
          _row('externalLink', profile.externalLink),
          _row('followersCount', profile.followersCount.toString()),
          _row('followingCount', profile.followingCount.toString()),
          _row('isVerified', profile.isVerified.toString()),
          _row('isBusiness', profile.isBusiness.toString()),
          _row('requiresOnboarding', profile.requiresOnboarding.toString()),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Colors.black),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

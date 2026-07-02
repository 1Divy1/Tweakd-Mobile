import 'package:flutter/material.dart';

import '../../../domain/entities/my_feedback.dart';
import 'my_feedback_tile.dart';

/// The loaded list of the user's submitted feedback.
class MyFeedbackListView extends StatelessWidget {
  final List<MyFeedbackEntity> feedback;

  const MyFeedbackListView({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: feedback.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) => MyFeedbackTile(feedback: feedback[i]),
    );
  }
}

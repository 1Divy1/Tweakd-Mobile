import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/forum_topic.dart';
import '../shared/forum_chips.dart';
import '../shared/forum_section_label.dart';

/// "TOPICS" section of the composer: one flat row of multi-select chips, in
/// the order the backend sends them.
class TopicSelector extends StatelessWidget {
  final List<ForumTopicEntity> topics;
  final Set<String> selectedTopicIds;
  final ValueChanged<String> onToggle;

  const TopicSelector({
    super.key,
    required this.topics,
    required this.selectedTopicIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ForumSectionLabel(label: l10n.forumsTopics),
        if (topics.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final topic in topics)
                ForumChoiceChip(
                  label: topic.name,
                  selected: selectedTopicIds.contains(topic.id),
                  onTap: () => onToggle(topic.id),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

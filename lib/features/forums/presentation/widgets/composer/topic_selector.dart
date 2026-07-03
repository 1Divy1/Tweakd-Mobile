import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/forum_topic.dart';
import '../shared/forum_chips.dart';
import '../shared/forum_section_label.dart';

/// "TOPICS" section of the composer: multi-select chips grouped by component
/// and format.
class TopicSelector extends StatelessWidget {
  final List<ForumTopicGroupEntity> topicGroups;
  final Set<String> selectedTopicIds;
  final ValueChanged<String> onToggle;

  const TopicSelector({
    super.key,
    required this.topicGroups,
    required this.selectedTopicIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    List<ForumTopicEntity> topicsOf(ForumTopicKind kind) => [
          for (final group in topicGroups)
            if (group.kind == kind) ...group.topics,
        ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    Widget chips(List<ForumTopicEntity> topics) => Wrap(
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
        );

    final components = topicsOf(ForumTopicKind.component);
    final formats = topicsOf(ForumTopicKind.format);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ForumSectionLabel(label: l10n.forumsTopics),
        if (components.isNotEmpty) ...[
          const SizedBox(height: 12),
          ForumSectionLabel(label: l10n.forumsComponentLabel),
          const SizedBox(height: 8),
          chips(components),
        ],
        if (formats.isNotEmpty) ...[
          const SizedBox(height: 16),
          ForumSectionLabel(label: l10n.forumsFormatLabel),
          const SizedBox(height: 8),
          chips(formats),
        ],
      ],
    );
  }
}

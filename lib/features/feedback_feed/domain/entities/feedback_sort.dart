/// The three orderings offered above the board. [popular] is highest net score
/// (up votes − down votes) first.
enum FeedbackSort { newest, popular, oldest }

extension FeedbackSortWire on FeedbackSort {
  /// The `?sort=` value the backend expects.
  String get wireValue => switch (this) {
        FeedbackSort.newest => 'newest',
        FeedbackSort.popular => 'popular',
        FeedbackSort.oldest => 'oldest',
      };
}

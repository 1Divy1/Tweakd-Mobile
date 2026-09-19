/// Every event name the app sends, in one place — the agreed taxonomy in
/// ANALYTICS_PROGRESS.md. A new event is added here first, never as a string
/// literal at the call site, so PostHog never ends up with two spellings of
/// the same thing.
abstract final class AnalyticsEvents {
  // Activation
  static const signedUp = 'signed_up';
  static const onboardingCompleted = 'onboarding_completed';
  static const signedIn = 'signed_in';
  static const signedOut = 'signed_out';

  // Posts & social
  static const postCreated = 'post_created';
  static const postLiked = 'post_liked';
  static const postUnliked = 'post_unliked';
  static const postCommented = 'post_commented';
  static const postReposted = 'post_reposted';
  static const postUnreposted = 'post_unreposted';
  static const postSaved = 'post_saved';
  static const userFollowed = 'user_followed';
  static const userUnfollowed = 'user_unfollowed';
  static const followRequestAccepted = 'follow_request_accepted';
  static const followRequestRejected = 'follow_request_rejected';
  static const searchPerformed = 'search_performed';

  // Messages
  static const conversationStarted = 'conversation_started';
  static const messageSent = 'message_sent';

  // Forums
  static const forumThreadCreated = 'forum_thread_created';
  static const forumReplyCreated = 'forum_reply_created';
  static const forumThreadLiked = 'forum_thread_liked';

  // Garage
  static const carAdded = 'car_added';
  static const modificationAdded = 'modification_added';
  /// The share sheet for a car loaded its link (created on first open).
  static const carShareOpened = 'car_share_opened';

  // Map & events
  static const mapOpened = 'map_opened';
  static const mapEventCreated = 'map_event_created';
  static const mapEventViewed = 'map_event_viewed';
  static const mapEventAttendanceSet = 'map_event_attendance_set';
  static const mapEventCarRegistered = 'map_event_car_registered';
  static const mapEventWithdrawn = 'map_event_withdrawn';
  /// A settled map-search query's first page landed (one per result tab).
  static const mapSearchPerformed = 'map_search_performed';
  /// A map-search result was tapped and the map flew to it.
  static const mapSearchResultOpened = 'map_search_result_opened';

  // Contests
  static const contestCreated = 'contest_created';
  static const contestViewed = 'contest_viewed';
  static const contestEntryRequested = 'contest_entry_requested';
  static const contestVoteCast = 'contest_vote_cast';
  static const participantCardShared = 'participant_card_shared';

  /// The share sheet was opened for an event's public link.
  static const eventShareOpened = 'event_share_opened';

  // Other
  static const feedbackSubmitted = 'feedback_submitted';
  static const contentReported = 'content_reported';
  static const userBlocked = 'user_blocked';
  static const notificationOpened = 'notification_opened';
  static const deepLinkOpened = 'deep_link_opened';
  static const analyticsConsentChanged = 'analytics_consent_changed';
}

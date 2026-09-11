/// Live contest boards, carried by Supabase Realtime Broadcast on the private
/// per-event topic `event:<event_id>:contests` — published by the backend
/// after every vote (debounced) and on every status change.
///
/// Everything here is **display-only**: the durable truth comes back from the
/// REST endpoints on any read, and a dropped message costs a second of
/// staleness, never data. Clients never publish on this topic.
///
/// Subscriptions are **ref-counted per event**: the contests tab and a contest
/// page open at once share one channel, because Realtime bills per delivered
/// message and two joins would double the bill for the same phone.
abstract class ContestRealtimeService {
  /// Raw `board` payloads (`contest_id`, `status`, `votes_count`, `entries`).
  /// Decoding to an entity happens in the map_events data layer, which owns
  /// the models — core stays feature-agnostic.
  Stream<Map<String, dynamic>> get boards;

  /// Raw `status` payloads (`contest_id`, `status`).
  Stream<Map<String, dynamic>> get statusChanges;

  /// Whether the channel for [eventId] is currently joined. A bloc polls while
  /// this is false.
  bool isLive(String eventId);

  /// Joins the event's topic (or bumps its ref-count).
  Future<void> subscribe(String eventId);

  /// Drops one reference; the channel leaves when the last one goes.
  Future<void> unsubscribe(String eventId);

  /// Leaves everything — sign-out.
  Future<void> disconnect();
}

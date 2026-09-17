# Realtime costs — progress

Goal: cut Supabase Realtime usage (free tier: 200 peak connections, 2M messages/month).

## Findings (2026-09-17)

- One device = **one WebSocket** no matter how many channels it joins. Peak connections count sockets.
- `supabase_flutter` closes the socket when the app is backgrounded and reopens it on resume, so only
  foregrounded apps count.
- Before this work the socket was opened at app start for every signed-in user:
  - `user:<id>` DM topic (whole session)
  - `presence:online` global presence channel (whole session)
  - `event:<id>:contests` (only while a contest page is open)
- Removing presence alone saves **zero connections** (the DM topic keeps the socket open), but it removes
  the O(N²) message fan-out of a global presence channel and the 20 presence events/sec free-tier limit.
- The socket closes on its own when the last channel is removed (`RealtimeClient.removeChannel`).
- `dm-push` edge function does not depend on presence — push delivery is unaffected.

## Decisions (owner, 2026-09-17)

- Unread-DM badge does not need to be live outside the Messages screens.
- Remove user presence entirely (online dots, "Active now" strip, chat header status).

## Plan

- [x] Audit realtime usage
- [x] DM socket held only while the inbox or a chat is open — `DmRealtimeService.retain()/release()`,
      held by `MessagesRepositoryImpl.chatEvents` / `inboxEvents` for as long as they have a listener
- [x] Catch-up when the DM topic (re)subscribes (`DmConnectedEvent`): the inbox refreshes, an open chat
      merges the latest page (`ChatLiveConnected`) and marks new peer messages read
- [x] `DmUnreadCubit` no longer listens to realtime; refreshes on app resume (plus feed mount, return from
      inbox/chat, foreground DM push)
- [x] Presence removed: services, use cases, entity, repo methods, bloc events, "Active now" strip, online
      dots, chat header status, `messagesActiveNow*` l10n keys
- [x] Regenerated DI + l10n; `flutter analyze` clean (2 pre-existing warnings in map_events);
      `flutter test` 867 passing, incl. new `test/features/messages/dm_live_connection_test.dart`
- [ ] Manual check on a device: open inbox → socket up; leave Messages → socket closes; background/resume
      in a chat → missed messages appear (Dashboard → Realtime → Connected Clients)

## Gotcha found on the way

Cancelling an `async*` stream that is suspended in `await for` only completes at its next `yield`. A
`try/finally` release in such a generator never runs on a quiet topic, so the held streams use a
`StreamController` with `onCancel` instead.

## Also done

- [x] DM publishes to unjoined topics use `RealtimeChannel.httpSend` explicitly instead of the deprecated
      implicit REST fallback of `sendBroadcastMessage`.

## Resolved questions (owner, 2026-09-17)

- Contest boards stay live via Realtime — they only hold the socket while a contest page is open.
- `presence:online` policies on `realtime.messages` and the Spring STOMP `presence` module stay as they are
  (unused, cost nothing, may be reused).

## Known limits

- The 200 peak connections are project-wide: Messages screens + contest pages combined.
- Contest detail page has no polling fallback when its join is refused; the event contests list polls every 30s.

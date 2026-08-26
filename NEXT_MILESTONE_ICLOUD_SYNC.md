# Tendora Next Milestone: iCloud Sync

Updated: August 25, 2026

This document defines the recommended next major milestone for Tendora after version 1.0 App Store submission.

## Recommended Milestone

Version `1.1`

Primary goal:

Enable iCloud sync so Tendora data can stay in sync across the user’s Apple devices.

## Why This Should Be Next

- Tendora is already working well as a local-first app.
- The next highest-value improvement is multi-device continuity.
- iCloud sync is more meaningful than adding small isolated features.
- It increases trust because the user’s data feels safer and more durable.

## Scope For 1.1

Include:

- sync for assets
- sync for maintenance tasks
- sync for completion history
- sync for attachments
- basic sync status/error handling

Do not include unless clearly needed:

- collaboration or sharing with other users
- non-Apple cloud backends
- complex conflict resolution UI
- monetization changes
- Mac or Vision support expansion

## Product Decisions To Make First

Before implementation starts, decide:

1. Should sync be automatic when iCloud is available?
2. Should the user be able to turn sync on or off in Settings?
3. What happens to existing local-only data when sync is enabled?
4. How should attachments be handled if sync is slow or temporarily unavailable?
5. What simple message should the app show if iCloud is unavailable?

## Recommended Product Direction

Use this unless you later choose differently:

- sync should be automatic when iCloud is available
- no account creation beyond Apple/iCloud
- existing local data should migrate forward into the synced store
- conflicts should use simple last-write-wins behavior unless testing proves that is too weak
- users should see simple, human-readable error states rather than technical sync details

## Technical Work Areas

Likely areas of change:

- `Tendora/Tendora/TendoraApp.swift`
- `Tendora/Tendora/Persistence/`
- `Tendora/Tendora/Models/`
- `Tendora/Tendora/Services/AttachmentManager.swift`
- `Tendora/Tendora/Views/Settings/SettingsView.swift`

Likely new work:

- iCloud-capable SwiftData model container configuration
- migration handling from local store to synced store
- attachment file strategy review for synced environments
- user-facing Settings text for sync status or sync availability
- test plan for same-account multi-device behavior

## Main Risks

### 1. Local Data Migration

Risk:

Users may already have local-only data when sync is introduced.

Need:

- a safe migration plan
- clear test coverage before release

### 2. Attachment Sync Complexity

Risk:

Attachments are often the hardest part of sync.

Need:

- verify whether current attachment storage strategy works cleanly with iCloud-backed persistence
- test import, delete, open, and share on multiple devices

### 3. Conflict Behavior

Risk:

The same task or asset may be edited on two devices.

Need:

- define expected behavior early
- keep conflict handling simple for version 1.1

### 4. Offline And Partial Sync States

Risk:

Users may assume sync is broken when a device is offline or delayed.

Need:

- light but clear messaging
- avoid exposing low-level sync implementation details

## Suggested Delivery Phases

### Phase 1: Planning

- confirm product rules
- confirm store/migration approach
- confirm attachment sync strategy

### Phase 2: Persistence Setup

- update model container configuration for iCloud-backed storage
- keep migration safety as the priority

### Phase 3: Core Sync Validation

- verify assets, tasks, and history sync correctly
- test create, edit, and delete flows on multiple devices

### Phase 4: Attachment Validation

- test imported files and photos across devices
- confirm open/share/delete behavior still works

### Phase 5: User-Facing Polish

- add minimal Settings or status messaging if needed
- fix confusing sync edge cases

### Phase 6: Release Testing

- same Apple ID on two devices
- fresh install on second device
- offline edits
- delayed sync
- notification behavior after synced changes

## Suggested Success Criteria

Version 1.1 is ready when:

- assets sync correctly across devices
- tasks and completion history sync correctly across devices
- attachments remain accessible after sync
- local-to-iCloud migration does not destroy existing data
- basic error states are understandable
- the app still feels simple

## What To Avoid

Do not expand the milestone too early with:

- subscriptions
- redesign work
- advanced reporting
- collaborative household sharing
- cross-platform ambitions outside Apple devices

## Recommended Restart Prompt

Use this when work begins on the next major milestone:

```text
Continue Tendora from NEXT_MILESTONE_ICLOUD_SYNC.md.
Current goal: plan and implement the first safe version of iCloud sync for Tendora.
Please inspect the current persistence setup and propose the safest implementation path.
```

# Tendora Project Status

Updated: August 24, 2026

## Current State

- Local SwiftData app is working and builds successfully in Xcode.
- Assets can be created and edited.
- Tasks can be created and edited.
- Attachments can be added, deleted, opened, and shared/exported.
- Notification scheduling is wired in for task reminders.
- Settings screen has been cleaned up and simplified.
- Localization cleanup has been started and unused placeholder strings were removed.

## Completed Recent Work

- Added attachment delete buttons instead of relying on hidden context menus.
- Added attachment preview/open support with Quick Look.
- Added attachment share/export support.
- Improved attachment error handling and alerts.
- Fixed task reminder save logic so disabling reminders cancels existing scheduled notifications.
- Prevented invalid custom repeat values like `0`.
- Improved asset form validation for year and odometer fields.
- Prevented stale type-specific asset data from carrying across asset type changes on save.
- Removed unused release-placeholder localization keys.
- Clarified the notification settings row in Settings so users understand it opens iPhone Settings.

## Important Product Direction

- Current plan is local-first storage now.
- App Store submission comes before iCloud sync.
- iCloud/database sync should be added later as a separate milestone after the local app is stable.

## Next Recommended Step

Choose one:

1. Do one more sweep for dead code, unused strings, and release leftovers.
2. Start App Store submission preparation:
   - app icon set
   - privacy policy/support details
   - screenshots
   - App Store metadata
   - TestFlight/release checklist

## Suggested Restart Prompt

Use this when you come back:

```text
Continue Tendora from PROJECT_STATUS.md.
Current goal: keep moving toward App Store readiness.
Please inspect the repo state and continue with the next recommended step.
```

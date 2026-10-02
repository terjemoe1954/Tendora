# Tendora Final App Store Submission Steps

Updated: August 25, 2026

Use this as the final runbook when you are ready to submit Tendora version 1.0.

## Phase 1: Lock Release Scope

| Step | Action | Status |
|---|---|---|
| 1 | Release as `iPhone + iPad` | Pending |
| 2 | Disable `Mac` support for version 1.0 | Pending |
| 3 | Disable `Apple Vision` support for version 1.0 | Pending |
| 4 | Confirm Xcode target settings match the intended release scope | Pending |

## Phase 2: Final Product Information

| Step | Action | Status |
|---|---|---|
| 1 | Finalize support URL | Pending |
| 2 | Finalize privacy policy URL | Pending |
| 3 | Decide app price | Pending |
| 4 | Confirm seller/display name in App Store Connect | Pending |

## Phase 3: Final Metadata

Use the approved metadata already drafted for Tendora.

| Field | Value |
|---|---|
| Name | `Tendora` |
| Subtitle | `Track maintenance for what you own` |
| Category | `Productivity` |
| Secondary Category | `Utilities` |
| Promotional Text | `Keep your assets, maintenance tasks, reminders, and important documents together in one simple app.` |
| Keywords | `maintenance,home,asset,reminder,service,documents,car,boat,house,organizer` |
| What’s New | `Initial release.` |

## Phase 4: Screenshots

| Step | Action | Status |
|---|---|---|
| 1 | Load screenshot demo data | Pending |
| 2 | Capture iPhone screenshots | Pending |
| 3 | Capture iPad screenshots | Pending |
| 4 | Review screenshots for empty states, dialogs, and demo UI | Pending |
| 5 | Upload screenshots to App Store Connect | Pending |

Use:

- [APP_STORE_SCREENSHOT_PLAN.md](/Users/terjemoe/Desktop/MyApps/Tendora/APP_STORE_SCREENSHOT_PLAN.md:1)
- [SCREENSHOT_DEMO_DATA.md](/Users/terjemoe/Desktop/MyApps/Tendora/SCREENSHOT_DEMO_DATA.md:1)

## Phase 5: Final Validation In App

| Test | Status |
|---|---|
| Fresh install onboarding | Pending |
| Create/edit/delete asset | Pending |
| Create/edit/delete task | Pending |
| Mark task as done and see confirmation | Pending |
| Reminder permission flow | Pending |
| Attachment import/preview/share/delete | Pending |
| Calendar screen with realistic data | Pending |
| Documents screen with realistic data | Pending |
| English text review | Pending |
| Norwegian text review | Pending |
| Thai text review | Pending |

## Phase 6: Release Build

| Step | Action | Status |
|---|---|---|
| 1 | Set final version number | Pending |
| 2 | Set final build number | Pending |
| 3 | Create Archive in Xcode | Pending |
| 4 | Validate Archive | Pending |
| 5 | Upload build from Organizer | Pending |

## Phase 7: App Store Connect

| Step | Action | Status |
|---|---|---|
| 1 | Create or open Tendora app record | Pending |
| 2 | Set platform to `iOS` | Pending |
| 3 | Fill app information | Pending |
| 4 | Fill pricing and availability | Pending |
| 5 | Fill App Privacy answers | Pending |
| 6 | Fill age rating answers | Pending |
| 7 | Add review notes | Pending |
| 8 | Select uploaded build | Pending |

## Phase 8: App Privacy Review

Based on the current codebase, verify these before answering in App Store Connect:

| Area | Current Likely Answer | Status |
|---|---|---|
| Tracking | No | Verify |
| Third-party analytics | No | Verify |
| Ads | No | Verify |
| Account creation | No | Verify |
| Developer data collection | Likely none | Verify carefully |
| On-device local storage only | Yes | Verify |

If you add any SDKs later, revisit these answers before every submission.

## Phase 9: Reviewer Notes

Suggested reviewer note:

```text
Tendora is a local-first maintenance tracking app. Reviewers can create assets, add tasks with reminder settings, and attach local photos or files to assets and tasks. Notification permissions are optional and are used only for maintenance reminders created by the user.
```

## Phase 10: Submit

| Step | Action | Status |
|---|---|---|
| 1 | Final pass through every App Store Connect field | Pending |
| 2 | Confirm screenshots map to supported devices | Pending |
| 3 | Confirm privacy policy and support URL are reachable | Pending |
| 4 | Confirm the correct build is selected | Pending |
| 5 | Submit for review | Pending |

## Recommended Immediate Next Steps

Do these now:

1. Confirm the release scope is `iPhone + iPad` only.
2. Prepare the real privacy policy URL and support URL.
3. Capture the 5 iPhone screenshots.
4. Capture the 5 iPad screenshots.
5. Run one archive build before opening the final submission form.

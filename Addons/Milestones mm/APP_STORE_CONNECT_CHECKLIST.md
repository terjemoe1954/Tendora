# Tendora App Store Connect Checklist

Updated: August 25, 2026

Use this document when you create the Tendora app record in App Store Connect and prepare the first submission.

## 1. App Record

| Field | Recommended Value | Status |
|---|---|---|
| Platform | `iOS` | Pending |
| App Name | `Tendora` | Ready |
| Primary Language | `English (U.S.)` or your preferred default | Choose |
| Bundle ID | Match Xcode target bundle identifier exactly | Verify |
| SKU | `tendora-ios-001` or your own internal ID | Choose |

## 2. Availability

| Field | Recommended Value | Status |
|---|---|---|
| Devices | `iPhone and iPad` if both are tested and supported | Confirm |
| Mac on Apple Silicon | Disable unless you want to support Mac now | Review |
| Apple Vision | Disable unless you want to support it now | Review |
| Price | Free or your chosen price tier | Choose |
| Availability Date | Release when approved or manual release | Choose |

## 3. App Information

| Field | Recommended Value | Status |
|---|---|---|
| Name | `Tendora` | Ready |
| Subtitle | `Track maintenance for what you own` | Ready |
| Category | `Productivity` | Ready |
| Secondary Category | `Utilities` | Optional |
| Content Rights | `No third-party content issues` unless applicable | Review |
| Age Rating | Likely `4+` based on current feature set | Complete in App Store Connect |

## 4. Promotional Text And Metadata

| Field | Recommended Value | Status |
|---|---|---|
| Promotional Text | `Keep your assets, maintenance tasks, reminders, and important documents together in one simple app.` | Ready |
| Keywords | `maintenance,home,asset,reminder,service,documents,car,boat,house,organizer` | Ready |
| Support URL | Your real support page or contact page | Needed |
| Marketing URL | Optional website for Tendora | Optional |
| Privacy Policy URL | Real public privacy policy page | Needed |

## 5. Description

Use this text unless you want to refine the tone before submission:

```text
Tendora helps you stay on top of the things you own.

Track homes, cabins, cars, boats, and other assets in one place. Add maintenance tasks, set reminders, and keep important photos and documents attached to each item so the details are always easy to find.

With Tendora you can:

- Add and organize your assets
- Create maintenance tasks with due dates
- Set reminder notifications before work is due
- Track upcoming tasks in a calendar view
- Store receipts, manuals, warranties, photos, and other documents
- Review maintenance history over time

Tendora is designed to make everyday ownership easier, whether you are keeping up with a home, a vehicle, or seasonal equipment.

Your data is currently stored locally on your device.
```

## 6. What’s New

| Release | Text | Status |
|---|---|---|
| Version 1.0 | `Initial release.` | Ready |

Optional longer first-release version:

```text
First public release of Tendora with asset tracking, maintenance reminders, calendar planning, and document attachments.
```

## 7. Privacy Answers

Based on the current codebase, this is the likely position to verify before submission.

| Question Area | Current Likely Answer | Status |
|---|---|---|
| Accounts | No account system | Verify |
| Tracking | No tracking | Verify |
| Analytics | No third-party analytics visible | Verify |
| Advertising | No ads or ad SDKs visible | Verify |
| Data Linked to User | Likely no, if data stays on-device only | Verify carefully |
| Data Collection | Likely none collected by developer, if fully local | Verify carefully |

Important:
Only answer these after one final code sweep for analytics, crash SDKs, external APIs, or hidden collection behavior.

## 8. Screenshots And Preview

| Asset | Recommended | Status |
|---|---|---|
| iPhone screenshots | Required | Pending |
| iPad screenshots | Required if iPad is supported in the store | Pending |
| App Preview video | Optional | Optional |
| Final app icon review | Required | Pending |

Use demo data before capturing screenshots so every screen looks intentional and complete.

## 9. Reviewer Notes

Suggested review note:

```text
Tendora is a local-first maintenance tracking app. Reviewers can create assets, add tasks with reminder settings, and attach local photos or files to assets and tasks. Notification permissions are optional and are used only for maintenance reminders created by the user.
```

## 10. Release Validation Before Upload

| Test | Status |
|---|---|
| Fresh install onboarding | Pending |
| Create, edit, delete asset | Pending |
| Create, edit, delete task | Pending |
| Mark task as done and confirm history updates | Pending |
| Reminder permission flow | Pending |
| Attachment import, preview, share, delete | Pending |
| Calendar screen with realistic data | Pending |
| Documents screen with realistic data | Pending |
| English localization pass | Pending |
| Norwegian localization pass | Pending |
| Thai localization pass | Pending |
| Archive/release build | Pending |

## 11. Before You Press Submit

| Item | Status |
|---|---|
| Remove or hide demo-only tools if they should not ship | Review |
| Confirm supported devices in Xcode and App Store Connect match | Pending |
| Confirm version and build number | Pending |
| Upload build from Xcode Organizer | Pending |
| Attach screenshots | Pending |
| Attach privacy policy and support URL | Pending |
| Complete age rating | Pending |
| Complete privacy nutrition answers | Pending |
| Add reviewer note | Pending |

## Recommended Next Action

Do these next, in order:

1. Decide whether Tendora should launch with `iPhone + iPad` only, or also `Mac` and `Apple Vision`.
2. Prepare the real `Privacy Policy URL` and `Support URL`.
3. Capture final iPhone and iPad screenshots using your demo data.
4. Run one archive/release build before uploading.

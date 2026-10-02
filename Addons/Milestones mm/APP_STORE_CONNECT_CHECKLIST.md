# Tendora App Store Connect Checklist

Updated: September 26, 2026

Use this document when you prepare the Tendora App Store Connect record for the version `1.2` build `5` Premium update. Version `1.1` build `4` is the approved public baseline.

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
| Price | Free app with optional Tendora Premium subscription | Confirm |
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
- Add new receipts, manuals, warranties, photos, and other documents with Premium
- Review maintenance history over time
- Keep your Tendora data in sync across your Apple devices with iCloud

Tendora is designed to make everyday ownership easier, whether you are keeping up with a home, a vehicle, or seasonal equipment.

Core asset and task tracking is available without Premium. Tendora Premium unlocks adding new photos and document attachments to assets and tasks. Existing attachments remain available, and eligible existing users may keep attachment creation unlocked as an early-supporter transition.

Your Tendora data is stored privately with your iCloud account when iCloud is available. Tendora does not provide shared household accounts or collaboration between different users.
```

## 6. What’s New

| Release | Text | Status |
|---|---|---|
| Version 1.2 / Premium update | `Adds Tendora Premium for adding new photo and document attachments, while keeping core asset and task tracking available without Premium. Existing attachments remain accessible.` | Draft |

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
| Data Linked to User | User-created content may sync through the user's private iCloud account; verify App Store privacy wording carefully | Verify carefully |
| Data Collection | No developer server or analytics visible; verify iCloud/private user content answers carefully | Verify carefully |

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
Tendora is a maintenance tracking app for user-created assets, tasks, reminders, and attachments. Version 1.2 build 5 adds Tendora Premium. Reviewers can create assets and add tasks with reminder settings without purchasing. Adding new photo or document attachments is a Tendora Premium feature for fresh installs; existing attachments remain accessible. Eligible users whose original App Store install predates build 5 may keep attachment creation unlocked as an early-supporter transition. Premium can be purchased, restored, and managed from Settings. Notification permissions are optional and are used only for maintenance reminders created by the user. If testing on multiple devices signed into the same iCloud account, data should sync through the user's private iCloud database.
```

## 10. Premium Subscription Products

| Product | App Store Connect Type | Product ID | Status |
|---|---|---|---|
| Tendora Premium Monthly | Auto-renewable subscription | `tendora_premium_monthly` | Create in App Store Connect |
| Tendora Premium Yearly | Auto-renewable subscription | `tendora_premium_yearly` | Create in App Store Connect |

Use one subscription group for both products. Confirm pricing, localizations, subscription duration, review screenshot, and App Review information in App Store Connect before upload.

## 11. Release Validation Before Upload

| Test | Status |
|---|---|
| Fresh install onboarding | Pending |
| Create, edit, delete asset | Pending |
| Create, edit, delete task | Pending |
| Mark task as done and confirm history updates | Pending |
| Reminder permission flow | Pending |
| Attachment import, preview, share, delete | Pending |
| Fresh install attachment gate and Premium upgrade sheet | Pending |
| Monthly Premium subscription purchase | Pending |
| Yearly Premium subscription purchase | Pending |
| Restore purchases | Pending |
| Manage subscription sheet | Pending |
| Pending purchase state | Pending |
| Purchases disabled by device/account restrictions | Pending |
| Early-supporter upgrade path from existing install | Pending |
| Calendar screen with realistic data | Pending |
| Documents screen with realistic data | Pending |
| English localization pass | Pending |
| Norwegian localization pass | Pending |
| Thai localization pass | Pending |
| Archive/release build | Pending |

## 12. Before You Press Submit

| Item | Status |
|---|---|
| Remove or hide demo-only tools if they should not ship | Review |
| Confirm supported devices in Xcode and App Store Connect match | Pending |
| Confirm version and build number | Ready: `1.2` build `5` |
| Upload build from Xcode Organizer | Pending |
| Attach screenshots | Pending |
| Attach privacy policy and support URL | Pending |
| Configure Premium subscription group and products | Pending |
| Confirm monthly/yearly Premium product IDs match the app | Pending |
| Add subscription group and at least one Premium subscription to the version `1.2` App Review submission | Pending |
| Add App Review notes for Premium and early-supporter behavior | Pending |
| Complete age rating | Pending |
| Complete privacy nutrition answers | Pending |
| Add reviewer note | Pending |

## Recommended Next Action

Do these next, in order:

1. Decide whether Tendora should launch with `iPhone + iPad` only, or also `Mac` and `Apple Vision`.
2. Prepare the real `Privacy Policy URL` and `Support URL`.
3. Capture final iPhone and iPad screenshots using your demo data.
4. Run one archive/release build before uploading.

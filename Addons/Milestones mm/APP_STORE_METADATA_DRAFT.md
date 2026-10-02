# Tendora App Store Metadata Draft

Updated: September 26, 2026

This draft is based on the current shipped feature set in the codebase:

- asset management
- maintenance task tracking
- reminders/notifications
- document and photo attachments
- calendar view
- iCloud sync across the user's Apple devices
- private user data storage through the user's iCloud account
- Tendora Premium subscriptions for adding new photo/document attachments
- early-supporter attachment access for eligible existing users

Release target:

- Approved public baseline: version `1.1` build `4`
- Premium update target: version `1.2` build `5`

## App Name

`Tendora`

## Subtitle

Option A:
`Track maintenance for what you own`

Option B:
`Assets, reminders, and documents`

Recommended:
`Track maintenance for what you own`

## Keywords

Draft:

`maintenance,home,asset,reminder,service,documents,car,boat,house,organizer`

## Promotional Text

`Keep your assets, maintenance tasks, reminders, and important documents in sync across your Apple devices.`

## Description

Updated draft:

`Tendora helps you stay on top of the things you own.

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

Your Tendora data is stored privately with your iCloud account when iCloud is available. Tendora does not provide shared household accounts or collaboration between different users.`

## What’s New

For sync/stability release:

`Adds iCloud sync improvements and stability fixes for keeping Tendora data available across your Apple devices.`

Optional richer version:

`This update improves iCloud sync across iPhone, iPad, and Mac, including better attachment handling and clearer storage error states.`

For paid/Premium release:

`Adds Tendora Premium for adding new photo and document attachments, while keeping core asset and task tracking available without Premium. Existing attachments remain accessible.`

## Primary Category

Recommended:

`Productivity`

Alternative:

`Utilities`

Recommendation:

Choose `Productivity` unless you want to position the app more as a tool/utility than an organizer.

## Secondary Category

Optional:

`Utilities`

## Age Rating

Likely answers based on current functionality:

- No user-generated public content
- No social features
- No web browsing
- No gambling
- No alcohol/tobacco/drug themes
- No sexual content
- No violence
- No medical treatment claims

Expected result:

`4+`

## Review Notes

Draft:

`Tendora is a maintenance tracking app for user-created assets, tasks, reminders, and attachments. Version 1.2 build 5 adds Tendora Premium. Reviewers can create assets and add tasks with reminder settings without purchasing. Adding new photo or document attachments is a Tendora Premium feature for fresh installs; existing attachments remain accessible. Eligible users whose original App Store install predates build 5 may keep attachment creation unlocked as an early-supporter transition. Premium can be purchased, restored, and managed from Settings. If testing on multiple devices signed into the same iCloud account, data should sync through the user's private iCloud database. Notification permissions are optional and are used only for maintenance reminders created by the user.`

## Privacy Summary Draft

Current likely position based on the app as implemented:

- Data is created by the user and stored in the user's private iCloud database when iCloud is available
- No Tendora account system
- No sharing of private data between different Apple IDs
- No third-party analytics visible in the current codebase
- No advertising SDKs visible in the current codebase
- No external tracking visible in the current codebase
- Premium subscriptions use StoreKit and the user's App Store account

This still needs to be confirmed in App Store Connect before submission.

## Open Items Before Final Submission

- Confirm final subtitle
- Confirm final keyword list
- Confirm final category choice
- Provide real privacy policy URL
- Provide support URL or contact page
- Confirm App Store privacy answers for iCloud-synced user content
- Confirm Premium monthly/yearly products are configured in App Store Connect
- Confirm Premium subscription localization, pricing, and review notes

## Suggested Next Prompt

```text
Use APP_STORE_METADATA_DRAFT.md and help me finalize the App Store text field by field.
```

# Tendora Milestone 1.1: Sync Stability + App Store Polish

Updated: September 25, 2026

## Goal

Make iCloud sync a stable production feature before starting paid/Premium work.

This milestone focuses on proving that Tendora data syncs reliably across a user's Apple devices, that attachment behavior is understandable, and that App Store metadata accurately describes the current app.

## Current State

- Tendora is live on the App Store.
- SwiftData uses the private CloudKit database:

  ```text
  iCloud.com.terjemoe.Tendora
  ```

- Production schema has been promoted.
- iPhone and iPad sync has been verified.
- Mac sync has been verified after fixing Mac-side iCloud/app access.
- Attachments now store file contents in `Attachment.fileData` with external storage.
- The app no longer silently falls back to an in-memory store when the CloudKit-backed store fails.

## Validated So Far

- [x] Production schema was promoted for `iCloud.com.terjemoe.Tendora`.
- [x] iPhone to iPad sync works.
- [x] iPad to iPhone sync works.
- [x] Mac to iOS sync works after toggling/fixing Mac-side iCloud app access.
- [x] iOS to Mac sync works after toggling/fixing Mac-side iCloud app access.
- [x] Same-account private CloudKit behavior is understood: users do not see another user's data.
- [x] Silent in-memory fallback was removed so storage/container failures are visible.
- [ ] Full delete propagation test still needs to be run.
- [ ] Full offline-to-online test still needs to be run.
- [ ] Attachment open/share/delete test still needs to be run on all device types.
- [x] App Store metadata draft has been updated for iCloud sync.
- [ ] App Store Connect metadata still needs to be updated from the draft.

## Release Decision

Use one of these version paths:

- `1.0.2` if this release is positioned as bug fixes and stability.
- `1.1` if iCloud sync is called out as a user-facing feature.

Recommended: use `1.1` if the App Store description and release notes will mention iCloud sync.

## Scope

Include:

- iCloud sync validation across iPhone, iPad, and Mac.
- Attachment sync validation for new photos and files.
- Delete propagation validation.
- Offline-to-online sync validation.
- Storage unavailable/error behavior validation.
- App Store metadata and privacy wording updates.

Do not include yet:

- StoreKit or paid subscriptions.
- Premium gating of sync.
- Collaboration or shared household data.
- Complex conflict resolution UI.
- Major redesign work.

## Sync Test Matrix

Run with the same iCloud account on all devices.

Use `SYNC_TEST_LOG_1_1.md` to record the actual test results.

| Test | Device A | Device B | Expected Result |
| --- | --- | --- | --- |
| Create asset | iPhone | iPad | Asset appears on iPad |
| Create asset | iPad | iPhone | Asset appears on iPhone |
| Create asset | iPhone | Mac | Asset appears on Mac |
| Create asset | Mac | iPhone | Asset appears on iPhone |
| Edit asset name | iPhone | iPad + Mac | Updated name appears everywhere |
| Delete asset | iPad | iPhone + Mac | Asset disappears everywhere |
| Create task | iPhone | iPad + Mac | Task appears everywhere |
| Edit due date | Mac | iPhone + iPad | Updated date appears everywhere |
| Mark task done | iPad | iPhone + Mac | Completion history and next due date sync |
| Delete task | iPhone | iPad + Mac | Task disappears everywhere |
| Add photo attachment | iPhone | iPad + Mac | Attachment row appears and opens |
| Add file attachment | iPad | iPhone + Mac | Attachment row appears and opens |
| Share attachment | Mac | iPhone/iPad data unchanged | Share works without data loss |
| Delete attachment | iPhone | iPad + Mac | Attachment disappears everywhere |

## Offline Test Matrix

| Test | Steps | Expected Result |
| --- | --- | --- |
| Offline create | Enable airplane mode, create asset, disable airplane mode | Asset syncs after reconnect |
| Offline edit | Disable network, edit task, reconnect | Edit syncs after reconnect |
| Offline delete | Disable network, delete attachment, reconnect | Delete syncs after reconnect |
| Delayed peer | Keep second device closed, make changes, open it later | Changes appear after sync delay |

## Attachment Validation Notes

New attachments should be tested more heavily than old attachments.

Expected behavior:

- New photo/file attachments sync their metadata and file contents.
- If a local attachment file is missing, Tendora should recreate it from `fileData`.
- Old attachments without `fileData` can be backfilled when opened/shared on the original device that still has the local file.
- If neither local file nor `fileData` exists, opening should show the attachment open error.

## App Store Metadata Updates

Update copy that says data is stored only locally.

Recommended wording direction:

- User-created data is stored in the user's private iCloud database when iCloud is available.
- Sync works across the user's Apple devices signed into the same iCloud account.
- Tendora does not provide collaboration or sharing between different users.
- Attachments are stored with the user's Tendora data.

Files to review:

- `Addons/Milestones mm/APP_STORE_METADATA_DRAFT.md`
- App Store Connect description
- Review notes
- Privacy details
- Support text, if it mentions local-only storage

## Release Checklist

- [x] Run basic same-account sync test across iPhone, iPad, and Mac.
- [ ] Run full sync test matrix, including edit/delete/task/history cases.
- [ ] Run offline test matrix.
- [ ] Verify fresh install on second iOS device downloads existing data.
- [ ] Verify fresh install on Mac downloads existing data.
- [x] Verify iPhone, iPad, and Mac can sync after iCloud app access is available.
- [x] Verify no storage unavailable screen appears during normal launch after Mac iCloud access fix.
- [ ] Verify attachment open/share/delete on each device.
- [x] Verify metadata draft no longer says local-only.
- [ ] Verify App Store Connect text no longer says local-only.
- [ ] Verify privacy answers match iCloud/private user data behavior.
- [ ] Archive and upload TestFlight build.
- [ ] Install TestFlight build on iPhone, iPad, and Mac.
- [ ] Repeat a small smoke test on TestFlight.

## Success Criteria

This milestone is complete when:

- New data syncs both directions between iPhone, iPad, and Mac.
- Deletes sync reliably.
- New attachments open on the device where they were not originally created.
- Offline changes sync after reconnecting.
- App Store metadata accurately describes iCloud sync.
- No known data-loss issue remains open.

## Next Milestone After This

After 1.1 is stable, move to paid/Premium planning:

- StoreKit 2
- App Store Connect products
- Premium entitlement verification
- free vs paid boundaries
- early-user/grace-period decision

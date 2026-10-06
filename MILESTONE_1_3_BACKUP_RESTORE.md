# Tendora Milestone 1.3: Backup and Restore

Updated: October 6, 2026

## Goal

Add a reliable Tendora backup and restore flow after the successful `1.2 (5)` Premium release.

The first version should prioritize trust over cleverness: a user can export all Tendora data into one backup file, store it wherever they want, and restore it later with clear warnings.

## Release Context

- Version `1.2 (5)` is live on the App Store with Tendora Premium.
- Version `1.3 (7)` is prepared for backup/restore submission.
- Current data is stored with SwiftData and private iCloud sync.
- Attachments are represented both as SwiftData `fileData` and as local files, so backup can use the stored attachment data.
- Premium currently gates adding new photo/document attachments for fresh installs.

## Backup File

Use one Tendora-specific JSON backup file.

Suggested file extension:

```text
.tendorabackup
```

The backup file should include:

- Format version.
- Export date.
- App version/build.
- Assets.
- Maintenance tasks.
- Completion history.
- Attachments, including file data when available.
- Relationship links by stable UUID.

Do not include:

- StoreKit purchase state.
- iCloud account data.
- Device-specific notification identifiers.
- App Store account information.

## Scope

Include:

- Backup archive data model.
- Backup export service.
- Backup import validation.
- Restore service with safe replacement flow.
- Local reminder rescheduling after restore.
- Settings UI entry point.
- File export/import using the system document picker.
- Registered `.tendorabackup` document type so Files can select Tendora backups for restore.
- Clear restore confirmation before deleting/replacing local data.
- Localized strings in English, Norwegian Bokmal, and Thai.
- Manual test log.

Do not include yet:

- Scheduled automatic backups.
- Partial restore.
- Conflict resolution between iCloud devices.
- Merge restore.
- Encrypted/password-protected backups.
- Cross-user sharing.
- Server backup.

## Restore Policy

For version `1.3`, use a conservative restore model:

- Validate the backup file first.
- Show a summary before restore.
- Require explicit confirmation.
- Replace current local Tendora data with backup contents.
- Recreate assets, tasks, completion records, and attachments using their original UUIDs.
- Recreate local attachment files from backed-up attachment data when possible.

Future versions can add merge restore after the replacement flow is proven.

## Premium Position

Initial recommendation:

- Export without attachments can remain free.
- Full backup with attachments can become Premium after testing.

For the first implementation, keep the entitlement decision easy to adjust. Do not hard-code a permanent business rule into the backup format.

## Release Checklist

- [x] Define backup archive Codable types.
- [x] Implement export from current SwiftData model context.
- [x] Implement import validation and summary.
- [x] Implement replace-all restore.
- [x] Recreate attachment local files after restore.
- [x] Add Settings backup/restore section.
- [x] Add file exporter/importer.
- [x] Register `.tendorabackup` document type for restore picker.
- [x] Add restore confirmation and success/error alerts.
- [x] Add localization.
- [x] Reschedule local task reminders after restore.
- [x] Update user manual.
- [x] Run manual backup/restore tests.
- [x] Set version/build to `1.3 (7)`.
- [ ] Archive and upload version `1.3`.

## Success Criteria

This milestone is complete when:

- A user can export a backup from Settings.
- The backup contains all assets, tasks, completion history, and attachments.
- A fresh install can restore the backup and show the same Tendora data.
- Attachments open after restore.
- Restore never happens without explicit confirmation.
- Invalid or unsupported backup files show a clear error.
- The feature is documented in the user manual.

## Next Milestone After This

After backup/restore is stable, continue with reports:

- Upcoming maintenance report.
- Overdue task report.
- Service history per asset.
- Missing document report.
- Optional PDF export.

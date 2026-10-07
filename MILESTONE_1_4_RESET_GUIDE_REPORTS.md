# Tendora Milestone 1.4: Reset, Guide, and Reports

Updated: October 7, 2026

## Goal

Continue after the approved `1.3` Backup/Restore release with three user-facing improvements:

1. Add a safe way to delete all Tendora user data.
2. Keep the user manual current.
3. Add useful reports for maintenance planning.

## Scope

### Reset Tendora

Include:

- A Settings section for deleting all Tendora user data.
- Clear destructive confirmation before deleting anything.
- Deletion of assets, tasks, completion history, attachments, and local reminder notifications.
- Preservation of Premium status, App Store purchase history, app language, appearance, and iCloud account settings.
- Localized strings in English, Norwegian Bokmal, and Thai.
- User manual update.

Do not include:

- Automatic account deletion.
- Cancelling subscriptions.
- Removing saved backup files outside the app.
- Remote iCloud account management.

### User Guide

Include:

- Reset Tendora instructions.
- Clear note that reset does not cancel Premium.
- Reports section when reports are implemented.

### Reports

Recommended report order:

1. Upcoming maintenance report.
2. Overdue tasks report.
3. Service history per asset.
4. Missing documents report.
5. PDF sharing/printing for the report overview.

## Reset Release Checklist

- [x] Add reset service.
- [x] Add Settings reset section.
- [x] Add destructive confirmation.
- [x] Delete attachment files and SwiftData records.
- [x] Cancel local task reminder notifications.
- [x] Add localization.
- [x] Update user manual.
- [x] Run manual reset test.

## Reports Release Checklist

- [x] Define report models/view structure.
- [x] Add Reports entry point.
- [x] Implement upcoming maintenance report.
- [x] Implement overdue tasks report.
- [x] Implement service history per asset.
- [x] Implement missing documents report.
- [x] Add PDF sharing/printing report.
- [x] Update user manual with reports.
- [ ] Run manual report tests.

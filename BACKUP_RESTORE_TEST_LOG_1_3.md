# Tendora 1.3 Backup and Restore Test Log

Test date: October 6, 2026

Build: 1.3 development build

Devices:

- Source device: iPhone 17 Pro / simulator during local testing
- Restore device: iPhone 17 Pro / simulator during local testing

## Preflight

- [x] App launches successfully.
- [x] Settings opens successfully.
- [x] Backup/Restore section is visible.
- [x] Existing assets, tasks, completion records, and attachments are present before export.
- [x] Temporary DEBUG attachment bypass removed before release preparation.

## Export

| Test | Result | Notes |
| --- | --- | --- |
| Export backup with assets only | Pass | Confirmed during local backup test |
| Export backup with tasks | Pass | Confirmed during local backup test |
| Export backup with completed task history | Pass | Confirmed during local backup test |
| Export backup with photo attachment | Pass | Backup file contained attachment data |
| Export backup with document attachment | Pass | Backup file contained attachment data |
| Cancel export picker | Not run | Expect no data changes |
| Export while offline | Not run | Should work from local data |

## Restore

| Test | Result | Notes |
| --- | --- | --- |
| Import valid backup on same device | Pass | Confirmed after `.tendorabackup` document type registration |
| Import valid backup on fresh install | Pass | User confirmed restore flow works OK |
| Confirm restore summary counts | Pass | Asset/task/attachment counts matched backup during restore test |
| Cancel restore confirmation | Not run | Existing data remains unchanged |
| Confirm restore replacement | Pass | Current data replaced by backup data |
| Attachments open after restore | Pass | User confirmed files restore/open correctly |
| Completion history restored | Pass | Included in restore confirmation test |
| Reminders/settings restored correctly | Pass | Task reminder fields restored and local notifications rescheduled |

## Error States

| Test | Result | Notes |
| --- | --- | --- |
| Import unsupported file type | Not run | Expect clear error |
| Import malformed JSON | Not run | Expect clear error |
| Import future backup format version | Not run | Expect unsupported-version error |
| Import backup missing required relationship | Not run | Expect clear validation failure |
| Restore with no attachment file data | Not run | Expect metadata restored and file handled gracefully |

## iCloud and Premium Smoke Test

| Test | Result | Notes |
| --- | --- | --- |
| Restore while iCloud is available | Not run | Watch for duplicate/conflict behavior |
| Restore while iCloud is unavailable | Not run | Local restore should still complete |
| Free user can export allowed backup scope | Not run | Depends on final entitlement policy |
| Premium user can export full backup with attachments | Not run | Depends on final entitlement policy |

## Localization Smoke Test

| Language | Result | Notes |
| --- | --- | --- |
| English | Not run | |
| Norwegian Bokmal | Not run | |
| Thai | Not run | |

## Final Decision

- [x] Ready for TestFlight.
- [ ] Ready for App Store submission.

Blocking issues:

- User manual still needs to be updated before App Store submission.

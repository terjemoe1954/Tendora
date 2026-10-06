# Tendora 1.3 Backup and Restore Test Log

Test date:

Build:

Devices:

- Source device:
- Restore device:

## Preflight

- [ ] App launches successfully.
- [ ] Settings opens successfully.
- [ ] Backup/Restore section is visible.
- [ ] Existing assets, tasks, completion records, and attachments are present before export.

## Export

| Test | Result | Notes |
| --- | --- | --- |
| Export backup with assets only | Not run | |
| Export backup with tasks | Not run | |
| Export backup with completed task history | Not run | |
| Export backup with photo attachment | Not run | |
| Export backup with document attachment | Not run | |
| Cancel export picker | Not run | Expect no data changes |
| Export while offline | Not run | Should work from local data |

## Restore

| Test | Result | Notes |
| --- | --- | --- |
| Import valid backup on same device | Not run | |
| Import valid backup on fresh install | Not run | |
| Confirm restore summary counts | Not run | Asset/task/attachment counts should match backup |
| Cancel restore confirmation | Not run | Existing data remains unchanged |
| Confirm restore replacement | Not run | Current data replaced by backup data |
| Attachments open after restore | Not run | |
| Completion history restored | Not run | |
| Reminders/settings restored correctly | Not run | Task reminder fields restored and local notifications rescheduled |

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

- [ ] Ready for TestFlight.
- [ ] Ready for App Store submission.

Blocking issues:

-

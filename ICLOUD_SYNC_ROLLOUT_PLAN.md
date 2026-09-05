# Tendora iCloud Sync Rollout Plan

Updated: September 5, 2026

This plan keeps iCloud sync separate from monetization until the data model, migration path, and attachment behavior are proven on real devices.

## Current State

- Tendora is live in the App Store.
- Local SwiftData persistence is working.
- The migration plan now has explicit historical schema snapshots:
  - `TendoraSchemaV1`: assets, tasks, completion records
  - `TendoraSchemaV2`: adds attachments
  - `TendoraSchemaV3`: current CloudKit-ready relationship shape
- The app no longer deletes the local store automatically on container creation failure.
- Settings includes a basic iCloud account availability check.
- The production SwiftData container is configured to use the private CloudKit database `iCloud.com.terjemoe.Tendora`.

## Xcode Setup

Do these steps in Xcode rather than editing `project.pbxproj` directly.

1. Select the Tendora project.
2. Select the Tendora app target.
3. Open Signing & Capabilities.
4. Add the iCloud capability.
5. Enable CloudKit.
6. Create or select this container:

   ```text
   iCloud.com.terjemoe.Tendora
   ```

7. Make sure the target uses `Tendora/Tendora.entitlements`.
8. Add Background Modes.
9. Enable Remote notifications.

## Implementation Sequence

### Step 1: Validate Capabilities

Run the app on a physical device signed into iCloud.

Expected Settings state:

```text
iCloud is available
```

If the app shows unavailable, check:

- the app target is using the entitlements file
- the CloudKit container exists in the developer account
- the device is signed into iCloud
- iCloud Drive is enabled
- the provisioning profile includes CloudKit

### Step 2: Verify SwiftData CloudKit Store

The production `ModelConfiguration` should use the private CloudKit database explicitly:

```swift
let configuration = ModelConfiguration(
    cloudKitDatabase: .private("iCloud.com.terjemoe.Tendora")
)
```

This is now implemented in `TendoraApp.swift`. If the app fails to launch on device, first verify entitlements and provisioning before changing the persistence code.

### Step 3: Development Schema

In a debug build, initialize the CloudKit development schema through SwiftData/Core Data tooling, then verify it in CloudKit Console.

Do not promote the schema to production until create, edit, delete, migration, and multi-device sync have been tested.

### Step 4: Two-Device Test Matrix

Use two physical devices signed into the same Apple ID.

Test these flows:

- fresh install on device A, create asset, confirm on device B
- create task on device A, edit due date on device B
- mark repeating task done on device A, confirm next due date on device B
- delete asset with tasks and attachments
- launch with airplane mode, create data, reconnect
- sign out of iCloud and confirm app keeps local data safe

### Step 5: Attachment Decision

Current attachments are local files in Application Support. SwiftData sync will sync metadata, not necessarily the file contents.

Before marketing this as full backup, choose one:

- store attachment file data in a CloudKit-compatible model field for small files
- move attachment files to iCloud Documents
- keep attachments local in the first sync release and say so clearly

Recommended: sync assets, tasks, and completion history first; treat attachment sync as a separate validation gate.

## Monetization Gate

Do not add StoreKit until the sync behavior above is stable.

Recommended first paid product:

```text
Tendora Pro - non-consumable lifetime unlock
```

Potential Pro features:

- iCloud sync
- backup/restore confidence
- higher asset/task limits, if you want a freemium boundary
- future document sync after attachment validation

Avoid subscriptions until there is a recurring service cost or recurring value that users can understand.

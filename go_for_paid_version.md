# Go For Paid Version

Use this file when Tendora is ready to continue from the current App Store version into a paid Premium version.

## Current State

- Tendora is already approved and released on the App Store.
- iCloud sync is working across iPhone and iPad.
- Photos and document attachments are working.
- The app has a Premium foundation in code, but payment is not active yet.
- Settings already has a Tendora Premium section.
- `PremiumEntitlementService` exists and is ready to be connected to StoreKit 2 later.

## Important Product Decision

Because Tendora is already released, do not suddenly remove existing functionality from current users without a deliberate transition plan.

Recommended approach:

- Keep current core features working for existing users.
- Use Premium for new or clearly expanded functionality.
- Avoid making current users feel that an app update took away something they already had.

## Suggested Premium Boundary

Good Premium candidates:

- Advanced iCloud sync controls.
- Backup and restore tools.
- Export features.
- Unlimited or expanded document-heavy usage.
- Future power-user features.

Be careful with:

- iCloud sync that existing users already rely on.
- Existing attachments and saved documents.
- Access to already-created data.

## App Store Connect Setup

Create products under the existing Tendora App Store Connect app.

Recommended product IDs:

- Monthly subscription: `tendora_premium_monthly`
- Yearly subscription: `tendora_premium_yearly`

Recommended product type:

- Auto-renewable subscription

Before coding StoreKit:

1. Confirm the products exist in App Store Connect.
2. Confirm pricing.
3. Confirm subscription group.
4. Confirm display names and descriptions.
5. Confirm localization for supported markets.
6. Confirm whether Family Sharing should be enabled.

## Technical Implementation Plan

1. Add StoreKit 2 support.
2. Fetch products using the product IDs from `PremiumEntitlementService`.
3. Add purchase flow.
4. Add restore purchases.
5. Listen for transaction updates.
6. Verify current entitlements on app launch.
7. Connect verified Premium status to `PremiumEntitlementService`.
8. Update Settings to show real subscription status.
9. Decide where Premium gates should appear in the UI.
10. Add user-friendly fallback states for offline, cancelled, pending, expired, and failed purchases.

## Existing User Strategy

Before submitting the paid update, decide one of these:

- Existing users keep current features, Premium applies only to new features.
- Existing users get a temporary grace period.
- Everyone uses the same Premium rules, but no existing data becomes inaccessible.

Recommended:

- Do not lock users out of their existing data.
- Do not block viewing or editing existing assets/tasks/documents.
- If limits are added, apply them to creating new items, not accessing old items.

## Required Test Plan

Test before App Store submission:

1. Fresh install with no purchase.
2. Upgrade from current App Store version with existing local data.
3. Upgrade from current App Store version with iCloud data.
4. iPhone and iPad sync after update.
5. Purchase monthly subscription.
6. Purchase yearly subscription.
7. Restore purchases.
8. Cancelled purchase.
9. Pending purchase.
10. Expired subscription.
11. Refund/revoked transaction.
12. Offline launch after previous purchase.
13. Offline launch without purchase.
14. Language switching with Premium UI.
15. App review account flow.

## App Review Notes

When submitting:

- Explain what Premium unlocks.
- Make sure restore purchases is visible.
- Make sure locked features explain why they are locked.
- Make sure the app is useful without purchase if it is listed as free.
- Avoid mentioning iCloud backup in a way that sounds like Apple system backup unless it is clearly Tendora data sync/backup.

## Next Codex Task

When ready, ask:

> Continue from `go_for_paid_version.md` and implement StoreKit 2 for Tendora Premium.


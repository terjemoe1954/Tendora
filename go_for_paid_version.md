# Go For Paid Version

Use this file when Tendora is ready to continue from the current App Store version into a paid Premium version.

## Current State

- Tendora is already approved and released on the App Store.
- Approved public baseline is version `1.1` build `4`.
- The next paid/Premium release target is version `1.2` build `5`.
- The Xcode target is set to `MARKETING_VERSION = 1.2` and `CURRENT_PROJECT_VERSION = 5`.
- Premium milestone tracker: `MILESTONE_1_2_PREMIUM.md`.
- Premium test log: `PREMIUM_TEST_LOG_1_2.md`.
- Premium App Store Connect setup guide: `APP_STORE_CONNECT_PREMIUM_SETUP.md`.
- iCloud sync is working across iPhone and iPad.
- Photos and document attachments are working.
- The app has a Premium foundation in code with StoreKit 2 purchase and restore handling.
- Settings has a Tendora Premium section with product rows, restore purchases, pending, loading, and error states.
- `PremiumEntitlementService` is connected to StoreKit 2 and updates local Premium entitlement from verified App Store transactions.
- Premium status is recomputed from StoreKit current entitlements after purchase, restore, transaction updates, and closing the manage-subscription sheet.
- Premium status is observable app state and is persisted to UserDefaults for launch/offline continuity.
- Pending purchases disable duplicate purchase/restore actions and clear when an active entitlement appears.
- Purchase buttons respect StoreKit payment availability and show a restriction message when purchases are disabled by the device or account.
- Premium purchase surfaces show recurring subscription disclosure text before purchase.
- Adding new photo/document attachments now requires Premium.
- Locked attachment add actions show a Premium cue before opening the upgrade sheet.
- Existing installs that had completed onboarding before this paid update keep new attachment creation unlocked as an early-supporter transition.
- In production, StoreKit `AppTransaction.originalAppVersion` also grants early-supporter attachment access to App Store customers whose original app build predates the paid attachment gate.
- Existing attachments remain accessible so existing user data is not locked away.
- Active Premium users can manage their subscription from Settings.
- Active Premium users see the current subscription period end date in Settings when StoreKit provides one.

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
- Adding new photos, receipts, manuals, and other document-heavy usage.
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

Before submitting Premium:

1. Confirm the products exist in App Store Connect.
2. Confirm pricing.
3. Confirm subscription group.
4. Confirm display names and descriptions.
5. Confirm localization for supported markets.
6. Confirm whether Family Sharing should be enabled.

## Technical Implementation Plan

1. StoreKit 2 support is implemented.
2. Products are fetched using the product IDs from `PremiumEntitlementService`.
3. Purchase flow is implemented.
4. Restore purchases is implemented.
5. Transaction updates are observed from app launch.
6. Current entitlements are verified on app launch.
7. Verified Premium status updates `PremiumEntitlementService`.
8. Settings shows real subscription status and purchase states.
9. Decide where Premium gates should appear in the UI.
10. Test and refine fallback states for offline, cancelled, pending, expired, and failed purchases.

## Existing User Strategy

Before submitting the paid update, decide one of these:

- Existing users keep current features, Premium applies only to new features.
- Existing users get a temporary grace period.
- Everyone uses the same Premium rules, but no existing data becomes inaccessible.

Recommended:

- Do not lock users out of their existing data.
- Do not block viewing or editing existing assets/tasks/documents.
- If limits are added, apply them to creating new items, not accessing old items.

Current implementation:

- New attachment creation is gated.
- Existing installs that had completed onboarding before the paid update keep attachment creation unlocked.
- App Store customers whose original app build predates build `5` keep attachment creation unlocked in production.
- Viewing, opening, sharing, and deleting existing attachments remains available.

## Required Test Plan

Test before App Store submission:

1. Fresh install with no purchase.
2. Upgrade from current App Store version with existing local data.
3. Upgrade from current App Store version with iCloud data.
4. iPhone and iPad sync after update.
5. Purchase monthly subscription.
6. Purchase yearly subscription.
7. Restore purchases.
8. Manage subscription sheet.
9. Cancelled purchase.
10. Pending purchase.
11. Purchases disabled by Screen Time or device management.
12. Expired subscription.
13. Refund/revoked transaction.
14. Offline launch after previous purchase.
15. Offline launch without purchase.
16. Language switching with Premium UI.
17. App review account flow.

## App Review Notes

When submitting:

- Explain what Premium unlocks.
- Make sure restore purchases is visible.
- Make sure manage subscription is visible for active subscribers.
- Make sure locked features explain why they are locked.
- Make sure the app is useful without purchase if it is listed as free.
- Avoid mentioning iCloud backup in a way that sounds like Apple system backup unless it is clearly Tendora data sync/backup.

## Next Codex Task

When ready, ask:

> Continue from `go_for_paid_version.md` and add the Premium feature gates after StoreKit sandbox testing passes.

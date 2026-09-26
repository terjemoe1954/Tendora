# Next Milestone: Paid Version

## Goal

Prepare Tendora for a paid version with StoreKit 2 purchase handling in place, while keeping the actual Premium feature boundary conservative until App Store Connect products and upgrade behavior are fully tested.

## Recommended Premium Offer

- Product type: Auto-renewable subscription
- Monthly product ID: `tendora_premium_monthly`
- Yearly product ID: `tendora_premium_yearly`
- Suggested positioning for version `1.2`: Tendora Premium unlocks adding new photos and document attachments.

## Release Target

- Approved public baseline: version `1.1` build `4`.
- Next paid/Premium release target: version `1.2` build `5`.
- The project target is set to `MARKETING_VERSION = 1.2` and `CURRENT_PROJECT_VERSION = 5`.
- The early-supporter attachment cutoff is build `5`, so users whose original App Store install predates build `5` can keep attachment creation unlocked.
- Milestone tracker: `MILESTONE_1_2_PREMIUM.md`.
- Test log: `PREMIUM_TEST_LOG_1_2.md`.
- App Store Connect setup guide: `APP_STORE_CONNECT_PREMIUM_SETUP.md`.

## Current Code Readiness

- `PremiumEntitlementService` centralizes whether Premium is unlocked.
- `PremiumEntitlementService` fetches StoreKit products, verifies transactions, listens for transaction updates, restores purchases, and refreshes current entitlements on launch.
- Premium entitlement is recomputed from StoreKit current entitlements after purchase, restore, transaction updates, and closing the manage-subscription sheet.
- Premium entitlement is stored as observable app state and persisted to UserDefaults, so Settings and gated UI update immediately after entitlement changes.
- Pending purchases disable duplicate purchase/restore actions and clear automatically when StoreKit later reports an active entitlement.
- Purchase buttons respect StoreKit payment availability and explain when purchases are disabled by the device or account.
- Premium purchase surfaces show recurring subscription disclosure text before purchase.
- Settings has a Tendora Premium section with product purchase buttons, restore purchases, loading, pending, and error states.
- Creating new photo/document attachments is gated behind Premium with an upgrade sheet.
- Attachment add actions show a visible Premium cue when locked.
- Existing installs that had completed onboarding before this paid update keep new attachment creation unlocked as an early-supporter transition.
- In production, StoreKit `AppTransaction.originalAppVersion` also grants early-supporter attachment access to App Store customers whose original app build predates the paid attachment gate.
- Existing attachments remain visible, openable, shareable, and deletable.
- Active Premium users can open Apple's manage-subscription sheet from Settings.
- Active Premium users see the current subscription period end date in Settings when StoreKit provides one.
- iCloud sync remains available in version `1.2`.

## Version 1.2 Paid Boundary

- Free: core asset and task tracking.
- Free: existing attachments remain visible, openable, shareable, and deletable.
- Free: iCloud sync remains available in the current build.
- Premium: adding new photos and document attachments.

## Future Premium Candidates

- Advanced backup controls.
- Export and restore tools.
- Shared household or collaboration tools.

## Before Enabling Purchases

1. Create subscription products in App Store Connect using the product IDs above.
2. Confirm StoreKit products load from App Store Connect or a StoreKit configuration file.
3. Decide whether existing App Store users should get a grace period or early-user unlock.
4. Decide where Premium gates should appear in the UI.
5. Test purchase, restore, manage subscription, expired subscription, refund/revocation, offline launch, pending purchase, and family sharing behavior.

## Release Notes Reminder

When Premium is activated, App Store copy should clearly explain what remains free and what requires Premium.

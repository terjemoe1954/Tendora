# Next Milestone: Paid Version

## Goal

Prepare Tendora for a paid version without enabling purchases yet.

## Recommended Premium Offer

- Product type: Auto-renewable subscription
- Monthly product ID: `tendora_premium_monthly`
- Yearly product ID: `tendora_premium_yearly`
- Suggested positioning: Tendora Premium unlocks sync, backup, and document-heavy usage.

## Current Code Readiness

- `PremiumEntitlementService` centralizes whether Premium is unlocked.
- Settings has a Tendora Premium section.
- The upgrade button is intentionally disabled until StoreKit 2 is added.
- iCloud sync remains technically available in the current build while the paid boundary is prepared.

## Suggested Paid Boundary

- Free: core asset and task tracking.
- Premium: iCloud sync across devices.
- Premium: cloud backup for Tendora data.
- Premium: photos and document attachments.
- Premium: future export and restore tools.

## Before Enabling Purchases

1. Create subscription products in App Store Connect using the product IDs above.
2. Add StoreKit 2 purchase and transaction verification.
3. Connect verified transactions to `PremiumEntitlementService`.
4. Decide whether existing App Store users should get a grace period or early-user unlock.
5. Test purchase, restore, expired subscription, refund, offline launch, and family sharing behavior.

## Release Notes Reminder

When Premium is activated, App Store copy should clearly explain what remains free and what requires Premium.

# Tendora Milestone 1.2: Premium Foundation

Updated: September 26, 2026

## Goal

Prepare Tendora version `1.2` build `5` for a conservative paid/Premium release while keeping version `1.1` build `4` users protected.

This milestone focuses on StoreKit 2 purchase readiness, clear Premium UI, and a low-risk feature boundary: core asset and task tracking stays free, while creating new photo/document attachments becomes a Premium feature for fresh installs.

## Current State

- Version `1.1` build `4` is approved on the App Store.
- The Xcode target is set to version `1.2` build `5`.
- `PremiumEntitlementService` manages StoreKit 2 product loading, purchases, restore, transaction updates, current entitlements, and local entitlement persistence.
- Settings includes a Tendora Premium section with product rows, restore purchases, pending/loading/error states, active status, manage subscription, and current subscription period end date when available.
- New attachment creation is gated behind Premium in asset details, task details, and the attachment import form.
- Existing attachments remain visible, openable, shareable, and deletable without Premium.
- Existing installs that completed onboarding before this update keep attachment creation unlocked as an early-supporter transition.
- In production, App Store customers whose original app build predates build `5` can also keep attachment creation unlocked through `AppTransaction.originalAppVersion`.
- `TendoraPremium.storekit` provides local Xcode StoreKit testing products for the monthly and yearly Premium subscriptions.

## Premium Products

| Product | Type | Product ID | Status |
| --- | --- | --- | --- |
| Tendora Premium Monthly | Auto-renewable subscription | `tendora_premium_monthly` | Create in App Store Connect |
| Tendora Premium Yearly | Auto-renewable subscription | `tendora_premium_yearly` | Create in App Store Connect |

Use one subscription group for both products.

App Store Connect setup guide: `APP_STORE_CONNECT_PREMIUM_SETUP.md`.

## Scope

Include:

- StoreKit 2 product load, purchase, restore, and entitlement refresh.
- Premium state visible in Settings.
- Upgrade sheet from locked attachment creation entry points.
- Recurring subscription disclosure before purchase.
- Payment unavailable and pending purchase messaging.
- Early-supporter attachment creation transition.
- App Store Connect subscription setup and review notes.
- Premium release metadata for version `1.2` build `5`.

Do not include yet:

- Locking existing attachments.
- Locking core asset or task creation.
- Locking existing iCloud sync behavior for current users.
- Family sharing assumptions until App Store Connect product settings are final.
- Shared household/collaboration features.

## Release Checklist

- [x] Set project version to `1.2`.
- [x] Set project build to `5`.
- [x] Implement Premium entitlement service.
- [x] Add Settings Premium section.
- [x] Add reusable Premium upgrade sheet.
- [x] Gate new attachment creation.
- [x] Preserve access to existing attachments.
- [x] Add early-supporter attachment creation transition.
- [x] Add App Store metadata and review-note drafts.
- [x] Show a clear unavailable/reload state when StoreKit returns no or incomplete Premium products.
- [x] Show a clear no-Premium-found message when restore succeeds but no active subscription exists.
- [x] Unlock Premium only from active auto-renewable subscription transactions.
- [x] Add local StoreKit configuration for Xcode purchase testing.
- [ ] Create subscription group in App Store Connect.
- [ ] Create monthly subscription product.
- [ ] Create yearly subscription product.
- [ ] Confirm product IDs exactly match the app.
- [ ] Confirm pricing, duration, localization, and review screenshots.
- [ ] Add the subscription group and at least one Premium subscription to the version `1.2` App Review submission.
- [ ] Run StoreKit sandbox/TestFlight purchase tests.
- [ ] Run upgrade-from-1.1 early-supporter test.
- [ ] Archive and upload build `1.2 (5)`.

## Test Log

Use `PREMIUM_TEST_LOG_1_2.md` to record purchase, restore, entitlement, upgrade, and App Review smoke-test results.

## Success Criteria

This milestone is complete when:

- Products load from App Store Connect sandbox/TestFlight or the local `TendoraPremium.storekit` test configuration.
- Monthly and yearly subscription purchases unlock Premium.
- Restore purchases unlocks Premium for an existing active subscriber.
- Manage subscription opens for active subscribers.
- Pending, failed, cancelled, restricted, expired, refunded, and offline states behave clearly.
- Fresh installs cannot create new attachments without Premium.
- Existing attachments stay accessible without Premium.
- Eligible existing users keep attachment creation unlocked after upgrading from build `4` to build `5`.
- App Store Connect metadata accurately explains Free, Premium, and early-supporter behavior.

## Next Milestone After This

After 1.2 Premium is validated, consider:

- Export and restore tools.
- Advanced backup controls.
- More Premium value beyond attachment creation.
- Shared household or collaboration design.

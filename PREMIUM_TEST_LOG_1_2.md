# Tendora 1.2 Premium Test Log

Test date:

Build: `1.2 (5)`

Devices:

- iPhone:
- iPad:

Apple ID / sandbox tester:

Local StoreKit configuration:

- [ ] Xcode Run scheme uses `TendoraPremium.storekit` for local StoreKit tests.

## Preflight

- [ ] App is installed as build `1.2 (5)`.
- [ ] App launches without storage unavailable screen.
- [ ] Settings opens successfully.
- [ ] Tendora Premium section appears in Settings.
- [ ] Monthly product row loads.
- [ ] Yearly product row loads.
- [ ] Monthly product row appears before yearly product row.
- [ ] Restore Purchases button is visible.
- [ ] Recurring subscription disclosure is visible before purchase and mentions monthly/yearly renewal based on selected plan.
- [ ] Premium UI only promises adding new attachments for version `1.2`.
- [ ] App remains useful without purchase: assets and tasks can be created.

## Fresh Install Without Purchase

| Test | Result | Notes |
| --- | --- | --- |
| Create asset | Not run | |
| Create task | Not run | |
| Try adding asset photo attachment | Not run | Expect Premium upgrade sheet |
| Try adding asset file attachment | Not run | Expect Premium upgrade sheet |
| Try adding task photo attachment | Not run | Expect Premium upgrade sheet |
| Try adding task file attachment | Not run | Expect Premium upgrade sheet |
| Dismiss upgrade sheet | Not run | User returns to detail screen |

## Purchases

| Test | Result | Notes |
| --- | --- | --- |
| Purchase monthly Premium | Not run | |
| Confirm Premium active in Settings | Not run | |
| Confirm Premium unlock comes from active subscription transaction | Not run | Product must be auto-renewable subscription, not non-consumable |
| Confirm current period end date appears if StoreKit provides one | Not run | |
| Confirm purchase offer rows are hidden after Premium is active | Not run | Settings should show status, restore, and manage subscription instead |
| Confirm purchases-disabled warning is hidden after Premium is active | Not run | Payment restriction warning is only useful before purchase |
| Add new photo attachment after purchase | Not run | |
| Add new file attachment after purchase | Not run | |
| Upgrade sheet dismisses when Premium is already active or becomes active | Not run | Applies after purchase, restore, or entitlement refresh |
| Manage subscription sheet opens | Not run | |
| Purchase yearly Premium with fresh tester | Not run | |
| Confirm yearly Premium active in Settings | Not run | |

## Restore

| Test | Result | Notes |
| --- | --- | --- |
| Tap Restore Purchases with no active subscription | Not run | Expect "No Premium Found" message |
| Delete/reinstall app with active subscription | Not run | |
| Tap Restore Purchases | Not run | |
| Confirm Premium active after restore | Not run | |
| Confirm attachment creation unlocks after restore | Not run | |

## Transaction States

| Test | Result | Notes |
| --- | --- | --- |
| App Store returns no Premium products | Not run | Expect inline unavailable message and reload button |
| App Store returns only one Premium product | Not run | Expect inline unavailable message and reload button |
| Cancel purchase sheet | Not run | Expect no Premium unlock, no scary error, and no stale restore/product message |
| Pending purchase | Not run | Expect pending message and disabled duplicate actions |
| Purchases disabled by device/account restrictions | Not run | Expect unavailable message |
| Expired subscription | Not run | Expect Premium inactive |
| Refunded/revoked transaction | Not run | Expect Premium inactive after entitlement refresh |
| Offline launch after previous purchase | Not run | Expect last known Premium status, then refresh later |
| Offline launch without purchase | Not run | Expect locked attachment creation |

## Existing User Upgrade

Use an install that completed onboarding on version `1.1` build `4`, then upgrade to `1.2` build `5`.

| Test | Result | Notes |
| --- | --- | --- |
| Existing assets remain visible | Not run | |
| Existing tasks remain visible | Not run | |
| Existing attachments open | Not run | |
| Existing attachments share | Not run | |
| Existing attachments delete | Not run | |
| New attachment creation remains unlocked for early supporter | Not run | |
| Settings shows early-supporter note when applicable | Not run | |

## Localization Smoke Test

| Language | Result | Notes |
| --- | --- | --- |
| English | Not run | |
| Norwegian Bokmal | Not run | |
| Thai | Not run | |

## App Review Smoke Test

| Test | Result | Notes |
| --- | --- | --- |
| Reviewer can use app without purchase | Not run | |
| Locked attachment feature explains Premium | Not run | |
| Restore purchases is easy to find | Not run | |
| Manage subscription is available for active subscriber | Not run | |
| Review note matches actual app behavior | Not run | |

## Final Decision

- [ ] Ready for TestFlight purchase test.
- [ ] Ready for App Store Connect metadata update.
- [ ] Ready for App Store submission.

Blocking issues:

-

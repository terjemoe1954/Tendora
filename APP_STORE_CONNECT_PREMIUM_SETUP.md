# Tendora Premium App Store Connect Setup

Updated: September 26, 2026

Use this when configuring Tendora version `1.2` build `5` for the Premium subscription release.

## Release Context

- Approved baseline: version `1.1` build `4`.
- Premium target: version `1.2` build `5`.
- Bundle ID: `com.terjemoe.Tendora`.
- Premium attachment gate starts at build `5`.
- Existing App Store users whose original iOS app build predates build `5` can keep attachment creation unlocked.

## Subscription Group

Create one auto-renewable subscription group:

| Field | Suggested Value |
| --- | --- |
| Reference Name | `Tendora Premium` |
| App Store Display Name | `Tendora Premium` |
| Purpose | Unlock Premium attachment creation and future Premium tools |

Keep both subscriptions in this same group so users can switch between monthly and yearly plans.

## Subscription Products

| Product | Duration | Product ID | Reference Name | Display Name |
| --- | --- | --- | --- | --- |
| Monthly | 1 month | `tendora_premium_monthly` | `Tendora Premium Monthly` | `Tendora Premium Monthly` |
| Yearly | 1 year | `tendora_premium_yearly` | `Tendora Premium Yearly` | `Tendora Premium Yearly` |

Configure both products as auto-renewable subscriptions. The app only unlocks Premium from active subscription transactions with a future expiration date, so do not configure these product IDs as non-consumable or consumable purchases.

The in-app Premium disclosure should remain visible before purchase and explain that subscriptions renew monthly or yearly based on the selected plan until cancelled.

Recommended product description:

```text
Unlock adding new photos and document attachments to your assets and tasks.
```

Avoid describing Premium as shared family data, collaboration, or Apple system backup. Tendora syncs user-created app data through the user's private iCloud account when iCloud is available.

## Pricing

Choose pricing in App Store Connect before testing. Suggested structure:

| Product | Pricing Note |
| --- | --- |
| Monthly | Lower entry price |
| Yearly | Better value than 12 monthly payments |

Do not add introductory offers, offer codes, win-back offers, or promotional offers for the first Premium submission unless you plan to test those flows too.

## App Review Information

Use this review note:

```text
Tendora is a maintenance tracking app for user-created assets, tasks, reminders, and attachments. Version 1.2 build 5 adds Tendora Premium. Reviewers can create assets and add tasks with reminder settings without purchasing. Adding new photo or document attachments is a Tendora Premium feature for fresh installs; existing attachments remain accessible. Eligible users whose original App Store install predates build 5 may keep attachment creation unlocked as an early-supporter transition. Premium can be purchased, restored, and managed from Settings. If testing on multiple devices signed into the same iCloud account, data should sync through the user's private iCloud database. Notification permissions are optional and are used only for maintenance reminders created by the user.
```

Attach a review screenshot that shows the Tendora Premium section in Settings after the products load.

## Sandbox Testing Setup

For quick local testing before App Store Connect products are ready, edit the Tendora Run scheme in Xcode and select `TendoraPremium.storekit` as the StoreKit Configuration. This uses Xcode-simulated transactions and should not replace sandbox or TestFlight testing before submission.

1. Create a Sandbox Apple Account in App Store Connect.
2. On the test device, sign in with the Sandbox Apple Account under the developer sandbox account settings.
3. Install a development build or TestFlight build of Tendora `1.2 (5)`.
4. Open Settings in Tendora and confirm both product rows load.
5. Run the tests in `PREMIUM_TEST_LOG_1_2.md`.

Apple notes that App Store Connect product metadata can take time to appear in sandbox. If products do not load immediately, wait and retry before changing app code.

## Required Tests Before Submission

| Test | Required |
| --- | --- |
| Monthly subscription purchase unlocks Premium | Yes |
| Yearly subscription purchase unlocks Premium | Yes |
| Restore purchases unlocks Premium | Yes |
| Restore purchases with no active subscription shows a clear no-Premium-found message | Yes |
| Manage subscription opens for active subscriber | Yes |
| Fresh install without purchase cannot add new attachments | Yes |
| App remains useful without purchase | Yes |
| Existing attachments remain accessible without purchase | Yes |
| Upgrade from `1.1 (4)` keeps eligible early-supporter attachment creation | Yes |
| Cancel purchase leaves Premium locked without a scary error | Yes |
| Pending purchase shows pending state | Yes |
| Product load failure shows retry/error state | Yes |
| Empty or incomplete product response shows inline unavailable message and reload button | Yes |
| English, Norwegian, and Thai Premium UI fit on device | Yes |

## If Products Do Not Load

Check these first:

- Product IDs exactly match `tendora_premium_monthly` and `tendora_premium_yearly`.
- Products are in the same app record as bundle ID `com.terjemoe.Tendora`.
- Products have required localization and pricing.
- Paid Apps agreement, tax, and banking details are complete if App Store Connect requires them.
- Test device is using a sandbox account for development/TestFlight purchases.
- Product metadata has had time to propagate.

## Submission Checklist

- [ ] Subscription group created.
- [ ] Monthly product created with exact product ID.
- [ ] Yearly product created with exact product ID.
- [ ] Pricing selected.
- [ ] Product localizations added.
- [ ] Review screenshot added.
- [ ] App Review note added.
- [ ] Sandbox tester created.
- [ ] `PREMIUM_TEST_LOG_1_2.md` completed.
- [ ] Archive/upload version `1.2` build `5`.
- [ ] Add the subscription group and at least one Premium subscription to the same App Review submission as version `1.2` build `5`.

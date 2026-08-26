# Tendora App Store Prep

Updated: August 24, 2026

## Current Technical Status

- App builds successfully in Xcode.
- Local SwiftData storage is working.
- Assets, tasks, reminders, documents, and attachment flows are implemented.
- Settings screen is cleaned up for release use.
- Localization cleanup has been done.

## App Icon Status

- `AppIcon.appiconset` exists.
- A `1024x1024` marketing icon file is present:
  - `Tendora/Tendora/Assets.xcassets/AppIcon.appiconset/Tendora_icon.png`
- Xcode currently reports no icon or asset warnings during build.

## Remaining App Store Work

## 1. Product/Legal Information

- Prepare a real privacy policy URL.
- Prepare support/contact information.
- Decide whether terms of use are needed as a separate URL.
- Confirm the seller/display name you want shown in App Store Connect.

## 2. App Store Metadata

- App name
- Subtitle
- Keywords
- Promotional text
- Description
- What’s New text for first release
- Category selection
- Age rating answers
- Privacy nutrition label answers

## 3. Visual Assets

- Final app icon review
- iPhone screenshots
- Optional iPad screenshots if you support iPad
- Optional App Preview video

## 4. Release Validation

- Test onboarding on fresh install
- Test create/edit/delete asset flows
- Test create/edit/delete task flows
- Test reminder permission flow
- Test attachment import/open/share/delete
- Test calendar and documents screens with realistic data
- Test localization presentation for `en`, `nb`, and `th`
- Test archive/release build, not only debug build

## 5. App Store Connect Setup

- Create app record in App Store Connect
- Fill metadata
- Upload screenshots
- Upload privacy policy/support URLs
- Upload build via Xcode Organizer
- Add review notes for the reviewer if needed

## Recommended Next Step

The next highest-value step is:

1. Prepare the App Store metadata text.

That can be done before final submission and does not require more code changes.

## Suggested Restart Prompt

```text
Continue Tendora from PROJECT_STATUS.md and APP_STORE_PREP.md.
Help me prepare the next App Store submission step.
```

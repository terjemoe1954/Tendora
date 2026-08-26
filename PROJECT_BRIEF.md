# Tendora — Project Brief for Codex

## 1. Product Summary

**App name:** Tendora

**Working App Store name:** Tendora – Home & Asset Care

**Tagline:** Take care of what you own.

Tendora is an iOS app that helps people organize and maintain the important things they own: homes, cars, cabins, boats, and other assets.

The core promise is simple:

> Tendora remembers maintenance, service, renewals, documents, and upcoming tasks so the user does not have to.

The first release should be focused, polished, and easy to understand. Avoid feature creep.

---

## 2. Primary Goal

Build a clean SwiftUI iPhone app where a user can:

1. Add an asset.
2. Add maintenance tasks for that asset.
3. Set due dates or recurrence.
4. Receive local reminders.
5. See upcoming tasks in one dashboard.
6. Attach photos or documents to tasks/assets.
7. Mark tasks as completed.
8. View maintenance history.

The app should work locally without requiring a server for the MVP.

---

## 3. Target Users

Primary users:

- Homeowners
- Car owners
- Cabin/cottage owners
- Boat owners
- People who want one place to track maintenance and important recurring tasks

The app should feel useful even if the user owns only one asset.

---

## 4. MVP Scope — Version 1.0

### Include

- SwiftUI interface
- SwiftData persistence
- Asset management
- Task management
- Due dates
- Recurring tasks
- Local notifications
- Dashboard
- Calendar/upcoming view
- Photos/documents
- Completion history
- Settings
- Basic onboarding
- Free vs Pro entitlement structure prepared for StoreKit 2

### Do not include yet

- AI scanning
- OCR
- Cloud backend
- Shared family accounts
- Web app
- Android app
- Complex analytics
- Social features
- Chatbot
- Marketplace
- Repair provider directory

Keep the first release small and reliable.

---

## 5. Supported Asset Types

Use an enum for asset type.

Initial asset types:

- Home
- Cabin / Holiday Home
- Car
- Boat
- Other

Future types may include:

- Motorcycle
- RV / Motorhome
- Bicycle
- Rental property
- Garden equipment
- Electronics

Do not hard-code the UI in a way that prevents adding more asset types later.

---

## 6. Main Navigation

Use a SwiftUI `TabView`.

Recommended tabs:

1. **Home**
2. **Calendar**
3. **Add**
4. **Documents**
5. **Settings**

The Add tab can present a sheet or full-screen flow rather than behaving like a normal tab.

---

## 7. Main Screens

### 7.1 Onboarding

Keep onboarding short.

Suggested pages:

**Page 1**
Tendora  
Take care of what you own.

**Page 2**
Smart reminders  
Stay ahead of service, inspections, renewals, and maintenance.

**Page 3**
Everything in one place  
Keep tasks, photos, receipts, manuals, and history together.

Final CTA:

**Get Started**

Do not require account creation in Version 1.0.

---

### 7.2 Dashboard / Home

This is the most important screen.

Header:

- Tendora
- Optional greeting
- Plus button

Sections:

#### My Assets

Show asset cards.

Example:

**My Home**  
7 tasks • 2 coming soon

**Volvo XC60**  
Service in 43 days

**Cabin**  
5 tasks • Next: Check chimney

**Boat**  
Winter storage • Oct 15

Each card should show:

- Asset icon or image
- Asset name
- Brief status
- Chevron
- Optional warning badge

#### Upcoming

Show upcoming tasks sorted by due date.

Example:

**Car service**  
Volvo XC60  
Due Sep 14, 2026

**Smoke detector check**  
My Home  
Due Nov 15, 2026

Use calm status indicators:

- Normal
- Due soon
- Overdue

---

### 7.3 Add Asset

Title:

**Add Asset**

Prompt:

**What do you want to add?**

Options:

- House
- Cabin / Holiday Home
- Car
- Boat
- Other

After selecting a type, show the relevant form.

Common fields:

- Name
- Asset type
- Photo
- Notes

Car-specific optional fields:

- Make
- Model
- Year
- Fuel type
- Current odometer
- Registration number

Boat-specific optional fields:

- Make
- Model
- Year

House/cabin optional fields:

- Address
- Year built

Avoid asking for too much information during setup.

---

### 7.4 Asset Detail

Header:

- Asset image
- Asset name
- Important metadata
- Edit button

Use sections or a segmented control:

- Tasks
- Documents
- History
- Info

Primary action:

**Add Task**

Example car task list:

- Car service
- Tire change
- EU inspection
- Insurance renewal

Example home task list:

- Heat pump service
- Smoke detector check
- Water heater inspection
- Change ventilation filter

---

### 7.5 Add / Edit Task

Fields:

- Task title
- Asset
- Due date
- Repeat rule
- Reminder timing
- Notes
- Photos
- Documents

Optional asset-specific field:

- Odometer due value

Repeat options should initially support:

- Never
- Weekly
- Monthly
- Every 3 months
- Every 6 months
- Yearly
- Every 2 years
- Custom interval

For car-related tasks, also support recurrence by odometer later. Structure the model so this can be added without a rewrite.

Primary button:

**Save Task**

---

### 7.6 Task Detail

Display:

- Task title
- Asset
- Due date
- Repeat rule
- Reminder
- Notes
- Attachments
- Completion history

Primary CTA:

**Mark as Done**

When marking complete:

1. Store a completion record.
2. If recurring, calculate the next due date.
3. Schedule the next notification.
4. Keep the old completion visible in history.

---

### 7.7 Calendar

Show:

- Month calendar
- Days with tasks
- Upcoming task list beneath the calendar

Tapping a day filters tasks for that day.

Do not over-engineer the first calendar implementation.

---

### 7.8 Documents

A simple list of saved attachments grouped by asset.

Types may include:

- Receipt
- Invoice
- Manual
- Warranty
- Insurance
- Service record
- Photo
- Other

Version 1.0 can use local file references or app-managed storage.

---

### 7.9 Settings

Include:

- Notifications
- Default reminder timing
- Appearance
- Tendora Pro
- Restore Purchases
- Privacy Policy
- Terms
- About Tendora

Later:

- iCloud
- Export
- Family sharing

---

## 8. Suggested SwiftData Models

These names are suggestions. Codex may improve them if there is a strong architectural reason.

### Asset

Suggested properties:

- `id: UUID`
- `name: String`
- `type: AssetType`
- `createdAt: Date`
- `notes: String?`
- `photoData: Data?`
- `make: String?`
- `model: String?`
- `year: Int?`
- `fuelType: String?`
- `odometer: Double?`
- `registrationNumber: String?`
- `address: String?`

Relationships:

- tasks
- attachments

---

### MaintenanceTask

Suggested properties:

- `id: UUID`
- `title: String`
- `createdAt: Date`
- `dueDate: Date?`
- `notes: String?`
- `isCompleted: Bool`
- `repeatRule: RepeatRule`
- `customRepeatValue: Int?`
- `customRepeatUnit: RepeatUnit?`
- `reminderEnabled: Bool`
- `reminderOffset: ReminderOffset`
- `odometerDue: Double?`

Relationships:

- asset
- attachments
- completionRecords

---

### CompletionRecord

Suggested properties:

- `id: UUID`
- `completedAt: Date`
- `notes: String?`
- `odometerAtCompletion: Double?`

Relationship:

- task

---

### Attachment

Suggested properties:

- `id: UUID`
- `createdAt: Date`
- `type: AttachmentType`
- `displayName: String`
- `fileName: String?`
- `imageData: Data?`

Relationships:

- asset
- task

---

## 9. Suggested Enums

Create Codable enums where appropriate.

### AssetType

- home
- cabin
- car
- boat
- other

### RepeatRule

- never
- weekly
- monthly
- threeMonths
- sixMonths
- yearly
- twoYears
- custom

### RepeatUnit

- days
- weeks
- months
- years

### AttachmentType

- photo
- receipt
- invoice
- manual
- warranty
- insurance
- serviceRecord
- other

### ReminderOffset

Suggested initial values:

- sameDay
- oneDayBefore
- threeDaysBefore
- oneWeekBefore
- twoWeeksBefore
- oneMonthBefore

---

## 10. Notifications

Use `UserNotifications`.

Create a dedicated service such as:

`NotificationManager`

Responsibilities:

- Request permission
- Schedule notifications
- Update notifications
- Cancel notifications
- Reschedule recurring task notifications

Notification example:

**Tendora Reminder**

Car service for Volvo XC60 is due in 7 days.

Use stable notification identifiers derived from task IDs.

Do not put notification scheduling logic directly inside SwiftUI views.

---

## 11. Architecture

Use a straightforward architecture suitable for a solo-developed SwiftUI application.

Preferred structure:

```text
Tendora/
├── App/
│   └── TendoraApp.swift
├── Models/
│   ├── Asset.swift
│   ├── MaintenanceTask.swift
│   ├── CompletionRecord.swift
│   ├── Attachment.swift
│   └── Enums.swift
├── Views/
│   ├── Onboarding/
│   ├── Home/
│   ├── Assets/
│   ├── Tasks/
│   ├── Calendar/
│   ├── Documents/
│   ├── Settings/
│   └── Components/
├── Services/
│   ├── NotificationManager.swift
│   ├── StoreManager.swift
│   └── AttachmentManager.swift
├── Utilities/
│   ├── DateHelpers.swift
│   └── Constants.swift
└── Resources/
```

Avoid unnecessary abstraction.

Do not introduce a networking layer until the product actually needs networking.

---

## 12. SwiftUI Coding Style

Important instructions for Codex:

- Use modern SwiftUI APIs.
- Target the current project deployment target.
- Use SwiftData rather than Core Data.
- Prefer native Apple controls.
- Keep views small.
- Extract reusable UI components.
- Keep business logic out of views where practical.
- Use `NavigationStack`.
- Use `@Query` where appropriate.
- Use Swift concurrency where needed.
- Avoid third-party dependencies for MVP.
- Keep accessibility in mind.
- Support Dynamic Type.
- Use SF Symbols where possible.

Do not use deprecated APIs if a modern equivalent exists.

---

## 13. Visual Direction

Tendora should look calm, trustworthy, modern, and premium.

The app should feel like an Apple-quality utility rather than a complicated maintenance database.

### General Style

- Lots of white space
- Rounded cards
- Soft shadows only where useful
- Large clear typography
- Simple icons
- Minimal visual clutter
- Friendly, reassuring language

### Color Direction

Primary brand direction:

- Deep navy / blue
- White
- Soft blue backgrounds
- Small warm yellow accent for attention or Pro

Status colors can follow system conventions:

- Normal / complete
- Due soon
- Overdue

Prefer semantic/system colors where practical so dark mode works correctly.

---

## 14. Brand

### Name

**Tendora**

### Tagline

**Take care of what you own.**

Alternative marketing line:

**The simple way to organize and never forget important maintenance, service, and renewals.**

### Brand Personality

Tendora should feel:

- Helpful
- Calm
- Reliable
- Organized
- Modern
- Not overly technical

Avoid fear-based messaging.

---

## 15. Free and Pro Model

Build the app architecture so StoreKit 2 can be added cleanly.

Possible Free plan:

- 1 asset
- Up to 10 active tasks
- Basic reminders

Possible Pro plan:

- Unlimited assets
- Unlimited tasks
- Photos and documents
- Advanced reminders
- iCloud sync in a later version
- PDF export in a later version
- Priority features

Possible pricing direction:

- Monthly
- Yearly
- Lifetime

Pricing is not final and must not be hard-coded throughout the UI.

Use a centralized product configuration.

---

## 16. StoreKit

Create a dedicated:

`StoreManager`

Do not implement fake purchase state throughout the app.

Use StoreKit 2 when payments are introduced.

Suggested product identifiers may eventually be:

- `tendora.pro.monthly`
- `tendora.pro.yearly`
- `tendora.pro.lifetime`

Treat these as placeholders until App Store Connect products are created.

---

## 17. Suggested Smart Defaults

When an asset is created, Tendora can suggest common tasks.

Do not automatically create everything without user approval.

### Home suggestions

- Smoke detector check
- Heat pump service
- Ventilation filter
- Water heater inspection
- Gutter cleaning
- Insurance renewal

### Car suggestions

- Service
- Tire change
- EU inspection
- Insurance renewal

### Cabin suggestions

- Chimney inspection
- Smoke detector check
- Shut off water
- Exterior inspection
- Insurance renewal

### Boat suggestions

- Winter storage
- Engine service
- Battery check
- Insurance renewal
- Safety equipment inspection

These suggestions can initially be static data in the app.

---

## 18. Privacy

Privacy should be simple for MVP.

The app should not collect personal information on a server because the MVP does not need a server.

Use local storage unless the user explicitly uses an Apple-provided cloud feature in a future version.

If photos/documents are used:

- Explain why photo access is needed.
- Request permissions only when required.
- Do not ask for unnecessary permissions.

---

## 19. Development Priorities

Build in this order.

### Phase 1 — Foundation

1. SwiftData models
2. Main TabView
3. Dashboard shell
4. Add Asset flow
5. Asset detail screen

### Phase 2 — Tasks

6. Add Task flow
7. Task detail
8. Mark as completed
9. Recurring task calculation
10. Upcoming task sorting

### Phase 3 — Reminders

11. Notification permission flow
12. Schedule reminders
13. Cancel/update reminders

### Phase 4 — Documents

14. Add photos
15. Add documents
16. Attachment list

### Phase 5 — Polish

17. Onboarding
18. Empty states
19. Error handling
20. Dark mode
21. Accessibility
22. App icon / branding
23. Pro screen shell

Do not jump to StoreKit, AI, or cloud features before the basic task workflow is solid.

---

## 20. Important UX Rules

The user should be able to add their first asset quickly.

Avoid long forms.

Use sensible defaults.

Important actions should require as few taps as practical.

Always provide good empty states.

Examples:

### Empty dashboard

**Take care of the things you own**

Add your home, car, cabin, boat, or anything else you want Tendora to help you remember.

Button:

**Add Your First Asset**

### No tasks

**Nothing to remember yet**

Add a maintenance task and Tendora will remind you when it is time.

Button:

**Add Task**

---

## 21. Future Features — Not for MVP

Keep these in mind when designing the data model, but do not build them yet:

- AI receipt scanning
- AI maintenance suggestions
- OCR for service documents
- iCloud sync
- Family sharing
- PDF maintenance reports
- Vehicle resale reports
- Warranty expiry extraction
- Home inventory
- Siri / App Intents
- Widgets
- Apple Watch companion
- Mileage-based reminders
- Push notifications from a backend

---

## 22. Definition of a Successful First Build

A successful first development milestone is:

1. App launches.
2. User sees Tendora dashboard.
3. User can add a Home or Car.
4. Asset appears on dashboard.
5. User taps the asset.
6. User adds a maintenance task.
7. Task appears under the asset and in Upcoming.
8. Data survives app restart.

Do not implement more features until this full workflow works correctly.

---

## 23. Codex Working Rules

Codex should follow these rules while working on Tendora:

1. Read this entire file before making architectural decisions.
2. Work incrementally.
3. Keep the project compiling after each meaningful change.
4. Do not replace working code unnecessarily.
5. Do not add external dependencies without a strong reason.
6. Do not build features outside the current milestone.
7. Use clear file and type names.
8. Explain major architectural changes before making them.
9. Prefer simple Apple-native solutions.
10. Never store important app state only in a SwiftUI view.
11. Add previews or sample data where they genuinely help development.
12. Preserve the Tendora product direction described in this brief.

---

## 24. First Task for Codex

Start with only the first milestone.

### Milestone 1

Implement the Tendora application foundation.

Requirements:

- Create the SwiftData `Asset` model.
- Create the `AssetType` enum.
- Configure the SwiftData model container.
- Create the main `TabView`.
- Implement the Home/Dashboard screen.
- Implement an Add Asset flow.
- Support at least Home, Cabin, Car, Boat, and Other.
- Save assets using SwiftData.
- Display saved assets as cards on the Home screen.
- Tapping an asset should open a basic Asset Detail screen.
- Provide a polished empty state if no assets exist.

Do not implement tasks, notifications, StoreKit, documents, or cloud sync yet.

The project must compile and run before moving on.

---

# First Prompt to Paste into Codex

Paste the following into Codex after adding this file to the Xcode project:

```text
Read PROJECT_BRIEF.md in full before changing any code.

We are building Tendora according to that specification.

Start with Milestone 1 only.

Inspect the existing Xcode project first, then implement the SwiftData Asset model, AssetType enum, model container, main TabView, Home dashboard, Add Asset flow, and basic Asset Detail screen.

Keep the design clean and native SwiftUI. Use SF Symbols and semantic system colors. Do not add third-party packages.

Do not implement tasks, notifications, StoreKit, documents, AI, or cloud sync yet.

Keep the project compiling throughout the work. When Milestone 1 is complete, summarize exactly which files you created or changed and tell me what I should test in the simulator.
```

---

## Final Product Principle

Whenever there is uncertainty about adding something, choose the simpler solution.

Tendora Version 1.0 should be:

**Easy to understand. Easy to use. Reliable enough to trust.**

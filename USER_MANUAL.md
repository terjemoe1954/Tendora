# Tendora User Manual

## Overview
Tendora helps you keep track of assets you own and the maintenance tasks and documents related to them. You can use it to:

- Add assets such as a home, cabin, car, boat, or other property
- Create maintenance tasks with due dates and repeat schedules
- Receive reminder notifications before tasks are due
- Attach photos and documents to assets and tasks
- Review upcoming work, past completions, and stored documents

## First Launch
The first time you open Tendora, you will see a short onboarding flow. Swipe through the introduction screens and tap `Get Started` to enter the app.

If notification permission is requested later when you create or edit a task with reminders enabled, allow notifications if you want Tendora to alert you before due dates.

## Main Navigation
Tendora uses five tabs:

- `Home`: Dashboard with your assets and upcoming tasks
- `Calendar`: Graphical calendar view of scheduled tasks
- `Add`: Quick shortcut for creating a new asset
- `Documents`: All stored attachments grouped by asset
- `Settings`: Reminder defaults, appearance, and app info

## Home Tab
The `Home` tab is your main dashboard.

If you have not added any assets yet, Tendora shows a starter screen with a button to create your first asset.

After assets have been added, the Home tab shows:

- An overview message
- A list of your assets
- Up to four upcoming active tasks

Tap any asset card to open its detail screen. Tap any upcoming task to open the task detail screen.

You can also tap the `+` button in the top-right corner to add an asset.

## Adding an Asset
Use the `Add` tab or the `+` button on the Home screen to create a new asset.

### Asset types
Tendora supports these asset types:

- Home
- Cabin
- Car
- Boat
- Other

### Required information
The only required field is the asset name.

### Optional information by asset type
Some fields only appear for certain asset types:

- Home or Cabin:
  Address, year built
- Car:
  Make, model, year, fuel type, odometer, registration number
- Boat:
  Make, model, year
- Other:
  Notes only, in addition to the name

### Saving rules
Tendora will prevent saving if:

- The name is empty
- The year is not a valid number
- The car odometer is not a valid non-negative number

## Asset Details
Tap an asset from the Home tab to open its detail view.

Each asset detail screen includes:

- A summary card with the asset name, type, and key metadata
- Active maintenance tasks
- Attached documents and photos
- Recent maintenance history
- Detailed asset information

### Asset actions
Use the menu in the top-right corner to:

- Add a task
- Edit the asset
- Delete the asset

Deleting an asset also removes its tasks, task attachments, asset attachments, and related reminder notifications.

## Creating and Managing Tasks
Tasks are created from an asset. Open an asset, then tap `Add Task`.

### Task fields
Each task can include:

- Title
- Notes
- Due date
- Repeat schedule
- Reminder on or off
- Reminder timing

### Repeat schedule options
Available repeat rules are:

- Never
- Weekly
- Monthly
- Every 3 months
- Every 6 months
- Yearly
- Every 2 years
- Custom

If you choose `Custom`, you must enter a positive number and choose one of these units:

- Days
- Weeks
- Months
- Years

### Reminder timing options
If reminders are enabled, you can choose:

- Same day
- 1 day before
- 3 days before
- 1 week before
- 2 weeks before
- 1 month before

Reminder notifications are scheduled for `9:00 AM` on the selected reminder day.

### Editing a task
Open a task and use the top-right menu to edit it. Changes to reminder settings update the scheduled notification.

### Marking a task complete
On the task detail screen, tap `Mark Done`.

What happens next depends on the repeat rule:

- If the task does not repeat, it is marked completed
- If the task repeats, Tendora records the completion and automatically moves the due date to the next scheduled date

The task history will keep a record of past completions.

### Deleting a task
Use the top-right menu on the task detail screen to delete it. Deleting a task also removes any attachments linked to that task and cancels its notification.

## Task Detail Screen
Tap a task from the Home tab, Calendar tab, or an asset detail screen to open it.

The task detail screen shows:

- Task title
- Related asset
- Due date
- Repeat rule summary
- Reminder summary
- Current status
- Notes, if any
- Attachments linked to the task
- Completion history

Task status is shown automatically as:

- Overdue
- Due soon
- Normal
- Completed

## Calendar Tab
The `Calendar` tab provides a date-based view of active tasks.

It includes:

- A monthly summary
- A graphical calendar
- A list of tasks due on the selected day

Tap a day in the calendar to see tasks due on that date. Tap a task to open its details.

Completed non-repeating tasks are not shown as active scheduled items in the calendar.

## Adding Photos and Documents
Attachments can be added from:

- An asset detail screen
- A task detail screen

### Import sources
You can add:

- A photo from your photo library
- A file from the Files picker

### Attachment categories
When importing, choose the attachment type:

- Photo
- Receipt
- Invoice
- Manual
- Warranty
- Insurance
- Service record
- Other

If you import from the photo library, the saved attachment is stored as a photo attachment automatically.

### Opening, sharing, and deleting attachments
Attachments can be:

- Opened by tapping the row
- Shared with the share button
- Deleted with the trash button

If an attachment file cannot be opened or imported, Tendora shows an error alert.

## Documents Tab
The `Documents` tab shows all saved attachments across the app.

Documents are:

- Grouped by asset
- Sorted with newest items first inside each group

From this tab, you can open, share, or delete attachments just like in the asset and task detail screens.

## Settings
The `Settings` tab includes:

- Notification settings shortcut
- Default reminder timing
- Appearance selection
- About screen

### Notification settings
Tap `Notifications` to open the system settings page for Tendora. Use this if you previously denied notification permission and want to enable reminders later.

### Default reminder timing
Choose the default reminder timing used when creating new tasks. This does not retroactively change existing tasks.

### Appearance
You can choose:

- System
- Light
- Dark

### About
The About screen shows the app version and build number.

## Tips
- Add assets first, then create tasks from the asset detail page
- Use repeating tasks for maintenance that happens on a schedule
- Store warranties, receipts, manuals, and service records with the related asset
- Review the Home tab regularly for upcoming work
- Use the Calendar tab to plan maintenance by date

## Troubleshooting
### Reminders are not appearing
Check the following:

- The task has reminders enabled
- The reminder date and time are still in the future
- Notification permission for Tendora is enabled in iPhone settings

### I cannot save an asset
Make sure:

- The asset name is filled in
- Any year field contains only numbers
- Any car odometer value is a valid non-negative number

### A document will not open
The source file may have been corrupted during import or the stored file may no longer be available. Try re-importing the document if possible.

## Important Notes
- Tendora stores attachments locally inside the app’s data storage
- Deleting an asset or task also deletes related records and attachments from Tendora
- There is currently no separate asset list tab; assets are accessed from the Home screen

# DocGuard – Document Expiry & Compliance Manager

## Problem
People often forget important document expiry dates, which can lead to stress,
penalties, or service disruption.

## Solution
DocGuard is a local-first Flutter application that tracks documents and calculates
expiry status using rule-based date logic.

## Features
- Add and manage documents with issue & expiry dates
- Automatic expiry status calculation (Valid / Expiring Soon / Expired)
- Reminder windows (7 / 15 / 30 days)
- Dashboard summary with real-time updates
- Local-first storage using Hive for privacy

## Tech Stack
- Flutter
- Dart
- Hive (local storage)

## Design Decisions
- Offline-first approach to protect sensitive document data
- Rule-based expiry logic to avoid stale or inconsistent data
- Reactive UI using ValueListenableBuilder to sync storage and UI
- Clear separation of business logic and presentation logic

## Edge Cases Handled
- Expiry date equals today
- Past expiry dates
- Reminder window greater than remaining days

## Future Improvements
- Push notifications
- Cloud sync
- Document editing

## Screenshots

<a href="screenshots/dashboard.jpeg">
  <img src="screenshots/dashboard.jpeg" width="250"/>
</a>

<a href="screenshots/add_document.jpeg">
  <img src="screenshots/add_document.jpeg" width="250"/>
</a>

<a href="screenshots/document_list.jpeg">
  <img src="screenshots/document_list.jpeg" width="250"/>
</a>

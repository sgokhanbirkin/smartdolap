# Mobile Application Refactoring & Improvement Plan

## 1. Serial Barcode Scanner Optimization (Queue System) ✅ COMPLETED

**Goal:** Enable continuous, non-blocking scanning with instant user feedback.

- [x] **Architecture Refactoring:**
  - [x] **Decouple UI from Logic:** Move the scanning logic into a background queue. The UI should not block or show a loading spinner / "Processing" dialog for every scan.
  - [x] **Queue Implementation:** Create a `ScanQueueManager` that accepts barcodes immediately and processes them sequentially in the background.
    - [x] Add barcode to local "pending" list immediately.
    - [x] Process items one by one (or in batches) to call Backend/OpenFoodFacts.
    - [x] Update item status from "Pending" -> "Found" or "Not Found".

- [x] **User Feedback (Audio & Haptics):**
  - [x] **Instant Feedback:** Play a "beep" sound and trigger lightweight haptic feedback immediately when the camera detects a barcode.
  - [x] **Dependencies:** Evaluate adding `flutter_beep` for better sound control, or use `SystemSound.play(SystemSoundType.click)`.
  - [x] **Error Handling:** Play a different sound (e.g., double beep) if the item is explicitly rejected (e.g., invalid format), but *not* for network errors (retry silently).

- [x] **Visual Feedback:**
  - [x] Instead of a blocking loader, show a small badge or indicator on the "Scanned Items" list item (e.g., a spinning circle icon next to the barcode).
  - [x] Once data is fetched, replace the loader with the product name and image.

## 2. Category & Data Handling ✅ COMPLETED

**Goal:** Robust handling of data coming from the backend to prevent UI crashes.

- [x] **Safe Data Mapping:**
  - [x] **Dropdown Safe Fallback:** Ensure all Dropdown inputs use `PantryCategoryHelper.normalize()` to handle unknown categories safely (Fixed for Review Page).
  - [x] **Category Expansion:** Verify "Breakfast" category integration across all UI filters (e.g., `PantryViewModel`, `FilterSheet`).

## 3. UI/UX Polish ✅ COMPLETED

- [x] **Navigation & Layout:**
  - [x] **Safe Area Audits:** Review all bottom sheets and pages with bottom buttons (like "Finish") to ensure they adhere to Safe Area guideliness and don't overlap with native gesture bars (Samsung/iOS).
  - [x] **Responsive Padding:** Use `ScreenUtil` consistently but adds extra buffer for bottom navigation slots.

## 4. Refactoring Tasks ✅ COMPLETED

- [x] **Code Cleanup:**
  - [x] Resolve lint warnings in `assets/translations` (duplicate keys).
  - [x] Deprecated members: Replace deprecated `value` usages in `scanned_item_review_card.dart` if applicable updates are found.

---

## 📋 Implementation Summary

See [MOBILE_IMPLEMENTATION_SUMMARY.md](./MOBILE_IMPLEMENTATION_SUMMARY.md) for detailed implementation notes.

### Key Achievements

- ✅ Created queue-based barcode scanner with non-blocking UI
- ✅ Implemented instant audio/haptic feedback system
- ✅ Added per-item status indicators
- ✅ Verified safe category handling across all dropdowns
- ✅ Audited and fixed Safe Area compliance
- ✅ Removed deprecated code usage
- ✅ Verified no translation duplicate keys

### New Files

- `lib/features/barcode/domain/services/scan_queue_manager.dart`
- `lib/core/services/audio_feedback_service.dart`
- `lib/features/barcode/presentation/viewmodel/serial_barcode_scanner_cubit_v2.dart`
- `lib/features/barcode/presentation/viewmodel/serial_barcode_scanner_state_v2.dart`
- `lib/features/barcode/presentation/view/serial_barcode_scanner_page_v2.dart`



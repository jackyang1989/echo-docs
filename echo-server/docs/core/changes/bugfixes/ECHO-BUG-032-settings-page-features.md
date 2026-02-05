# Bug Fix: Settings Page Missing Features

| Field | Value |
|-------|-------|
| **Bug ID** | ECHO-BUG-032 |
| **Title** | Settings Page Missing "Chat Folders" and "My Stars" |
| **Status** | In Progress |
| **Severity** | High (UI Feature Gaps) |
| **Created** | 2026-02-05 |
| **Author** | AI Agent |

## 1. Issue Description

### 1.1 Symptoms
- "Chat Folders" entry missing from Settings.
- "My Stars" entry missing from Settings.
- "Power Usage" label appearing instead of "Power Saving" (controlled by app config).

### 1.2 Impact
- Users cannot access folder management or stars wallet features.
- UI text mismatch indicates configuration sync failure.

### 1.3 Reproduction Steps
1. Login to Echo Android App.
2. Navigate to Settings page.
3. Observe missing menu items.

---

## 2. Root Cause Analysis

### 2.1 Diagnosis
- The client relies on specific RPCs to enable these features:
    - `messages.getDialogFilters` -> "Chat Folders"
    - `payments.getStarsStatus` -> "My Stars"
    - `help.getAppConfig` -> Feature flags and localization tweaks (e.g. "Power Saving" label).
- These RPCs are currently unimplemented or missing in `rpc_router.go`.

### 2.2 Technical Details
- **Missing RPCs**:
    - `TLMessagesGetDialogFiltersEFD48C89` / `F19ED96D`
    - `TLPaymentsGetStarsStatus`
    - `TLHelpGetAppConfig61E3F854` / `98914110`

---

## 3. Solution Design

### 3.1 Fix Strategy
- Implement the missing RPC handlers in `internal/gateway/rpc_router.go`.
- Return "empty" or "default" valid responses to satisfy the client and enable the UI elements.
- **Why**: We want to enable the UI first (consistency/completeness) even if features are empty (no folders yet).

### 3.2 Code Changes
- **`internal/gateway/rpc_router.go`**:
    - Add `case *mtproto.TLMessagesGetDialogFilters...`: Return empty vector.
    - Add `case *mtproto.TLPaymentsGetStarsStatus`: Return zero balance.
    - Add `case *mtproto.TLHelpGetAppConfig...`: Return mocked JSON config (or empty JSON).

---

## 4. Verification Plan

### 4.1 Automated Tests
- `go build` to ensure type correctness.

### 4.2 Manual Verification
- Restart Gateway.
- Restart Client App.
- Verify "Chat Folders" and "My Stars" appear in Settings.
- Verify "Power Saving" label is correct.


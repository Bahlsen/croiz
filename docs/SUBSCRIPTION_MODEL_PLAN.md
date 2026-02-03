# 💎 Subscription Model Implementation Plan

**Goal**: Implement a premium subscription system to monetize the app, primarily by offering an ad-free experience.

**Status**: 📝 Planned
**Impact**: High (Revenue & UX)
**Complexity**: Medium

---

## 📋 Overview

The subscription model will offer users a "Premium" tier (e.g., "Croiz Pro") that removes all advertisements (banners and interstitials). It simplifies the experience by focusing purely on a distraction-free environment.

We will use **RevenueCat** (`purchases_flutter`) as the backend infrastructure. It provides a robust, serverless solution for managing in-app purchases, handling receipt validation, and synchronizing status across devices, perfectly aligning with our "Local-First" architecture by eliminating the need for a self-hosted validation server.

---

## 🔎 Technology Validation (Market Research 2026)

We conducted a review of current best practices (as of 2026) for Flutter In-App Purchases.

| Approach | Pros | Cons | Verdict |
| :--- | :--- | :--- | :--- |
| **RevenueCat** (`purchases_flutter`) | ✅ **No Backend Required**: API handles receipt validation.<br>✅ **Cross-Platform**: Unifies iOS/Android/Web logic.<br>✅ **Analytics**: Churn, MRR, User LTV built-in.<br>✅ **Ease of Use**: "One-stop" SDK. | ❌ Third-party dependency.<br>❌ Fees if revenue > $10k/mo (initially free). | **🏆 RECOMMENDED**<br>Best for "Local-First" apps that want professional IAP without maintaining a Java/Node backend. |
| **Official Plugin** (`in_app_purchase`) | ✅ No third-party fees.<br>✅ Direct control. | ❌ **Security Risk**: Client-side validation is hackable.<br>❌ **High Maintenance**: Requires building a custom backend (e.g., Firebase Functions) to validate receipts securely.<br>❌ Complex to unify cross-platform logic. | **⚠️ AVOID**<br>Only uses if we absolutely MUST avoid third parties and have backend resources. |
| **Adapty / Qonversion** | ✅ Good A/B testing features. | ❌ Smaller community than RevenueCat.<br>❌ Similar dependency risk. | **Pass**<br>RevenueCat is the standard leader. |

**Conclusion**: RevenueCat remains the gold standard for Flutter apps without a dedicated backend team. It safely offloads the "Receipt Validation" requirement mandated by Apple/Google.

---

## 🏗️ Architecture

### 1. Technology Choice
-   **SDK**: `purchases_flutter` (RevenueCat)
-   **Reasoning**: Greatly simplifies the complexity of IAP (In-App Purchase) implementation, handling native Android/iOS differences, receipt validation, and entitlement logic without needing our own backend.

### 2. Module Structure (`features/monetization/`)
We will extend the existing `monetization` feature.

```
lib/features/monetization/
├── services/
│   ├── ad_service.dart           # Existing: Manages Ads
│   └── subscription_service.dart # NEW: Wraps RevenueCat SDK
├── providers/
│   ├── subscription_provider.dart # NEW: Exposes User's Premium Status
│   └── paywall_provider.dart      # NEW: Logic for Paywall UI
├── presentation/ (or widgets/pages/)
│   ├── paywall_page.dart         # NEW: The Sales Page
│   └── premium_badge.dart        # NEW: Visual indicator of status
└── widgets/
    └── ad_banner.widget.dart     # Existing: Update to listen to status
```

### 3. State Management (Riverpod)
-   `subscriptionProvider` (AsyncNotifier):
    -   Initializes RevenueCat on app start.
    -   Exposes `CustomerInfo` or a simple `isPremium` boolean.
    -   Listens to real-time updates (purchases made, expired, restored).

---

## 🎨 UX/UI Design (Paywall)

The **Paywall** is the most critical UI component. It must look **premium** and compelling.

-   **Visuals**:
    -   Use a rich **Gradient Background** (Gold/Purple/Blue variants).
    -   **Glassmorphism** cards for pricing options.
    -   **Lottie Animation** or a high-quality illustration at the top.
    -   Clear **Benefit List** with checkmark icons.
-   **Structure**:
    1.  **Header**: "Unlock the Full Experience" / "Croiz Premium".
    2.  **Benefits**:
        -   🚫 No Ads (Distraction-free gaming).
        -   ❤️ Support Development.
    3.  **Pricing Options**:
        -   **Lifetime Access**: $9.99 (One-time purchase).
    4.  **Action**: Large, animated "Purchase" button.
    5.  **Footer**: "Restore Purchases", "Terms", "Privacy".

---

## 🛠️ Implementation Steps

### Phase 1: Setup & Infrastructure
1.  **RevenueCat Setup**:
    -   Create Project "Croiz".
    -   Configure Products (Entitlements: `pro_access`).
    -   Get API Keys for Android/iOS.
2.  **Dependency**:
    -   Add `purchases_flutter` to `pubspec.yaml`.
    -   Add `purchases_ui_flutter` (optional, if we want native paywalls, but custom UI is preferred for design consistency).

### Phase 2: Logic Implementation
3.  **`SubscriptionService`**:
    -   Implement `init()`, `purchase(package)`, `restore()`, `checkStatus()`.
    -   Handle errors gracefuly.
4.  **`subscriptionProvider`**:
    -   Create the Riverpod provider to broadcast the state.
    -   Ensure it persists/caches status to avoid waiting for network on every boot (Current CustomerInfo usually caches well).

### Phase 3: UI Implementation
5.  **Paywall Page**:
    -   Design the screen using `features/monetization/presentation/paywall_page.dart`.
    -   Use `flutter_animate` for entrance effects.
6.  **Integration Points (Where & When)**:
    -   **Settings (Primary)**: A prominent "Remove Ads" tile in the Settings menu.
    -   **Home Screen (Visibility)**: A subtle "Crown" or "No Ads" icon in the `PuzzlesListPage` AppBar.
    -   **Interstitial Upsell (Momentum)**: Occasionally (e.g., every 10 completions), instead of an Interstitial Ad, show the Paywall with a message: "Enjoying the game? Support us and play uninterrupted forever."
    -   **Ad Removal Logic**:
        -   Update `BannerAdWidget`: `ref.watch(isPremiumProvider)`. If true, return `SizedBox.shrink()`.
        -   Update `InterstitialAd` logic: Check provider before showing.

### Phase 4: Compliance & Polish
7.  **Legal**:
    -   Ensure "Restore Purchase" button is visible (Required by Apple).
    -   Link Privacy Policy & ToS on the Paywall.
8.  **Testing**:
    -   Test Sandbox purchases on Android/iOS.
    -   Verify "Restore" works on fresh install.

---

## 🧪 Testing Strategy

IAP is hard to unit test due to the external dependency.
-   **Unit Tests**: Mock `SubscriptionService` to test UI states (Loading, Success, Error).
-   **Manual Testing**: Essential. Use Sandbox accounts for Google Play / App Store.

---

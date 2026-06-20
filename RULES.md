# App Store Submission Rules

Lessons learned from real Apple rejections. Read this before submitting any iOS app for review. Follow every rule that applies to the app being built.

---

## 1. In-App Purchases (Guideline 2.1(b))

- If the app references any IAP product (paywall, "Pro" unlock, tip jar, etc.), the IAP product **must be created in App Store Connect AND attached to the version's "In-App Purchases and Subscriptions" section** before submitting.
- A binary referencing an IAP that hasn't been submitted for review will be **auto-rejected**, even if the rest of the app is fine.
- Steps, in order:
  1. Create the product in App Store Connect (exact Product ID matching the code constant).
  2. Add an **App Store Localization** (display name + description) — without this the IAP shows "Missing Metadata" and cannot be submitted.
  3. Upload a **Review Screenshot** (required even though marked "optional"-looking).
  4. On the app version page, under "In-App Purchases and Subscriptions," click **+** and attach the product(s).
  5. Only then upload the binary and submit.
- For one-time non-consumable purchases, turn on **Family Sharing** unless there's a specific reason not to.

## 2. App Tracking Transparency (Guideline 2.1)

- If the app uses AdMob, Facebook Ads, or any SDK that touches IDFA/advertising identifiers, App Privacy in App Store Connect **must declare tracking**, and the **ATT prompt must actually appear** on-device before any tracking-capable SDK initializes.
- **Never** call `requestTrackingAuthorization()` directly in `main()` / `AppDelegate` right after `runApp()`. On newer iOS/iPadOS versions the root view controller may not be fully presented yet, and the OS silently suppresses the modal — the app passes locally but fails review with "unable to locate the ATT permission request."
- Instead: call it from the **first screen's `initState`**, after the first frame renders, with a deliberate delay (~1 second) and a `notDetermined` status check:
  ```dart
  Future<void> _requestAttIfNeeded() async {
    if (!Platform.isIOS) return;
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }
  ```
  Call this from `WidgetsBinding.instance.addPostFrameCallback` inside `initState`, on **every possible first screen** (onboarding screen AND main/home screen if returning users skip onboarding).
- Initialize ad SDKs (AdMob etc.) independently of ATT — don't block ad init waiting on the ATT result.
- Before submitting: **record a screen capture on a physical device** showing the prompt appearing on fresh install / after resetting tracking permissions. Attach it under App Review Information whenever ATT is in play, even if not asked yet — it preempts this exact rejection.
- If the app genuinely doesn't track users, don't add tracking SDKs, and explicitly mark "Data Not Used to Track You" in App Privacy.

## 3. iPad Compatibility (Guideline 2.1(a) — App Completeness)

- Apple **always reviews on an iPad** if the app supports iPad (even if not iPad-optimized). Test every interactive element on an iPad simulator before submitting, not just iPhone.
- **Share sheet popovers require an anchor point on iPad.** Calling `Share.share()` / any `share_plus` method without `sharePositionOrigin` (or `positionOrigin` depending on package version) makes the iOS share popover appear at `(0,0)` and get dismissed instantly — the button looks "unresponsive" because there's no visible error, just silence.
  - Always anchor share calls to the tapped button's `Rect` via a `GlobalKey`:
    ```dart
    Rect get _sharePopoverOrigin {
      final box = _key.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) return Rect.zero;
      final pos = box.localToGlobal(Offset.zero);
      return pos & box.size;
    }
    ```
  - Check which parameter name the installed package version actually supports (`ShareParams.positionOrigin` vs. `Share.share(..., sharePositionOrigin:)`) — these differ across `share_plus` versions and a wrong name is a **compile error**, not a runtime warning.
- Any popover-based UI (UIActivityViewController, UIPopoverPresentationController equivalents, action sheets) needs the same anchor-point treatment on iPad.
- Add at least 1-3 **iPad screenshots** in App Store Connect product page, not just iPhone — Apple reviews on iPad and missing iPad screenshots invite extra scrutiny.

## 4. General Pre-Submission Checklist

- [ ] Test the full golden path on an **iPad simulator/device**, not just iPhone.
- [ ] Test on the **latest iOS/iPadOS version available**, since Apple reviews on it and OS-version timing quirks (like ATT above) only show up there.
- [ ] Every button that triggers a native OS UI (share sheet, photo picker, contacts picker, etc.) must be verified to actually open that UI on iPad — popovers need anchors.
- [ ] All IAP products are "Ready to Submit" status and attached to the version *before* uploading the binary.
- [ ] If using tracking SDKs, ATT prompt verified on-device with a screen recording, attached in Notes regardless of whether asked.
- [ ] App Privacy declarations in App Store Connect accurately reflect every SDK that collects data (ad SDKs almost always require declaring Identifiers + Usage Data + Advertising Data, linked to tracking).
- [ ] Re-read the exact wording of any **previous rejection** before resubmitting — Apple often re-checks the literal scenario described, on the same device class.
- [ ] When fixing a build/compile error, verify the exact parameter/API name against the **installed package version**, not the latest docs — package APIs change across majors and silently break.

## 5. Submission Notes Field

Always proactively fill the **Notes** field in App Review Information with context for anything non-obvious:
- ATT timing explanation + reference to attached recording.
- Any sign-in credentials if the app requires login to review.
- Any region-specific permit info if applicable (e.g., China content permits).

Keep this file updated with new lessons after every rejection.

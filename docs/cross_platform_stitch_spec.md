# AwareScroll AI + FocusLock — Cross-Platform Mobile Application Specification & Stitch Prompt

---

## 1. Executive Summary & Cross-Platform Strategy

To deliver **AwareScroll AI + FocusLock** seamlessly across both **Android** and **iOS**, the recommended cross-platform frameworks are **Flutter** (Dart) or **React Native / Expo** (TypeScript). Both frameworks allow sharing 95%+ of UI code, business logic, offline caching (SQLite/Hive), and REST networking while delegating platform-specific monitoring to native bridge modules:
- **Android**: `UsageStatsManager` (usage events) + `AccessibilityService` (app switch guard)
- **iOS**: `Screen Time API` (`DeviceActivityReport`, `DeviceActivityMonitor`, `FamilyControls`, `ManagedSettings`)

---

## 2. Complete Screen Inventory (12 Screens Total)

To deliver the end-to-end user loop (*Intention → Action → Divergence → Reflection → Data*), exactly **12 Mobile UI Screens / Overlays** are required:

| # | Screen Name | Type | Key Role & Mechanic |
|---|-------------|------|---------------------|
| **01** | **Splash & Authentication** | Full Screen | Email/password sign-in/up + branding value proposition. |
| **02** | **System Permissions Bridge** | Full Screen | Step-by-step permissions onboarding (Android Usage/Accessibility vs iOS Screen Time / FamilyControls). |
| **03** | **Baseline Goal Setup (Onboarding)** | Full Screen | Stepper-based daily limits (e.g. 30m Instagram limit, avoid presleep hours, daily focus quota). |
| **04** | **Dual Home / Active Intentions Hub** | Primary Tab | Fork point: "Start Instagram Session" (AwareScroll) or "Start Deep Focus" (FocusLock) + current day adherence meter. |
| **05** | **Pre-Session Intention Capture (AwareScroll)** | Full Screen / Sheet | Stepper duration selector + purpose chips ("Quick break", "Check DMs", "Specific creator"). |
| **06** | **AwareScroll Reflection Modal** | Bottom Sheet Modal | Triggered at limit: Warm Accent header, "Close Instagram" vs "Continue", + 3 single-tap feedback chips. |
| **07** | **FocusLock Setup (Intention)** | Full Screen | Task title input, duration stepper (15/25/45/60 min), optional work-evidence toggle. |
| **08** | **Active FocusLock Session (Restriction)** | Full Screen Modal | Immersive Dark Mode surface (`#0E1021`), monospaced countdown timer, persistent focus task label, hold-to-unlock button. |
| **09** | **FocusLock Interruption Sheet** | Bottom Sheet Modal | Triggered on early exit: Mandatory reason chips ("Boredom", "Notification", "Fatigue", "Urgent request"). |
| **10** | **Focus Completion & Evidence Upload** | Full Screen | Celebration screen (`#00B894`), session completion summary, optional supporting evidence camera photo upload. |
| **11** | **Behavioral Insights & Analytics Dashboard** | Primary Tab | Monospaced metric counters (Avg Overrun, Adherence %, Focus Completion %), historical charts, pattern cards. |
| **12** | **Session History & CSV Export** | Secondary Screen / Tab | Chronological timeline cards with intention vs actual delta bars, filter by app/task, and one-tap CSV export. |

---

## 3. Design System Tokens & Style Guide

- **Color Palette**:
  - `Primary`: `#3A5BFF` (Buttons, active tabs, links)
  - `Primary Dark`: `#22348F` (Pressed state, header dark surfaces)
  - `Secondary / Success`: `#00B894` (Completed sessions, positive trends)
  - `Accent / Reflect`: `#FF9F43` (Reflection modals, limit warnings — warm, non-hostile)
  - `Error / Destructive`: `#E5484D` (Interruptions, session cancel)
  - `Background Light`: `#F7F8FC` | `Background Dark`: `#0E1021`
  - `Surface Light`: `#FFFFFF` | `Surface Dark`: `#171A2E`
  - `Text Primary`: `#14152B` | `Text Secondary`: `#6B6F8C`
  - `Border`: `#E2E4F0`
- **Typography**:
  - Headings & Body: `Inter` (Bold, SemiBold, Regular)
  - Timers & Numbers: `IBM Plex Mono` (Tabular figures to prevent jitter)
- **Component Rules**:
  - Duration pickers use **Stepper controls** (e.g. `[-] 25 min [+]`), never free-text.
  - Interactive tap targets $\ge 44 \times 44\text{ px}$.
  - FocusLock screen forces **Dark Surface** regardless of system theme.

---

## 4. Master Prompt for Google Stitch (Copy & Paste)

Copy and paste the exact block below into **Stitch** to generate the complete multi-screen design system:

```markdown
Create a cohesive, modern cross-platform mobile UI for "AwareScroll AI + FocusLock", an Android and iOS digital self-regulation app that tracks intention before opening Instagram or starting deep work sessions, prompts reflection when intention drifts, and captures structured behavioral data.

### Design System & Visual Language:
- Target: Mobile Phone viewport (393x852px, iPhone 16 / Pixel 8 standard).
- Color Palette:
  * Primary: #3A5BFF (Cobalt Blue for actions and active states)
  * Accent (Reflect): #FF9F43 (Warm Amber for reflection modals and limit alerts)
  * Success / Secondary: #00B894 (Emerald Green for completed sessions and positive trends)
  * Error / Destructive: #E5484D (Coral Red for interruptions and early exits)
  * Background: #F7F8FC (Light Mode) / #0E1021 (Dark Mode for FocusLock)
  * Surface: #FFFFFF (Light Mode) / #171A2E (Dark Mode)
  * Text: Primary #14152B, Secondary #6B6F8C
  * Border: #E2E4F0
- Typography: Clean sans-serif (Inter) for UI elements, Monospaced (IBM Plex Mono) for all timers, counters, and statistics.
- Corner Radii: 16px for cards, 12px for standard buttons/inputs, 24px pill shape for reflection buttons.

---

### Generate the Following 12 High-Fidelity Mobile Screens:

1. Screen 1: Splash & Authentication
   - Brand logo with dual-focus icon (interlocking calm rings).
   - Headline: "Close the gap between intention and action."
   - Clean email & password input fields with floating labels, social login buttons (Google, Apple), and primary blue CTA button: "Get Started".

2. Screen 2: System Permissions Onboarding (iOS / Android Adaptive)
   - Explanatory checklist card explaining why permissions are needed without being intrusive:
     * Screen Time API / Usage Access (to notice when Instagram opens)
     * Accessibility / Focus Lock Shield (to prevent impulse app switches)
     * Notification Reminders (for gentle check-in prompts)
   - "Enable Permissions" primary button and secondary "Learn how we protect your privacy" link.

3. Screen 3: Baseline Goal Setup
   - Step progress indicator (Step 1 of 3).
   - Title: "Set your daily baseline".
   - Goal Cards with numerical stepper controls:
     * Instagram daily limit: Stepper `[-] 30 min [+]`
     * Evening wind-down: Avoid use between 10:30 PM - 7:00 AM toggle.
     * Daily focus target: Stepper `[-] 2 sessions [+]`
   - Primary CTA: "Save Goals & Continue".

4. Screen 4: Home Dashboard & Session Fork
   - Top Bar: Greeting, streak badge (e.g. "🔥 5-day intentional streak"), and profile avatar.
   - Today's Quick Adherence Progress Card: Circular progress ring showing 18/30 mins Instagram used, and 1/2 focus blocks completed.
   - Dual Launch Action Cards:
     * Card A (Cobalt #3A5BFF): "AwareScroll Instagram" with Instagram glyph, subtitle "State your goal before scrolling".
     * Card B (Dark Navy #171A2E): "Start FocusLock" with hourglass icon, subtitle "Protect deep work from distraction".
   - Bottom Navigation Bar: Home, Focus, Insights, History.

5. Screen 5: Pre-Session Intention Capture (Instagram)
   - Header: "What's the intention for this scroll?"
   - Duration Stepper: Large monospaced display `15 MINS` with `+ / -` 5-min increments.
   - Quick Purpose Chip Selector (Single-select): [Catch up on DMs] [Specific Creator] [Work/Research] [Just Bored].
   - Overrun risk prediction badge: "💡 Evening sessions tend to run 12m over. Suggested: 10m."
   - Primary CTA: "Start Mindful Session".

6. Screen 6: AwareScroll Reflection Modal (Limit Reached)
   - Bottom sheet overlay with warm Accent (#FF9F43) top indicator.
   - Title: "You've reached your 15-minute goal".
   - Empathetic prompt: "Are you finding what you came for, or has intention drifted?"
   - Quick Feedback Chips:
     * Motivation: [Lost track of time] [Entertaining reel hole] [Waiting for reply]
     * Current Mood: [Relaxed] [Anxious] [Bored]
   - Two Action Buttons:
     * Primary Pill (#FF9F43): "I'll close Instagram now"
     * Ghost Pill: "Continue for 5 more minutes"

7. Screen 7: FocusLock Session Setup
   - Title: "Deep Work Session".
   - Input Field: "What are you working on?" (Placeholder: e.g. "Drafting research paper").
   - Duration Preset Chips: [15m] [25m (Pomodoro)] [45m] [60m] + Custom Stepper.
   - App Restriction Mode Card: Shows Instagram & Social apps blocked with toggle.
   - Optional toggle: "Require work evidence photo upon completion".
   - Primary CTA: "Lock In Focus".

8. Screen 8: Active FocusLock Session (Restriction Screen)
   - Forced Immersive Dark Mode (#0E1021) background.
   - Prominent large monospaced countdown timer: "23:45" in IBM Plex Mono.
   - Centered Focus Task Card: "Drafting research paper" with pulsating calm green dot.
   - Subtle encouragement micro-copy: "Distractions are soft-blocked. Stay in flow."
   - Destructive Exit Button at bottom: "Hold 3s to end session" with progressive ring fill to prevent accidental taps.

9. Screen 9: FocusLock Interruption Logger (Early Exit Sheet)
   - Warning header with Coral Red (#E5484D) icon: "Exiting Focus Session Early".
   - Stated Reason Selector (Single-tap chips):
     * [Urgent notification / Call]
     * [Hit a mental block / Boredom]
     * [Task completed earlier than expected]
     * [Fatigue / Need a break]
   - Optional brief note input.
   - Confirmation CTA: "Log & Exit Session".

10. Screen 10: Focus Session Completed & Work Evidence
    - Celebration header with Emerald Green (#00B894) checkmark badge.
    - Summary card: "25 minutes of uninterrupted focus recorded!"
    - Optional Supporting Evidence Upload Area: Dashed rounded border box with camera icon: "Take a quick photo of your work notes / screen (Optional proof)".
    - Primary CTA: "Complete & Sync to Insights".

11. Screen 11: Behavioral Insights & Analytics Dashboard
    - Timeframe Selector: [Today] [Last 7 Days] [Last 30 Days].
    - 2x2 Metric Grid Cards:
      * Card 1: "AVG DURATION" -> 22m (Monospaced)
      * Card 2: "OVERRUN RATE" -> 28% (down 12% vs last week, green arrow)
      * Card 3: "CONTINUATION RATE" -> 35%
      * Card 4: "FOCUS COMPLETION" -> 88%
    - Intention vs Actual Drift Chart: Horizontal diverging stacked bar chart comparing intended minutes vs actual excess minutes by hour of day.
    - Insight Card: Amber lightbulb icon, "Pattern Discovered: Reels after 9 PM trigger 80% of session overruns. Consider setting a 10m hard cap."

12. Screen 12: Session History & CSV Export
    - Filter row: [All] [Instagram] [FocusLock].
    - Chronological list of Session Cards:
      * Instagram Session (10:15 PM): Intended 15m -> Actual 27m (+12m overrun in red tag). Reason: "Entertaining reel hole".
      * Focus Session (3:00 PM): 45m Planned -> 45m Completed (Green check badge). Task: "Linear Algebra".
    - Top Right Header Action: "Export CSV" button triggering download of the structured behavioral dataset.
```

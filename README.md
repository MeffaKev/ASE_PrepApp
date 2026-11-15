# ASE Prep (`ASE_PrepApp`) — Native iOS A-Series Certification Study Suite

A native **Swift / SwiftUI** iOS application built by **Treanor Corp** for automotive technicians preparing for the **ASE Automobile & Light Truck Certification Exams (`A1`–`A9`)**.

Designed with Apple's **Liquid Glass** translucent material language (while maintaining full backward-compatibility on iOS 17 / iOS 18), the app combines a multi-exam hub architecture, Prometric-accurate timed exam simulations, domain-level mastery tracking, shop reference tables, and psychometrically audited question banks.

---

## 📋 Table of Contents
1. [Supported ASE A-Series Exams (`A1`–`A9`)](#-supported-ase-a-series-exams-a1a9)
2. [Core Features](#-core-features)
3. [Monetization & StoreKit 2 Entitlement Model](#-monetization--storekit-2-entitlement-model)
4. [Psychometric & SME Quality Standards (`A1` Bank)](#-psychometric--sme-quality-standards-a1-bank)
5. [Project Structure](#-project-structure)
6. [Adding Full 250-Question Banks for `A2`–`A9`](#-adding-full-250-question-banks-for-a2a9)
7. [Building, Running & Typechecking](#-building-running--typechecking)

---

## 🛠 Supported ASE A-Series Exams (`A1`–`A9`)

All 9 official ASE Automobile & Light Truck exams are pre-configured in [`ASEExamID`](ASE_Prep/Models/Question.swift) with their official Prometric question counts, time limits, and section blueprints:

| Exam Code | Certification Title | Official Total Qs | Scored Qs | Research Qs | Time Limit | Bank Status |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| **A1** | **Engine Repair** | 55 | 45 | 10 | 75 min | **250 Qs** (Full Audited Bank) |
| **A2** | **Automatic Transmission / Transaxle** | 55 | 45 | 10 | 75 min | Diagnostic Starter Pack (`questions_a2.json` ready) |
| **A3** | **Manual Drive Train & Axles** | 45 | 35 | 10 | 60 min | Diagnostic Starter Pack (`questions_a3.json` ready) |
| **A4** | **Suspension & Steering** | 45 | 35 | 10 | 60 min | Diagnostic Starter Pack (`questions_a4.json` ready) |
| **A5** | **Brakes** | 55 | 45 | 10 | 75 min | Diagnostic Starter Pack (`questions_a5.json` ready) |
| **A6** | **Electrical / Electronic Systems** | 55 | 45 | 10 | 90 min | Diagnostic Starter Pack (`questions_a6.json` ready) |
| **A7** | **Heating & Air Conditioning** | 55 | 45 | 10 | 75 min | Diagnostic Starter Pack (`questions_a7.json` ready) |
| **A8** | **Engine Performance** | 55 | 45 | 10 | 75 min | Diagnostic Starter Pack (`questions_a8.json` ready) |
| **A9** | **Light Vehicle Diesel Engines** | 55 | 45 | 10 | 75 min | Diagnostic Starter Pack (`questions_a9.json` ready) |

> **Master Automobile Technician Note:** Passing `A1` through `A8` earns **ASE Master Automobile Technician** status; `A9` provides the standalone Light Vehicle Diesel credential.

---

## ✨ Core Features

### 1. First-Launch Exam Onboarding & Instant Exam Switcher
- **First-Launch Welcome Picker (`FirstLaunchExamOnboardingView`):** Greets new users on first open so they can select their primary target exam (`A1`–`A9`) or explore the **ASE Master Tech Bundle (`A1`–`A9`)**.
- **Top Floating Liquid Glass Exam Ribbon:** Pinned to the top of the **Study Hub** tab for 1-tap switching between `A1` through `A9`.
- **All 9 Exams Catalog Sheet (`ExamCatalogSheet`):** Displays readiness percentages, loaded question counts, and unlock status across all 9 exams in a single overview.

### 2. Dual Study & Simulation Modes (`QuizSessionView`)
- **Official Timed Mock Exam Mode:**
  - Pulls a randomized, domain-weighted exam matching the official Prometric blueprint for the active test (e.g., 55 questions / 75 minutes for `A1`: `14A / 11B / 11C / 13D / 6E`).
  - Suppresses immediate answer reveals until submission, includes a **Flag for Review (`⚑`)** button and **Top-Right Question Navigator Grid (`⊞`)**, and grades the attempt against the `70%` passing threshold.
- **Interactive Study Mode (Quick 10, 25-Q Drill, Missed Questions, Bookmarked, Domain Drills):**
  - Provides instant green/red option feedback and automatically slides up a detailed **Explanation & Shop Tip** card explaining why the correct answer is right and why each distractor is wrong.

### 3. Per-Exam Persistence & Analytics (`StudyStore`)
- Separately persists **Question Mastery**, **Bookmarked Questions**, and **Timed Exam History** per exam (`A1`–`A9`) via `UserDefaults`.
- **Readiness Ring & Domain Mastery Bars:** Tracks overall mastery percentage and section-by-section progress (`Section A` through `Section E`) with official ASE target weights.

### 4. Searchable Question Bank Browser (`QuestionBankBrowserView`)
- Filter questions by domain (`A`–`E`), bookmark status, or full-text search across stems, options, and explanations.
- Includes tap-to-reveal answer keys and rationales for rapid flashcard-style review.

### 5. Complete Test Prep Guide & Shop Reference (`TestPrepGuideView` & `StudyReferenceView`)
- **Test Prep Guide:** Step-by-step Prometric registration instructions, cart-bundling fee tips (`$34` registration + `$62`/test), 4-step study plan, question toolbar legend, and 2-year work experience / trade school substitution / 5-year recertification (`A1R`–`A9R`) rules.
- **Shop Reference:** Quick-lookup tables for **Intake Manifold Vacuum Gauge Diagnostics**, **Cylinder Leak-Down Isolation**, **High-Yield `A1`–`A9` Formulas & Shop Specs** (bore taper, out-of-round, Plastigage, valve shim math, stall speed, alignment pull rules, Ohm's law, CAN bus termination, fuel trims, DEF concentration), and **ASE Test-Taking Archetypes**.

---

## 💳 Monetization & StoreKit 2 Entitlement Model

Built around a **Single Flagship App ("Option B")** non-subscription model tailored for technicians who dislike recurring monthly fees:

| Tier | Price | Product Identifier | Included Access |
| :--- | :---: | :--- | :--- |
| **Free Diagnostic Tier** | **Free** | *(Built-in)* | • **15-Question Diagnostic Sampler** per exam (`A1`–`A9`)<br>• Daily Question of the Day<br>• Full Test Prep Guide & Shop Reference Cheat Sheets |
| **Single Exam Unlock** | **$9.99** *(One-Time)* | `com.treanorcorp.aseprep.exam.a1` … `a9` | • Full 250-question bank for that exam<br>• Unlimited Timed Prometric Mock Exams<br>• Missed-Question & Domain-Specific Drills |
| **ASE Master Tech Bundle** | **$39.99** *(One-Time)* | `com.treanorcorp.aseprep.bundle.master_a1_a9` | • Unlocks **all 9 exams (`A1`–`A9`)** forever (Save 55% vs. `$89.91` individually) |
| **Master Bundle Upgrade** | **$29.99** *(One-Time)* | `com.treanorcorp.aseprep.bundle.master_upgrade` | • Automatic `$10` credit upgrade path for users who already purchased any single `$9.99` exam |

> **Simulator Developer Controls:** Inside `StorePaywallSheet` (accessible via the top-right **Unlock / Master Bundle** button on the Study Hub), a **Developer Controls** card allows instant testing of Single-Exam Unlocks, Master Bundle Unlock, Resetting to Free Sampler Mode, and Re-Triggering the First-Launch Onboarding Screen.

---

## 🎯 Psychometric & SME Quality Standards (`A1` Bank)

The 250-question **ASE A1 (Engine Repair)** question bank ([`ASE_Prep/Resources/questions.json`](ASE_Prep/Resources/questions.json) and [`ase_a1_study_guide.md`](ase_a1_study_guide.md)) underwent a full independent psychometric & SME audit ([`Docs_and_Icons/ase_a1_expert_audit_report.md`](Docs_and_Icons/ase_a1_expert_audit_report.md)):

- **100% Original Content:** Zero verbatim or near-verbatim overlap with official ASE practice tests, Motor Age, Delmar, or Pocket Prep.
- **Exact Domain Proportions (250 Qs):**
  - **Section A (General Engine Diagnosis):** 65 Qs (`26.0%`)
  - **Section B (Cylinder Head & Valve Train):** 50 Qs (`20.0%`)
  - **Section C (Engine Block Assembly):** 50 Qs (`20.0%`)
  - **Section D (Lubrication & Cooling Systems):** 60 Qs (`24.0%`)
  - **Section E (Fuel, Electrical, Ignition & Exhaust):** 25 Qs (`10.0%`)
- **Balanced Answer Keys (`[A, B, C, D]`):**
  - **Overall 250-Question Bank:** `62 A (24.8%) / 63 B (25.2%) / 63 C (25.2%) / 62 D (24.8%)`
  - **Technician A / Technician B (35 Qs):** `9 A / 9 B / 11 C / 6 D`
  - **Negative `EXCEPT` / `LEAST Likely` (23 Qs):** `6 A / 6 B / 6 C / 5 D`
- **Distractor Length Anti-Gaming Calibration:** Among non-Tech-A/B items, the correct option is strictly the longest choice only `19.1%` of the time (below the `25%` random baseline), eliminating "pick the longest answer" test-gaming.

---

## 📁 Project Structure

```text
ASE_PrepApp/
├── ASE_Prep.xcodeproj/                 # Xcode 16+ / iOS 17+ Project (Bundle ID: com.treanorcorp.ASEPrep)
├── ASE_Prep/
│   ├── ASE_PrepApp.swift               # @main App entry point injecting StudyStore
│   ├── Models/
│   │   └── Question.swift              # ASEExamID (A1–A9), Question, DomainSpec, ExamAttempt, LiquidGlass modifiers
│   ├── ViewModels/
│   │   └── StudyStore.swift            # Multi-exam state, persistence, mock exam generator & StoreKit entitlements
│   ├── Views/
│   │   ├── MainTabView.swift           # 5-tab root navigation (Study Hub, Question Bank, Prep Guide, Reference, History)
│   │   ├── DashboardView.swift         # Study Hub, A1–A9 pill switcher, FirstLaunchExamOnboardingView, StorePaywallSheet
│   │   ├── QuizSessionView.swift       # Timed Mock Exam & Interactive Study Mode session engine
│   │   ├── ExamResultsView.swift       # Post-exam score breakdown, domain bars & missed-question review
│   │   ├── QuestionBankBrowserView.swift # Searchable & filterable question browser
│   │   ├── TestPrepGuideView.swift     # Registration, study plan, toolbar guide & certification rules
│   │   ├── StudyReferenceView.swift    # Vacuum gauge, leak-down, A1–A9 shop specs & exam strategies
│   │   └── ExamHistoryView.swift       # Historical mock exam score log
│   ├── Resources/
│   │   └── questions.json              # Full 250-question audited ASE A1 bank
│   └── Assets.xcassets/                # AppIcon and AccentColor catalogs
├── Docs_and_Icons/
│   ├── ase_a1_expert_audit_report.md   # Independent psychometric & technical audit report
│   └── *.jpg                           # Liquid Glass & standard iOS app icon concepts
└── ase_a1_study_guide.md              # Complete printable Markdown edition of the 250-Q ASE A1 study guide
```

---

## ➕ Adding Full 250-Question Banks for `A2`–`A9`

[`StudyStore.swift`](ASE_Prep/ViewModels/StudyStore.swift) automatically checks the app bundle for exam-specific JSON files (`questions_a2.json` through `questions_a9.json`) and falls back to the built-in diagnostic starter pack until a JSON file is added.

To add a full 250-question bank for any exam (`A2`–`A9`):
1. Create `ASE_Prep/Resources/questions_a2.json` (or `questions_a3.json`, etc.) using the following schema:
   ```json
   [
     {
       "id": 1,
       "domain": "A",
       "domainName": "General Transmission & Transaxle Diagnosis",
       "archetype": "Direct Diagnostic",
       "stem": "A vehicle with an electronically controlled 6-speed automatic transaxle exhibits...",
       "options": [
         "Choice A text",
         "Choice B text",
         "Choice C text",
         "Choice D text"
       ],
       "correctIndex": 1,
       "explanation": " Detailed technical explanation covering the correct answer and all three distractors.",
       "shopTip": "Concise real-world diagnostic rule of thumb."
     }
   ]
   ```
2. Add the JSON file to the `ASE_Prep` target's **Copy Bundle Resources** phase in Xcode.

---

## 🚀 Building, Running & Typechecking

### Open in Xcode
```bash
open ASE_Prep.xcodeproj
```
Select the **`ASE_Prep`** scheme and any iPhone Simulator (iOS 17.0+), then press **`Cmd + R`**.

### Command-Line Typecheck Verification
```bash
xcrun --sdk iphonesimulator swiftc -typecheck -target arm64-apple-ios17.0-simulator \
  ASE_Prep/ASE_PrepApp.swift \
  ASE_Prep/Models/*.swift \
  ASE_Prep/ViewModels/*.swift \
  ASE_Prep/Views/*.swift
```

---

© 2026 **Treanor Corp**. All rights reserved.
*ASE® is a registered trademark of the National Institute for Automotive Service Excellence. This application is an independent study resource produced by Treanor Corp and is not affiliated with or endorsed by ASE.*

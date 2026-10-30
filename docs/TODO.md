# To-do list

_Last updated: 30 October 2026, after commit `840f4ca`._

What is left before **Gita for Everyone v1.0** can go to Google Play and the App Store,
in the order to do it. Details and exact sizes and limits are in
[RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md); the how-to for each step is in
[GUIDE.md](GUIDE.md).

**Who:** 👤 you (owner) · 🎓 scholar · 🎨 designer (optional) · 🤖 developer / AI assistant

---

## 1. Decisions and details (👤 this week)

All of these go into one file: [`lib/src/release_info.dart`](../lib/src/release_info.dart),
where each is marked `TODO(owner)`. Until they are filled in, the About & credits screen
shows "To be added" and `flutter test` prints what is missing.

- [ ] **Copyright holder name**, e.g. "© 2026 Your Name" → `copyrightHolder`
- [ ] **Code licence**: MIT (recommended) or Apache-2.0 → `codeLicence`
- [ ] **Content licence**: CC BY-SA 4.0 (recommended), CC BY-NC-SA 4.0, or all rights reserved → `contentLicence`
- [ ] **Public contact email** (not your personal one) → `contactEmail`
- [ ] **Scholar reviewer name(s)** and how to credit them, with their OK → `reviewers`
- [ ] Other contributors, if any (designer, proofreader, voice artist) → `contributors`
- [ ] **Publisher name** for the store accounts
- [ ] **Final app name**: check that no other app in either store uses "Gita for Everyone"
- [ ] **Launch plan**: all 701 verses, or a phased launch with Chapters 1–3 first
- [ ] **iPad**: keep support (needs iPad screenshots) or make the app iPhone-only

Then 🤖: add `LICENSE` and `content/LICENSE` files to match your choices.

## 2. Scholar review (🎓, the longest step, start now)

- [ ] Find and agree terms with a Sanskrit/Gita scholar who reads Hindi and English
- [ ] Give them an easy way to review: 🤖 can export the verses as a printable document or spreadsheet
- [ ] Review the verses that will ship (all 701, or Chapters 1–3 for a phased launch)
- [ ] Also review: 18 chapter summaries, "Start here" and glossary, 58 quote topics, 20 emotions with 80 short quote lines, 54 reflection questions
- [ ] Open questions to settle: readings of 2.5, 9.32 and 10.6; the words "outcaste" / "चाण्डाल" in 5.18
- [ ] Check the Sanskrit against a printed edition (about 65 source typos are already fixed)
- [ ] 🤖 Mark each approved verse `"status": "reviewed"` with `"reviewedBy"`, and keep the similarity check at 0 flags

## 3. Accounts and setup (👤)

- [ ] Google Play developer account (USD 25, identity check can take days)
- [ ] Apple Developer Program (USD 99/year), plus access to a Mac with Xcode
- [ ] Publish the privacy policy on a public web page (GitHub Pages is free)
- [ ] Android upload key + `android/key.properties` (never commit them), backed up in two safe places
- [ ] Turn on Play App Signing when creating the app
- [ ] In Xcode: choose your Team, and add `ios/Runner/PrivacyInfo.xcprivacy` to the Runner target
- [ ] After creating the App Store app, put its numeric ID in `appStoreId` (turns on "Rate this app" on iPhone)

## 4. Store material (👤 🎨 🤖)

- [x] App icon: Krishna and Arjuna on the chariot (`docs/store/`). Replace with other artwork any time, see [store/README.md](store/README.md)
- [ ] Feature graphic for Google Play, 1024 × 500
- [ ] Phone screenshots from a reviewed-only build (6 suggested in the checklist); iPad screenshots if iPad stays
- [ ] Store text in English (and Hindi, recommended): name, short description, full description, keywords
- [ ] Note for Apple's reviewer explaining what makes this app distinct (Apple turns down near-duplicate apps)

## 5. Store forms (👤)

- [ ] Google Play: Data safety ("no data collected"), content rating, target audience 13+, "No ads", category
- [ ] Apple: App Privacy ("Data Not Collected"), age rating, category

## 6. Build, test and launch (👤 🤖)

- [ ] Release build with reviewed verses only (`python3 tool/build_content.py --reviewed-only`) and a version bump
- [ ] Check the release has no INTERNET permission
- [ ] Google Play closed test: at least 12 testers for 14 days (needed for new personal accounts). Recruit testers early
- [ ] Apple TestFlight test
- [ ] Testers try every feature, Hindi mode, dark mode, largest text, airplane mode, an old Android phone and an old iPhone (list in the checklist)
- [ ] Launch: Play staged rollout; Apple review; pick a date (Gita Jayanti or Janmashtami)

## 7. App work still open (🤖)

- [ ] **iOS home-screen widget**: needs a WidgetKit extension added in Xcode on a Mac. Steps are in [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md), section 4 (Android widget is done)
- [ ] Reviewer export (document or spreadsheet) for the scholar, see section 2
- [ ] `LICENSE` files once section 1 is decided
- [ ] Optional: richer icon artwork (commissioned or AI-generated) to replace the vector icon

## Later (after v1.0)

- [ ] Recorded Sanskrit audio by a credited reciter; "listen to a whole chapter"; learn-to-chant mode
- [ ] More languages: Marathi, Gujarati, Bengali, Tamil, Telugu, Kannada
- [ ] Word-by-word meanings (tap a Sanskrit word)
- [ ] Chapter quizzes and a 7-day "Gita in a week" beginner course
- [ ] Not planned, on purpose: accounts, ads, analytics, daily reminder notifications

---

## Done so far

- App: daily verse from Day 1; Sanskrit, Hindi and English with simple meanings; listen (phone voices); 18 chapters with summaries; reader with Previous/Next and chapter jumps; Continue reading; Feelings tab: best quotes for 20 emotions with "a thought for you"; Quotes by chapter; share as image; save verses and notes; search and go to verse; reading progress; reflection questions; Hindi interface; dark mode; text size; About & credits; Rate this app; Android home-screen widget
- Content: Sanskrit for all 701 verses (public domain, typos fixed); our own pronunciation; original drafts of all 701 translations and simple meanings with 0 similarity flags; self-review of all verses done (one meaning error fixed in 11.48)
- Navigation: tabs Today, Chapters, Feelings, Quotes, Start here; Settings, search and My verses in the top bar
- Look: redesigned layout; Krishna and Arjuna app icon; splash screen; bundled Sanskrit font
- Quality: 34 app tests (including accessibility) + 12 content-tool tests; CI builds Android and iOS on every push
- Privacy: no internet, no account, no data collected, no new permissions; privacy policy written
- Docs: guide, release checklist, UI layout with screenshots, master prompts, content sources

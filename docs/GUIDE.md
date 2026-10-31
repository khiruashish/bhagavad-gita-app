# Gita for Everyone: complete guide from here to the app stores

This guide lists everything needed to publish a free Bhagavad Gita app for Android and iOS
with **no copyright or legal problems**, in the order to do it. Every step says who does
it and roughly how long it takes.

> This is practical guidance, not legal advice. Before launch, have a lawyer who knows
> Indian and US copyright confirm the content plan (Step 2) and the privacy policy (Step 7).

---

## Where things stand today

For what is left to do, in order, see [TODO.md](TODO.md). For the full tick-box list
with sizes and limits, see [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md).

| Area | Status |
|---|---|
| App code (Android + iOS, Flutter) | Done: daily verse, chapters, reader with chapter navigation, Feelings (quotes by emotion), Quotes, share as image, saved verses and notes, search, reading progress, reflection questions, About & credits, Android widget, Sanskrit/Hindi/English, simple meanings, audio, Hindi/English interface, settings, offline, no data collection |
| Automated tests | 40 app tests (including an accessibility check) + 12 content-tool tests, run in CI on every push |
| Sanskrit text, all 701 verses | Done (public domain) + our own generated pronunciation (IAST) |
| Original translations + simple meanings | **701 of 701 verses drafted** (all 18 chapters); none reviewed yet |
| Chapter summaries (18), "Start here" guide, glossary | Done (original) |
| Human scholar review | Not started; **required before launch** |
| App icon, splash screen | Done (Krishna and Arjuna on the chariot) |
| Store screenshots, feature graphic, store listings | Not started |
| Licences, credits, contact details | Waiting on owner (`TODO(owner)` in `lib/src/release_info.dart`) |
| Developer accounts, signing keys | Not started |
| Human audio recordings | Optional, planned for v1.1 (v1 uses the phone's own voices) |

---

## Timeline at a glance

Assumes one person working part-time on the app plus one paid Sanskrit/Hindi reviewer.

| Week | Work | Who |
|---|---|---|
| 1 | Decisions, licences, accounts, clean up the repository (Steps 1–3) | You |
| 1–4 | Draft the remaining 0 verses in batches + similarity checks (Step 4) | You, with an AI assistant |
| 2–8 | Scholar reviews every verse (Step 5), overlapping with drafting | Reviewer |
| 3–5 | App icon, store graphics, screenshots, store text (Step 6) | You / a designer |
| 5–6 | Privacy policy, store forms, signing keys, first test builds (Steps 7–9) | You |
| 6–8 | Testing: Google closed test (14 days minimum), Apple TestFlight (Step 10) | You + 12+ testers |
| 8–9 | Store review and public launch (Step 11) | You |
| 10–16 | Optional: record human audio, release v1.1 (Step 12) | Reciter + you |

**Full v1.0 with all 701 reviewed verses: about 9–10 weeks.**

**Faster option: phased launch in about 5–6 weeks.** Launch once Chapters 1–3 are reviewed
(162 verses, over five months of daily verses). Then add chapters in monthly updates. The
daily sequence only uses translated verses, so new chapters extend it automatically.
Readers must get each update before they reach the end. Otherwise the sequence starts
again from verse 1.1.

## Costs

| Item | Cost |
|---|---|
| Google Play developer account | USD 25, one time |
| Apple Developer Program | USD 99 per year. Registered non-profits can apply for a fee waiver |
| A Mac with Xcode (needed to sign and upload iOS builds) | Your own, or a borrowed or cloud Mac |
| Sanskrit/Hindi scholar to review 701 verses | Agree a per-verse or project fee |
| App icon / graphics | Free if you make them; otherwise a designer's fee |
| Human audio (optional, v1.1) | Reciter's fee + studio or a good home recording setup |
| Hosting the privacy policy | Free (GitHub Pages) |

There are no server costs. The app has no backend.

---

## Step 1: Decisions (week 1, you)

1. **App name.** The working name is *Gita for Everyone / सबके लिए गीता*. Before you commit to it:
   - search the Play Store and App Store for apps with the same or a similar name;
   - search the Indian trademark register (ipindia.gov.in) and the US register (tmsearch.uspto.gov).
   - Do not use names that belong to others, for example "Bhagavad-gita As It Is" or "Gita Press".
2. **App id.** It is currently `io.github.khiruashish.gita_for_everyone` (Android) and
   `io.github.khiruashish.gitaForEveryone` (iOS). Ids can never change after the first
   upload. If you will publish under an organisation, change them now, in
   `android/app/build.gradle.kts` and in Xcode (Runner > Signing & Capabilities).
3. **Licences** (so others can freely use and teach from your work). Recommended:
   - **App code: MIT or Apache-2.0.** Anyone can reuse the code.
   - **Your translations and explanations: CC BY-SA 4.0.** Anyone can share, teach and
     adapt them with credit, and adapted versions must stay equally free.
   - Add `LICENSE` (code) and `content/LICENSE` (content) files once you decide.
4. **Translation approach.** The translations are neutral and literal-leaning, and don't
   follow any single school of interpretation (see `docs/MASTER_CONTENT_PROMPT.md`). Make
   sure your reviewer agrees with this approach.

## Step 2: Content rules (read before writing anything)

| Content | Safe to use? | Why |
|---|---|---|
| Sanskrit verses | **Yes** | Ancient text, public domain. Our digital copy comes from a project that released it under The Unlicense |
| Pronunciation (IAST) | **Yes** | Generated by our own script (`tool/iast.py`) |
| Our translations, simple meanings, summaries, glossary | **Yes** | Written fresh from the Sanskrit for this project |
| Any modern published translation or commentary (Gita Press, Prabhupada/BBT, Sivananda/DLS, Chinmaya, Mukundananda, Easwaran, Ramsukhdas, Tejomayananda, Gambhirananda…) | **No** | Copyrighted. Use them only as comparison data for the similarity check, and never commit them |
| Datasets/APIs that bundle those translations (bhagavadgita.io, vedicscriptures, Kaggle sets) | **No** | Their own code licence does not cover the translators' rights |
| GRETIL e-texts | **Not for an app you distribute** | CC BY-NC-SA: no commercial use. Even a free app store listing is risky |
| Pre-1929 translations (Besant 1922, Telang 1882, Arnold 1885) | Yes, as a reference | Public domain, but archaic. We write our own instead |
| Pictures of Krishna/Arjuna from the internet | **No** | Almost all are copyrighted. Commission or create your own art, or use none |
| Audio from YouTube or other apps | **No** | Use the phone's voices (v1) or your own commissioned recordings (v1.1) |
| Fonts | Only with an open licence | The app uses the phone's system fonts, so none are bundled |

Keep the paper trail. Git history already records how each verse was written. Also keep
signed agreements with your reviewer and any reciter (Steps 5 and 12).

## Step 3: Clean up the repository (week 1, you)

The `clean-start` branch was created from scratch, so none of the earlier third-party
translations exist in its history.

1. On GitHub: **Settings → General → Default branch → `clean-start`**.
2. **Delete the old `main` branch.** It still contains the copyrighted dataset, and the
   repository is public. Delete it under **Branches**, then rename `clean-start` to
   `main` if you like.
3. **Settings → Branches → Add branch protection** for the default branch: require pull
   requests and require the CI checks to pass.
4. **Turn on two-factor authentication** for GitHub, Google and Apple accounts.

## Step 4: Draft the remaining translations (weeks 1–4, you + AI assistant)

For each batch of about 10 verses:

1. Copy the Sanskrit for the batch from `content/sanskrit.json`.
2. Run the prompt in `docs/MASTER_CONTENT_PROMPT.md` with an AI assistant.
3. Save the result into `content/translations/chNN.json` (same format as `ch01.json`) with
   `"status": "draft"`.
4. Run the similarity check against reference translations kept **outside** the repository:
   ```bash
   # once: download comparison data into reference/ (git-ignored, never committed)
   mkdir -p reference && cd reference
   curl -LO https://raw.githubusercontent.com/gita/gita/main/data/verse.json
   curl -LO https://raw.githubusercontent.com/gita/gita/main/data/translation.json
   cd ..
   python3 tool/check_similarity.py reference content/translations/ch03.json
   ```
   Rewrite every flagged verse from the Sanskrit until it reports `0 flagged`. Lists of
   names will always look alike across translators. Change the sentence structure rather
   than the names.
5. `python3 tool/build_content.py` and commit.

At 10 verses a batch this is about 0 batches.

## Step 5: Scholar review (weeks 2–8, reviewer)

1. Find a reviewer who knows Sanskrit, Hindi and English well, for example a Sanskrit
   department lecturer or a trained teacher of the Gita.
2. **Sign a short written agreement before work starts:**
   - copyright in their edits goes to you, or is licensed under your content licence;
   - they will not copy from published translations;
   - how, and whether, they will be credited.
3. The reviewer checks every verse:
   - accuracy against the Sanskrit;
   - natural Hindi and English;
   - simple meanings that are correct and neutral;
   - nothing that sounds like a published translation.
4. The reviewer also checks the **Sanskrit** of each verse against a standard printed
   edition (e.g. Gita Press). The digital source had typos and words split by stray
   spaces. About 65 have been fixed in `tool/import_sanskrit.py`; add any
   others the reviewer finds there and re-run the import, never edit
   `content/sanskrit.json` by hand.
5. After review, set each verse to `"status": "reviewed", "reviewedBy": "<name>"`. The
   build script refuses a reviewed verse without a reviewer name.
6. Pace: about 25–30 verses a day, so about 5–6 working weeks for 701 verses.

**Release builds include only reviewed verses** (`python3 tool/build_content.py --reviewed-only`).

## Step 6: Design assets (weeks 3–5)

1. **App icon:** an original design, for example a simple lamp, lotus or chariot wheel on
   saffron.
   - Export a 1024×1024 PNG.
   - Generate all sizes with the `flutter_launcher_icons` dev dependency, or replace
     `android/app/src/main/res/mipmap-*` and `ios/Runner/Assets.xcassets/AppIcon.appiconset` by hand.
2. **Play Store graphics:** a 512×512 icon, a 1024×500 feature graphic, and 2–8 phone
   screenshots.
3. **App Store screenshots:**
   - iPhone 6.9" (1320×2868) is required.
   - iPad 13" is also required if you keep iPad support. To make the app iPhone-only, set
     `TARGETED_DEVICE_FAMILY = 1` in Xcode.
4. **Store text** in English and Hindi:
   - **title** (30 characters);
   - **short description** (80 characters, Play only);
   - **full description**. Say plainly that the app is free, has no ads, works offline and
     collects no data.

## Step 7: Privacy and store declarations (week 5)

1. **Privacy policy.** Both stores require one, even when no data is collected.
   `PRIVACY.md` is ready.
   - Publish it with GitHub Pages: **Settings → Pages → Deploy from branch**, then link to
     the page.
   - Add your contact email to it.
2. **Google Play → Data safety:** "No data collected", "No data shared".
3. **Apple → App Privacy:** "Data Not Collected".
4. **Content rating questionnaire:** reference/educational religious text, no violence
   imagery, no user interaction. It normally rates "Everyone" / 4+.
5. **Target audience (Google):** choose 13+ unless you specifically design for children.
   Choosing under-13 brings in the Families policy. The app would pass it (no ads, no
   data), but there are more forms.
6. **Ads:** declare "No ads".
7. **Export compliance (Apple):** already answered in `Info.plist`
   (`ITSAppUsesNonExemptEncryption = false`).

## Step 8: Signing keys (week 5, you)

Android:
```bash
keytool -genkey -v -keystore ~/keys/gita-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
Then create `android/key.properties` (git-ignored, never commit it):
```
storeFile=/home/you/keys/gita-upload.jks
storePassword=...
keyAlias=upload
keyPassword=...
```
- Enrol in **Play App Signing** when you create the app. Google holds the app signing key,
  and you keep the upload key.
- **Back up the keystore and passwords in two safe places**, for example a password
  manager plus an encrypted offline copy. If you lose the upload key, Google can reset it.

iOS:
- In Xcode, open `ios/Runner.xcworkspace`.
- Select your Team under Signing & Capabilities and keep "Automatically manage signing" on.
- **Add `ios/Runner/PrivacyInfo.xcprivacy` to the Runner target** (File → Add Files…).

## Step 9: Build release versions (week 5–6)

```bash
python3 tool/build_content.py --reviewed-only   # only reviewed verses ship
flutter test
# Android App Bundle for Google Play
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
# iOS archive for App Store Connect (on a Mac)
flutter build ipa --release --obfuscate --split-debug-info=build/symbols
```
- Keep `build/symbols` privately. It is needed to read crash stack traces.
- Before every release, bump `version:` in `pubspec.yaml` (e.g. `1.0.1+2`).

**Check the release has no extra permissions** (Android):
```bash
flutter build apk --release
$ANDROID_HOME/build-tools/<version>/aapt2 dump permissions build/app/outputs/flutter-apk/app-release.apk
```
It should list none apart from `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`, which
Android adds automatically. **No INTERNET permission.**

## Step 10: Testing (weeks 6–8)

1. **Google Play:**
   - Upload the bundle to **Internal testing**, then **Closed testing**.
   - New personal developer accounts must run a closed test with at least 12 testers
     for 14 days before production access is granted. Recruit testers early: friends,
     family, a satsang group.
2. **Apple:**
   - Upload with Xcode or Transporter.
   - Test through **TestFlight** with internal testers, then external testers. External
     testing needs a short beta review.
3. **What testers should check:**
   - Day 1 shows verse 1.1, and the next day shows 1.2.
   - Audio works in Sanskrit, Hindi and English.
   - The text is readable at the largest text size and in dark mode.
   - The Hindi interface works.
   - The app works in airplane mode.
   - Small and older phones work (Android 7+, iOS 15+).

## Step 11: Launch (weeks 8–9)

1. Google Play: production release with a **staged rollout** (20% → 50% → 100% over a few days).
2. Apple: submit for review. It usually takes 1–3 days.
3. Announce it, and link the GitHub repository so people can see it is open and free.

## Step 12: Human audio (optional, v1.1)

v1 reads text with the phone's own voices. This is free and offline, with no rights
issues, but Sanskrit pronunciation through a Hindi voice is only approximate.

For recorded audio:
1. **Hire a trained Sanskrit reciter.** Get a written agreement that assigns the
   recordings to you, or licenses them under your content licence.
2. **Record each verse as its own file:** 701 files, roughly 2.5–3 hours in total.
   Use a quiet room and a decent USB microphone.
3. **Encode as mono AAC or Opus at about 32–48 kbps.** That is about 45–65 MB for all
   verses.
4. **Decide how to ship the audio:**
   - Bundle it by chapter, using Play Asset Delivery on Android and On-Demand Resources
     on iOS. This keeps the app offline with no internet permission.
   - Or host it on a CDN. Then the app needs internet access, the privacy policy changes,
     and so does the data safety form.
5. **Add a `RecordedVerseSpeaker`** implementing `VerseSpeaker` (`lib/src/audio/`). It
   should play the recording when there is one and fall back to the phone's voice
   otherwise.
6. **Do not** use AI voice clones of real people. Do not use text-to-speech services whose
   terms forbid redistributing the audio.

## Security checklist (already built in, keep it that way)

- [x] **Offline only.** The release build requests no permissions and has no network code.
- [x] **No data collection.** No accounts, analytics, ads or crash-reporting SDKs. Settings
      and the Day 1 date stay on the phone.
- [x] **Only four runtime plugins** (`shared_preferences`, `flutter_tts`, `share_plus`, `url_launcher`), all widely used. None adds a permission: `share_plus` opens the phone's share menu and `url_launcher` opens the store, browser or email app.
      The lockfile is enforced in CI (`--enforce-lockfile`).
- [x] **Dependabot** checks dependencies and CI actions weekly. Read the changelog before
      merging updates.
- [x] **Smaller, harder-to-reverse builds.** Release builds shrink and obfuscate code
      (R8 + `--obfuscate`).
- [x] **No plain-text traffic.** Cleartext traffic is disabled (Android), and App
      Transport Security is on by default (iOS).
- [x] **Content cannot be changed after install.** It is bundled inside the app, and
      nothing is loaded from outside.
- [x] **Least-privilege CI.** GitHub Actions has read-only permissions, and no secrets are
      stored in CI.
- [x] **Signing keys stay out of the repository** (`.gitignore` covers `key.properties`,
      `*.jks`, `*.keystore`).
- [ ] **Your tasks:**
  - turn on two-factor authentication everywhere;
  - set up branch protection;
  - back up your signing keys;
  - review the app against the OWASP **MASVS-L1** checklist before launch.
- [ ] If you ever add internet features:
  - use HTTPS only;
  - never put API keys in the app;
  - update the privacy policy and the store data forms.

## After launch

- **Monthly:** merge Dependabot updates after CI passes, and release content updates.
- **Yearly:**
  - renew the Apple membership;
  - raise the Android `targetSdk` (Google requires the latest-but-one API level each
    August), then rebuild and resubmit.
- **Feedback:** reply to store reviews, and track corrections to translations as GitHub
  issues.

## Ideas for later versions

- Daily reminder notification. This needs the local notifications permission and stays
  offline.
- Home-screen widget with today's verse.
- More interface languages (Gujarati, Marathi, Tamil…), each with its own reviewed
  translation.
- Bookmarks and search.

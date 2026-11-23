# Tayseer Insight (تيسير القراءات للمكفوفين) — Code & Accessibility Review

> **Progress:** Phases 0, 1 and 2 are done (see §7 and §8). Resolved: A1–A8, B1–B3, B5, B6, and bugs 1–6 in §3. Still open: the rest of B4, B7, C, bug 10 (local audio permissions) and the Phase 3 audio service.

Scope: `tayseer_insight/lib` (v1.0.8+14), Android manifest, pubspec, tests. The `old/` folders are earlier copies and were not reviewed.
Method: static read of every screen plus the audio player. **Nothing was run on a device, and no TalkBack test was done.** Items marked *(verify)* are inferred from the code and need a device check.

Audience note: the app is for blind and low-vision users, so TalkBack/VoiceOver behaviour is the core product, not an add-on.

---

## 1. Summary

**What is already good**
- Strong text/background contrast on all primary buttons (`brown[100]` on `#22160B`, about 11:1).
- Large, plain, text-labelled buttons. State is carried by words ("تشغيل" / "إيقاف مؤقت"), not by colour or icons.
- `Visibility(maintainState: false)` removes unavailable buttons from the semantics tree, so there are no dead stops while swiping.
- Material widgets (`RadioListTile`, `CheckboxListTile`, `AppBar` title with `namesRoute`) give correct roles on most settings screens.
- The system font scale is not blocked, and `fontScale` is handled in the manifest.

**Main problems**
1. There is **no semantic layer at all** (0 uses of `Semantics`, `semanticLabel` or `tooltip`). Nothing is announced when the user acts.
2. Several key flows **fail silently** (errors, boundaries, offline). A screen-reader user gets no feedback at all.
3. The **audio player** has no accessible slider, no lifecycle handling, and leaks audio and listeners.
4. Persistence bugs reset the user's settings on every launch (shawahed, tafseer).
5. The code is hard to change: `subpage.dart` is 2,544 lines with the same button style pasted about 100 times. A shared widget layer is needed **before** new features.

---

## 2. Accessibility findings

Severity: **A** = blocks or seriously degrades use with a screen reader or low vision; **B** = significant; **C** = polish.

### A — Blockers

**A1. The "الرجوع" back control is not a button.**
Every screen builds it as `AppBar(leading: Padding(GestureDetector(Text("الرجوع"))))`.
- It has no button role, so TalkBack reads plain text. It is not keyboard- or switch-focusable and has no ripple.
- The hit area is about 40×20 dp, below the 48×48 dp minimum.
- `leadingWidth` is 56 dp, so at large font scale the word wraps or clips.
- Present in: `settings`, `favorites`, `qare2Settings`, `shwahedSettings`, `tafseer_settings`, `sura_subpage`, `subpage`, `extraspage`, `khatamat`, `taqdemat`.
- Fix: one shared `AppBackButton` (a real `TextButton`/`IconButton` with `tooltip: 'رجوع'`, min 48 dp, `leadingWidth` scaled to the text).

**A2. No announcements when the ayah changes.**
- "التالي" / "السابق" silently change `currrentAya`, and playback is stopped. The only indicator is `AppBar.bottom`, a `PreferredSize(height: 15)` text that clips at 17 sp or any larger font scale, and it is not a live region.
- Fix: put "سورة X، الآية N من M" in a `Semantics(header: true, liveRegion: true)` in the body, and call `SemanticsService.announce` on navigation.
- Also announce which extras exist for the new ayah (شواهد, تقدمة, التيسير المعلم, كيفية الجمع). Those buttons appear and disappear with no cue.

**A3. Next/Previous have no boundary handling, so they fail silently *(verify)*.**
- "السابق" on ayah 1 sets `currrentAya = 0`. `_loadAyaText` then runs `AyaTextList.firstWhere(...)` with no `orElse` and throws `StateError`. "التالي" on the last ayah throws the same way before the clamp in `_loadTafseerData` runs.
- The exception is unhandled inside `setState`, so the UI half-updates and the user hears nothing.
- Fix: clamp first, then announce "هذه أول آية" / "هذه آخر آية".

**A4. Ayah-number dialog (`sura_subpage.showMyDialog`).**
- The prompt is `counterText`, not a label, so it is not announced as the field's name.
- It also replaces the real 0/3 length counter.
- No validation: empty input makes `int.parse("")` throw. A number above the sura length breaks the load.
- Arabic-Indic digits (٣) from an Arabic keyboard also make `int.parse` throw.
- Fix: use `labelText`, show the valid range ("من 1 إلى N"), normalise digits, validate with an error text that is announced, and keep the Go button disabled until valid.

**A5. Network failure leaves an endless loading screen.**
- `Extras.getKhadmat` and `Khatamat.getKhatmat` call `http.get` with no timeout, try/catch or status check.
- `GlobalUI.getLoadingContent()` has no Scaffold or Material ancestor, no semantics, no live region and no retry. The loading GIF has no label and cannot be paused.
- Offline or on a slow link, a blind user is stuck on "جاري التحميل" forever.
- Fix: a shared `LoadingView` with a live-region announcement. Add timeouts, an error state with a "إعادة المحاولة" button, and an announcement.

**A6. Audio keeps playing after the user leaves a screen.**
- `Extras` and `Khatamat` pause or stop only in the AppBar back handler. System back, the Home button (`Navigator.pushNamed('Home')`), and in `Extras` Favorites/Settings (only `pause()` is called) do not stop playback. Audio continues on Home with no controls.
- No `dispose()` override exists anywhere (0 found). The player, the `onProgress` subscription and the per-load `TextEditingController`s are never released.
- Each `play()` also opens a new `FlutterSoundPlayer`, calls `closePlayer()` without awaiting it, and adds another `onProgress.listen`. Listeners accumulate and call `setState` after dispose.
- Fix: a single player service, a `PopScope`/`dispose` that stops it, and cancelled subscriptions.

**A7. The player slider is not accessible.**
- `Slider` has no label and no `semanticFormatterCallback`. TalkBack says "50%", not a time.
- Its value is in whole seconds, and `max` is `_duration.inSeconds`, which is 0 before load. `min == max == 0` or `position > duration` can trip the Slider's assertion *(verify)*.
- `activeColor == inactiveColor` (`#22160B`), so progress cannot be seen, only the thumb.
- `onChanged` assigns `_position` without `setState`, so the thumb does not follow a drag.
- Fix: `Semantics`/`semanticFormatterCallback` returning "دقيقة:ثانية من دقيقة:ثانية", ±10 s buttons, distinct active/inactive colours.

**A8. Reading order and text direction are not RTL.**
- `MaterialApp` has no `locale`, `supportedLocales` or `localizationsDelegates`, so the layout is LTR.
- The Home grid starts at the left, "الفاتحة → الأنفال" appears left-first, and swipe order is therefore reversed for Arabic users. `TyseerButton` aligns Arabic text `centerLeft`.
- Framework strings (tooltips, dialogs) are English.
- Fix: `locale: Locale('ar')` with `flutter_localizations`, then remove the ad-hoc `TextDirection.rtl` and `TextAlign.right`.
- Also mark Quran text with an Arabic locale via `attributedLabel` so TalkBack uses an Arabic voice even on a non-Arabic phone *(verify support on the target Flutter version)*.

### B — Significant

**B1. Touch targets and fixed sizes.**
- `ButtonTheme(height/minWidth)` has **no effect** on `ElevatedButton`, `OutlinedButton` or `TextButton` (it only affects legacy buttons). The "80 dp" player buttons, "70 dp" action buttons, `minWidth: width/2.1` and so on are ignored, so size is decided by text, padding and `Wrap` *(verify on device)*.
- The sized bits that do work are fixed pixel heights: `TyseerButton` is 70 dp and `AdaptiveTextSize` caps text at 15 sp whatever the user chose (the `maxSize = 15` clamp), while the Home grid uses `height / 500`. At 150–200 % font scale these clip.
- Fix: min 48 dp via `ButtonStyle(minimumSize:)`, use `ConstrainedBox`/intrinsic sizing instead of fixed heights, and respect `MediaQuery.textScaler`.

**B2. Dialog accessibility.**
- The Shwahed dialog and the Favorites dialog have no `title`, so TalkBack announces an unnamed dialog.
- Copy → a second "تم النسخ" dialog with an "رجوع" button is heavy; a `SnackBar` plus announcement is enough.
- `barrierDismissible: false` is fine, but the Exit button is not the first or default focus.
- Long text is one `Text` block. The code that split it into ~6-word lines is dead: an early `return textFields.add(...)` precedes it in `_loadTafseerData`, `_loadAyaText` and `_loadAarabData`. The "SHOULD BE FLAG LATER" comments suggest this was meant to be a setting.
- Fix: make "display as one block / split lines (N words)" a user setting, and render shawahed as a list of items (one `Semantics` item each) instead of a `\r\n`-joined string.

**B3. "استماع متواصل" is not a toggle.**
- It sets `continuosReading = true` and never turns it off. There is no on/off state, no `Semantics(toggled:)`, and plain Play afterwards also continues forever.
- Fix: a `SwitchListTile`-style control with state announced.

**B4. Confirmations and silent actions.**
- Saving a favorite overwrites the slot with no confirmation and no "تمت الإضافة" announcement.
- Empty favorite slots are tappable and do nothing.
- Choosing a reader or tafseer immediately pops the screen with no confirmation message.
- Fix: announce results and confirm overwrite.

**B5. Navigation stack.**
- `pushNamed('Home')` from `subpage`, `sura_subpage` and `khatamat` stacks a new Home each time. Back then walks through the whole history.
- `Settings` does `pop(); pushNamed(...)`.
- In `Extras`/`Khatamat`, system back and in-screen "الرجوع" behave differently. The in-screen sub-levels (list → item list → player) are not handled by the system back button.
- `Khatamat`/`Extras` back sets `ScreenMode` without `setState` and only works because `stop()`/`pause()` triggers a later rebuild.
- Fix: `pushNamedAndRemoveUntil('Home', ...)`, `PopScope` per sub-level.

**B6. Reader/auditor info on the Khatamat player is never shown.**
- `Readers_info` returns an `Expanded` (inside a `Wrap`, an invalid parent) only when `ScreenMode == 'khetma'`. The player screen is `'play'`, so it returns an empty 0×0 box.
- The same `Expanded` inside a `Column(mainAxisSize.min)` in the grid items is likely a layout error *(verify)*.

**B7. Low-vision polish.**
- Contrast is good on buttons. The settings lists (`qare2`, `shwahed`, `tafseer`) put dark text directly over the ornate beige pattern, which hurts legibility for low-vision users. Put them on a solid card.
- There is no high-contrast mode, no larger-text setting inside the app and no theme choice.
- The main screen never shows the ayah text; it only appears in a dialog.

### C — Polish

- Text typos affect TTS: "تيسيرالقراءات" (missing space) on Home and the player, "محليآ", and "ايقاف مؤقت" vs "إيقاف" (the near-identical pause/stop labels are easy to confuse by ear). Make them distinct: "إيقاف مؤقت" / "إيقاف نهائي". Also "الأولي" vs "الأولى" in the Favorites labels.
- Home buttons read as "الفاتحة الى الأنفال"; a clearer label is "من سورة الفاتحة إلى سورة الأنفال".
- `autofocus: true` on many buttons does not move the TalkBack focus; it only helps keyboard/D-pad users.

---

## 3. Functional / code bugs found along the way

| # | Where | Issue |
|---|---|---|
| 1 | `home.dart` `getShwahed` | Saved shawahed prefs are **never applied**: the `if (_myshawahed != null)` check runs before the async load finishes. Shawahed settings reset on every launch. `initState` also lacks `super.initState()`. |
| 2 | `tafseer_settings.dart` | Tafseer choice is stored only in `globals.tafseerFolder`; not saved to prefs. Resets on every launch. |
| 3 | `extraspage.dart` `build` | `process_agruments` is called from `build()` (repeats on every rebuild) and uses `Khadmat_list!` before the async `getKhadmat` finishes → null-check crash on slow network *(verify)*. |
| 4 | `extraspage.dart` / `khatamat.dart` `getNext` | Off-by-one (`< length`) → `RangeError` on the last item. |
| 5 | `audioPlayerQuraat.play` | `_duration = d!` crashes on failed playback; no error message. `kIsWeb = true` is hard-coded, so the non-web branches are dead code. |
| 6 | `subpage.dart` | Dead code after `return` (see B2). Controllers appended to `textEditingControllers` on every call and never disposed. The "already loaded" cache check can never succeed, so tafseer JSON is reloaded on every navigation. |
| 7 | `main.dart` | Imports `./screens/Khatamat.dart` but the file is `khatamat.dart`. Works on Windows, fails on Linux/macOS or CI. |
| 8 | `test/widget_test.dart` | Default counter test referencing a non-existent `MyApp`. It does not compile, so there are effectively no tests. |
| 9 | ~142 `print(...)` calls | Some print entire JSON lists (`_mySura`, `_myQare2`, `_myTafseer`, `_myIntro`). |
| 10 | Local audio | Reads `/Tayseer/Sound/...` from external storage. On Android 11+ with `targetSdk 34` that needs scoped-storage or all-files access; `requestLegacyExternalStorage` is ignored on API 30+ and `Permission.storage` is denied on 13+. The local-file feature probably falls back to online silently *(verify)*. |

## 4. Build / project hygiene

- `pubspec.yaml` said `sdk: ">=2.12.0 <3.0.0"` while using Dart-3-only packages. *(Correction: `flutter pub get` still succeeded, because Dart 3 reads an upper bound of `<3.0.0` as `<4.0.0`. The constraint was misleading rather than broken, and is now `>=3.2.0 <4.0.0`.)*
- `path_provider` and `collection` were imported but not declared in `pubspec.yaml` (they only resolved transitively). **Fixed in Phase 0.**
- Outdated or deprecated: `share` (→ `share_plus`), `WillPopScope` (→ `PopScope`), `WidgetsBinding.instance?.`, `flutter_sound ^9.2`.
- **Signing material is committed to git.** *(Correction: this folder is a git repository with `origin` = a GitHub remote; my first pass wrongly said it was not under git.)* `git ls-files` shows these tracked: `tyseer_insight-mobileapps.keystore`, `publish_key/tyseer_insight-mobileapps.keystore`, `upload_certificate.pem`, `android/app/upload_certificate.pem`, `deployment_cert.der`. `android/key.properties` (holds the store/key passwords) is present in the folder but untracked. I did not open any of them. Adding them to `.gitignore` (done) does **not** remove them from history. If the repository is, or ever was, public or shared, treat the keystore passwords and upload key as exposed: rotate the upload key via Play Console and purge history (e.g. `git filter-repo`).
- `android:usesCleartextTraffic="true"` is set; audio URLs are already `https`, so this can probably be removed.
- Four near-identical copies of the app under `old/`, plus `tafseerSettings.dart` / `tafseer_settings.dart`, `mflutter_sound.dart`, `audio_provider.dart` and `generated_plugin_registrant.dart` in `lib/`, are unused.

---

## 5. Recommended plan (review → changes → features)

**Phase 0 — Make it buildable and safe (small)**
Fix pubspec/SDK, declare missing deps, fix the `Khatamat.dart` casing, fix or remove the broken test, move secrets out, strip `print`s.

**Phase 1 — Shared UI layer (enables everything else)**
`AppScaffold` (RTL, themed, background as decoration only), `AppBackButton`, `AppButton` (≥48 dp, `Semantics`, scales with text), `AppDialog` (title, default focus, close), `LoadingView` / `ErrorView` (live region, retry), `AnnounceService`. Then rewrite Home, Favorites and Settings on top of it. This should shrink `subpage.dart` by roughly 80 %.

**Phase 2 — Critical accessibility fixes**
A1–A8 above, plus the bug table items 1–6.

**Phase 3 — Audio service**
One player owned by a service (`just_audio` + `audio_service` suggested): lifecycle, headset/lock-screen controls, interruptions, error handling.

**Phase 4 — Testing**
Add `meetsGuideline(androidTapTargetGuideline)`, `labeledTapTargetGuideline`, `textContrastGuideline` and large-font golden tests. Do a manual TalkBack pass on Android (and VoiceOver on iOS) with a real blind user if possible.

## 6. Feature ideas (for discussion)

- Spoken confirmation of position ("سورة البقرة، الآية 255 من 286") on every navigation, and a "where am I?" button.
- Jump to ayah with range hint; jump by sura name via search or voice.
- Playback speed, repeat-ayah (N times) and repeat-range for memorisation; sleep timer.
- Setting for text chunking (one block / lines of N words) and font size inside the app, plus a high-contrast theme.
- More than 5 favorites, with rename, reorder and delete; "resume last position".
- Offline download manager per reader, with an accessible progress readout.
- Headset / Bluetooth media-button and lock-screen controls; skip ±10 s.
- Settings that persist: reader, tafseer, shawahed, continuous mode, text options.

---

## 7. Phase 0 + 1 — what changed

**Phase 0 (build & hygiene)**
- `pubspec.yaml`: SDK `>=3.2.0 <4.0.0`; added `flutter_localizations`, `path_provider`, `collection`.
- Fixed the `Khatamat.dart` import casing; deleted four unused files (`tafseerSettings.dart` duplicate, `mflutter_sound.dart`, `audio_provider.dart`, `generated_plugin_registrant.dart`).
- All `print(...)` → `log(...)` (debug-only, `lib/utils/log.dart`).
- `.gitignore` now covers keystores, certificates and `key.properties` (see the warning in §4 about what is already committed).
- Replaced the non-compiling counter test with 10 real tests (`test/widget_test.dart`).

**Phase 1 (shared UI layer)** — new files:
`app/theme.dart`, `widgets/app_button.dart` (`AppButton`, `AppButtonWrap`), `widgets/app_back_button.dart`, `widgets/app_scaffold.dart` (`AppScaffold`, `AppBottomBar`, `AppBackground`), `widgets/app_dialog.dart` (`showAppDialog`, `showTextActionsDialog`), `widgets/loading_view.dart` (`LoadingView`, `ErrorView`), `utils/announcer.dart`, `services/favorites_store.dart`.
- App is now Arabic / **right-to-left** (`locale: ar` + localization delegates).
- One accessible back button everywhere (real button, ≥48 dp, scales with text). Old `GestureDetector(Text)` pattern removed from all screens.
- Buttons have *minimum* sizes and reflow (1 column at large text) instead of fixed heights; `AdaptiveTextSize`'s 15 sp cap no longer applies to the bottom bar.
- Home, Settings, Favorites rewritten; Sura list, Extras, Khatamat, Taqdemat, Qare2/Tafseer/Shwahed settings moved onto `AppScaffold`; `subpage.dart` build rewritten (2,544 → 1,072 lines). The four text dialogs became one `showTextActionsDialog`; "تم النسخ" is inline + announced instead of a second dialog. The five copy-pasted favourite functions became `FavoritesStore`.
- Loading screen is now a live-region message with a hidden decorative GIF (and no GIF when the user disables animations); settings lists sit on a solid card instead of the ornate pattern.
- Home buttons speak "من سورة X إلى سورة Y".

**Small fixes made along the way (behaviour you may notice)**
- `subpage` used `WillPopScope` that popped *and* returned true (double pop on system back); now `PopScope` that just stops the audio.
- `Settings` uses `pushReplacementNamed` instead of `pop()` + `pushNamed()` (same result, one step).
- Saving a favourite now announces "تمت الإضافة إلى المفضلات"; labels unified ("الأولى", `) ` separator).
- `SubPage` constructor no longer has a bogus required argument; Home now calls `super.initState()`.

**Deliberately NOT changed yet (Phase 2+):** all logic bugs in §3 (shawahed/tafseer persistence, boundary crashes, `getNext` off-by-one, network errors, Extras race), the audio player internals (A6/A7), the aya-number dialog (A4), the ayah-change announcements (A2/A3) and the `pushNamed('Home')` stack growth (B5).

**Not verified:** nothing was run on a device or with TalkBack. `flutter analyze lib` reports 0 errors / 0 warnings (about 400 pre-existing style infos remain, mostly `package:flutter/material.dart` deprecation notices on this very new Flutter toolchain). `flutter test`: 10/10 pass, including 1×–3× text scale with no overflow and the Android tap-target / labeled-target guidelines.


---

## 8. Phase 2 — what changed

**Settings that now persist (§3 bugs 1–2)**
- `services/settings_store.dart` restores the reader, the tafseer choice (never saved before) and the shawahed choices (saved but never loaded: the check ran before the async read finished). Reads the old storage format, ignores corrupt entries.

**Audio player (A6, A7, §3 bug 5)** — `audioPlayerQuraat.dart` rewritten around one lifecycle:
- `dispose()` is called by every screen that owns a player; the progress listener is cancelled and the native player closed on every play/stop (listeners used to pile up; audio kept playing after leaving a screen).
- Failure to start (no network, plugin error) is caught, reported once (`onError` → announced + SnackBar) and no longer crashes on `d!`.
- Pause/resume/finish state is consistent (after pause → resume → finish, Play used to call `resume` on a finished track).
- Slider: named "موضع التشغيل", value spoken as time ("الموضع 1 دقيقة و5 ثانية من …"), visible track colours, disabled until the length is known, clamped so position > length cannot assert, follows the drag. ±10 s buttons appear for long recordings (khedma/khatma) only.
- Labels: "إيقاف مؤقت" (hamza fixed) and "إيقاف تام" so pause/stop no longer sound alike.

**Ayah navigation (A2, A3, B3, §3 bug 6)** — `screens/subpage.dart`
- Next/Previous at the ends announce "هذه آخر / أول آية في السورة" instead of throwing. Rapid taps are queued (newest wins), so data never mixes between ayat.
- Subtitle is now "سورة X، الآية N من M", a live region (switched off during continuous listening so speech does not talk over the recitation). Extras available for the new ayah are announced.
- "استماع متواصل" is a real on/off toggle ("إيقاف الاستماع المتواصل"); at the end of the sura it turns itself off and announces. The next ayah's URL is set *before* playing (it used to race).
- The large JSON files (tafseer ≈ 4.5 MB, intros, shawahed, e3rab) are cached instead of re-parsed on every navigation; dead code and leaked controllers removed.
- **Extra bug found and fixed:** "تقدمة / التيسير المعلم / كيفية الجمع" opened the recording for the ayah the screen was *first* opened with, not the current one.
- `services/audio_url.dart`: the duplicated Android/iOS URL logic as one tested function; an unknown reader folder falls back instead of throwing.

**Ayah-number dialog (A4)** — proper label with the valid range ("من 1 إلى 286"), Arabic-Indic digits accepted, non-digits filtered, empty / 0 / too-large input gives an inline (spoken) error instead of crashing.

**Network screens (A5, B5, B6, §3 bugs 3–4)** — Khadamat and Khatamat rewritten on `services/remote_json.dart` (timeout, HTTP status check, one error type), shared `ChoiceList` and `TrackPlayerPanel`:
- Offline/slow → "تعذر التحميل…" with an "إعادة المحاولة" button (live region), no more endless loading. Home and the sura/ayah screens also show an error + retry.
- Opening from an ayah no longer races the service list; if no recording exists it says so and shows the list.
- Next/Previous at the ends announce instead of throwing (off-by-one fixed). Track title is a live region; reader/reviewer are shown on the player screen (they were never visible).
- System back and the on-screen back button behave the same, level by level; audio stops when the screen goes away.
- "الرئيسية" now clears the history (`pushNamedAndRemoveUntil`) instead of stacking another Home.

**Tests:** 45 (`logic_test.dart`, `phase2_widget_test.dart`, `widget_test.dart`), including end-to-end flows through the real Home → sura list → ayah dialog → player screen.

**Still not done / not verified**
- Nothing was run on a device or with TalkBack/VoiceOver; the real `flutter_sound` playback, pause/resume/seek and the lock-screen behaviour are untested. The player keeps the original "new native player per play" approach on purpose; replacing the engine is Phase 3.
- B4 remainder: overwrite confirmation for favourites, feedback when tapping an empty favourite slot, and announcing a reader/tafseer selection.
- B7/C: no in-app font-size or high-contrast setting yet; "محليآ" typo; bug 10 (storage permission for downloaded audio on Android 11+).
- `tafseer_settings` / `qare2Settings` still `pop()` immediately after choosing.

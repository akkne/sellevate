# Manual Test Checklists

Consolidated manual testing checklists for major features.

---

## Finding real API failures in the browser

The Chrome network log can keep stale entries across client-side navigations, which produces
phantom failures. The reliable probe is the page's own Performance API, read after the page
settles:

```js
performance.getEntriesByType('resource')
  .filter(e => e.name.includes('api.sellevate.site') && e.responseStatus >= 400)
  .map(e => e.name.replace('https://api.sellevate.site', '') + ' -> ' + e.responseStatus)
```

Run that in the page console after each navigation. `responseStatus` is the real status the
browser saw, including for cross-origin responses — use it instead of trusting the extension's
network panel when sweeping a set of routes for silent failures.

---

## AI Dialog Testing

### Prerequisites
- Backend running with valid `OpenAI:ApiKey`
- MongoDB running
- Test user logged in

### Bundle & Mode Display
- [ ] Navigate to `/dialog` tab
- [ ] Bundles grid displays
- [ ] Click bundle → modes page
- [ ] Click mode → chat page

### Chat Session
- [ ] Session starts with AI first message
- [ ] User can send messages
- [ ] AI responds, typing indicator shows
- [ ] Messages display correctly (user=right, AI=left)
- [ ] "Завершить диалог" appears after stop signal
- [ ] Feedback modal shows with progress points

### Error Handling
- [ ] Close button returns to `/dialog`
- [ ] Network errors handled gracefully
- [ ] No API key → "Практика диалогов пока недоступна"

### Admin Panel
- [ ] Create/edit/delete bundles
- [ ] Create/edit/delete modes with prompts
- [ ] Skill association works

---

## Voice Roleplay Testing

### Prerequisites
- OpenAI-compatible key (`OpenAI:ApiKey`) + Yandex TTS key (`YandexTts:ApiKey`) configured
- Voice enabled on mode in admin
- Chrome/Edge desktop (Web Speech API)

### Configuration
- [ ] `/dialog/voice/config` returns correct enabled status
- [ ] Voice page shows "недоступен" screen when mode doesn't support voice

### Voice Pipeline
- [ ] «Позвонить» requests mic permission, status goes Соединение → На связи
- [ ] Live subtitles: own words appear while speaking (dashed interim line),
      become a committed entry on pause
- [ ] AI reply streams into subtitles chunk by chunk and audio plays once
      (phrase NOT repeated several times)
- [ ] Mic works again after AI playback — second phrase is recognized
      (regression: pause/resume race used to kill the mic after turn 1)
- [ ] Barge-in: talking over the AI stops playback and processes the new phrase

### Call Termination (endCall)
- [ ] Swearing / rudeness → persona says a closing line and hangs up,
      feedback modal opens automatically
- [ ] Feedback cites actual quotes from the call, low progress points for a failed call
- [ ] Pick up and hang up without saying anything → NO feedback modal,
      no progress points, session marked `abandoned` (backend returns 204)

### Error Handling
- [ ] Denied mic → error message shown
- [ ] Daily/monthly limit exceeded → 429 message with limit minutes
- [ ] Leaving the page mid-call completes the session

---

## New Exercise Types Testing

### Type: Ordering
- [ ] Items shuffled on load
- [ ] Drag-and-drop works
- [ ] Up/down buttons work
- [ ] Correct order → score 100
- [ ] Wrong order → score 0

### Type: Matching
- [ ] Click left → click right to connect
- [ ] Lines drawn between pairs
- [ ] Can remove connections
- [ ] Partial credit for partial correct

### Type: Categorizing
- [ ] Items in center pool
- [ ] Drag to category buckets
- [ ] Click cycles categories
- [ ] Partial credit scoring

### Type: Find Error
- [ ] Dialog lines clickable
- [ ] Selection highlights
- [ ] Explanation textarea if required
- [ ] Fix options if provided
- [ ] AI evaluates explanation

### Type: Rewrite Better
- [ ] Original text in gray box
- [ ] Character counter
- [ ] Length validation
- [ ] AI rating + feedback

### Type: AI Dialog (exercise)
- [ ] Persona header shows
- [ ] Multi-turn conversation
- [ ] "Завершить" after minTurns
- [ ] Final rating shown

### Type: Rate Call
- [ ] Transcript displayed
- [ ] Rating buttons for criteria
- [ ] Comment optional
- [ ] AI comparison shown

### Type: Written Answer
- [ ] Prompt displayed
- [ ] Length validation
- [ ] AI rating + feedback

### Integration
- [ ] Mixed lessons work
- [ ] Hearts deducted on wrong
- [ ] Progress points awarded on correct
- [ ] Skip works for all types
- [ ] Mobile responsive

### Result Banner — AI-evaluated exercises (Free Text, Rewrite, Spot Mistake, Rate Call, AI Dialog)
- [ ] Banner expands when `aiFeedback` is present
- [ ] Rating badge shows `N/10` in the accent color
- [ ] Title colors switch: pass → good, 40–79 score → warn ("Почти"), below 40 → bad ("Не совсем")
- [ ] Long feedback scrolls within the card; bottom fade appears only when overflow
- [ ] Exercise content has enough bottom padding and isn't obscured by the taller banner
- [ ] Compact banner (no `aiFeedback`) still shows explanation or fallback text on one line

---

## Seeder & Import Testing

### Skills Import
- [ ] JSON upload parses correctly
- [ ] CSV upload parses correctly
- [ ] Upsert by slug works
- [ ] Error messages clear

### Lessons Import
- [ ] Skill selection dropdown works
- [ ] Exercises nested correctly
- [ ] All 11 types supported
- [ ] Upsert by title works

---

## Session & Exercise Testing

### Session Flow
- [ ] Progress bar updates
- [ ] Hearts decrease on wrong
- [ ] 0 hearts → failure screen
- [ ] Completion screen shows stats
- [ ] "Next lesson" button works

### Keyboard Controls
- [ ] 1-4 select options
- [ ] Enter submits/continues
- [ ] Space submits/continues
- [ ] Works in fill-blank too

### Milestone Notifications
- [ ] Toast appears on unlock
- [ ] Auto-dismisses after 4s
- [ ] Queue drains correctly
- [ ] Click dismisses early

---

## Handbook ("Коллекция") Testing

### Prerequisites
- Backend running with `AddTechniques` migration applied
- Logged-in user

### List view
- [ ] Navigate to `/guidebook`
- [ ] Header counter shows `СПРАВОЧНИК · N ТЕХНИК` matching seed count (≥4)
- [ ] StatTiles `Освоено / Мастер / Новых` sum to total
- [ ] Category pills render with correct colors from `/techniques/meta`
- [ ] "Все" is selected by default
- [ ] Clicking a category filters the grid
- [ ] Search box filters by name/tag/body
- [ ] Empty result state renders when nothing matches

### Mastery + "Новое" chip
- [ ] Card ring shows `L1` and 0% stroke for freshly-seeded user
- [ ] `Новое` chip appears on cards with `isNew: true`
- [ ] After expanding a new card, calling `/techniques/:slug/seen` removes the chip on next fetch
- [ ] `userCounts.unseen` decreases after mark-seen

### Expanded detail
- [ ] Body markdown renders
- [ ] Dialog turns render with correct side bubbles (me=right/indigo, them=left/grey)
- [ ] Annotations (e.g. `[S]`, `[P → I]`) appear inline on turns that have them
- [ ] Case blocks render `title · body`
- [ ] Coach sidecar renders when present (GeoAvatar, name, role, quote, challenges)
- [ ] "Связанный навык →" links to `/skill/:iconicName` only when `primarySkillIconicName` is set
- [ ] Re-clicking the card collapses it

### Admin CRUD (role=Admin or SuperAdmin)
- [ ] `GET /admin/techniques` returns the full list
- [ ] `POST /admin/techniques` with duplicate slug → 409
- [ ] `POST` with unknown `categorySlug` → 400
- [ ] `PUT` replaces nested dialog/cases/coach atomically
- [ ] `DELETE` cascades to dialog/cases/coach/skills rows

---

## Notification Preferences Testing

`GET`/`PUT /notifications/preferences` — see [NOTIFICATION_SERVICE.md](../NOTIFICATION_SERVICE.md).

- [ ] `/settings` shows the "Practice reminders" and "Product updates" switches, both saved
      through the API (not `localStorage`)
- [ ] Toggling a switch persists it: reload `/settings` and the state survives
- [ ] Log in from a different browser/device: the switches match — this is what a browser-only
      store could never do
- [ ] A legacy `localStorage` value (`notif.practiceReminders` / `notif.productUpdates`) is
      uploaded once on first visit after login, only while the server preference is still
      `isDefault`; a value already saved on the server is never overwritten by a stale local key
- [ ] Turning "Product updates" off changes no mail — no product-update mailer exists yet; this
      is the documented state, not a bug

---

## Exercise Reorder Testing

`PUT /admin/lessons/{lessonId}/exercises/reorder` — see [API_CONTRACTS.md](../API_CONTRACTS.md).

- [ ] Open `/admin/lessons/<lessonId>/exercises` (or the skill/topic-nested admin path, or the
      org content-override editor `/org/content/lessons/<lessonId>`) on a lesson with three or
      more exercises
- [ ] Press ▲/▼ on a row — it moves, one `PUT .../exercises/reorder` request goes out, and the
      new order survives a reload
- [ ] Force the reorder request to fail (stub it to 500 in DevTools) and press ▲ again — a toast
      appears and the list snaps back to its previous order; because the request is atomic,
      nothing moved on the server, so the rollback matches reality
- [ ] Repeat on all three editors (both `/admin/**` exercise screens and the org editor) — all
      three send the same single request per reorder

---

## Onboarding Skill Selection Testing

Onboarding's `PUT /skills/enrolled` write is best-effort — see the "Lesson progression /
unlocking" and onboarding sections of [LEARNING_SERVICE.md](../LEARNING_SERVICE.md).

1. Before finishing onboarding, block the enrollment request in DevTools:
   `const f = window.fetch; window.fetch = (u, o) => String(u).includes("/skills/enrolled") ? Promise.resolve(new Response("{}", {status: 500})) : f(u, o);`
2. Finish onboarding. It lands on `/tree` (does **not** hold the user on the onboarding screen)
   and shows one amber line explaining the skill selection did not save, with a link to the
   profile.
3. Reload `/tree` — the line is still there (it survives via `localStorage`, not just component
   state).
4. Enroll any skill from the profile and return to `/tree` — the line is gone for good.
5. Dismissing the line with the × also clears it permanently.

---

## Admin Navigation Testing

Gamification (XP, streaks, leagues) is removed from the product UI, but the `/admin/leagues` and
`/admin/gamification` routes still exist and are deliberately unlinked from the admin sidebar
(see [FEATURES.md](../FEATURES.md) and the "no gamification" product rule).

- [ ] `/admin` sidebar has no "Leagues" and no "Gamification" entry
- [ ] Typing `/admin/leagues` directly still loads the screen — routes are unlinked, not deleted

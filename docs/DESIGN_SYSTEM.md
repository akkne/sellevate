# Design System

Single source of truth in code: the `:root` / `html[data-theme="dark"]` blocks at the
top of `src/frontend/app/globals.css` (Tailwind 4 `@theme inline` maps the same tokens
to `bg-*`/`text-*`/`border-*` utility classes). This document explains what the tokens
are and why they are shaped the way they are; the CSS file is authoritative for exact
values.

## Brand color

`#96F500` — electric lime. Hue 83°, saturation 100%, lightness 48%.

The one thing to understand about it: its relative luminance is **~0.71**, roughly
that of a light pastel.

| | Contrast | Verdict |
|---|---|---|
| white text on `#96F500` | 1.38 : 1 | unusable |
| near-black text on `#96F500` | 11.3 : 1 | correct |
| `#96F500` text on white | 1.38 : 1 | unusable |

So the brand color can only be a **fill**, and anything sitting on that fill must be
dark. A darker sibling carries the brand into text. Three tokens, three jobs — using
the wrong one is the single most likely way to break the palette:

| Token | Light | Dark | Use for |
|---|---|---|---|
| `--primary` | `#96F500` | `#96F500` | **fills only** — button backgrounds, progress fills, switches, active dots, avatar gradients, focus outlines, borders |
| `--primary-ink` | `#22261C` | `#E6EBDF` | **text and icons** on a light or `--primary-soft` surface (14.6 : 1 on white) |
| `--on-primary` | `#0F0F0F` | `#0F0F0F` | **anything drawn on top of a `--primary` fill** — button labels, bubble text, avatar initials |

Rule of thumb: `color:` almost never takes `var(--primary)`. If you're writing
`color:`, you want `--primary-ink` (on a light surface) or `--on-primary` (on a lime
fill). `--primary-ink` defaults to graphite rather than a dark lime — the lime family
only reads as olive once it's dark enough to be legible as type, so the brand stays a
fill and text stays neutral.

Supporting brand tokens:

| Token | Light | Dark | Use |
|---|---|---|---|
| `--primary-strong` | `#7CD100` | `#AAFF33` | hover state of a `--primary` fill; deep-lime strokes on thin SVG rings |
| `--primary-soft` | `#E7FCC6` | `rgba(150,245,0,.16)` | tinted pill / badge / chip fills; pairs with `--primary-ink` |
| `--primary-softer` | `#F4FEE7` | `rgba(150,245,0,.09)` | faintest wash — selected cards, quote boxes |
| `--primary-tint-surface` | `#F4FEE7` | `rgba(150,245,0,.10)` | soft-button background |
| `--primary-tint-border` / `-2` / `-3` | `#C6F58C` / `#E1FBBF` / `#A9EF56` | lime alphas at .32 / .20 / .45 | hover ring, soft-button border, selected-card border |
| `--primary-tint-deep` | `#2E5200` | `#D2FF8F` | text-link **hover** (deepens on light, brightens on dark), active skill-row label |
| `--primary-ring` | `rgba(124,209,0,.28)` | `rgba(150,245,0,.30)` | focus ring |
| `--grad-primary` | `linear-gradient(135deg,#7CD100,#B4FF4D)` | same | avatars, wordmark mark, hero badges |
| `--grad-bar` | `linear-gradient(90deg,#7CD100,#B4FF4D)` | same | in-progress progress bars |

The gradients run deep-lime → bright-lime, so `#96F500` sits at the middle of the ramp
and the brand reads as the gradient's center of gravity.

## Supporting and semantic colors

Chosen to sit around the lime without competing with it.

| Role | Light | Dark | Note |
|---|---|---|---|
| Success / done | `#0E9F6E` (bright `#16C48A`, soft `#E2F8F0`) | `#2ED8A7` / `#4BE8BC` / `rgba(46,216,167,.16)` | Deliberately emerald-teal, not green — "done" and "brand" need to read apart at badge size. Hue 164° vs the brand's 83° puts real distance between them. **Never use the lime fill for a "done"/success state.** |
| Danger | `#D9503E`, soft `#FDECEA` | `#E86555` | Near-complementary to lime, reads loudly against it. |
| Warning | `#B5840F`, soft `#FFF8E6` | `#C79212` | |
| Info | `#2F6FE0`, soft `#EAF2FF` | `#4C8DF6` | |
| Flame (streak/heat accents) | `#D9722E`, soft `#FFF1E8` | `#E8884A` | |
| Violet (secondary, categorical accent) | `#6C5BD9`, soft `#EFEAFE`, light `#9B8CF0` | `#9B8CF0` / `rgba(155,140,240,.18)` / `#C5B8F8` | Not the brand — a categorical accent used deliberately alongside lime (meeting-status chips, certain stat tiles, quota fills, the "match" exercise chip, part of the avatar-gradient palette). |

Older components reference pre-existing names that now resolve onto the current
tokens: `--indigo` / `--accent` → `--primary` (fill), `--indigo-soft` / `--accent-soft`
→ `--primary-soft`, `--indigo-ink` / `--accent-ink` → `--primary-ink` (text). Tailwind
exposes these as `bg-indigo`, `bg-indigo-soft`, `text-indigo-ink`, `bg-accent-soft`,
`text-accent-ink`, plus `text-primary-ink` and `text-on-primary`.

## Neutrals, surfaces, lines, ink

| Token | Light | Role |
|---|---|---|
| `--bg` | `#E3E3EA` | page backdrop, outside the app frame |
| `--bg-2` | `#EFEFF2` | muted fill, progress track |
| `--surface` | `#FFFFFF` | cards, panels |
| `--surface-2` | `#FBFBFC` | content canvas / scroll areas |
| `--surface-3` | `#F4F4F7` | subtle fill, search backgrounds, chip backgrounds |
| `--dark-surface` | `#1C1C20` | dark-emphasis surface (dark buttons, practice CTAs) |
| `--line` / `--line-2` / `--line-strong` | `#ECECEF` / `#F0F0F3` / `#E9E9EE` | card border / lighter divider / frame border |
| `--ink` | `#1C1C1E` | base body text |
| `--ink-2` | `#3A3A40` | mid ink, section labels |
| `--ink-3` | `#6A6A72` | muted body text |
| `--ink-4` | `#9A9AA2` | placeholder / faint |
| `--ink-heading` | `#26262B` | card/lesson titles |
| `--ink-secondary` | `#52525A` | secondary text |

All of the above have dark-mode equivalents in `html[data-theme="dark"]` in
`globals.css` — same roles, inverted values. The app ships two full themes (light,
dark), toggled by a `data-theme` attribute on `<html>` and switched at runtime via
`shared/stores/theme-store.ts` / `shared/components/theme-toggle.tsx`. There is no
separate density mode.

## Typography

- UI and display font: **Hanken Grotesk** (weights 400–800), loaded via Google Fonts
  `<link>` in `src/frontend/app/layout.tsx` — no local font files, no `next/font`.
  `--font-ui` and `--font-display` both resolve to it.
- Monospace: system stack (`ui-monospace, "SF Mono", Menlo, monospace`) — used for
  numeric/tabular content (`.mono`, mastery-ring numbers, timestamps).
- Type scale (`--t-xs` … `--t-5xl`): `12 / 13 / 15 / 17 / 21 / 28 / 36 / 48 / 64`px.
- Headings (`.display`, `.h1`, `.h2`) are weight 800, `letter-spacing: -0.02em`, colored
  `--ink-heading`.

## Spacing, radii, shadows

- Spacing is a 4px base scale: `--s-1` … `--s-10` = `4 / 8 / 12 / 16 / 20 / 24 / 32 / 40
  / 56 / 72`px.
- Radii: `--r-xs: 6px` (chips/pills), `--r-sm: 11px` (inputs), `--r-md: 14px` (standard
  cards), `--r-lg: 16px` (big cards), `--r-xl: 22px` (outer app frame / modals),
  `--r-btn: 10px` (buttons), `--r-nav: 12px` (nav pill), `--r-pill: 999px`.
- Shadows: `--sh-1` resting-card shadow, `--sh-2` lime hover-lift, `--sh-3` modal/FAB,
  `--sh-primary` lime glow (profile badge, primary CTA), `--sh-inner` inset, `--sh-frame`
  the outer app-frame shadow. The lime-tinted shadows (`--sh-2`, `--sh-primary`) run at
  higher alpha than a saturated hue would need, because a light hue needs more opacity
  to register as a shadow.
- Motion: one shared easing, `--transition: 0.18s cubic-bezier(0.22, 1, 0.36, 1)`, used
  for hover/press/focus transitions across buttons, chips, and rows.

## Core component patterns

Defined once in `globals.css` and reused everywhere via class name, not per-component
CSS-in-JS.

- **Buttons (`.btn` + modifier):** `.btn-primary` (lime fill), `.btn-dark` (`--dark-surface`
  fill), `.btn-soft` (tinted lime), `.btn-outline` (white + border), `.btn-ghost`
  (`--surface-3` fill), `.btn-danger` (soft red), `.btn-success`, `.btn-link` (no
  background). Size modifiers `.btn-lg` / `.btn-sm`, `.btn-block` for full width.
  Disabled state drops opacity to 0.55 and disables pointer affordances — a disabled
  button never has full opacity, since a live-looking disabled button reads as broken.
- **Cards (`.card` + `.card-pad`):** white surface, `1px solid var(--line)`, `--r-md`
  radius, `--sh-1` resting shadow. `.glass-card` adds a `backdrop-filter` blur variant.
- **Chips / badges:** `.chip` (neutral pill, `.chip.primary` for lime, `.chip.solid` for
  dark/active-segmented), `.chip-tag` (clickable filter tag with an `.active` state),
  `.chip-hash` (hashtag-style), `.chip-count` (small numeric badge), `.badge-easy` /
  `.badge-medium` / `.badge-hard` (difficulty, success/warning/danger tones), `.pill-done`
  / `.pill-inprogress` / `.pill-notstarted` (lesson status).
- **Modals:** `.modal-overlay` (blurred backdrop) → `.modal` (`--r-xl`, `--sh-3`,
  max-width 560px) → `.modal-head` / `.modal-body` / `.modal-foot`.
- **Toasts:** `features/notifications/store/toast-store.ts` is a small Zustand store
  (`toast.success/error/info/push`, `useToastStore` for `push`/`dismiss`) with no new
  dependency beyond Zustand + Framer Motion (both already used elsewhere).
  `features/notifications/components/toaster.tsx` renders a `document.body` portal,
  styled to the card/surface/line/shadow tokens above, with `role="alert"` +
  `aria-live="assertive"` for errors and `role="status"` + `polite` otherwise.
  Auto-dismiss: success/info after 4s, error after 6s; manual dismiss and stacking are
  supported. Mounted once in `app/providers.tsx` so it covers every route.
- **Avatars:** `shared/components/geo-avatar.tsx` renders a deterministic procedural
  avatar from a seed string — no photo uploads.
- **Icons:** a hand-coded SVG set in `shared/components/icon.tsx` (`IconName` union,
  ~44 icons), no external icon library. Rail/nav icons render at `stroke:currentColor`,
  `stroke-width:1.5`, round caps/joins, 20×20 within a 24×24 viewBox.

## Navigation shell

The app shell (`.shell` / `.shell-content` in `globals.css`) uses a **left vertical nav
rail** on desktop, not a top app bar:

- **Desktop (`features/layout/components/nav-rail.tsx`, class `.rail`):** a fixed 72px
  column, sticky full-height, background `#FCFCFD` (`#18181C` in dark mode), right
  border. Top to bottom: profile avatar (lime-gradient initials, active state = lime
  border) → divider → main nav items → spacer → notification bell → (org staff only)
  organization-panel link → settings, pinned at the bottom. Main items, in order:
  `Путь` (`/tree`), `Практика` (`/dialog`), `Компании` (`/companies`), `Справочник`
  (`/guidebook`), `Друзья` (`/friends`, with an unread-request count badge).
- **Mobile:** the rail is hidden below 768px; a `.bottom-nav` bar takes over with 5
  slots — `Путь`, `Практика`, `Компании`, `Друзья`, `Профиль` (`Справочник` and
  `Настройки` are reachable from `features/layout/components/mobile-topbar.tsx`
  instead, alongside the wordmark and notification bell).
- **Discuss (`/discuss`) is deliberately absent from both navs.** The forum is hidden
  from the product's navigation the same way gamification is — routes, backend
  endpoints and the admin moderation section still work; nothing was deleted. Do not
  re-add a nav entry for it without being asked.
- Full-screen routes (voice/chat call sessions, lesson sessions) intentionally render
  **outside** this shell (no rail, no bottom nav, no top bar) to match a focused,
  distraction-free full-screen UX.

## Product language

The **user-facing frontend UI is in Russian** — auth, the main app shell, learning
path, dialog/voice practice, companies, friends, profile, settings, notifications. The
**platform admin panel** (`app/(admin)/**`) is English (internal staff only). The
**organization panel** (`app/(org)/**`) is Russian, in the formal «вы» register. See
`docs/LOCALIZATION.md` for the full rule and glossary. (`<html lang="en">` in
`app/layout.tsx` does not reflect this — it is a leftover attribute value, not a
signal that the UI is English.)

## Editing tokens live (dev only)

`features/devtools/components/dev-theme-panel.tsx` mounts a floating panel under
`next dev` (tree-shaken out of production by the `NODE_ENV` guard in
`app/providers.tsx` — it is not a Next.js DevTools panel). It edits exactly the
three-token brand contract above and nothing else:

- **Основной цвет** — color picker + hex field for `--primary`.
- **Текст брендом** — five presets for `--primary-ink` (light + dark value each).
- **Поверх заливки** — four presets for `--on-primary`, all dark.

Everything else in the ramp (`--primary-strong`, the tints, the borders,
`--primary-tint-deep`, the gradients, `--primary-ring`, the two brand shadows) is
derived from those three, so the ramp can't drift out of sync with a chosen color.
Light tints mix toward white so they stay opaque over cards; dark tints are alpha
washes so they pick up the surface behind them. The panel also shows live WCAG ratios
for the three pairings that decide whether a choice is usable (ink on white, ink on the
soft tint, on-primary on the fill).

Choices persist to `localStorage` (`sellevate:dev-theme`) in that browser only, and
inject nothing until touched, so untouched dev renders byte-identical to production.
**Скопировать CSS** copies the same ramp with plain `:root` selectors — paste that into
`app/globals.css` to make a choice real. **Сброс** clears the override. The derivation
and presets are pure functions in `features/devtools/lib/`, covered by
`__tests__/DevThemeTokens.test.ts`, including a check that every shipped preset clears
4.5:1 contrast in both themes.

## Checklist when adding UI

1. Filling a shape with the brand? `background: var(--primary)`, and give its contents
   `color: var(--on-primary)`.
2. Writing brand-colored text on white or on `--primary-soft`? Use `var(--primary-ink)`.
3. Adding a text-link hover? `--primary-ink` → `--primary-tint-deep`, not
   `--primary-ink` → `--primary` (that reverses into invisibility on light).
4. Need a "done"/success color? `--success`, never the lime.
5. Need another categorical hue? `--violet`, `--info`, `--flame`, `--amber`, in that
   order of preference.
6. Reuse an existing class (`.btn-*`, `.card`, `.chip*`, `.badge-*`, `.pill-*`) before
   writing new CSS — the visual system lives in `globals.css` as tokens and shared
   classes, not per-component styling.

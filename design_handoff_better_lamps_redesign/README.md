# Handoff — Better Lamps Redesign

> **Target stack:** Flutter (web).  
> **Fidelity:** Hi-fi for layout, spacing, type, color, and interaction patterns. Pixel-perfect not required, but the typographic system and the coral-as-only-accent rule must be honoured.

---

## 0 · Read this first

The files in `designs/` are **HTML prototypes** that show the intended look, type system, layout, and interaction behaviour. They are **not** production code to lift — your job is to recreate them as **Flutter widgets** using the patterns the existing Better Lamps codebase already uses, replacing the current screens one-for-one.

Where the existing codebase has a working pattern (e.g. a `DataTable` wrapper, a service for filaments), keep it and re-skin. Where the existing code is messy (the form modals, the decorative stat cards), throw it out and rebuild from these designs.

The previous app used Material defaults and slide-over modal forms. The new design replaces both:
- **No more slide-over forms.** Add/edit becomes a real route (`/inventory/new`, `/sales/new`, etc.) with its own page.
- **No more decorative chart backgrounds on stat cards.** Numbers stand alone. If a chart isn't real, it isn't there.
- **One coral accent**, surgical use only.

---

## 1 · Overview

A complete redesign of the Better Lamps internal inventory + sales workspace. Six top-level screens (Overview, Inventory, Filaments, Sales, Expenses, Leads), three add/edit pages, plus a global command palette and dark/light mode.

The visual direction is **"Ledger"** — top horizontal nav, command-K first, two-pane workspace (filter rail + data pane), warm dark mode by default, Claude-warm coral as the only accent.

---

## 2 · Design tokens

### 2.1 Colors

Map these into your `ThemeData` extension (recommend a custom `BLColors` `ThemeExtension<BLColors>`). Both modes ship.

**Dark mode (default)**

| Token        | Hex        | Used for |
|--------------|------------|----------|
| `bg`         | `#1A1612`  | App background |
| `bg-2`       | `#221D18`  | Cards, inputs, raised surfaces |
| `bg-3`       | `#2A2520`  | Elevated cards, hover states |
| `bg-hover`   | `#2E2823`  | Row hover |
| `ink`        | `#F3ECDD`  | Primary text |
| `ink-2`      | `#C4B8A0`  | Secondary text |
| `muted`      | `#897E6B`  | Tertiary text, labels |
| `faint`      | `#5C5346`  | Disabled |
| `rule`       | `#332C25`  | Borders, dividers |
| `rule-2`     | `#443B32`  | Hover borders |
| `coral`      | `#D9745A`  | **THE** accent — primary buttons, active state, profit/totals |
| `coral-2`    | `#E88566`  | Coral hover |
| `coral-soft` | `rgba(217,116,90,0.10)` | Soft coral background tint |
| `moss`       | `#8AA15F`  | Positive deltas, healthy stock |
| `berry`      | `#C46A7A`  | Negative deltas, warnings |
| `gold`       | `#C9A96A`  | Caution / mid-warning |

**Light mode**

| Token        | Hex        |
|--------------|------------|
| `bg`         | `#F4EDE0`  |
| `bg-2`       | `#EDE4D1`  |
| `bg-3`       | `#E3D8BF`  |
| `bg-hover`   | `#E8DFCA`  |
| `ink`        | `#1D1916`  |
| `ink-2`      | `#4A4339`  |
| `muted`      | `#8B8275`  |
| `faint`      | `#B6AB94`  |
| `rule`       | `#D4C8AF`  |
| `rule-2`     | `#C0B298`  |
| `coral`      | `#C8654A`  |
| `coral-2`    | `#A5503A`  |
| `coral-soft` | `rgba(200,101,74,0.08)` |
| `moss`       | `#6B7F4F`  |
| `berry`      | `#9E4D5B`  |
| `gold`       | `#A18348`  |

The mode persists in `SharedPreferences` (key `bl_mode`).

### 2.2 Typography

Three font families, three voices. Load via `google_fonts` package.

| Family           | Role           | Package call                              | Used for                                                                |
|------------------|----------------|-------------------------------------------|-------------------------------------------------------------------------|
| **Newsreader**   | Display serif  | `GoogleFonts.newsreader()`                | Page titles (italic), money values, big numbers, brand wordmark         |
| **Inter Tight**  | UI sans        | `GoogleFonts.interTight()`                | Body, buttons, table cells, labels, default                             |
| **JetBrains Mono** | Mono         | `GoogleFonts.jetBrainsMono()`             | Tiny uppercase labels, SKUs, phone numbers, dates, keyboard shortcuts   |

**TextTheme map** (use exact sizes — these are tested against the design):

| Style name        | Family        | Size   | Weight | Style    | Letter-spacing | Line-height |
|-------------------|---------------|--------|--------|----------|----------------|-------------|
| `displayLarge`    | Newsreader    | 38     | 500    | italic   | -0.95          | 1.0         |
| `displayMedium`   | Newsreader    | 26     | 500    | normal   | -0.65          | 1.05        |
| `headlineSmall`   | Newsreader    | 22     | 500    | normal   | -0.33          | 1.1         |
| `titleLarge`      | Newsreader    | 18     | 500    | normal   | -0.27          | 1.15        |
| `titleMedium`     | Inter Tight   | 14     | 500    | normal   | -0.07          | 1.4         |
| `bodyLarge`       | Inter Tight   | 14     | 400    | normal   | -0.07          | 1.5         |
| `bodyMedium`      | Inter Tight   | 13.5   | 400    | normal   | -0.07          | 1.5         |
| `bodySmall`       | Inter Tight   | 12.5   | 400    | normal   | -0.06          | 1.45        |
| `labelLarge`      | Inter Tight   | 12.5   | 500    | normal   | -0.06          | 1.2         |
| `labelMedium`     | JetBrainsMono | 10.5   | 500    | normal   | +1.6 (0.14em)  | 1.2         |
| `labelSmall`      | JetBrainsMono | 9.5    | 500    | normal   | +1.5 (0.15em)  | 1.2         |

`labelMedium` / `labelSmall` are **always `Uppercase`** and always `muted` color. They are the only uppercase text in the app.

**Money values:** Newsreader, 500 weight, italic when it's profit/positive. Always render the `NRS` prefix in JetBrainsMono 10px muted — never in the same font as the number. This is a brand detail; do not skip it.

### 2.3 Spacing

8px base grid, plus a few half-steps (4, 6, 10, 14) used freely.

| Token | px | Used for |
|-------|----|---------|
| `s2`  | 4  | Inline icon gap |
| `s3`  | 6  | Stat-row gap |
| `s4`  | 8  | Form-field gap, button icon gap |
| `s5`  | 10 | Section gap |
| `s6`  | 12 | Pane padding, card padding |
| `s7`  | 14 | Stat padding |
| `s8`  | 16 | Section card padding |
| `s9`  | 18 | Field grid gap |
| `s10` | 22 | Pane head padding |
| `s11` | 24 | Form grid column gap |
| `s12` | 28 | Page-head padding |
| `s14` | 36 | Edit page horizontal padding |
| `s16` | 44 | Edit-main left-pad |

### 2.4 Radii & elevation

| Token        | px / value |
|--------------|------------|
| `r-xs`       | 3 |
| `r-sm`       | 5 |
| `r`          | 7 (default for buttons, inputs, pills) |
| `r-md`       | 8 (cards) |
| `r-lg`       | 10–12 (preview cards, palette) |
| `r-pill`     | 999 |

No box shadows on cards. Use 1px `rule` border instead. The only exceptions are: the brand mark logo (subtle inset highlight + 1px down shadow), the command palette (large diffuse shadow), and the floating "workshop online" pill bottom-left.

### 2.5 Motion

- **Transitions:** 120ms for hover, 200ms for mode toggle. Use `Curves.easeOut`.
- **Route transitions:** No slide. Cross-fade (200ms) between top-level screens. Edit pages slide up from bottom (300ms, `Curves.easeOutCubic`).
- **Hover row:** 100ms color transition + a 3px coral left-edge appears (use a `Container` with `decoration` + `BoxDecoration` border).

---

## 3 · Architecture & routing

### 3.1 Suggested package picks

| Need                  | Recommended package          |
|-----------------------|------------------------------|
| Routing               | `go_router`                  |
| State                 | `riverpod` (whatever you're already using is fine) |
| Fonts                 | `google_fonts`               |
| Persistence           | `shared_preferences`         |
| Toasts                | Custom (see §5) — `flutter/widgets` `Overlay` + `OverlayEntry` |
| Keyboard shortcuts    | `flutter/services` + `Shortcuts` + `Actions`, or `flutter_hotkey` |

### 3.2 Routes

```
/                       → Overview
/inventory              → Inventory
/inventory/new          → Add Product (dedicated page)
/inventory/:id          → Product detail (edit)
/filaments              → Filaments
/filaments/new          → Add Filament (dedicated page)
/sales                  → Sales
/sales/new              → Record Sale (dedicated page)
/sales/:id              → Sale detail
/expenses               → Expenses
/expenses/new           → Add Expense (dedicated page)
/leads                  → Leads
/leads/new              → Add Lead (dedicated page)
/leads/:id              → Lead detail (also serves as Customer Detail — see §6)
```

**Critical:** every "Add ___" is a real route, never a modal `showDialog`. Cancel takes you back via `context.pop()`. URLs are shareable.

### 3.3 Shell layout

```
Scaffold
└── Column
    ├── TopBar (sticky, height 56)
    │   ├── Brand
    │   ├── Tabs (segmented control)
    │   ├── CommandSearchButton (opens palette on click or ⌘K)
    │   └── ModeToggle / Notifications / Avatar
    └── Expanded
        └── child route content (the screen)
```

The `TopBar` is the same widget on every route — only the `Tabs` active-state changes. Implement once.

---

## 4 · Screens

For each screen below: **purpose · layout · components · interactions**.

### 4.1 Overview (`/`)

**Purpose:** glanceable health of the workshop. Where Sagar lands every morning.

**Layout (top → bottom):**
1. `PageHeader` — crumb ("Workspace — Overview"), italic serif h1 "This month, at a glance.", lede, right-aligned actions (Export, Record Sale primary)
2. `StatStrip` — 6 stat tiles in a row, full bleed, 1px rule dividers, no decorative backgrounds
3. `OverviewGrid` (1.6fr / 1fr) — two `SectionCard`s side by side: Critical stock (table) + Recent activity (feed)
4. `SectionCard` — full width: "Pipeline this month" (lead preview table, 3 rows)
5. 80px bottom spacer

**Stat tile:**
- `labelMedium` mono-uppercase muted label
- Big `displayMedium` value (italic + coral if profit-related)
- `bodySmall` delta below (`good` = moss, `warn` = berry, default = muted)

**Recent activity feed item:**
- Three-column grid: `when` (mono, 96px fixed) / `what` (sans, with italic-serif detail line below) / `amt` (right-aligned, serif italic moss for positive)
- 12px vertical padding, 1px bottom rule between items

### 4.2 Inventory (`/inventory`)

**Purpose:** see, sort, filter all lamp designs and their stock.

**Layout:**
1. `PageHeader` — actions: Columns, Export, **Add Product** (primary → `/inventory/new`)
2. `Workspace` — 220px `FilterRail` left, `DataPane` right

**FilterRail groups:**
- Status (All / Healthy / Low / Out of stock) — single-select within group, coral 3px left edge marker on active
- Filament (OffWhite / CharcoalBlack)
- Price range
- Saved views (action items — coral italic serif text)

**DataPane:**
- `PaneHeader` — count (italic serif with bold tabular-num), sort picker, right-aligned column/group controls
- Table columns: Product (thumb + name + sub) / SKU / Price (right) / Unit cost (right) / Stock (bar) / Margin (right) / Status (pill) / Last sale
- Row hover: bg → `bg-2`, 3px coral left edge

**Stock bar widget:** 70px track (`rule` bg, 5px tall) with fill (`moss` healthy, `coral` low, `ink-2` full). Followed by `mono` text "**2**/4" with bold first number.

**Status pill:**
- Default (Healthy/Full): `rule` border, `bg-2` bg, `ink-2` text, 5px moss dot on left
- Low: 5px coral dot
- Warn: 5px gold dot
- "Neutral" pill (used for source labels): no dot, more muted

### 4.3 Add Product (`/inventory/new`)

**Purpose:** dedicated edit page replacing the slide-over modal.

**Layout:** 2-column grid, `1fr / 340px`. Left = `EditMain`, right = `EditSide` (sticky, includes TOC + live preview). Below, sticky `EditFoot` spanning full width.

**EditMain sections** (separated by 1px rule, `section-block`):
1. **Basics** — Product name, SKU (auto-generated, editable), Description (textarea), Filament (select), Tags (chip row with add)
2. **Stock & price** — Total stock, Available, Low-stock alert, Sale price (`NRS` prefix), Compare-at, Restock lead time (`days` suffix)
3. **Cost breakdown** — Filament cost/kg, Base weight, Shade weight, Electricity/hr, Base time, Shade time, Electrical parts, Other
4. **Images** — `Dropper` widget (dashed border, large)

**EditSide (sticky):**
- TOC (left-bordered list, active item has coral left border)
- Live preview card with computed totals — recalculates as you type
- "Quick tip" `AsideNote` (coral-soft bg, 2px coral left border, italic serif)

**EditFoot (sticky bottom):**
- Left: keyboard-shortcut hint ("`⌘S` save · `esc` discard · `⌘⇧S` save and add another")
- Right: Cancel ghost / Save draft / **Add Product** primary

**Input variants** to implement once:
- Plain `input` (default)
- `with-prefix` — mono prefix (`NRS`) inside the bordered box, left
- `with-suffix` — mono suffix (`g`, `hr`, `days`) right
- `select` — adds a rotated chevron on right
- `textarea` — auto-grow, serif font, italic placeholder

### 4.4 Filaments (`/filaments`)

Same workspace pattern as Inventory. Stats: Types / Spools / Low stock (coral) / Used Jan / Tied up.

**FilamentSwatch widget:** 34×34 rounded square, gradient fill matching the material (CharcoalBlack: dark gradient. OffWhite: cream gradient). Inset 4px ring at 40% opacity to suggest the spool shape.

**Stepper widget:** [`−`] [value] [`+`] in a single bordered pill. Value is serif italic + coral if ≤3 spools (low). Hooked to `+/-` callbacks. See `app.js` lines 156–171 for the JS behavior.

Second table on the screen: **Purchase history** (Date / Filament with mini swatch / Supplier / Qty / Total).

### 4.5 Sales (`/sales`)

Workspace pattern. Stats: Sales / Revenue / Profit (coral) / Margin / Avg ticket.

**FilterRail:** Period · Source · Product · Payment received by.

**Table:** Date / Product (thumb+meta) / Customer (name+phone-mono) / Source (neutral pill) / Amount (right) / Profit (right, moss italic with `+` prefix).

### 4.6 Record Sale (`/sales/new`)

Same edit-page pattern as Add Product.

**Sections:**
1. **What sold** — Product select (with helper line "2 in stock · NRS 166 unit cost · last sold Dec 19, 2025"), Sale price, Date
2. **Customer** — Name, Phone, Instagram, Address — auto-match against existing customers as user types in Name
3. **Marketing & payment** — Source select, Payment received by select, Notes textarea, Followed-up checkbox (with sub-label)

**EditSide:**
- TOC (3 items)
- **Receipt preview card** — looks like a real receipt: "Better *Lamps.*" italic top-left, mono `#BL-007 · 22 MAY 2026` top-right, then line items, then bold coral profit line at the bottom
- **Insight `AsideNote.moss`** — auto-computed: "Margin on this sale is **89%** — above your 85% target. Three more like it covers the workshop's monthly electricity."

### 4.7 Leads (`/leads`)

Stats: Open / Awaiting reply (coral) / Quoted / Pipeline value / Conversion rate.

**FilterRail:** Stage (8 stages incl. New/Awaiting/Quoted/Visited/Discount asked/Won/Lost) · Source · Quick filters (action items).

**Table** — same shape as Sales, but adds "Stage" pill column and "Next follow-up" date. **Coral date** when ≤today (urgent). Pill colors: `Awaiting reply` warn, `Discount asked` low (coral), others default.

### 4.8 Add Lead (`/leads/new`)

3-section edit page.
1. **The person** — Name (required), Instagram, Phone, Alt phone, Gender, Age, Address. Matches against existing leads by last name on save.
2. **What they want** — Source, Interested in (multi-select), Budget, Quantity, Expected delivery, "Asked for discount" check (with sub-label "They mentioned a 10% reduction"), Notes textarea
3. **Tracking** — Stage, Follow-up date, Last contacted, Tags (chip row)

**EditSide:**
- Lead card preview
- **Smart match `AsideNote`** — "Last name **Maharjan** appears in **2 existing leads**. Worth checking before save — same household?"

### 4.9 Expenses (`/expenses`)

Stats: Total Jan / Filament / Ads / Operations / Net (coral if positive).

**FilterRail:** Category (color-tagged) · Period · Vendor.

**Table:** Date / Category (neutral pill) / Description / Vendor / Amount (with `−` prefix and mono `NRS` pre).

---

## 5 · Cross-cutting components

### 5.1 Command palette

Trigger: `Cmd/Ctrl + K`, or click the search input in the topbar.

**Behavior:**
- Fullscreen overlay with blurred dark backdrop (`Color(0xCC000000)` + `BackdropFilter` blur 6)
- Centered card, max-width 640, animated open (fade + tiny scale-up from 0.97)
- Top: search input (italic serif placeholder "Type to navigate, create, or search…"), `esc` chip
- Middle: scrollable command list, grouped (Navigate / Create / Search / Workspace)
- Bottom: keyboard-hint footer ("↑↓ navigate · ↵ open · esc close · Better *Lamps.*")

**Keyboard:** ↑↓ to navigate, Enter to run, Esc to close. Selected item has 3px coral left edge and `bg-3` background.

**Commands** (see `app.js` lines 25–40 for the full list):
- Navigate: Overview / Inventory / Filaments / Sales / Expenses / Leads
- Create: Record a sale (`/sales/new`) / Add a product / Add a lead
- Search: Find a customer / Find an expense (these open the destination screen scoped to the query — basic; can be enhanced later)
- Workspace: Toggle dark/light · Export this month

### 5.2 Toast notifications

When something is saved/deleted/updated, surface a non-blocking toast.

**Layout:**
- Position: bottom-center, 24px from edge (or top-right if you prefer — both work; pick one and stick to it)
- Card: `bg-2` bg, 1px `rule` border, 10px radius, 14px padding
- Icon (left, 18px) — circle background tinted by kind:
  - `success` → moss
  - `warning` → gold
  - `danger` → berry
  - `info` → muted
- Title (`titleMedium`, ink) and optional message (`bodySmall`, italic serif, muted)
- Optional action button (`btn ghost sm`) — typically "Undo"
- Auto-dismiss 4 seconds; pause timer on hover; manual `×` close on right
- Stack vertically with 8px gap when multiple

**API:**
```dart
Toaster.show(
  context,
  kind: ToastKind.success,
  title: 'Sale recorded',
  message: 'AuraSpira → Kiran Giri · NRS 1,499',
  action: ToastAction('Undo', () => salesService.undoLast()),
);
```

**Triggers:**
- Sale recorded → success + Undo
- Product added → success
- Lead added → success
- Filament restocked → info ("+5 spools added")
- Delete confirmed → danger ("AuraGlow deleted") + Undo
- Network error → warning ("Couldn't save — retry?")

Implement with an `OverlayEntry` + `AnimatedSwitcher` inside an app-level `Overlay`. Don't use `SnackBar` — looks wrong against this aesthetic.

### 5.3 Confirmation dialogs

Use sparingly. Only on **destructive actions**: delete product, delete lead, delete expense, archive sale. Never for routine saves.

**Pattern:**
- Modal centered, max-width 440
- `bg-2` background, 1px `rule` border, 12px radius
- Header: italic-serif title "Delete AuraGlow?" (`titleLarge`)
- Body: italic-serif explanation in `ink-2` — "This will remove the product, its cost breakdown, and any sales records linked to it. **This cannot be undone.**" (bold the warning, no caps lock)
- Footer: Cancel ghost / **Delete** primary in `berry` (not coral — destructive ≠ accent)

Build as a normal route or `showDialog` — modal is fine here because it's blocking + non-form.

### 5.4 Status pills

Centralise in one widget. Variants: `healthy` (moss), `low` (coral), `warn` (gold), `berry`, `neutral` (no dot). 11px font, 2px vertical padding, 8px horizontal, 5px dot, pill-shaped.

### 5.5 Filter rail

`SingleChildScrollView` with sticky-on-scroll. Each group is a `Column` with:
- `labelSmall` mono-uppercase muted header
- List of selectable rows: padding 5×8, 5px radius, hover bg `bg-2`. Active row: 3px coral left edge marker (positioned absolute), bg `bg-2`, font-weight 500.
- "Action" rows (e.g., "+ add tag", "+ Best margin") are coral italic serif and behave like buttons, not selectors.

Single-select per group is the default. (Multi-select can be added later for Saved views.)

---

## 6 · Customer detail page (NEW — design forthcoming)

> **Note:** detailed mockup pending. Below is the spec to start scaffolding routes & data.

**Route:** `/customers/:id` (you may also alias `/leads/:id` to it — a lead and a customer are the same entity, different stages).

**Layout sketch:**
- `PageHeader` — crumb "Workspace — Customers / Anjali Maharjan", italic serif h1 with the name, lede summarising their relationship ("3 inquiries · 2 purchases · NRS 4,498 lifetime value")
- Stat strip: Total spent / Items bought / Last seen / Open inquiries
- Two-column body:
  - **Left (2fr)** — Activity timeline: chronological list of events (sale, lead, follow-up, message). Same shape as the Overview activity feed but full-page.
  - **Right (1fr)** — Sticky info card: name, all contact channels, address, tags, notes (editable inline).

Keep this in mind when modelling the data layer: every Sale and every Lead should `belongsTo` a Customer. If the existing schema doesn't separate Customer from Lead, refactor now.

---

## 7 · Behavior & state

| State | Trigger | Storage |
|-------|---------|---------|
| Theme mode | ModeToggle / ⌘\\ / palette command | `SharedPreferences['bl_mode']` |
| Active filters (per screen) | FilterRail click | URL query params (`?status=low&filament=offwhite`) so they survive refresh |
| Sort + group | PaneHeader picker | URL query params |
| Command palette open | ⌘K, ⌘P, click | ephemeral (not persisted) |
| Form drafts | edit-page input change | optional: `SharedPreferences` debounced for unsaved drafts |
| Workshop online indicator | always on | hardcode for v1; tie to socket presence in v2 |

---

## 8 · Files in this handoff

```
designs/
├── Better Lamps.html              ← main hi-fi prototype (open this first)
├── styles.css                     ← all CSS tokens & component styles
├── app.js                         ← router, palette logic, mode toggle, steppers
└── wireframes/
    ├── Better Lamps Redesign Wireframes.html   ← original sketch exploration
    └── styles.css
```

**How to use them:**

1. Open `designs/Better Lamps.html` in a browser at width ≥ 1280.
2. Click each tab in the top nav to see every screen.
3. Press **⌘K** to see the command palette.
4. Click the sun/moon icon (top right) to compare light/dark.
5. When recreating a screen in Flutter, open the corresponding section of `styles.css` for the exact CSS — every spacing, color, and type value is verbatim from the design tokens above.

---

## 9 · Open questions for the team

These were left open in the design phase — flag during implementation:

1. **Currency formatting** — currently hard-coded "NRS". Should this become a setting if Better Lamps expands to other markets?
2. **Multi-user** — "Payment received by" implies multiple operators. Is auth/users in scope for v2?
3. **Funnel/Kanban view for Leads** — table only for now. Funnel view button is in the actions row but unimplemented; tracked separately.
4. **Charts** — design deliberately omits decorative charts. If real charts (revenue over time, stock burn-down) are wanted, they need their own design pass — don't free-style.
5. **Mobile** — desktop-only for v2. The grid breakpoint behavior at < 1024 is undefined and out of scope until the team commits to mobile.

---

## 10 · Definition of done

A screen is "done" when:
- [ ] All tokens come from `BLColors` / `BLTextStyles` — no hardcoded hex or `TextStyle()` literals
- [ ] Both light and dark modes render correctly
- [ ] Hover states match the prototype (coral edge on table rows, bg shift on cards)
- [ ] Add/edit pages are real routes (not `showDialog`)
- [ ] Keyboard shortcuts work (⌘K for palette, ⌘S to save on edit pages, Esc to cancel)
- [ ] Sale recorded → toast appears with Undo
- [ ] Delete actions show a confirmation dialog (berry primary, not coral)
- [ ] No leftover Material defaults peeking through (`SnackBar`, `AlertDialog`, default `TextField` underlines)

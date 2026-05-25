# Handoff — Phase 2 Addendum

> **Read this AFTER the main README.md.** This document covers only what changed since the first hand-off. The base architecture (routing, tokens, type, color, screen layouts) is unchanged — refer to the main README for those.
>
> **Target stack:** Flutter (web).

The updated `designs/Better Lamps.html` + `designs/styles.css` + `designs/app.js` in this folder now include everything below. Open the file in a browser and scroll to the bottom of **Overview** — there's a "Try the new pieces" panel that exercises all four new components.

---

## What's new

| # | Component                | Where to find it in the prototype                  |
|---|--------------------------|----------------------------------------------------|
| 1 | **Customer Detail page** | Route `customers/kiran` (palette `G C`)            |
| 2 | **Toast system**         | Bottom-right; fires on save, delete, restock, etc. |
| 3 | **Confirmation dialog**  | Triggered by Delete in row-menu or demo button     |
| 4 | **Row-menu dropdown**    | Click any `⋯` in a row or page header              |
| 5 | New **palette commands** | Open ⌘K → "Kiran Giri's profile", "Try" group      |

---

## 1 · Customer Detail page

**Route:** `/customers/:id`

Also serves as the underlying entity for Leads. **A lead and a customer are the same record at different stages** — the redesign treats them as one. The existing schema may need a small refactor:

```dart
// Old:        Lead has its own table separate from Sales' customer fields
// New:        Customer is the root entity. Both Lead and Sale belong to a Customer.

class Customer {
  String id;
  String fullName;
  String? instagram;
  String? phone;
  String? altPhone;
  String? address;
  String? gender;
  int? age;
  CustomerStatus status;  // new | active | returning | dormant
  List<String> tags;
  String? privateNotes;
  DateTime firstContactAt;
  DateTime? lastSeenAt;
  // Relationships (loaded as needed)
  List<Sale> sales;
  List<Lead> leads;
}
```

The customer page is the natural place to merge these two view points.

### 1.1 Layout

```
PageHeader  (crumb + h1 + sub + actions: Message · ⋯ · Record Sale)
StatStrip   (5 tiles: Lifetime spend · Items bought · Open inquiries · Source · First contact)
CustomerPage  ───  Grid:  1fr / 340px
  ├── CustomerMain (left, scrollable, takes timeline)
  └── CustomerSide (right, sticky, profile + contact + tags + notes + related)
```

### 1.2 CustomerMain — Activity Timeline

A chronological feed of events, grouped by month. Newest first.

**Event types** (each gets a coloured icon container):

| Type    | Icon class | Bg + border          | Icon (Feather)    |
|---------|------------|----------------------|-------------------|
| `sale`  | `.sale`    | moss tint + 40% rule | `arrow-down-circle` ("incoming money") |
| `lead`  | `.lead`    | coral-soft + line    | `user-plus` or `check`  |
| `msg`   | `.msg`     | bg-3, ink-2 text     | `message-square`  |
| `status`| `.status`  | gold tint + 40% rule | `clock` or `flag` |
| `note`  | `.note`    | bg-2, muted text     | `edit-3`          |

**Event item structure:**

```
[icon 32×32]   What happened (sans 500, ink)         [date mono 10.5px muted]
               Detail line (italic serif ink-2)      [optional amount serif italic moss]
               <optional product chip: thumb + name>
```

Vertical 1px `rule` connector line runs from the bottom of each icon to the top of the next, fading out at the last item. CSS: `position: absolute; left: 21px; top: 36px; bottom: -2px; width: 1px; background: var(--rule);` on `.tl-event:not(:last-child)::before`.

Month header (between groups):
```
JANUARY 2026  ─────────────────────────────  (mono uppercase 10px, 18em letter-spacing, muted, trailing horizontal rule)
```

**Data needed per event:**
```dart
class TimelineEvent {
  String id;
  EventKind kind;       // sale | lead | msg | status | note
  DateTime at;
  String title;         // bold first line
  String? body;         // markdown-italic detail; supports inline <b>
  String? productRef;   // SKU — used for the chip
  int? amountNrs;       // shown right-aligned when set
}
```

### 1.3 CustomerSide — Sticky right rail

Five blocks, top to bottom:

#### a) Profile card
- 56×56 circular avatar (gradient from `#c08658 → #8a5a35`, with first initial in serif italic 24px)
- Customer name (`titleLarge`)
- Inline status pills (`Returning`, `1 inquiry open`, etc.)
- Three-button action row: **Call · DM · Edit** (each fires a toast in the prototype)

#### b) Contact list
- Grouped card with 1px rule between items
- Each row: 28px icon left, label-row mono + value sans, right "copy"/"open" pill
- Click → copy to clipboard + success toast

#### c) Tags
- Chip row, last chip is dashed "+ add tag"

#### d) Notes (private)
- Inline `contenteditable` block, italic serif 13.5px, no border by default
- On focus: coral border + soft glow (same as input focus)
- Auto-save on blur (debounced 800ms) — fire `info` toast on save

#### e) Possibly related
- Smart-match suggestion cards (matched by phone, last name, address)
- Each card: small avatar + name + reason + arrow
- Click → navigate to that customer's profile

### 1.4 Interactions

- **Header ⋯ button** opens the `customer` row-menu variant (see §4)
- **"Record Sale" primary action** → `/sales/new` pre-filled with this customer
- **"Message" action** → opens DM composer (toast for now, real integration later)
- **Clicking a customer name anywhere in the app** (Sales table, Overview pipeline) → routes here

### 1.5 Definition of done

- [ ] Timeline renders mixed event types with correct icon colors
- [ ] Timeline events grouped by month with rule-divider headers
- [ ] Vertical connector line visible between events
- [ ] Sticky right column stays in view while timeline scrolls
- [ ] Notes are inline-editable with debounced autosave
- [ ] Customer name in any other table links here
- [ ] Profile actions (Call/DM/Edit) wire to platform handlers

---

## 2 · Toast system

A non-blocking notification system. Replaces all `SnackBar` and `ScaffoldMessenger` usage.

### 2.1 API

```dart
// From anywhere with a BuildContext:
Toaster.show(
  context,
  kind: ToastKind.success,                // success | info | warning | danger | coral
  title: 'Sale recorded',
  message: 'AuraSpira → Kiran Giri · NRS 1,499',  // optional, supports bold via Text.rich
  undo: () => salesService.undoLast(),     // optional — shows Undo button
  duration: const Duration(seconds: 4),    // default 4s; pauses on hover
);

// Or convenience:
Toaster.success(context, 'Sale recorded', 'AuraSpira → Kiran Giri');
Toaster.warning(context, 'Couldn\'t save', 'Network hiccup. Your changes are safe.');
Toaster.danger(context,  'AuraGlow deleted', 'Removed product.', undo: () => …);
```

### 2.2 Layout (per toast)

```
┌───────────────────────────────────────────────────┐
│ ▏ [icon]  Title                       [Undo]  ✕   │
│ ▏          Detail line in italic serif            │
│ ▏▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁  │  ← progress bar shrinks left→right
└───────────────────────────────────────────────────┘
   ↑ 3px left edge stripe, color per kind
```

- Container: `bg-2` background, 1px `rule-2` border, 12px radius, `shadow-md`
- Left **3px coloured stripe** — never optional. Colour matches the kind:
  - `success` → `moss` (#8AA15F dark / #6B7F4F light)
  - `info`    → `ink-2`
  - `warning` → `gold`
  - `danger`  → `berry`
  - `coral`   → `coral` (use for insights / "margin above target")
- 24×24 rounded icon container, tinted background (kind colour at 18% alpha), kind-coloured icon
- Title: `titleMedium`, ink
- Message: `bodySmall` italic serif, ink-2 (bold via `<b>` → ink, non-italic, weight 500)
- Right-side: optional **Undo** text button (coral, no border) + close ✕
- Bottom: 1.5px progress bar that animates `scaleX(1 → 0)` over `duration` linearly. Pause animation on `hover` / `pointer-enter`.

### 2.3 Stack behaviour

- Position: **bottom-right**, 24px from edges
- New toasts push existing ones **up** (10px gap)
- Max 4 visible — older ones auto-dismiss to make room
- Animate in: `translateY(20) scale(0.96) opacity(0) → final, 240ms cubic-bezier(0.2, 0.9, 0.3, 1)`
- Animate out: `translateX(0) opacity(1) → translateX(20) opacity(0), 200ms`
- Hover any toast: clear auto-dismiss timer; on leave, restart with 2s timeout
- Click outside the toast doesn't dismiss it (it's non-modal); only ✕ or auto-timeout

### 2.4 Triggers in the app

Wire these in your services / view models:

| Action                           | Toast kind | Title              | Has Undo |
|----------------------------------|------------|--------------------|----------|
| Save product (new)               | success    | "Product added"    | ✓        |
| Save sale                        | success    | "Sale recorded"    | ✓        |
| Save lead                        | success    | "Lead added"       | ✓        |
| Filament restocked / +1 spool    | info       | "Filament restocked" | ✗      |
| Delete product / sale / lead     | danger     | "X deleted"        | ✓        |
| Network error on any save        | warning    | "Couldn't save"    | ✗ (retry?) |
| Copy to clipboard                | success    | "Copied"           | ✗        |
| Margin > 85% on a new sale       | coral      | "Margin ↑ NN%"     | ✗ (insight) |

### 2.5 Implementation

Use a global `OverlayEntry` inserted at app startup:

```dart
// In your MaterialApp builder:
return Overlay(
  initialEntries: [
    OverlayEntry(builder: (_) => widget.child!),
    OverlayEntry(builder: (_) => const ToastStack()),
  ],
);
```

The `ToastStack` is a `Positioned` (bottom-right, 24/24) `Column` that listens to a `ToastBus` (`ChangeNotifier` / Riverpod `Provider` / your existing pattern) and renders animated `Toast` widgets.

**Do not use `SnackBar`** — its visual language fights the design (rounded corners, position, materially dense). Roll the custom widget.

### 2.6 Definition of done

- [ ] Five kinds render with correct stripe + tint
- [ ] Auto-dismiss progress bar animates
- [ ] Hover pauses the timer
- [ ] Undo button fires the supplied callback and dismisses
- [ ] Stack of multiple toasts pushes upward, animates in/out
- [ ] Every successful save in the app shows a toast (no silent saves)

---

## 3 · Confirmation dialog

A blocking modal for **destructive actions only**. Never for routine saves.

### 3.1 API

```dart
final ok = await BLDialog.confirm(
  context,
  title: 'Delete Kiran Giri?',
  body: 'This removes the customer along with **1 sale** and **1 lead**. '
        '<warn>This cannot be undone.</warn> Consider archiving instead.',
  confirmLabel: 'Delete',
  danger: true,  // default — uses berry button
);
if (ok) await customerService.delete(id);
```

Returns a `Future<bool>` — completes with `true` on confirm, `false` on Cancel / Esc / outside-click.

### 3.2 Layout

```
┌──────────────────────────────────────────────────────┐
│                                                      │
│   Delete Kiran Giri?            ← italic serif 26  │
│                                                      │
│   This removes the customer along with 1 sale and    │
│   1 lead. This cannot be undone. Consider archiv-    │  ← italic serif 15 ink-2
│   ing instead.                       (warn = berry)  │
│                                                      │
│  ──────────────────────────────────────────────────  │
│  ⏎ confirm · esc cancel              [Cancel] [DELETE] │
└──────────────────────────────────────────────────────┘
                                          ↑ berry primary button
```

- Width: `min(480, 100%)`
- Background: `bg-2`, 1px `rule-2` border, 14px radius, `shadow-lg`
- Backdrop: `rgba(0,0,0,0.55)` + `backdrop-filter: blur(4px)`
- Padding: `28px 28px 22px`
- Title: `Newsreader 500 italic 26px`, `-0.02em` letter-spacing
- Body: `Newsreader 400 15px`, line-height 1.55, ink-2 with selective bold/warn spans:
  - `<b>` → ink color, weight 500, italic (matches running text style)
  - `<warn>` → berry color, weight 500, italic — use for the irreversibility line
- Footer: 1px `rule` top border, 14px top padding
  - Left: mono 10px hint `⏎ confirm · esc cancel`
  - Right: `Cancel` ghost button, then primary action button in **`berry`** (not coral!) when destructive
- Animation in: 180ms cubic-bezier(0.2, 0.8, 0.3, 1), `opacity 0 → 1` + `translateY(8) scale(0.97) → 0/1`
- Animation out: 160ms `opacity 1 → 0` (no transform)

### 3.3 Keyboard

- **Enter** → confirms (when focus isn't in a text input within the dialog body — for this redesign there is no body input)
- **Esc** → cancels
- **Tab** → cycles between Cancel and the primary
- On open, primary button gets focus automatically (so Enter just works)

### 3.4 Where to use it

Only these actions:

| Action                  | Title                          | Notes                                 |
|-------------------------|--------------------------------|---------------------------------------|
| Delete product          | "Delete AuraGlow?"             | Mention linked sales count            |
| Delete customer/lead    | "Delete Kiran Giri?"           | Mention linked sales + leads          |
| Delete sale             | "Reverse this sale?"           | "Stock will be added back."           |
| Delete filament         | "Remove PLA · CharcoalBlack?"  | Mention spools remaining              |
| Archive product         | "Archive AuraNest?"            | Not destructive → primary in coral, not berry |
| Clear filters           | **don't** — just clear them    |                                       |
| Cancel a draft sale     | **don't** — esc-able           |                                       |

### 3.5 Definition of done

- [ ] Returns a `Future<bool>` — confirms or rejects on every close path
- [ ] Esc and outside-click both resolve `false`
- [ ] Primary is `berry` for destructive, `coral` for non-destructive (archive, etc.)
- [ ] Backdrop is blurred, dialog is animated in/out
- [ ] Enter confirms when primary has focus

---

## 4 · Row-menu dropdown

A small floating menu anchored to a `⋯` trigger.

### 4.1 Anchoring

- Anchor: any `Widget` with the trigger (typically `IconButton(icon: Icons.more_horiz)`)
- Position: below trigger, right-aligned. If overflowing viewport bottom, flip above.
- 6px gap between trigger and menu
- Min-width: 200px
- Animation in: 120ms `opacity 0 → 1` + `translateY(-4) → 0`

### 4.2 Item shape

```
┌────────────────────────────────────────────┐
│ [icon 14]  Edit                       [⏎]  │
│ [icon 14]  Duplicate                  [⌘D] │
│ [icon 14]  Archive                         │
│  ─── 1px rule, 5px above/below ───         │
│ [icon 14]  Delete                     [⌫]  │   ← danger row: berry text + icon
└────────────────────────────────────────────┘
```

- Container: `bg-2`, 1px `rule-2`, 10px radius, `shadow-md`, 6px padding
- Item: 7×10 padding, 6px radius, hover bg `bg-3`
- Icon: 14×14, muted (or berry for `danger` items)
- Label: `bodyMedium`, ink (berry for danger)
- Optional right-aligned mono keyboard hint
- Danger item: full row text + icon in `berry`; hover bg = `rgba(196,106,122,0.10)`

### 4.3 Default item set (per row type)

For **inventory / sales / leads / expenses** rows:

```
Edit                            ⏎
Duplicate                       ⌘ D
Archive
─── separator ───
Delete                          ⌫    (danger)
```

For **customer** page header:

```
Edit profile
Merge with another customer…
Export history (PDF)
─── separator ───
Delete customer                       (danger)
```

For **filament** rows (when relevant):

```
Restock…                        +
Adjust quantity
─── separator ───
Mark as discontinued                  (danger)
```

### 4.4 Definition of done

- [ ] Opens anchored below trigger; flips above when near bottom
- [ ] Closes on item click, Esc, or outside click
- [ ] Danger row shown in berry with hover tint
- [ ] Delete actions route through the confirmation dialog (§3) before firing

---

## 5 · New command palette entries

Append these to your existing command list:

```dart
const navigateExtra = [
  PaletteCommand(group: 'Navigate', label: "Kiran Giri's profile",
    sub: 'Customer · returning · 1 open inquiry', route: '/customers/kiran', keybind: 'G C'),
];

// "Try" group only in dev / debug builds — useful for QA, drop from prod
const tryGroup = [
  PaletteCommand(group: 'Try', label: 'Show a success toast', action: ToastAction.success),
  PaletteCommand(group: 'Try', label: 'Show a warning toast', action: ToastAction.warning),
  PaletteCommand(group: 'Try', label: 'Show an info toast',   action: ToastAction.info),
  PaletteCommand(group: 'Try', label: 'Show a delete confirmation', action: DialogAction.demo),
];
```

The "Try" group is intentional dev tooling — ship it behind `kDebugMode` so QA can fire each variant from anywhere.

---

## 6 · Updated `Definition of done` for the full app

Add these to the master DoD checklist:

- [ ] A lead and a customer share a single underlying entity
- [ ] Clicking any customer name routes to `/customers/:id`
- [ ] The customer page has a working timeline (sales + leads + status + messages) sorted by date, grouped by month
- [ ] No `SnackBar` left in the codebase
- [ ] No `showDialog` for routine actions — only destructive confirmations
- [ ] Every successful save fires a toast
- [ ] Every delete action goes through the confirmation dialog → toast pattern
- [ ] Row `⋯` menus open a custom dropdown, not a `PopupMenuButton` with Material styling

---

## 7 · Files in this addendum

All files in `designs/` have been **replaced with the latest versions** that include the additions above. Open `designs/Better Lamps.html` to interact with everything described in this doc.

Specifically:
- `designs/Better Lamps.html` — adds the `customers/kiran` screen + the demo bar on Overview
- `designs/styles.css` — adds CSS for customer page, timeline, toast, dialog, row-menu (search for the `═══ CUSTOMER DETAIL` / `═══ TOAST SYSTEM` / `═══ CONFIRMATION DIALOG` / `═══ ROW MENU DROPDOWN` block comments)
- `designs/app.js` — adds the `toast()`, `blConfirm()`, dropdown, and palette extensions

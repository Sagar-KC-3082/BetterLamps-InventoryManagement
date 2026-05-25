# Better Lamps — Gemini Handoff

## Situation

This is a Flutter **web** app for a 3D-printed lamp workshop (inventory, sales, filaments, expenses, leads). It uses Firebase Firestore + Provider for state. A full UI redesign was planned but **nothing has been implemented yet** — the codebase is 100% original. You are starting the redesign from scratch.

---

## Codebase — What Exists Today

**Stack:** Flutter web, Firebase Firestore, Provider (ChangeNotifier), `google_fonts` already in pubspec.

**File structure:**
```
lib/
  main.dart                     ← StatefulWidget with left sidebar nav, 5 tabs
  theme/app_theme.dart          ← Old blue Material theme, Inter + PlusJakartaSans
  services/database_service.dart ← ChangeNotifier, Firestore listeners, CRUD
  services/theme_service.dart   ← ThemeMode toggle via Provider
  models/product.dart, sale.dart, expense.dart, filament.dart, lead.dart, cost_price.dart
  screens/dashboard_screen.dart, inventory_screen.dart, filaments_screen.dart,
          sales_screen.dart, expenses_screen.dart, leads_screen.dart
  widgets/product_form_dialog.dart, sale_form_dialog.dart, expense_form_dialog.dart,
          product_details_sheet.dart, sale_details_sheet.dart,
          lead_form_dialog.dart, lead_details_sheet.dart
```

**Key DatabaseService API (do not change):**
- `db.products`, `db.sales`, `db.expenses`, `db.filaments`, `db.leads` — live lists
- `db.addProduct(p)`, `db.updateProduct(p)`, `db.deleteProduct(id)`
- `db.addSale(s)`, `db.updateSale(s)`, `db.deleteSale(id)`
- `db.addExpense(e)`, `db.deleteExpense(id)`
- `db.addFilament(f)`, `db.updateFilamentSpools(id, qty)`
- `db.addLead(l)`, `db.updateLead(l)`, `db.deleteLead(id)`

**Do NOT touch:** models, database_service.dart, firebase_options.dart, firebase setup in main().

---

## What You Need to Build

### Step 1 — pubspec.yaml
Add:
```yaml
go_router: ^14.0.0
shared_preferences: ^2.3.0
```
Run `flutter pub get`.

---

### Step 2 — lib/theme/app_theme.dart (full replacement)

Create `BLColors` as a `ThemeExtension<BLColors>` with these fields (both dark + light):

**Dark (default):**
`bg=#1A1612, bg2=#221D18, bg3=#2A2520, bgHover=#2E2823, ink=#F3ECDD, ink2=#C4B8A0, muted=#897E6B, faint=#5C5346, rule=#332C25, rule2=#443B32, coral=#D9745A, coral2=#E88566, coralSoft=Color(0x1AD9745A), moss=#8AA15F, berry=#C46A7A, gold=#C9A96A`

**Light:**
`bg=#F4EDE0, bg2=#EDE4D1, bg3=#E3D8BF, bgHover=#E8DFCA, ink=#1D1916, ink2=#4A4339, muted=#8B8275, faint=#B6AB94, rule=#D4C8AF, rule2=#C0B298, coral=#C8654A, coral2=#A5503A, coralSoft=Color(0x14C8654A), moss=#6B7F4F, berry=#9E4D5B, gold=#A18348`

Add `static BLColors of(BuildContext context)` and a `BuildContext` extension `.bl` returning the extension.

**Typography** via `google_fonts`:
- Newsreader → display/headlines/money values (italic when profit)
- Inter Tight → body/buttons/table cells
- JetBrains Mono → labels, SKUs, dates, keyboard hints (always uppercase for labelMedium/labelSmall)

TextTheme sizes: displayLarge=38/w500/italic, displayMedium=26/w500, headlineSmall=22/w500, titleLarge=18/w500, titleMedium=InterTight 14/w500, bodyLarge=InterTight 14/w400, bodyMedium=InterTight 13.5/w400, bodySmall=InterTight 12.5/w400, labelLarge=InterTight 12.5/w500, labelMedium=JetBrainsMono 10.5/w500/ls+1.6, labelSmall=JetBrainsMono 9.5/w500/ls+1.5.

ThemeData: coral as primary, no shadows on cards (1px rule border instead), 7px input radius, coral focus border, bg2 input fill. No Material blue anywhere.

---

### Step 3 — lib/main.dart (full replacement)

- Keep `Firebase.initializeApp`, `DatabaseService`, `ThemeService` Provider setup
- Replace `MaterialApp` navigation with `go_router` + `ShellRoute`
- **Routes:**
  - `/` → OverviewScreen
  - `/inventory` → InventoryScreen, `/inventory/new` → AddProductPage
  - `/filaments` → FilamentsScreen
  - `/sales` → SalesScreen, `/sales/new` → RecordSalePage
  - `/expenses` → ExpensesScreen, `/expenses/new` → AddExpensePage
  - `/leads` → LeadsScreen, `/leads/new` → AddLeadPage
  - `/customers/:id` → CustomerDetailPage
- **Shell:** Column → TopBar (h=56) + Expanded child
- **TopBar:** "Better *Lamps.*" Newsreader italic wordmark | nav tabs (Overview/Inventory/Filaments/Sales/Expenses/Leads) with 2px coral bottom border on active | ⌘K search button | sun/moon toggle
- Wrap app with `ToastOverlay` widget
- Theme persisted in SharedPreferences key `bl_mode`

---

### Step 4 — lib/widgets/bl_components.dart (NEW)

Build these once, use everywhere:

- **BLColors** access via `context.bl`
- **BLStatusPill(kind)** — kinds: healthy(moss dot), low(coral dot), warn(gold dot), berry, neutral. JetBrains Mono 11px uppercase, pill-shaped
- **BLStockBar(available, total)** — 70px track, 5px tall, moss=healthy/coral=low fill, "2/4" text bold first
- **MoneyText(amount, {positive=false})** — "NRS" in JetBrainsMono 10px muted + number in Newsreader, italic+coral if positive
- **BLPageHeader({crumb, title, subtitle, actions})** — breadcrumb labelSmall, italic Newsreader h1, lede, right-aligned actions
- **BLSectionCard({title, child})** — bg2 bg, 1px rule border, 8px radius, no shadow
- **BLFilterRail({groups})** — 220px, each group has labelSmall mono header + selectable rows; active row = 3px coral left edge + bg2 bg; action rows = coral italic serif
- **BLTableRow({onTap, child})** — hover: bgHover bg + AnimatedContainer 3px coral left edge (100ms)
- **BLWorkspace({filterRail, child})** — Row: 220px rail + Expanded right pane
- **BLInput({label, prefix, suffix, ...})** — bg2 fill, 7px radius, rule border, coral focus
- **BLButton({label, kind, onTap})** — kinds: primary(coral), ghost(rule border), danger(berry)
- **BLConfirmDialog** — `static Future<bool> show(context, {title, body, confirmLabel, danger=true})`. Newsreader italic title, Newsreader italic body, berry or coral confirm button, blurred backdrop. Returns bool.
- **BLRowMenu({items, trigger})** — custom anchored dropdown (NOT PopupMenuButton). bg2, rule2 border, 10px radius, 6px padding. Items: icon+label+optional keybind. Danger items in berry. Separator support. Closes on Esc/outside-click.
- **FilamentSwatch(color)** — 34×34 rounded square, gradient fill (CharcoalBlack: dark gradient; OffWhite: cream gradient)

---

### Step 5 — lib/services/toast_service.dart (NEW)

```dart
enum ToastKind { success, info, warning, danger, coral }

class Toaster {
  static void show(BuildContext context, {required ToastKind kind, required String title, String? message, VoidCallback? undo});
  static void success(BuildContext context, String title, [String? message, VoidCallback? undo]);
  static void warning(BuildContext context, String title, [String? message]);
  static void danger(BuildContext context, String title, [String? message, VoidCallback? undo]);
  static void info(BuildContext context, String title, [String? message]);
}
```

Layout: bottom-right, 24px from edges. Per toast: bg2 bg, 1px rule2 border, 12px radius, **3px coloured left stripe** (moss=success, ink2=info, gold=warning, berry=danger, coral=coral), 24×24 tinted icon, title in titleMedium, message in bodySmall italic Newsreader, optional Undo text button, × close. Bottom: 1.5px progress bar animating scaleX 1→0 over 4s, paused on hover. Stack pushes up with 10px gap. Max 4 visible. Animate in: fade+translateY(20)+scale(0.96), 240ms. Animate out: translateX(20)+fade, 200ms. Use OverlayEntry (not SnackBar).

**Wire toasts to:** every save (success), every delete (danger+undo), filament restock (info), network error (warning), margin >85% on sale (coral insight).

---

### Step 6 — lib/widgets/command_palette.dart (NEW)

Trigger: ⌘K / ⌘P or clicking the TopBar search button.

- Fullscreen overlay: `Color(0xCC000000)` + `BackdropFilter` blur 6
- Centered card: max-width 640, bg2, 12px radius, rule border
- TextField at top (Newsreader italic placeholder "Type to navigate, create, or search…")
- Commands grouped — Navigate: Overview/Inventory/Filaments/Sales/Expenses/Leads | Create: Record a sale/Add a product/Add a lead | Workspace: Toggle dark/light
- **Phase 2 additions:** also add "Kiran Giri's profile" in Navigate group (route `/customers/kiran`). In `kDebugMode`, add "Try" group: Show success/warning/info toast + Show delete confirmation
- ↑↓ navigate, Enter run, Esc close. Active item: 3px coral left edge + bg3 bg
- Animate open: FadeTransition + ScaleTransition 0.97→1.0, 200ms

---

### Step 7 — Screens (rewrite each, keep DatabaseService calls)

**overview_screen.dart** (replaces dashboard_screen.dart):
- BLPageHeader: crumb "Workspace — Overview", title "This month, at a glance." (italic), actions: Export ghost + Record Sale primary
- StatStrip: 6 tiles (Products, Stock, Revenue, Profit coral+italic, Low Stock coral, Expenses berry). Full-width row, 1px rule dividers, no bg images
- OverviewGrid (1.6fr/1fr): Left BLSectionCard "Critical stock" (low-stock table with BLStockBar + BLStatusPill) | Right BLSectionCard "Recent activity" (date mono / product+customer / amount moss italic)
- Full-width BLSectionCard "Pipeline" — 3 most recent leads (name, stage pill, follow-up date)

**inventory_screen.dart:** BLWorkspace. FilterRail: Status (All/Healthy/Low/Out of stock) + Filament type. Table via BLTableRow: thumb+name+SKU / Price MoneyText / BLStockBar / Margin / BLStatusPill / BLRowMenu(Edit→`/inventory/:id`, Duplicate, Archive, Delete→BLConfirmDialog→Toaster.danger)

**add_product_page.dart** (NEW — real route, not modal): 2-col grid `1fr/340px`. Left: sections Basics + Stock & price + Cost breakdown (each separated by 1px rule). Right sticky: TOC with coral active border + live preview card (recalculates as user types) + AsideNote (coral-soft bg, 2px coral left border, Newsreader italic). Sticky footer: keybind hint left + Cancel ghost / Add Product primary right. ⌘S saves. On save: `db.addProduct()` → `Toaster.success` → `context.pop()`.

**sales_screen.dart:** BLWorkspace. Stats: Sales / Revenue / Profit coral / Avg ticket. FilterRail: Period + Source. Table: date mono / product thumb+name / customer name+phone mono / source neutral pill / amount MoneyText / profit moss italic. Add Sale → `/sales/new`.

**record_sale_page.dart** (NEW): 2-col. Sections: What sold (product select with stock helper, sale price NRS prefix, date) / Customer (name auto-match, phone, instagram, address) / Marketing (source, payment by, notes, followed-up checkbox). Right sticky: TOC + receipt preview card ("Better *Lamps.*" header, line items, coral profit line) + moss AsideNote showing margin %. On save: `Toaster.show(kind: coral if margin>85, else success, title: 'Sale recorded', message: 'Product → Customer · NRS X', undo: ...)`.

**filaments_screen.dart:** Stats strip (Types/Spools/Low stock coral/Tied up). FilamentSwatch widget. Stepper pill [−][value][+] — Newsreader italic value, coral if ≤3. Second table: Purchase history. BLRowMenu: Restock/Adjust quantity/Mark discontinued.

**expenses_screen.dart:** BLWorkspace. Stats: Total + category breakdown. FilterRail: Category + Period. Table: date mono / category neutral pill / description / amount with "−" prefix + mono NRS + berry color. Add Expense → `/expenses/new`.

**add_expense_page.dart** (NEW): Single-column centered. Fields: Date, Category select, Description, Amount (NRS prefix), Vendor, Notes. Save → `db.addExpense()` → `Toaster.success` → pop.

**leads_screen.dart:** BLWorkspace. Stats: Open / Awaiting reply coral / Quoted / Pipeline value. FilterRail: Stage (All/New/Awaiting/Quoted/Won/Lost) + Source. Table: date mono / name (clickable → `/customers/:id`) / stage BLStatusPill / follow-up date (coral if ≤today). BLRowMenu: Edit/Duplicate/Archive/Delete.

**add_lead_page.dart** (NEW): 3-section edit page. Sections: The person (Name, Instagram, Phone, Gender, Address) / What they want (Source, Interested in, Budget, Expected delivery, Notes) / Tracking (Stage select, Follow-up date, Tags chip row). Right sticky: lead preview card. Save → `Toaster.success` → pop.

---

### Step 8 — Customer Detail Page (Phase 2) — lib/screens/customer_detail_page.dart (NEW)

Route: `/customers/:id`

A lead and a customer are the same entity. Add a `Customer` model:
```dart
class Customer {
  String id, fullName;
  String? instagram, phone, altPhone, address, gender;
  int? age;
  String status; // new | active | returning | dormant
  List<String> tags;
  String? privateNotes;
  DateTime firstContactAt;
  DateTime? lastSeenAt;
}
```

**Layout:**
- BLPageHeader: crumb, italic Newsreader h1 name, lede ("3 inquiries · 2 purchases · NRS 4,498 lifetime"), actions: Message ghost + ⋯ BLRowMenu + Record Sale primary
- StatStrip (5 tiles): Lifetime spend / Items bought / Open inquiries / Source / First contact
- 2-col grid `1fr/340px`:
  - **Left (CustomerMain, scrollable):** Activity timeline — chronological events grouped by month (newest first). Month headers: `JANUARY 2026 ───` in labelSmall muted. Each event: 32×32 coloured icon container (sale=moss tint, lead=coral-soft, msg=bg3, status=gold tint, note=bg2) + title bodyMedium bold + detail bodySmall italic Newsreader + optional amount MoneyText right. Vertical 1px rule connector line between events.
  - **Right (CustomerSide, sticky):** 
    - Profile card: 56×56 gradient avatar + name titleLarge + status pills + Call/DM/Edit button row
    - Contact list card: phone, instagram, address — each row has copy pill (click → clipboard + `Toaster.success('Copied')`)
    - Tags chip row + dashed "+ add tag"
    - Private notes: inline editable, Newsreader italic, coral focus border, auto-save on blur debounced 800ms → `Toaster.info('Notes saved')`
    - "Possibly related" smart-match cards (match by last name/phone)

Clicking any customer name in Sales table or Overview pipeline navigates to `/customers/:id`.

---

## Phase 2 Confirmation Dialog Spec

`BLConfirmDialog.show()` must:
- Return `Future<bool>`
- Width: `min(480, 100%)`
- bg2 background, 1px rule2 border, 14px radius, blurred backdrop `rgba(0,0,0,0.55)` blur 4px
- Title: Newsreader 500 italic 26px
- Body: Newsreader 400 15px italic, ink2. `<warn>` spans → berry. `<b>` spans → ink w500
- Footer: 1px rule top, left mono hint "⏎ confirm · esc cancel", right: Cancel ghost + confirm button (berry if danger=true, coral if danger=false)
- Enter confirms, Esc cancels, outside-click cancels
- Animate: 180ms fade+translateY(8)+scale(0.97) in; 160ms fade out

---

## Definition of Done Checklist

- [ ] All colors from `BLColors` — zero hardcoded hex in screens
- [ ] Both dark and light modes correct
- [ ] Coral is the ONLY accent — no blue anywhere
- [ ] TopBar replaces sidebar, go_router routes all work
- [ ] Add/edit are real routes, not `showDialog`
- [ ] ⌘K command palette opens, navigates, closes with Esc
- [ ] Every save → Toaster success (no silent saves)
- [ ] Every delete → BLConfirmDialog → Toaster danger + Undo
- [ ] Table rows have hover state (bgHover + coral left edge)
- [ ] ⋯ menus use BLRowMenu (not PopupMenuButton)
- [ ] No SnackBar anywhere in the codebase
- [ ] Customer name anywhere → `/customers/:id`
- [ ] Customer page timeline renders with connector line, month groups
- [ ] Notes inline-editable with auto-save toast
- [ ] `flutter analyze` → 0 errors

---

## Important Rules

1. **Never change models or DatabaseService** — UI layer only
2. **Never use SnackBar** — always Toaster
3. **Never use showDialog for routine saves** — only BLConfirmDialog for destructive actions
4. **Never use PopupMenuButton** — always BLRowMenu
5. **Coral is the only accent** — never use blue as a brand color
6. The existing `ThemeService` + `Provider` setup stays; just add `ThemeNotifier` backed by SharedPreferences for persistence

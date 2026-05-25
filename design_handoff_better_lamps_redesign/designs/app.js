/* ─────────────────────────────────────────────
   Better Lamps · Ledger · app.js
   Router · mode toggle · ⌘K palette
   ───────────────────────────────────────────── */

(function () {
  const screens = document.querySelectorAll('[data-screen]');
  const tabs    = document.querySelectorAll('[data-route]');
  const STORAGE_KEY = 'bl_state_v1';

  /* ─── Persistent state ────────────────────── */
  const load = () => {
    try { return JSON.parse(localStorage.getItem(STORAGE_KEY)) || {}; }
    catch { return {}; }
  };
  const save = (s) => localStorage.setItem(STORAGE_KEY, JSON.stringify(s));
  const state = Object.assign({ route: 'overview', mode: 'dark' }, load());

  /* ─── Mode toggle ─────────────────────────── */
  function applyMode(m) {
    document.body.classList.toggle('light', m === 'light');
    const btn = document.getElementById('mode-btn');
    if (btn) {
      btn.innerHTML = m === 'light'
        ? `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>`
        : `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M4.93 19.07l1.41-1.41M17.66 6.34l1.41-1.41"/></svg>`;
      btn.setAttribute('aria-label', m === 'light' ? 'Switch to dark mode' : 'Switch to light mode');
    }
  }
  applyMode(state.mode);

  /* ─── Routing ─────────────────────────────── */
  function go(route) {
    state.route = route;
    save(state);
    screens.forEach(s => s.classList.toggle('active', s.dataset.screen === route));
    // Map sub-routes back to parent tab for the top-nav highlight
    const tabKey = route.split('/')[0];
    tabs.forEach(t => t.classList.toggle('active', t.dataset.route === tabKey));
    // scroll to top of stage
    window.scrollTo({ top: 0, behavior: 'instant' });
  }

  tabs.forEach(t => t.addEventListener('click', () => go(t.dataset.route)));
  // delegate for any [data-go]
  document.addEventListener('click', (e) => {
    const el = e.target.closest('[data-go]');
    if (el) { e.preventDefault(); go(el.dataset.go); }
  });

  /* ─── Mode toggle button ──────────────────── */
  document.getElementById('mode-btn').addEventListener('click', () => {
    state.mode = state.mode === 'light' ? 'dark' : 'light';
    save(state);
    applyMode(state.mode);
  });

  /* ─── Command palette ─────────────────────── */
  const palette = document.getElementById('palette');
  const paletteInput = document.getElementById('palette-input');
  const paletteList  = document.getElementById('palette-list');

  const commands = [
    { group: 'Navigate', label: 'Overview',          sub: 'Dashboard, recent activity',   route: 'overview',     k: 'G O' },
    { group: 'Navigate', label: 'Inventory',          sub: 'Products & stock',              route: 'inventory',    k: 'G I' },
    { group: 'Navigate', label: 'Filaments',          sub: 'Spool rack & suppliers',        route: 'filaments',    k: 'G F' },
    { group: 'Navigate', label: 'Sales',              sub: 'Transactions ledger',           route: 'sales',        k: 'G S' },
    { group: 'Navigate', label: 'Expenses',           sub: 'Categorised spend',             route: 'expenses',     k: 'G E' },
    { group: 'Navigate', label: 'Leads',              sub: 'Pipeline & follow-ups',         route: 'leads',        k: 'G L' },
    { group: 'Create',   label: 'Record a sale',      sub: 'New transaction',               route: 'sales/new',    k: 'N S' },
    { group: 'Create',   label: 'Add a product',      sub: 'New lamp design',               route: 'inventory/new', k: 'N P' },
    { group: 'Create',   label: 'Add a lead',         sub: 'Inquiry intake',                route: 'leads/new',    k: 'N L' },
    { group: 'Search',   label: 'Find a customer…',   sub: 'Across sales & leads',          route: 'sales',        k: '' },
    { group: 'Search',   label: 'Find an expense…',   sub: 'By vendor or category',         route: 'expenses',     k: '' },
    { group: 'Workspace', label: 'Toggle dark / light', sub: 'Match the time of day',       action: 'mode',        k: '⌘ \\' },
    { group: 'Workspace', label: 'Export this month',   sub: 'CSV · 6 sales · 11 expenses', action: 'export',      k: '⌘ E' },
  ];

  let paletteSel = 0;
  let paletteFiltered = commands;

  function renderPalette() {
    const q = paletteInput.value.trim().toLowerCase();
    paletteFiltered = q
      ? commands.filter(c => (c.label + ' ' + c.sub + ' ' + c.group).toLowerCase().includes(q))
      : commands;
    paletteSel = Math.min(paletteSel, Math.max(0, paletteFiltered.length - 1));

    if (paletteFiltered.length === 0) {
      paletteList.innerHTML = `<div style="padding: 40px; text-align: center; font-family: var(--serif); font-style: italic; color: var(--muted); font-size: 15px;">Nothing for "${escapeHtml(q)}". Try less.</div>`;
      return;
    }

    let html = '';
    let lastGroup = null;
    paletteFiltered.forEach((c, i) => {
      if (c.group !== lastGroup) {
        html += `<div class="cmd-group">${c.group}</div>`;
        lastGroup = c.group;
      }
      html += `<div class="cmd-item ${i === paletteSel ? 'sel' : ''}" data-idx="${i}">
        <span class="ic">${iconFor(c.group)}</span>
        <span class="lbl">${escapeHtml(c.label)}<span class="sub">${escapeHtml(c.sub)}</span></span>
        ${c.k ? `<span class="k">${escapeHtml(c.k)}</span>` : ''}
      </div>`;
    });
    paletteList.innerHTML = html;
  }

  function iconFor(group) {
    if (group === 'Navigate')  return `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polygon points="3,11 22,2 13,21 11,13 3,11"/></svg>`;
    if (group === 'Create')    return `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14M5 12h14"/></svg>`;
    if (group === 'Search')    return `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><path d="m21 21-4.3-4.3"/></svg>`;
    return `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 1 1-4 0v-.09a1.65 1.65 0 0 0-1-1.51 1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 1 1 0-4h.09a1.65 1.65 0 0 0 1.51-1 1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33h0a1.65 1.65 0 0 0 1-1.51V3a2 2 0 1 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82v0a1.65 1.65 0 0 0 1.51 1H21a2 2 0 1 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>`;
  }

  function escapeHtml(s) {
    return String(s).replace(/[&<>"']/g, c => ({ '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;' }[c]));
  }

  function openPalette() {
    palette.classList.add('open');
    paletteInput.value = '';
    paletteSel = 0;
    renderPalette();
    setTimeout(() => paletteInput.focus(), 20);
  }
  function closePalette() { palette.classList.remove('open'); }

  function runCommand(c) {
    closePalette();
    if (c.action === 'mode') {
      state.mode = state.mode === 'light' ? 'dark' : 'light';
      save(state); applyMode(state.mode); return;
    }
    if (c.route) { go(c.route); }
  }

  paletteInput.addEventListener('input', () => { paletteSel = 0; renderPalette(); });
  paletteInput.addEventListener('keydown', (e) => {
    if (e.key === 'ArrowDown') { paletteSel = Math.min(paletteFiltered.length - 1, paletteSel + 1); renderPalette(); e.preventDefault(); }
    if (e.key === 'ArrowUp')   { paletteSel = Math.max(0, paletteSel - 1); renderPalette(); e.preventDefault(); }
    if (e.key === 'Enter')     { const c = paletteFiltered[paletteSel]; if (c) runCommand(c); }
    if (e.key === 'Escape')    { closePalette(); }
  });
  paletteList.addEventListener('click', (e) => {
    const item = e.target.closest('.cmd-item');
    if (!item) return;
    const idx = Number(item.dataset.idx);
    const c = paletteFiltered[idx];
    if (c) runCommand(c);
  });
  palette.addEventListener('click', (e) => {
    if (e.target === palette) closePalette();
  });

  // ⌘K / Ctrl-K / clicking the topbar search opens palette
  document.addEventListener('keydown', (e) => {
    const mod = e.metaKey || e.ctrlKey;
    if (mod && e.key.toLowerCase() === 'k') { e.preventDefault(); openPalette(); return; }
    if (mod && e.key === '\\') { e.preventDefault();
      state.mode = state.mode === 'light' ? 'dark' : 'light';
      save(state); applyMode(state.mode); return; }
    if (e.key === 'Escape' && palette.classList.contains('open')) closePalette();
  });
  document.querySelectorAll('[data-open-palette]').forEach(el => {
    el.addEventListener('click', openPalette);
  });

  /* ─── Filter rail interactivity ───────────── */
  document.addEventListener('click', (e) => {
    const li = e.target.closest('.rail-list li');
    if (!li || li.classList.contains('action')) return;
    const ul = li.parentElement;
    // single-select within group
    ul.querySelectorAll('li').forEach(x => x.classList.remove('active'));
    li.classList.add('active');
  });

  /* ─── Check toggles ───────────────────────── */
  document.addEventListener('click', (e) => {
    const c = e.target.closest('.check');
    if (c) c.classList.toggle('on');
  });

  /* ─── Stepper +/- ─────────────────────────── */
  document.addEventListener('click', (e) => {
    const inc = e.target.closest('.stepper button');
    if (!inc) return;
    const v = inc.parentElement.querySelector('.v');
    if (!v) return;
    const isMinus = inc.dataset.act === '-';
    let n = parseInt(v.textContent, 10) || 0;
    n = Math.max(0, n + (isMinus ? -1 : 1));
    v.textContent = n;
    v.classList.toggle('low', n <= 3);
  });

  /* ─── Initial route ───────────────────────── */
  go(state.route);
})();

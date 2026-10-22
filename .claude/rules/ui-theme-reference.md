# UI theme reference — verified from supplied theme CSS

This file records the theme details verified in the supplied `Infath_Reactive_Theme` CSS. It is a reference, not permission to change global styling without impact analysis. If the deployed theme differs from this snapshot, inspect the live theme through MCP and follow the live implementation.

## 1. Typography
- The CSS defines the `Infath` font family using:
  - `/Infath_Reactive_Theme/IBMPlexSansArabic-Bold.woff2` (weight 700)
  - `/Infath_Reactive_Theme/IBMPlexSansArabic-Regular.woff2` (weight 400)
- It also defines a `Cairo` font face using `/Infath_Reactive_Theme/Cairo-Regular.ttf` (weight 500).
- Global `body`, inputs, textareas, selects, and buttons use `font-family: 'Infath'` and `font-size: 0.875rem`.
- The CSS defines heading/typography custom properties including `--font-size-display`, `--font-size-h1` through `--font-size-h6`, `--font-size-base`, `--font-size-s`, and `--font-size-xs`.
- Tablet and phone rules adjust several heading-size custom properties. Inspect the actual selector and inheritance before relying on a token value.

## 2. Verified theme variables
Use these existing variables when they fit the design; verify their current values in the live theme before changing them.

| Variable | Value in supplied CSS |
|---|---|
| `--color-error` | `#9B3E30` |
| `--color-red` | `#FF2116` |
| `--color-success` | `#006666` |
| `--color-primary` | `#01355A` |
| `--color-primary-hover` | `#00796F` |
| `--color-secondary` | `#17A3A3` |
| `--color-tertiary-1` | `#8FBA1F` |
| `--color-tertiary-2` | `#8D8070` |
| `--color-tertiary-3` | `#D3DFE3` |
| `--color-gray-1` | `#E9ECEF` |
| `--color-gradient-fill` | Navy-to-teal gradient beginning at `#01355A` and ending at `#006666` |
| `--color-neutral-11` | `#6F6F6F` |
| `--color-background-body` | `#ffffff` |
| `--header-color` | Gradient using `#00796F` and `#005470` |

The supplied CSS also references OutSystems UI variables such as `--space-none`, `--space-s`, `--space-base`, `--space-m`, `--space-l`, `--border-size-s`, `--border-size-m`, `--border-radius-soft`, and `--font-semi-bold`. Do not assume these are defined in this file; check the active theme and OutSystems UI stylesheet.

## 3. Existing selectors and patterns
The supplied CSS includes styling for selectors such as `.btn`, `.header`, `.header-top`, `.content`, `.dashboard-card`, `.dashboard-card_image`, `.dashboard-card_title`, `.dashboard-card_label`, `.dashboard-card_status`, `.status-card`, `.btn-icon`, `.custom-card-title`, `.custom-card`, `.footer-actions`, `.arrow-container`, `.side-list`, `.side-list-items`, `.arrow-sidemenu-collapsed`, `.app-menu-small-width`, `.app-menu-full-width`, `.table`, `.table-responsive`, `.outlined-label`, `.outlined-label-input`, `.outlined-label-text`, `.layout-multi-menu`, `.main-content-body`, `.sidemenu`, `.sidemenu-item`, `.BorderRed`, `.btn-secondary`, `.btn-primary-light`, `.popup-dialog`, `.popup-dialog-new`, and `.skinny-card`.

These names are a discovery shortlist, not a guarantee that each selector is suitable for every page. Search the full CSS and inspect the target markup before reusing one. Preserve exact spelling and capitalization where relevant.

## 4. RTL patterns
The supplied CSS includes `.is-rtl` rules, including direction-specific styling for elements such as `.header-top`, `.main-content-body`, and `.arrow-sidemenu-collapsed`. Reuse the application's established RTL mechanism; do not add a parallel direction class or assume all selectors automatically mirror.

## 5. Known CSS risks in the supplied snapshot
- `.btn` is declared in multiple places with different corner-radius declarations. Before changing button shape, inspect the full cascade, selector specificity, source order, and any component-level classes. Do not assume the first declaration wins.
- `.header-top` also appears in multiple rules. Avoid adding another broad duplicate without understanding existing overrides.
- A media query for `max-width: 1900px` applies `zoom: 0.70 !important` to `body`; the CSS also contains a Firefox-specific scale transform. Treat these as legacy/global scaling behaviour, not as a responsive design pattern to copy.
- Before modifying global selectors such as `body`, `.btn`, `.header-top`, `.table`, `.content`, or `.is-rtl`, estimate the blast radius and list affected screens/modules. Prefer a narrowly scoped selector when the requirement is local.
- Do not delete or consolidate existing declarations as incidental cleanup during a feature request. Propose a separate cleanup with explicit impact analysis.

## 6. Theme-change checklist
- [ ] Search the full theme for the selector and later overrides.
- [ ] Confirm the target screen/block markup actually uses the selector.
- [ ] Check whether the selector is shared globally.
- [ ] Check desktop, tablet, phone, RTL, and LTR.
- [ ] Check hover, focus, active, disabled, loading, validation, and empty states as relevant.
- [ ] Avoid fixed dimensions unless the design requires them and overflow has been checked.
- [ ] Keep the diff limited to the requested change.


## 7. Project-authoritative rules added by the team

These conventions are mandatory even if a legacy CSS declaration or older page differs. Inspect the live OutSystems module/theme through MCP before editing.

- Main theme for portals: `Infath_LSGTheme` in `Infath_Reactive_Theme`.
- Apply `Infath_LSGTheme` to portals only, never automatically to non-portal apps.
- Main system color: `var(--color-primary)`.
- System green: `var(--color-secondary)`.
- Inline styles are prohibited everywhere in new or modified UI. This includes widget Style properties, HTML `style` attributes, and JavaScript-generated inline styling.
- `FileUpload` and `SingleUpload`: add `attachment` to the container.
- Popup action container classes: `actions_buttons display-flex justify-content-center`.
- Tables: use an `If` condition driven by `IsDataFetched`; true displays the table, false displays `TableSekleton` from `Infath_OutSystemsUI`.
- When a label has its paired Expression, give that Expression the `text-primary` class.
- External portal pages: use `LayoutTopMenuExternal` from `Eservices_External_Layouts`; in `MainContent`, create the `margin-right-l side-list sideMenuWeb` container with `SideMenu_External` from `Infath_UIPattern`, plus the `flex-auto margin-x-l margin-y-m` container holding the main content block. In `Header`, use `SideMenu_External` from `Infath_UIPattern`.

If the live module does not contain a named item or its exact spelling differs, do not silently correct or replace it. Report the mismatch and ask for clarification.

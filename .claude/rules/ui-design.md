# UI design rules — OutSystems 11 Reactive Web

Apply these rules when creating or changing screens, blocks, layouts, forms, tables, navigation, and other visible UI. Follow `architecture.md`, `coding.md`, `editing.md`, `environments.md`, and the relevant command file as well.

## 1. Inspect before designing
- Use the OutSystems MCP to inspect the target screen/block, its parent layout, nearby screens, existing reusable blocks, and the current theme before proposing a UI change.
- Prefer an existing theme pattern or shared block over a new one. Search by both element name and visible purpose.
- Identify whether the change affects one screen or a shared block/theme used by multiple screens.
- Do not claim that a CSS class, theme token, widget, or reusable block exists until it has been verified in the target app/theme.

## 2. Design consistency
- Reuse the existing application layout, spacing, typography, button styles, cards, form controls, table patterns, alerts, and modal patterns.
- Keep visual hierarchy clear: one primary action per context where practical; secondary actions should not compete with it.
- Use consistent alignment, spacing, labels, validation placement, empty states, loading states, and disabled states.
- Avoid adding decorative elements that do not improve usability or communicate information.
- Do not replace a working design system with a new framework, icon set, or component library unless explicitly requested and approved.

## 3. Responsive behaviour
- Check desktop, tablet, and phone breakpoints using OutSystems' responsive layout conventions and the actual app layout.
- Prefer responsive containers, columns, Flex, Grid, and existing OutSystems UI patterns over fixed widths and absolute positioning.
- Avoid horizontal overflow in forms, cards, tables, menus, dialogs, and long labels.
- On phone layouts, stack content where appropriate, keep primary actions reachable, and avoid shrinking text to force a fit.
- Do not use page-wide `zoom`, `transform: scale(...)`, or similar scaling hacks as a responsive solution. Fix the relevant layout, sizing, spacing, or breakpoint instead.
- Test long Arabic and English labels, validation messages, and dynamic data; do not assume sample text represents the maximum content length.

## 4. RTL and LTR
- Respect the application's configured language and direction. Inspect how the app sets `is-rtl` and how the parent layout handles direction.
- Prefer logical CSS properties such as `margin-inline-start`, `padding-inline-end`, `inset-inline-start`, and `text-align: start` over left/right-specific properties when direction should mirror.
- Keep icons, chevrons, breadcrumbs, navigation, form alignment, and directional affordances correct in both RTL and LTR.
- Do not add a second competing direction mechanism or hard-code RTL-only positioning without confirming the component's intended behaviour.
- Verify both directions whenever a shared component or global style changes.

## 5. Accessibility and interaction
- Use visible labels for inputs; placeholder text is not a substitute for a label.
- Preserve keyboard operation, visible focus, semantic headings, meaningful link text, and accessible names for icon-only buttons.
- Do not communicate status using colour alone. Keep text or another visible cue.
- Provide loading, success, error, empty, and disabled states when relevant.
- Prevent repeated submission while a save/action is in progress. Show validation near the relevant field and retain user-entered values after recoverable errors.
- Confirm destructive actions and explain what will be deleted or changed.

## 6. UI change plan
Before making changes, show:
1. Target module and exact screen/block/theme selectors to change.
2. Existing pattern(s) inspected and the proposed reuse strategy.
3. Before → After summary.
4. Responsive and RTL/LTR impact.
5. Accessibility and interaction states affected.
6. Shared consumers and regression checks.
7. Whether CSS is local, shared, or global.
Wait for approval when required by the existing workflow. Keep the implementation as small as possible and publish only to Development.


## 7. Infath portal-specific conventions (mandatory)

### Theme selection
- `Infath_LSGTheme` from `Infath_Reactive_Theme` is the main theme for the relevant Infath portal UI.
- Use `Infath_LSGTheme` in portals only. Do not apply it automatically to non-portal modules/apps.
- Before assigning a theme, inspect the target application/module and confirm it is a portal. Do not change an existing theme without stating the impact and receiving approval.

### Theme colors
- Use `var(--color-primary)` for the system's main color.
- Use `var(--color-secondary)` for the system's green color.
- Prefer these variables over hard-coded color values. Do not hard-code a color when the existing theme variable expresses the intended semantic role.

### No inline styles
- Never use inline styles. This includes OutSystems widget `Style` properties, `style="..."` attributes, or inline CSS values for layout, spacing, colors, typography, or positioning.
- Use existing theme classes and design-system classes. If no suitable class exists, propose a reusable CSS class in the appropriate theme/module stylesheet and wait for approval when required.
- Do not work around this rule by generating inline styles from JavaScript.

### File upload
- If the widget/block is `FileUpload` or `SingleUpload`, apply the class `attachment` to its container.
- Verify the class is on the intended container around the upload control, not merely on an unrelated child.

### Popup actions
- Popup action containers must use both classes: `actions_buttons display-flex justify-content-center`.
- Preserve existing button semantics and event handling; this is a layout convention, not a reason to rebuild popup actions.

### Tables and loading skeletons
- Tables must be conditionally displayed based on `IsDataFetched`.
- When `IsDataFetched` is true, show the table.
- When `IsDataFetched` is false, show the `TableSekleton` block from `Infath_OutSystemsUI` instead of the table.
- Use the exact block spelling `TableSekleton` as specified by the project. Inspect the module through MCP and reuse the existing block; do not create a replacement if it exists.
- Ensure the condition is wired to the actual data-fetch state and that the skeleton and table do not display simultaneously.

### Labels and expressions
- When a label and its associated expression are both present in a UI pattern, apply the `text-primary` class to the Expression widget.
- Confirm the Expression is the value/content paired with that label; do not apply the class indiscriminately to every Expression on the screen.

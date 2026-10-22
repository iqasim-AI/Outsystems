# UI customization and CSS safety

## Scope first
- Classify every proposed style as: existing theme reuse, local screen/block style, shared component style, or global theme style.
- Prefer, in order: existing pattern/component → existing theme class/variable → narrowly scoped local class → shared theme change only when necessary.
- Do not create a new global selector for a one-screen requirement.
- Use descriptive, component-scoped class names. Avoid broad selectors that style every `div`, `button`, `input`, `.content`, `.btn`, or `.table` unless the request explicitly targets the global design system.

## Before adding CSS
1. Search the active theme and target module for the selector, variable, and similar component.
2. Check selector specificity, source order, media queries, RTL overrides, and component-generated classes.
3. Confirm whether a style is overridden by OutSystems UI or later theme declarations.
4. State the exact file/module and selector to change in the plan.
5. Do not edit generated CSS or Theme Editor output in a way that will be overwritten without explaining the maintenance risk.

## Responsive and direction-safe CSS
- Prefer CSS logical properties for direction-aware spacing and positioning.
- Prefer flex/grid/wrapping and breakpoint-specific layout changes over `zoom`, page-wide transforms, fixed widths, or absolute positioning.
- Do not use `!important` as the first fix. If it is unavoidable due to a verified cascade conflict, explain why and scope it as narrowly as possible.
- Do not add a new breakpoint without checking the application's established breakpoints and OutSystems `.phone`, `.tablet`, and `.desktop` conventions.
- Keep focus-visible and keyboard states intact when changing controls.

## Change safety
- A change to a global theme selector may affect many unrelated screens. Find known consumers where possible and explicitly state what cannot be verified.
- Do not silently normalize inconsistent legacy styles or refactor unrelated selectors.
- Do not change a shared Foundation/theme module without calling out the wider impact and receiving approval under the team's existing workflow.
- After implementation, publish only to Development, run TrueChange as applicable, and test representative screens in both RTL and LTR plus phone/tablet/desktop.

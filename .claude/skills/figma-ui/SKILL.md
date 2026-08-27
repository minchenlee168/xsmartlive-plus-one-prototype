---
name: figma-ui
description: Convert Figma designs into Flutter UI for this white-label multi-tenant app (Multi-Flavor + Remote Theme JSON). TRIGGER when user shares a Figma URL, requests UI changes based on Figma, asks to read a Figma node, or invokes any `mcp__figma-desktop__*` tool. Enforces token-based design system — NEVER hardcodes colors/spacing/fonts/strings from Figma. Separates structure (from Figma) from visual tokens (from Theme).
---

# Figma MCP Workflow — White-Label App

## 🎯 Core Principle (read this line, then scroll)

**Figma defines structure. Theme tokens define visuals. Never hardcode Figma's colors / fonts / sizes / strings into UI code.**

This app is White-Label (Multi-Flavor + runtime Remote Theme JSON from `/theme/{id}`). Whatever colors/sizes the Figma shows represent **one merchant's brand** — not a universal truth. Hardcoding them breaks the second merchant.

---

## Layer 1 — Structure (follow Figma)

- Widget tree & nesting (Column / Row / Stack)
- Element presence & relative positioning
- Navigation flow (button → target page)
- Flex / padding **ratios** (not absolute values)

## Layer 2 — Visual Tokens (always via Theme, never inline)

| Figma shows | Code must use | ❌ Forbidden |
|---|---|---|
| `#EC4899` | `Theme.of(context).colorScheme.primary` or `context.appTheme.*` | ❌ `Color(0xFFEC4899)` |
| success/warning/info/divider/muted | `context.appTheme.success` etc. | ❌ hex literals |
| gradient | `context.appTheme.primaryGradient` | ❌ hand-built `LinearGradient` |
| `fontSize: 16` / `SF Pro` | `Theme.of(context).textTheme.titleMedium` | ❌ inline fontSize / fontFamily |
| radius | `context.appTheme.cardRadius / buttonRadius / chipRadius / dialogRadius / sheetRadius / avatarRadius` | ❌ `BorderRadius.circular(12)` |
| padding / gap | `context.appTheme.spacingXxs ~ spacingXxxl` (2/4/8/12/16/20/24/32) | ❌ magic numbers |
| shadow | `context.appTheme.elevation1/2/3` (`List<BoxShadow>`) | ❌ hand-built `BoxShadow` |
| merchant logo | `context.appTheme.logoUrl` or `FlavorConfig.instance.*` | ❌ `Image.asset('merchantA_logo.png')` |
| product image URL | API response field | ❌ Figma export placeholder |
| text "加入購物車" | `AppLocalizations.of(context)!.addToCart` | ❌ inline string literal |

**Unified entry point**: `context.appTheme` — from `lib/theme/app_theme_extension.dart`

## Layer 3 — Data fields

| Figma | Code | API | Action |
|---|---|---|---|
| ✅ | ✅ | ✅ | Update styling per Figma |
| ✅ | ❌ | ✅ | **Add UI**, wire to API |
| ✅ | ❌ | ❌ (dynamic data) | **Skip**, keep current code, record in TODO to ask backend |
| ✅ | ❌ | ❌ (pure decoration: icon/divider/banner) | Add, still use theme tokens for visuals |
| ❌ | ✅ | — | **Do not touch**, preserve existing code |
| only style differs | — | — | Follow Figma, but through theme tokens |

## Layer 4 — Token missing? "Add Token" 4-Step Rule (CRITICAL)

When Figma needs a visual token that `AppThemeExtension` does NOT yet have:

### ❌ NEVER
Hardcode in UI (`Color(0xFFFFE0F0)`, `BorderRadius.circular(20)`) → breaks white-label.

### ✅ DO

1. **Add field + baseline default** in `lib/theme/app_theme_extension.dart`
   - Use Figma merchant's current value as baseline default
   - Update `copyWith` and `lerp` accordingly

2. **Add optional field** in `lib/theme/remote_theme_model.dart`
   - All new fields use `@Default(...)`
   - For a brand-new category (e.g., `RemoteBorder`), use nullable + `??` fallback in builder

3. **Map JSON → extension** in `lib/theme/remote_theme_builder.dart`

4. **Run codegen**: `dart run build_runner build --delete-conflicting-outputs`

5. **Use new token in UI**: `context.appTheme.newToken`

6. **Report in output**:
   - New tokens added
   - Backend JSON keys needed (so backend team knows to add them)

## Layer 5 — Do Not Touch

- Riverpod provider structure & naming
- Freezed model fields & naming (adding optional fields is OK; rename/remove is NOT)
- go_router routes
- `DioClient` / `AuthNotifier` / 401 refresh flow
- `ApiConstants` URL composition via `FlavorConfig`
- i18n key naming (adding is OK; renaming/removing is NOT)
- `main_shell.dart` viewPadding handling (see `CLAUDE.md` UI & Edge-to-Edge)

## Layer 6 — Required Output Checklist

After every Figma-MCP-driven UI change, end the response with:

1. **New / modified theme tokens** (if any)
2. **New i18n keys** (all `.arb` files must stay in sync)
3. **Backend remote theme JSON keys needed** (if any)
4. **Codegen required?** (Yes when Freezed / Riverpod / l10n changed)
5. **Flutter files touched** (paths)
6. **Assets downloaded / pending** — every `<image>` / `<vector>` node from Phase A step 4, tagged as:
   - `[downloaded]` path + source URL (auto-fetched via `curl` from `localhost:3845/assets/…`)
   - `[reused]` path (matched an existing file in `assets/`, no new download)
   - `[no-asset]` layer name (MCP returned no localhost URL for this node)
   - `[placeholder]` — widget temporarily uses `Icon()` / solid color until asset lands

## Layer 7 — When a design looks merchant-specific

Stop and ask. Examples:

- Figma shows pink promo banner, other merchants use blue → Make it themeable?
- Figma has festival-specific icon → Bundled in code, or served from API/theme?
- Figma shows brand-specific button style → Is this the universal style or merchant-custom?

## Layer 8 — Standard Workflow

When user says "help me implement this Figma page":

### Phase A — Gather design context (ALL steps mandatory)

1. **Structure first** — call `mcp__figma-desktop__get_design_context` with the nodeId. Get the widget tree, element positions, layer names, padding/gap ratios.
2. **Visual reference second** — call `mcp__figma-desktop__get_screenshot` with the same nodeId. Keep this image open mentally; it is the ground truth for visual diff at the end.
3. **Variable definitions** — call `mcp__figma-desktop__get_variable_defs` to see which design tokens the node uses (maps to `AppThemeExtension` fields).
4. **Asset auto-download via localhost server (mandatory — NEVER silently skip)**

   Figma Dev Mode MCP runs a local asset server at `http://localhost:3845/assets/<hash>.<ext>` whenever **Image source: Localhost** (a.k.a. *Local image server*) is enabled in Figma Desktop → MCP settings. `get_design_context` then embeds those URLs directly in its code output, for BOTH raster images AND SVG vectors.

   **Verified 2026-04-23** against this project — works end-to-end with no extra tool arguments. This is the primary path. The `Download` / write-to-disk mode is intentionally NOT used because its required tool argument isn't in the currently registered MCP schema (Claude Code strips unknown params via `additionalProperties: false`).

   **4a. Enumerate first.** Scan the `get_design_context` output for every `localhost:3845/assets/…` URL and every `<image>` / `<vector>` node. Immediately push ONE TodoWrite item per asset. No asset may be marked done until the file is on disk AND referenced from code.

   **4b. Auto-download with `curl` (raster + SVG share this path).**
   - For every `http://localhost:3845/assets/<hash>.<ext>` URL in the response, run:
     ```
     curl -sSL -o assets/images/figma/<feature>/<slug>.<ext> "<url>"
     ```
     (SVG files land in `assets/icons/<slug>.svg` instead.)
   - `<feature>` = parent screen name (`product-detail`, `coupon`, `register`, …).
   - `<slug>` = the Figma layer name, lowercased, ASCII-only, hyphen-separated. Fall back to the first 12 chars of the asset hash if the layer name is generic (e.g. `"image"` / `"vector"`).
   - Before downloading, grep `assets/` for an existing file with the same slug **or** the same hash prefix — reuse instead of duplicating.
   - If the asset server is unreachable (curl fails with connection refused), stop: **Figma Desktop is probably closed or MCP got disabled**. Ask the user to re-enable, then retry. Never silently skip.

   **4c. Fallback paths** (only when step 4b can't work):
   - MCP returns no localhost URL (rare — usually means the node is pure layout, no real image bound) → record as `[no-asset]` in the report.
   - User has Image source set to something other than Localhost → ask the user to switch back in Figma Desktop → MCP settings, then retry.

   **4d. Path-based `CustomClipper` shapes** (wave dividers, blob backgrounds, curved masks) — the SVG downloaded in 4b already contains the `d=` path data. Read the saved SVG file directly (Read tool) to extract `d=` for Layer 8 step 8 transcription; no need to ask the user to paste.

   **4e. Register in `pubspec.yaml`** — new folders under `assets/images/figma/<feature>/` and new files under `assets/icons/` must be added to `flutter.assets` in a single edit at the end of this phase, never deferred to Phase B.

   **4f. Report.** Phase D MUST list every asset by path + source (`[downloaded]` for curl-based, `[reused]` for matched existing file, `[no-asset]` when MCP returned nothing, `[placeholder]` when the task ships with temporary widgets awaiting backend).

### Phase B — Implement

5. Locate the matching file under `lib/screens/`.
6. **Check which tokens `AppThemeExtension` already has**; add any missing ones first (Layer 4).
7. Edit UI code — all visuals through `context.appTheme.*`.
8. For SVG-backed shapes: transcribe the SVG `d=` path into a `CustomClipper<Path>` **coordinate-by-coordinate** using the Figma frame dimensions as the coordinate system. Do not reinterpret — bezier control points don't survive "approximation".

### Phase C — Verify (do NOT skip)

9. **Static checks** — `flutter analyze` on the changed file(s). Must report zero issues.
10. **Layout sanity pass** — before declaring done, mentally walk the widget tree for these recurring Flutter pitfalls:
    - `Stack` needs `fit: StackFit.expand` if a `Positioned.fill` child should cover the full body (non-positioned siblings otherwise collapse the Stack).
    - `Scaffold` needs `extendBodyBehindAppBar: true` for gradients/backdrops that must render behind a transparent AppBar.
    - `DecoratedBox` with no child has zero size — use `Container` for background-only painting.
    - `InputDecoration(isDense: true, contentPadding: EdgeInsets.zero)` squashes editable area below the visible box — for tall fields (OTP cells, etc.) use a `Container` wrapper + bare TextField instead.
    - `SafeArea(top: false)` + `extendBodyBehindAppBar: true` = card hides behind AppBar. Add `kToolbarHeight` to scroll padding.
    - Keyboard compression: confirm `SingleChildScrollView` is the root scroll, and OTP-style rows use `Expanded` not fixed widths (so keyboard resize doesn't overflow).
11. **Visual 1:1 diff** — ask the user to hot-reload and send a screenshot. Compare side-by-side against the Figma screenshot from step 2. Flag any mismatch (position, padding, color, shape, gradient direction) and iterate. **Do not declare the task complete without this step.**

### Phase D — Report

12. Report per Layer 6.

---

## Quick Reference — `context.appTheme` tokens

**(Source of truth: `lib/theme/app_theme_extension.dart`)**

```
Assets:      logoUrl, splashUrl
Radii:       cardRadius, buttonRadius, chipRadius, dialogRadius, sheetRadius, avatarRadius
Gradient:    gradientColors, primaryGradient
Colors:      success, warning, info, divider, muted
             (primary / secondary / error / surface → Theme.of(context).colorScheme)
Spacing:     spacingXxs(2), spacingXs(4), spacingSm(8), spacingMd(12),
             spacingLg(16), spacingXl(20), spacingXxl(24), spacingXxxl(32)
Elevation:   elevation1, elevation2, elevation3  (List<BoxShadow>)
```

Typography → `Theme.of(context).textTheme.*` (M3 naming).

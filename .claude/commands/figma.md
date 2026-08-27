---
description: Load Figma MCP rules and start a Figma-to-Flutter UI task. Use when converting a Figma node into Flutter widgets on this white-label app.
argument-hint: "[Figma URL or node-id]"
---

# /figma — Figma MCP Workflow (loader)

This command is a thin loader. All workflow rules live in the `figma-ui` skill —
this file intentionally does NOT duplicate them, so the skill stays the single
source of truth.

## Instructions

1. **Read `.claude/skills/figma-ui/SKILL.md` in full.** Follow every step of its
   `Layer 8 — Standard Workflow` (Phase A → D) without deviation.

2. **Parse `$ARGUMENTS`** and hand the result to Phase A:
   - Figma URL with `?node-id=X-Y` → extract the nodeId (convert `X-Y` to `X:Y`
     if the MCP tool requires it).
   - Already a nodeId like `123-456` or `123:456` → use as-is.
   - Empty → use whatever node is currently selected in Figma Desktop.

3. **Execute the skill's workflow**. Do not shortcut — the visual 1:1
   verification in Phase C is mandatory before reporting completion.

## User input

`$ARGUMENTS`

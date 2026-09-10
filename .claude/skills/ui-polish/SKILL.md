---
name: ui-polish
description: 收斂畫面的間距 / 尺寸 / 圓角 / 字級 / 行高 / 對齊到本專案 appTheme 設計 token（手機舒適度優先、不忽大忽小），並檢查畫面「不合理處」（溢位 / 文字被截斷、卡片高度不齊、同型元件不一致、圖片比例 / 視覺層級錯亂）。TRIGGER 當使用者說「排版怪怪的」「間距調一下」「比例不協調」「字太大 / 太小」「這頁 polish 一下」「元件不一致」「畫面不合理 / 怪怪的」時使用。不改文案、顏色語意、業務邏輯。
---

# ui-polish — 視覺細節收斂入口

這個 skill 是入口；**實際規則與 persona 由 `ui-polish` subagent 承載**（`.claude/agents/ui-polish.md`，資深 UI/UX 設計師），維持單一來源。你（主對話）負責決定範圍、生 subagent、把提案拿給使用者確認、驗證與部署。

## 流程

1. **確定範圍**：使用者指定哪一頁 / 哪個元件？沒指定就問，或就當前討論的畫面。多頁時可平行處理。
2. **生 subagent 做 Inventory + 提案**：用 Agent 工具、`subagent_type: "ui-polish"`，請它列出目標檔的間距 / 圓角 / 字級離群值，**並掃描畫面「不合理處」**（溢位 / 文字截斷、卡片高度不齊、同型元件不一致、圖片比例 / 層級錯亂），產出 `before → after(token) → 依據` 清單＋不合理處清單（**先不要動手**）。多頁就平行生多個。
3. **拿提案給使用者確認**：把清單摘要呈現；涉及視覺變動（字級大小、圖片比例、顏色）要讓使用者拍板，不要自作主張。
4. **確認後施作**：請同一個 subagent 套用，並跑 `flutter analyze <改到的檔>`（只允許既有 info lint）。
5. **驗證**：在瀏覽器 / headless 截圖確認版面未破、無 overflow、字級舒適；改到共用元件或固定高度容器時尤其要看。
6. **回報**：條列改了哪些（before→after→token）、保留未動的 flag、analyze 結果。commit / 部署依使用者平時的節奏。

## 邊界（同 subagent）

- 只碰間距 / 尺寸 / 圓角 / 字級 / 行高 / 對齊；不碰文案、顏色語意、結構邏輯、i18n。
- 一律用 `context.appTheme.*` token，不 hardcode 數值 / 色碼 / 字體家族。
- 手機舒適度：正文 / 清單 / 商品名 16，區塊標題 18，次要資訊 12，頁面主標 20–24，微型 chrome 9–11（例外要 flag）；同類元素固定同一級、不忽大忽小。
- **角色判別**：一段文字若領著一整組卡片 / 清單 / 內容（如「近期訂單」「我的最愛」）就是**區塊標題 18**（用 `fg`，別用 `fgMuted` 灰掉縮小）；eyebrow 12 只留給「單一欄位 / 設定列上方的小 overline」。分不清標題 vs eyebrow 的**一律 flag 給使用者，不自行 revert 成小字**。
- 共用元件（`ProductCard` 等）先 `Grep` 使用點；固定高度容器改動要重算列高。

## 相關

- 設計 token 定義：`lib/theme/app_theme_extension.dart`
- 全站商品卡：`lib/widgets/product_card.dart`（`ProductCard`，variant: standard / compact）
- Figma → 程式（結構 vs token）：`figma-ui` skill

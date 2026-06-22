# ADR-005: 設計方向決策 — Dark-First、Linear-Inspired、冷靜動畫

**日期：** 2026-06-20
**狀態：** Accepted

## Context

在 2026-06-20 的產品願景工作坊（Product Vision Workshop）中，Design Reviewer 與 Architecture Guardian 共同參與，針對產品的使用者體驗與視覺風格做出了多項具體的設計方向決策。這些決策被記錄在 `docs/product-vision.md` 的第 7–9 節（設計層級）以及 `docs/session-notes/2026-06-20-initial-setup.md` 中，但從未以正式的 ADR 形式被記錄與背書。

鑑於這些決策將影響所有的 UI 實作、元件庫設計、主題系統與前端架構，有必要將其獨立成一份正式的架構決策記錄，以確保團隊成員與未來的開發者能理解這些選擇的動機與取捨。

## Decision

### 1. Dark-First 主題架構

**選擇：** 以深色主題為第一優先，背景色 `#0f0f0f`，採用「陰影作為邊框（shadow-as-border）」手法（參考 Vercel 設計風格）。

**理由：**
- 目標使用者（開發者）長時間在 IDE 與終端機環境工作，深色主題是預期體驗
- `#0f0f0f` 提供接近純黑的沈穩基底，但保留微妙的層次感，避免純黑 `#000000` 造成的視覺疲勞
- Shadow-as-border 取代傳統 border 線條，減少視覺雜訊，讓資訊層級由光影而非線條定義
- 符合「Precision over personality」原則——不做裝飾性邊框

### 2. Linear-Inspired 互動哲學

**選擇：** 鍵盤驅動（Keyboard-driven）的操作模型、Opinionated 簡潔（Opinionated Simplicity）而非功能完整。

**理由：**
- 開發者偏好鍵盤操作 > 滑鼠點擊，減少上下文切換
- Opinionated 簡潔意味著我們為 90% 的使用情境做最佳化，而非為 10% 的邊界情況提供開關
- Linear 已驗證「速度本身就是功能」——快速、精確、不打斷 flow state
- 與 Key Principle #2（Opinionated 簡潔勝過彈性）一致

### 3. 冷靜的動畫（Calm Motion）

**選擇：**
- 動畫僅在有意義的狀態轉換時使用（任務完成、建立、歸檔、狀態變更）
- 持續時間 ≤300ms
- 尊重 `prefers-reduced-motion` 媒體查詢
- 不使用彈跳（bounce）、旋轉（spin）、或「慶祝」效果（confetti）

**理由：**
- 動畫的目的是引導注意力，而非娛樂
- ≤300ms 確保動畫不阻擋操作（ humanos 的短期注意力閾值約 300–400ms）
- 尊重無障礙需求——部分使用者（前庭障礙、偏頭痛）會被過度動畫觸發不適
- 靜態、預測的介面比動態介面更符合生產力工具的信賴感

### 4. Precision over Personality（精確勝過個性）

**選擇：**
- 單一強調色（single accent color），不使用漸層
- 不使用 emoji 作為圖示
- 不使用左框線卡片（left-border cards）
- 不使用 Tailwind Indigo 或其他框架預設色

**理由：**
- 單一強調色建立清晰的視覺階層，使用者能立即識別可互動元素
- 漸層、emoji-as-icon、左框線卡片是常見的「AI 生成 slop 信號」（參考 `craft/anti-ai-slop.md`），會降低專業感
- 精確的資訊層級比視覺個性更重要——工具不應該刷存在感
- 與 Key Principle #1（速度是功能）的精神一致：視覺克制的介面載入更快、感知更快

### 5. 資訊密度與清晰度並存（Craft Typography Hierarchy）

**選擇：** 採用 Craft Typography Hierarchy 的排版原則——克制的類型尺度（type scale）、明確的入口點（entry points）、以留白和行距而非裝飾建立層級。

**理由：**
- 開發者需要在單一畫面看到足夠的 context（任務列表 + branch 名稱 + PR 狀態），低資訊密度意味著更多滾動與切換
- 清晰的排版層級讓使用者能快速掃描而非閱讀
- 參考 `docs/../craft/typography-hierarchy.md` 與 `docs/../craft/typography-hierarchy-editorial.md`
- 不需要 hover 才能看到的關鍵資訊——所有重要狀態應靜態可見

### 6. WCAG 2.2 AA 色彩對比強制

**選擇：** 所有文字色彩組合必須滿足 WCAG 2.2 AA 標準，一般文字對比度 ≥ 4.5:1，大文字 ≥ 3:1。

**理由：**
- 深色主題中，低對比度是常見的無障礙陷阱（如灰色文字 on 深色背景）
- WCAG 2.2 AA 是國際法定最低標準（歐洲 EN 301 549、美國 Section 508）
- 不僅是合規要求，也是設計品質的保證——高對比的深色主題看起來更銳利、更專業
- 對於長時間使用工具的開發者，減少眼睛疲勞有直接生產力價值

## Consequences

### Positive

- **一致的視覺語言**——所有元件從第一天就共享同一套設計決策，減少後續重工
- **開發效率提升**——dark-first + shadow-as-border 意味著 CSS 主題系統只需專注於一組色彩變數（暗色為主），亮色主題為衍生
- **無障礙合規**——WCAG 2.2 AA 從設計系統層級強制，避免上線後才發現對比不足
- **品牌辨識度**——不同於 Jira/Linear/Notion 的視覺風格，建立獨特的產品氣質（沈穩、精確、專業）
- **較低的設計決策 fatigue**——Precision over personality 減少了裝飾性選擇的數量（不使用漸層、emoji、左框線），讓設計師專注於資訊架構

### Negative

- **亮色主題支援成本增加**——Dark-first 意味著亮色主題是 second-class citizen，需要額外測試與維護
- **Shadow-as-border 的微妙渲染差異**——在不同瀏覽器/平台上，box-shadow 的渲染可能有細微差異，需要仔細處理
- **Keyboard-driven 提高入門門檻**——非鍵盤偏好使用者（如設計師、PM）可能需要適應期
- **單一強調色的限制**——某些場景（如多種狀態標籤）可能需要更豐富的色彩系統來區分資訊維度
- **Calm motion 可能被認為「缺乏個性」**——部分使用者可能偏好更有活力的互動反饋

## References

- `docs/product-vision.md` §7 — Precision over personality
- `docs/product-vision.md` §8 — 資訊密度與清晰度
- `docs/product-vision.md` §9 — 冷靜的動畫
- `docs/session-notes/2026-06-20-initial-setup.md` — 工作坊記錄（第 35 行：設計方向決策摘要）
- `craft/typography-hierarchy.md` — Open Design 參考
- `craft/color.md` — 色彩系統設計原則
- `craft/accessibility-baseline.md` — WCAG 2.2 AA 標準
- `craft/anti-ai-slop.md` — 避免 AI 生成痕跡的 7 項原則
- Vercel 設計系統 — Shadow-as-border 參考來源
- Linear 設計系統 — 完整視覺語言參考（`design-systems/linear-app/DESIGN.md`）
- `docs/design/tokens.md` — 設計系統選擇流程與 Token 速查表

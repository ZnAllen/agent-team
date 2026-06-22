# 設計參考：系統選擇流程

> 不鎖定單一系統。每個專案開始時自動從 Open Design 選取適合的系統。

---

## 流程（自動執行）

```
新專案開始
  │
  ├── 1. 判斷專案類型
  │     從 product-vision.md / conventions / 專案描述推斷
  │
  ├── 2. 從 Open Design 選取對應系統
  │      開發工具 → Linear / Vercel / Supabase / shadcn
  │      社交產品 → Airbnb / 小紅書
  │      AI 產品  → Claude / Cursor / xAI
  │      一般 SaaS → Stripe / Notion
  │      其他     → 選風格最接近的
  │
  ├── 3. 自動提取 Token → docs/design/<project>-tokens.md
  │
  └── 4. 開始開發，design-reviewer 把關品質
```

## 永遠不變的原則

| 原則 | 來源 |
|------|------|
| WCAG 2.2 AA 對比度 (≥4.5:1) | Open Design `craft/accessibility-baseline.md` |
| 五種狀態 (loading, empty, error, populated, edge) | Open Design `craft/state-coverage.md` |
| 尊重 `prefers-reduced-motion` | Open Design `craft/animation-discipline.md` |
| 表單即時驗證 + server sync | Open Design `craft/form-validation.md` |
| RTL 支援 (CSS logical properties) | Open Design `craft/rtl-and-bidi.md` |
| 無 AI slop（漸層、emoji 圖示、左框線） | Open Design `craft/anti-ai-slop.md` |

---

*設計系統清單：`E:\Open Design\resources\open-design\design-systems\`*
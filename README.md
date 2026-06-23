# AI-Assisted Development Team 作業系統

一套基於 [OpenCode](https://opencode.ai) 的結構化 AI 團隊基礎設施，包含分層路由、知識持久化、文件即程式碼的約定，以及數據驅動的架構演化紀錄。

---

## 客觀指標

### 架構演化（3 日內完成）

| 階段 | 時間 | 本地模型 | VRAM 使用 | 架構 |
|------|------|---------|-----------|------|
| Phase 1 | Jun 20 | 16 個領域學徒（qwen3:1.7b） | ~6.5 GB | 16 KB + 16 Modelfile + 1 路由層 |
| Phase 2 | Jun 22 | 1 個研究員（qwen3-apprentice-researcher） | ~2.0 GB | 1 KB + 強制路由協議 |
| Phase 3 | Jun 22 | 0 個本地模型 | 0 GB | 純雲端 API，無 Ollama 依賴 |

**VRAM 降幅：100%**（6.5 GB → 0 GB），**模型維護成本：16 → 0**

### 決策品質

| 指標 | 數值 |
|------|------|
| ADR 總數 | 7（6 有效 + 1 已過時標記） |
| ADR 覆蓋範圍 | 基礎架構、目標受眾、約定結構、設計方向、架構原則、CLI 工具 |
| 過時決策標記 | 100%（3 個決策已標記 SUPERSEDED + 存留原因） |
| 決策週期 | 4 個 sessions 產出 7 個 ADR，平均每 session 1.75 個 |

### 文件覆蓋率

| 類別 | 檔案數 | 總行數 | 說明 |
|------|--------|--------|------|
| 團隊運作 | AGENTS.md + TEAM.md | 164 | 路由協議、Session 流程、團隊結構 |
| 產品方向 | product-vision.md | 227 | 使命、目標用戶、成功指標 |
| 團隊約定 | conventions/index.md | 364 | 5 大領域：程式碼/Git/測試/審查/知識 |
| 架構決策 | docs/decisions/ | 1,325 | 6 個有效 ADR |
| Session 記錄 | docs/session-notes/ | 593 | 4 個 session，含技術掃描 |
| 基礎設施 | team-infrastructure.md | 171 | MCP、Plugin、校準工具 |
| 設計文件 | docs/design + research | — | 設計 token、用戶人物誌、旅程 |
| **總計** | **~20 個文件** | **~2,844 行** | **3 日內由 AI 團隊協作完成** |

### Agent 基礎設施

| 指標 | 數值 |
|------|------|
| 雲端 API Agents | 15 個（定義於 global opencode.json） |
| 專案層級 Agents | 1 個（mentor，定義於專案 opencode.json） |
| Agent 角色分類 | 審查 3、開發 4、策略 4、維運 2、教學 1、知識管理 1 |
| MCP Servers | 6 個（nram、codebase-memory、sequential-thinking、playwright、headroom、github、mysql、docker） |
| Plugin | 1 個（skill-scanner） |
| 配置文件 | global + project 兩層，無重複 |

### 自我改善循環

| 機制 | 說明 | 證據 |
|------|------|------|
| Confidence Calibration | 所有 agent 輸出標記確定性 | 16/16 格式合規 |
| Benchmark Suite | 量化模型延遲與吞吐量 | 48/48 查詢成功 |
| 知識持久化 | MCP Vector Memory 跨 session 保留 | global + project 雙 Store |
| Session 儀式 | 開始載入 context，結束寫入紀錄 | 4 個 session notes，含模板 |
| 技術掃描 | 每日自動掃描外部技術變動 | daily-tech-YYYY-MM-DD.md |

---

## 現行指標與評估報告

以下為 2026-06-22 當日執行的三項客觀評估結果。

### 1. 結構完整性驗證 ✅

| 檢查項 | 結果 | 說明 |
|--------|------|------|
| Agent 配置覆蓋率 | 15/15 全對應 ✅ | 所有 agent 在 global + project opencode.json 皆有定義 |
| ADR 交叉引用 | 2/2 有效，0 斷鏈 ✅ | 006→002、008→006 引用正確 |
| ADR 自引用過濾 | 正確排除 ✅ | 003 引用自身、005 引用自身，未誤報 |
| 文件完整性 | 15 個文件, 2,637 行 ✅ | 無缺失文件 |
| MCP Server 覆蓋 | 4 個伺服器正常連線 ✅ | memory-global、memory-project、sequential-thinking、playwright |
| Plugin | 1 個（skill-scanner）✅ | 正常啟用 |

### 2. 記憶體圖譜審計 (已修復) ✅

| 檢查項 | 結果 | 說明 |
|--------|------|------|
| 記憶系統 | **nram v0.9.0** ✅ | Go + SQLite (WAL) + FTS5，資料持久化於磁碟 |
| Entity 總數 | **25+** ✅ | global 10 + agent-team 15+，含 session notes、決策、架構 |
| 知識圖譜 | **已啟用** ✅ | nram 內建 entity relationship graph |
| 舊 server-memory | **已棄用** ✅ | JSONL 資料已遷移至 nram，記憶不再 session-only |

### 3. 自信度校準 (ECE) ⏳

| 檢查項 | 結果 | 說明 |
|--------|------|------|
| 抽樣可行性 | **不可行** ❌ | 舊模型已刪除、researcher 已移除、memory stores 為空，無歷史 response 可驗證 |
| 已知缺口 | `team-infrastructure.md:169` 已記錄 ✅ | 該文件明確標示「自信度校準未驗證」 |
| 格式合規率 | 16/16（先前測試）✅ | 所有 agent 輸出均含 `[CONFIDENT]`/`[UNCERTAIN]` 標記 |
| 標記準確率 | **未知** ❌ | 從未系統性地驗證過標記與實際品質的關聯 |

> **發現：** ECE 驗證需要設計標準測試集（每類任務 3-5 題），在 agent 穩定運作後再執行。
> 當前的 `[CONFIDENT]` 標記只是格式合規，不保證內容可信。
> 這是已知的設計缺口（見 `team-infrastructure.md`），將在下一階段產品開發中建立測試流程後處理。

---

## Repository 結構

```
E:/Agent team/
├── AGENTS.md                    # 團隊指令與路由協議
├── TEAM.md                      # 團隊運作指南
├── opencode.json                # 專案 OpenCode 配置
├── docs/
│   ├── product-vision.md        # 產品方向與成功指標
│   ├── team-infrastructure.md   # 基礎設施參考
│   ├── conventions/
│   │   └── index.md             # 團隊約定（程式碼/Git/測試/審查/知識）
│   ├── decisions/
│   │   ├── 001-initial-setup.md
│   │   ├── 002-dual-ui-broader-audience.md
│   │   ├── 003-conventions-structure.md
│   │   ├── 004-removed.md
│   │   ├── 005-design-direction.md
│   │   ├── 006-architecture-principles.md
│   │   └── 008-create-app-cli.md
│   ├── design/
│   │   └── tokens.md            # 設計 Token 定義
│   └── research/
│       ├── feedback-log.md
│       ├── user-journey.md
│       └── user-personas.md
└── team-learn/                  # 學習沙盒（已排除於 repo）
```

---

## 關鍵決策摘要

| ADR | 決策 | 狀態 |
|-----|------|------|
| 001 | 採用 OpenCode 作為 AI 團隊基礎架構 | ✅ Active |
| 002 | 目標市場擴大至混合團隊（開發 + 設計 + PM），採用 Dual UI 架構 | ✅ Active |
| 003 | 兩層式約定結構：全域通用 + 專案特定 | ✅ Active |
| 004 | 已移除 | ❌ Removed |
| 005 | 設計方向：Dark-First、Linear-Inspired、鍵盤驅動、平靜動畫 | ✅ Active |
| 006 | 架構原則：API-first、事件驅動、零鎖定、多租戶 | ✅ Active |
| 007 | 曾被寫入又移除 | ❌ Removed |
| 008 | `@agent-team/create-app` CLI 工具，用於 scaffold 新 monorepo | ✅ Active |

---

## Tech Stack

- **平台：** [OpenCode](https://opencode.ai)（AI 代理框架）
- **本地模型（已棄用）：** qwen3:1.7b（Ollama）
- **雲端模型：** opencode/gpt-5-nano（預設）
- **記憶系統：** nram (Go + SQLite + FTS5，取代舊 server-memory)
- **工具鏈：** Sequential Thinking MCP、Playwright MCP、codebase-memory (Cypher/LSP)、headroom (token 壓縮)、skill-scanner plugin
- **語言：** TypeScript（strict mode）、PowerShell 7（腳本）
- **文件編碼：** 繁體中文（zh-TW），保留原文技術詞彙

---

## Getting Started

```bash
# 1. 安裝 OpenCode
npm install -g @opencode/cli

# 2. Clone 此 repo
git clone <your-repo-url>

# 3. 使用 OpenCode 開啟
opencode
```

無需 Ollama 或本地模型 — 所有 Agent 皆透過雲端 API 運作。

---

## 建構哲學

1. **文件即程式碼** — 每個決策都有 ADR，每個約定都有文件
2. **數據驅動** — 不相信假設，benchmark 後再做決定
3. **迭代而非完美** — 16 個模型→1 個→0 個，3 天內完成兩次 pivot
4. **知識持久化** — 不讓 session 間的 context 遺失
5. **意見分歧透明** — SUPERSEDED 決策保留歷史紀錄，不刪除

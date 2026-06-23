# 團隊基礎架構設計文件

## 1. 架構概觀

本文件提供 Agent Team 基礎架構的完整參考，涵蓋 `E:\Agent team` 工作區內所有元件。團隊以 **opencode CLI** 為核心，驅動 15 個雲端 API Agent，搭配 nram 記憶系統與多個 MCP 伺服器，實現分層路由、持久化知識管理與自動化 CI/CD。

### 核心哲學

- **純雲端架構** — 無本地模型，無 Ollama 依賴，VRAM 使用量 0 GB
- **兩層路由** — Lead 直接處理 Tier 1（研究/查詢）與 Tier 3（架構/設計/安全），僅 Tier 2（實作/測試/審查）委派給專屬 agent
- **記憶持久化** — nram (Go + SQLite) 提供跨 session 的知識保留，無需 embedding 也有 FTS5 全文搜尋
- **所有文件繁體中文（zh-TW）**，保留原文技術詞彙

## 2. 系統架構圖

```
┌──────────────────────────────────────────────────────────┐
│                     opencode CLI                          │
│           (指令路由 + 工具調用 + MCP 客戶端)               │
├──────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────┐    │
│  │             15 雲端 API Agents (Tier 2)           │    │
│  │                                                   │    │
│  │  code-writer-a/b/c/d  (前端/後端/共用/GPU)         │    │
│  │  code-reviewer         (程式審查)                  │    │
│  │  architecture-guardian (架構合規)                  │    │
│  │  design-reviewer       (UI/UX 審查)               │    │
│  │  security-reviewer     (安全審計)                  │    │
│  │  test-writer           (測試)                     │    │
│  │  memory-keeper         (知識管理)                 │    │
│  │  devops-sre            (CI/CD/維運)               │    │
│  │  mentor                (教學)                     │    │
│  │  product-manager       (產品策略)                 │    │
│  │  user-researcher       (用戶研究)                 │    │
│  │  tech-architect        (架構設計)                 │    │
│  └──────────────────────────────────────────────────┘    │
│                                                          │
│  ┌──────────────────────────────────────────────────┐    │
│  │   MCP Servers (6 個已啟用)                       │    │
│  │                                                   │    │
│  │  nram         記憶系統 (Go + SQLite + FTS5)       │    │
│  │  codebase-    程式碼知識圖譜 (Cypher/LSP)         │    │
│  │    memory                                         │    │
│  │  sequential-   結構化推理鏈                       │    │
│  │    thinking                                       │    │
│  │  playwright    E2E 瀏覽器自動化                   │    │
│  │  headroom      Token 壓縮                         │    │
│  │  github        GitHub API 操作                   │    │
│  │  mysql         資料庫查詢 (唯讀)                  │    │
│  │  docker        容器管理 (需 Docker Desktop 運行)   │    │
│  └──────────────────────────────────────────────────┘    │
├──────────────────────────────────────────────────────────┤
│  組態源頭: C:\Users\User\.config\opencode\opencode.json  │
│  (定義 15 個 Agent + 8 個 MCP 的完整配置)                │
└──────────────────────────────────────────────────────────┘
```

## 3. Agent 階層與路由

```
收到任務 ─── 關鍵字比對判定 Tier
  │
  ├── Tier 1: 研究/查詢/解釋 (Lead 直做)
  │     → 無委派，直接回答
  │
  ├── Tier 2: 實作/測試/審查 (委派雲端 API)
  │     → @code-writer-a/b/c/d, @test-writer 等
  │     ※ 觸發字：實作、寫、新增、修改、測試、Review、審查
  │
  └── Tier 3: 架構/設計/安全/策略 (Lead 直做)
        → 觸發字：架構、設計、規劃、安全、審計、策略、除錯
        → 複雜工作由 Lead 直接完成，不委派
```

**路由關鍵字對照：**
| 觸發字 | Tier | 處理方式 |
|--------|------|----------|
| 研究、查詢、解釋、比較、摘要 | T1 | Lead 直做 |
| 實作、寫、新增、測試、Review | T2 | 委派對應 code-writer / test-writer |
| 架構、設計、規劃、安全、審計、策略 | T3 | Lead 直做 |

## 4. MCP 伺服器清單

所有 MCP 伺服器均使用**絕對路徑**執行（npm 不在 PATH 中）：

| 伺服器 | 類型 | 用途 | 二進位路徑 |
|--------|------|------|-----------|
| nram | remote | 持久化記憶 (SQLite + FTS5) | `C:\Users\User\AppData\Local\opencode-mcp\nram\nram.exe` |
| codebase-memory-mcp | local | 程式碼知識圖譜 (Cypher/LSP) | `C:\Users\User\AppData\Local\opencode-mcp\cbm\codebase-memory-mcp.exe` |
| sequential-thinking | local | 結構化推理鏈 | `pnpm.cmd -s start` |
| playwright | local | 瀏覽器自動化 | `npx.cmd @playwright/mcp` |
| headroom | local | Token 壓縮 | `headroom.exe mcp serve` |
| github | local | GitHub API | `npx.cmd -y @modelcontextprotocol/server-github` |
| mysql | local | 資料庫查詢 (唯讀) | `node.exe ...mysql-mcp-server` |
| docker | local | 容器管理 | `pnpm.cmd -s start` |

### nram 記憶系統

nram v0.9.0 (donuts-are-good/nram) 是核心記憶後端：

- **二進位：** `C:\Users\User\AppData\Local\opencode-mcp\nram\nram.exe` (52 MB)
- **後端：** SQLite (WAL mode) + FTS5 全文搜尋 + pure-Go HNSW vector index
- **資料庫：** `E:\Agent team\.opencode\nram.db`
- **連接埠：** HTTP :8674 (Streamable HTTP, OAuth MCP)
- **自動啟動：** 已加入 Windows 啟動資料夾，`scripts/start-nram.ps1` 負責啟動與健康檢查
- **記憶空間：**
  | Project | 內容 | 記憶數 |
  |---------|------|--------|
  | global | 工具知識、偏好、約定、MCP 資訊 | 10+ |
  | agent-team | PRD、tech stack、ADRs、團隊上下文、session notes | 15+ |
  | about_me | 使用者 persona (保留) | 自動 |
- **無 embedding 提供者** — 搜尋使用 FTS5 關鍵字 (無語意向量搜尋)

## 5. 關鍵檔案清單

| 檔案 | 用途 |
|------|------|
| `E:\Agent team\AGENTS.md` | 團隊指令與路由協議 (global + project 兩層) |
| `E:\Agent team\opencode.json` | 專案層級 OpenCode 配置 |
| `E:\Agent team\scripts\start-nram.ps1` | nram 啟動腳本 (健康檢查 + 自動重啟) |
| `C:\Users\User\.config\opencode\opencode.json` | 全域配置 — 15 個 Agent + 8 個 MCP |
| `C:\Users\User\.config\opencode\skills\` | 技能檔案：memory-management, session-memory, decision-log |
| `E:\Agent team\.opencode\commands\` | 自訂命令：session-start, session-end |
| `E:\Agent team\.opencode\nram.db` | nram SQLite 資料庫 |
| `E:\Agent team\.github\workflows\ci.yml` | GitHub Actions CI/CD |
| `E:\Agent team\.github\dependabot.yml` | 自動相依性更新 |

## 6. 基礎設施元件狀態

| 元件 | 狀態 | 說明 |
|------|------|------|
| Docker Desktop v29.5.3 | ✅ 正常 | WSL2 後端，需手動啟動或開機自動啟動 (已設定) |
| MySQL 9.4 Server | ✅ 正常 | Windows 服務，root/ss941227 |
| nram v0.9.0 | ✅ 正常 | HTTP :8674, MCP OAuth 已授權 |
| GitHub | ✅ 正常 | 公開 repo: ZnAllen/agent-team, gh 已登入 |
| CI/CD | ✅ 已設定 | PR/ push 到 main 自動觸發 lint + 檢查 |
| codebase-memory-mcp v0.8.1 | ✅ 正常 | 269 MB, E:\Agent team 已索引 (68 nodes, 67 edges) |
| Playwright MCP | ✅ 正常 | Chromium 149.0 (183 MB) |

## 7. 已知限制與注意事項

| 限制 | 影響 | 因應方式 |
|------|------|----------|
| npm/npx 不在 PATH | 所有 MCP 必須用絕對路徑 | 已全部使用絕對路徑配置 |
| nram 無 embedding | 搜尋僅關鍵字，無法語意匹配 | 已夠用；未來可加 embedding provider |
| Docker Desktop 需登入後手動啟動 | session 開始時 docker 命令可能失敗 | `scripts/start-nram.ps1` 模式可沿用；已加入啟動資料夾 |
| 無集中式日誌 | 除錯需逐個查看 agent 回覆 | 待建立 logging 機制 |

## 8. 部署流程

```bash
# 1. 確保必要服務運行
.\scripts\start-nram.ps1                # nram 記憶伺服器
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"  # Docker

# 2. 啟動 opencode
opencode

# 3. session 開始時自動執行 /session-start
#    - 載入 nram procedural rules
#    - 從 nram recall 專案與全域 context
#    - 讀取相關檔案到 buffer

# 4. session 結束時執行 /session-end
#    - 將重要決策寫入 nram
#    - 更新程序規則
#    - 記錄 session notes (git-ignored)
```

## 9. 附錄：架構演化記錄

| 階段 | 日期 | 本地模型 | VRAM | Agent 數 | MCP 數 |
|------|------|---------|------|---------|--------|
| Phase 1 | Jun 20 | 16 qwen3:1.7b | ~6.5 GB | 32 (16 cloud + 16 local) | 2 |
| Phase 2 | Jun 22 | 1 researcher | ~2.0 GB | 17 (16 cloud + 1 local) | 4 |
| Phase 3 | Jun 22 | 0 | 0 GB | 15 (all cloud) | 4 |
| Phase 4 | Jun 23 | 0 | 0 GB | 15 (all cloud) | 8 (含 nram) |

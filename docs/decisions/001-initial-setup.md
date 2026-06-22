# ADR 001：AI 團隊架構

**日期：** 2026-06-20
**狀態：** 已接受

## 背景

我們正在使用 opencode 作為編排層來建立一個 AI 輔助開發團隊。該團隊需要持久化記憶、一致的程式碼品質、設計判斷力以及使用者研究能力。

## 決策

採用多代理架構，以 opencode（big-pickle）作為團隊負責人：

| Agent | 角色 | 主要職責 |
|---|---|---|
| **big-pickle (Lead)** | 編排者 | 執行任務、分派工作、確保品質 |
| **test-writer** | QA | 撰寫與審查測試、覆蓋率、邊界情況 |
| **code-reviewer** | Reviewer | 錯誤偵測、錯誤處理、安全性 |
| **architecture-guardian** | Reviewer | 確保程式碼一致性與 ADR 合規性 |
| **design-reviewer** | Designer | 依據設計原則進行 UI/UX 審查 |
| **user-researcher** | Researcher | 將使用者回饋綜整為洞察 |
| **memory-keeper** | Librarian | 跨工作階段持久化與檢索知識 |
| **product-manager** | Strategist | 產品願景、需求、優先順序 |
| **devops-sre** | Operator | CI/CD、部署、監控、基礎設施 |
| **security-reviewer** | Auditor | 安全審查、OWASP、滲透測試 |
| **tech-architect** | Architect | 系統設計、技術棧、技術設計文件 |
| **mentor** | Teacher | 結對程式設計、概念教學、逐步引導 |

## 影響

- 注意：qwen 最初被納入，但於 2026-06-20 因透過 task tool 間歇性連線問題而被移除；同日清理了其專用 MCP server（`memory-qwen` 設為 `enabled: false`）
- 正面：專業 Agent 可專注於特定領域
- 正面：持久化知識庫減少工作階段之間的上下文遺失
- 負面：需要維護更多設定
- 負面：需要嚴格記錄決策的紀律

## 備註

- 知識庫位於 `docs/`
- Agent 定義位於 `.opencode/agents/`
- Skills 位於 `.opencode/skills/`

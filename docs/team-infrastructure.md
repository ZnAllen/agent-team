# 團隊基礎架構設計文件

## 1. 架構概觀

本文件提供 Agent Team 基礎架構的完整參考，涵蓋 `E:\Agent team` 工作區內所有元件。團隊以 **opencode CLI** 為核心，驅動 32 個 Agent（16 雲端 API + 16 本地 Ollama），搭配 MCP 向量記憶系統，實現分層路由、零成本研究與自動化每日技術掃描。

## 2. 系統架構圖

```
┌──────────────────────────────────────────────────────────────┐
│                        opencode CLI                           │
│              (指令路由 + 工具調用 + MCP 客戶端)                 │
├──────────────────────────────────────────────────────────────┤
│  ┌────────────────────────┐  ┌────────────────────────────┐  │
│  │  16 API Agents (Tier 2) │  │  16 Ollama Apprentices    │  │
│  │  (cloud API, 正式執行)   │  │  (local qwen3:1.7b, 研究) │  │
│  │                        │  │  Tier 1: 0 API cost        │  │
│  │  code-writer-a/b/c/d   │  │  ─────────────────         │  │
│  │  code-reviewer         │  │  共用同一基底權重           │  │
│  │  architecture-guardian │  │  16 組不同的 Modelfile      │  │
│  │  design-reviewer       │  │  (SYSTEM prompt + temp.)    │  │
│  │  security-reviewer     │  │                             │  │
│  │  test-writer           │  │  temp 0.3 (Precise) ×4      │  │
│  │  memory-keeper         │  │  temp 0.4-0.6 (Balanced)×7  │  │
│  │  devops-sre            │  │  temp 0.7 (Creative) ×5     │  │
│  │  mentor                │  │                             │  │
│  │  product-manager       │  │  ─────────────────         │  │
│  │  user-researcher       │  │  無網路權限，純文字推理      │  │
│  │  tech-architect        │  │  回覆標記自信度              │  │
│  │                        │  │  [CONFIDENT]/[UNCERTAIN]    │  │
│  └────────────────────────┘  └────────────────────────────┘  │
├──────────────────────────────────────────────────────────────┤
│  MCP Memory Servers                                          │
│  ┌──────────────────────┐  ┌──────────────────────────────┐  │
│  │  memory-global        │  │  memory-project              │  │
│  │  ~/.opencode/         │  │  E:\Agent team\.opencode/    │  │
│  │  跨專案偏好/風格/習慣   │  │  本專案領域/架構/團隊脈絡    │  │
│  └──────────────────────┘  └──────────────────────────────┘  │
├──────────────────────────────────────────────────────────────┤
│  組態源頭: C:\Users\User\.config\opencode\opencode.json     │
│  (定義 32 個 Agent 的 mode/description/command)             │
└──────────────────────────────────────────────────────────────┘
```

## 3. Agent 階層與路由

```
收到任務 → 關鍵字比對判定 Tier
  │
  ├── Tier 1: 研究/查詢/解釋（0 API cost）
  │     → @apprentice-xxx (本機 qwen3:1.7b)
  │       ├── [CONFIDENT] → 直接回覆使用者
  │       └── [UNCERTAIN] → 附 context 轉 Tier 2
  │
  ├── Tier 2: 實作/測試/審查（雲端 API）
  │     → @code-writer-a/b/c/d, @test-writer, 等
  │     ※ 可選：先派學徒（Tier 1）收集 context
  │
  └── Tier 3: 架構/設計/安全/策略（Lead 直做）
        → @product-manager, @tech-architect,
          @security-reviewer, @architecture-guardian
```

**路由關鍵字對照：**
| 觸發字 | Tier | 路由目標 |
|--------|------|----------|
| 研究、查詢、解釋、比較、摘要 | T1 | @apprentice-xxx |
| 實作、寫、新增、測試、Review | T2 | 對應 code-writer / test-writer |
| 架構、設計、規劃、安全、審計 | T3 | Lead 直做 |

**Lead 角色：** Orchestrator — 不直接實作，負責任務拆解、委派、品質閘門。

## 4. Apprentice 模型架構

所有 16 個學徒模型共用同一個基底權重 `qwen3:1.7b`（~1.8GB VRAM），透過不同的 Modelfile 實現角色分化：

```
qwen3:1.7b (基底模型, ~1.8GB VRAM)
  │
  ├── Modelfile: code-writer-a  ─── temp 0.7, SYSTEM: 前端開發
  ├── Modelfile: code-writer-b  ─── temp 0.7, SYSTEM: 後端開發
  ├── Modelfile: code-writer-c  ─── temp 0.7, SYSTEM: 共用工具
  ├── Modelfile: code-writer-d  ─── temp 0.7, SYSTEM: GPU/CUDA
  ├── Modelfile: devops-sre     ─── temp 0.7, SYSTEM: CI/CD/維運
  ├── Modelfile: architecture-guardian ─ temp 0.4, SYSTEM: 合規審查
  ├── Modelfile: test-writer    ─── temp 0.5, SYSTEM: 測試
  ├── Modelfile: memory-keeper  ─── temp 0.5, SYSTEM: 記憶管理
  ├── Modelfile: mentor         ─── temp 0.6, SYSTEM: 教學指導
  ├── Modelfile: product-manager ── temp 0.5, SYSTEM: 產品策略
  ├── Modelfile: tech-architect ─── temp 0.5, SYSTEM: 架構設計
  ├── Modelfile: lead           ─── temp 0.5, SYSTEM: 團隊領導
  ├── Modelfile: code-reviewer  ─── temp 0.3, SYSTEM: 程式審查
  ├── Modelfile: design-reviewer ── temp 0.3, SYSTEM: UI/UX 審查
  ├── Modelfile: security-reviewer ─ temp 0.3, SYSTEM: 安全審計
  └── Modelfile: user-researcher ── temp 0.3, SYSTEM: 用戶研究
```

**Temperature 對照表：**
| 階層 | 溫度 | 模型數 | 適用場景 |
|------|------|--------|----------|
| Creative | 0.7 | 5 | 程式碼生成、腳本撰寫、創意發想 |
| Balanced | 0.4-0.6 | 7 | 一般任務、產品策略、記憶管理 |
| Precise | 0.3 | 4 | 審查、安全、品質閘門（要求一致性） |

所有模型共用基底權重，Ollama 透過 `Modelfile` 中的 `FROM qwen3:1.7b` 指向同一組參數，僅 SYSTEM prompt 與 temperature 不同。VRAM 佔用約 2GB（單一模型載入），足以在 4GB GPU 上運行。

## 5. 每日技術掃描流程

```
Session 開始
  ├── ① ensure-ollama.ps1
  │     ├── 檢查 ollama.exe 是否執行
  │     ├── 未執行 → Start-Process 自動啟動
  │     └── 呼叫 warmup-ollama.ps1
  │
  ├── ② warmup-ollama.ps1
  │     ├── GET /api/ps 檢查模型是否已載入
  │     ├── 未載入 → POST /api/generate 推論一次
  │     └── 設定 keep_alive=30m 保持 GPU 駐留
  │
  ├── ③ @memory-keeper 執行每日技術掃描
  │     ├── 檢查 git 更新、相依套件、API 狀態
  │     ├── 比對前日掃描結果
  │     └── 產出 docs/session-notes/daily-tech-YYYY-MM-DD.md
  │
  └── ④ Lead 摘要發現 → 詢問使用者第一個指令
```

## 6. 關鍵檔案清單

| 檔案 | 用途 |
|------|------|
| `E:\Agent team\AGENTS.md` | 專案層級 Agent 指令（每日掃描流程 + 路由協議） |
| `E:\Agent team\ensure-ollama.ps1` | Ollama 啟動檢查 + GPU 預熱觸發 |
| `E:\Agent team\warmup-ollama.ps1` | 將 qwen3:1.7b 載入 GPU 記憶體，設 keep_alive=30m |
| `E:\Agent team\benchmark-apprentices.ps1` | 16 模型 × 3 查詢 = 48 次推論基準測試 |
| `E:\Agent team\apprentices\build-all.ps1` | 批次建立所有 16 個 Ollama 模型 |
| `E:\Agent team\apprentices\validate-all.ps1` | 7 項完整性檢查（Modelfile、KB、模型存在等） |
| `C:\Users\User\.config\opencode\opencode.json` | 32 個 Agent 的單一組態源頭 |
| `E:\Agent team\apprentices\{name}\Modelfile` | 各學徒的 Ollama 模型定義（FROM + SYSTEM + PARAMETER） |
| `E:\Agent team\apprentices\{name}\knowledge-base.md` | 各學徒的領域知識庫 |

## 7. 基準測試結果摘要

**測試日期：** 2026-06-22
**測試規模：** 16 models × 3 queries = 48/48 成功（100%）

| 指標 | Creative (0.7) | Balanced (0.4-0.6) | Precise (0.3) |
|------|---------------|-------------------|--------------|
| 模型數 | 5 | 7 | 4 |
| 首次 TTFT 中位數 | ~428ms | ~484ms | ~574ms |
| 後續 TTFT | 65-101ms | 64-67ms | 66-70ms |
| Tokens/s 範圍 | 82-90 | 70-89 | 78-87 |
| 平均總時間 (查詢 A) | ~2.5-10s | ~2.3-5s | ~2.5-4.7s |
| 平均總時間 (查詢 B) | ~14-17s | ~13-17s | ~11-20s |

**關鍵發現：**
- **First-call penalty:** 首次推論需載入模型，TTFT 顯著較高（268-673ms）；後續查詢降至 ~65ms
- **VRAM 使用：** 單一 qwen3:1.7b 約佔 1.8GB，搭配 warmup keep_alive 可持續駐留 GPU
- **設計審查者（design-reviewer）** 有最高首次 TTFT（673ms），因其知識庫較大（621 prompt tokens）
- **T/s 穩定度：** 所有模型 tokens/s 集中在 80-90，差異主要來自輸出長度而非推理速度

## 8. 已知限制與未來改善

| 限制 | 影響 | 改善方向 |
|------|------|----------|
| qwen3:1.7b thinking 開銷 | ~30-70% 輸出為思考過程，浪費 tokens | 考慮切換至非 thinking 模型或設定思考預算上限 |
| 無 Ollama 降級備援 | 若 Ollama 未執行，Tier 1 完全停擺 | 加入 HTTP 健康檢查 + 自動重啟邏輯 |
| 自信度校準未驗證 | `[CONFIDENT]` / `[UNCERTAIN]` 的準確率未知 | 設計校準測試集，計算自信度 vs. 實際正確率 |
| 16 模型同時載入 VRAM 不足 | 僅能同時駐留 1-2 個學徒 | 依賴 keep_alive + LRU 淘汰策略 |
| 無集中式日誌 | 學徒回覆無法追溯除錯 | 加入 request/response 日誌到 `.opencode/logs/` |

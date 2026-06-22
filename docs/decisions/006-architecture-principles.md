# ADR-006: 架構原則 (Architecture Principles)

## Status

Accepted

## Context

在 2026-06-20 的產品願景工作坊中，architecture-guardian 與 product-manager、user-researcher、design-reviewer 共同定義了產品的架構層級原則。這些原則是未來所有系統設計、技術選型與程式碼審查的基礎假設。

本 ADR 記錄產品願景文件 `docs/product-vision.md` 中第 10–13 節 (架構層級) 所隱含的 7 項架構原則，並補充工作坊討論中形成的共識與取捨。

## Decision

### 原則一：API-First — 產品本身就是 API

> 對應 Product Vision §5 (API-first：產品本身就是 API)、§10 (Data Sync 透過 webhook 或 API)

**所有功能都必須有 API 端點。UI 只是 API 的一個客戶端。**

#### 理由

1. **CI/CD 原生整合** — pipeline 需要在 merge 時呼叫「關閉 task #42」，而不是模擬瀏覽器操作
2. **生態系擴展** — GitHub Actions、Slack slash commands、自訂 script 都透過同一組 API 與核心互動
3. **Zero Lock-in 的前提** — 如果所有操作都有 API，匯出與遷移就不需要 reverse engineer UI 的行為
4. **測試面** — API 合約明確，integration test 可以直接驗證 business logic 而不需要經過 UI

#### 意涵

- Route 設計以 resource 為中心 (`/tasks`, `/workspaces/:id/members`)，不以頁面為中心
- API versioning 從 v1 開始 (URL path 或 header)
- Internal UI 元件也只能透過 API 取得資料，不能直接存取資料庫
- 所有 mutation 操作回傳完整 resource 而非僅 ID (RESTful 慣例)

---

### 原則二：Event-Driven Architecture — 事件驅動，非流程驅動

> 對應 Product Vision §10 (Events：hook 到任務建立、狀態轉換、評論等事件)

**Plugin 與擴展 hook 到事件 (task.created、status.changed)，不修改核心 workflow。**

#### 理由

1. **核心簡潔** — 核心系統只需要關心 4 種狀態轉換，不需要知道 plugin 在做什麼
2. **Plugin 隔離** — 一個 plugin 當掉不會影響核心流程 (circuit breaker 在事件層實作)
3. **可觀測性** — 所有事件有紀錄，可以 replay、可以 debug「為什麼這個 webhook 沒觸發」
4. **Async 本質** — 事件發送後立即回傳，不等待 handler 完成，符合 async-first

#### 意涵

- 定義核心事件清單 (task.created、task.updated、status.changed、comment.added、member.joined)
- 事件 payload 包含足夠 context (resource snapshot + delta)，避免 handler 需要額外查詢
- 事件傳遞使用 message queue (e.g., RabbitMQ / Redis Stream) 而非直接 HTTP callback
- Handler 失敗不影響主流程，但有 dead-letter queue 與 retry 機制

---

### 原則三：Zero Lock-In — 零鎖定，隨時可遷出

> 對應 Product Vision §11 (所有資料以 Markdown 作為 canonical format)

**Markdown 是資料的 canonical format。匯出功能不是加進去的功能，是核心架構的一部分。使用者應能在 5 分鐘內將全部資料匯出為可讀的 Markdown 文件。**

#### 理由

1. **信任** — 小型團隊最怕 vendor lock-in。保證可遷出是讓團隊願意採用的前提
2. **互通性** — Markdown 是人類與機器都可讀的格式，即使離線也能用任何編輯器開啟
3. **備份即匯出** — 不需要專屬備份工具，git push markdown files 就是備份
4. **Long-term archive** — 五年後這個產品可能不存在，但 Markdown 永遠可讀

#### 意涵

- Database 中的每一筆 task、comment、document 都必須能單向映射到 Markdown
- Export 不是背景 job — 是直接從 database 產生 Markdown 的同步操作，確保 5 分鐘內完成 (1000 tasks 以內)
- Import 支援 Markdown 反向解析 (optional，P1)
- 不依賴專屬 binary format 儲存任何使用者資料
- 附件 (images, files) 以相對路徑連結儲存於 workspace export 目錄

---

### 原則四：Multi-Tenant from Day One — 從第一天起多租戶

> 對應 Product Vision §12 (每個 workspace 的資料完全隔離)

**Schema 設計從第一天就支援多租戶。這不是「以後再處理」的問題——這是資料模型的基本假設。**

#### 理由

1. **資料隔離是安全基礎** — 不同 workspace 的使用者不該有機會看到彼此資料
2. **避免大規模 migration** — 先做 single-tenant 再轉 multi-tenant 的成本遠高於第一天就設計好
3. **B2B 商業模式** — 即使 MVP 是單一 workspace，未來付費版本需要 workspace 管理
4. **測試與 staging** — 內部團隊可以用 workspace 隔離 dev/staging/production 資料

#### 意涵

- 所有 table 都有 `workspace_id` 作為 composite primary key 的一部份
- DB queries 預設加上 `WHERE workspace_id = ?`（透過 middleware / RLS 強制）
- Workspace 層級的 rate limiting、storage quota、feature flags
- URL 路徑包含 workspace slug (`/workspace-slug/tasks/42`)
- 不用 schema-per-tenant (PostgreSQL schema 隔離)，因為：
  - Migration 需要跑 N 次
  - Connection pooling 效率較差
  - 小型團隊規模不需要，row-level isolation 已足夠

---

### 原則五：Observability as UX — 可觀測性就是使用者體驗

> 對應 Product Vision §13 (團隊應該能看到自己的工作流數據)

**Cycle time、throughput、blocker 熱點不是「報表功能」，而是 UX 的一部份。Marcus 打開 tool 就應該知道「這週 shipping 速度正常嗎？」**

#### 理由

1. **消除手動報告** — 團隊不該為了回答「這週 shipping 什麼」而開會或整理 spreadsheet
2. **數據驅動的改善** — 可視化的 workflow 數據讓 retrospective 有事實基礎而非感覺
3. **信號/雜訊分離** — Marcus 的痛點是「所有事情看起來一樣重要」，數據儀表板提供信號
4. **即時反饋迴圈** — 當開發者看到自己的 cycle time 趨勢，自然會優化工作方式

#### 意涵

- 儀表板不是獨立頁面 — 洞察嵌入在任務列表、團隊視圖、digest 中
- 追蹤的指標：
  - **Cycle time** (從 Todo → Done 的經過時間，P50/P80/P95)
  - **Throughput** (每週 completed tasks 數量)
  - **Blocker 熱點** (哪些任務/成員被 blocked 最久)
  - **Shipped vs Planned** (Now/Next/Later 的完成率)
- 指標計算在 read path 上即時計算，不依賴排程的 ETL job (因為數據量在小型團隊規模下可接受)
- 比較基準是 workspace 自身的歷史趨勢，而非跨 workspace 的 benchmark (隱私考量)

---

### 原則六：Extend at Fixed Points Only — 在固定點擴展，而不是處處開洞

> 對應 Product Vision §10 (擴展點只能在 Events、UI Slots、Data Sync)

**不要讓使用者修改核心流程。擴展點限制在三個固定位置。**

#### 理由

1. **核心穩定性** — 不允許 plugin 修改核心 state machine，確保任務狀態永遠可預測
2. **支援成本** — 客製 workflow 是 Jira 最大的支援黑洞。固定擴展點讓團隊可以專注
3. **Onboarding 速度** — 新成員加入時不需要學習「這個 workspace 的客製流程」
4. **升級相容性** — 固定擴展點有明確的 API contract，升級時只需要檢查這三個點

#### 意涵

**允許的擴展點：**

| 類型 | 內容 | 範例 |
|------|------|------|
| **Events** | hook 到生命週期事件 | 任務建立時發 Slack 通知、狀態轉換時更新外部看板 |
| **UI Slots** | 指定位置插入自訂元件 | Task detail 側欄顯示外部系統連結、自訂 badge |
| **Data Sync** | webhook / API 同步 | 每小時同步到內部報表系統、雙向同步 GitHub Projects |

**禁止的擴展點：**

- 修改核心狀態轉換邏輯 (不能新增自訂狀態)
- 修改 API 回傳結構 (不能加欄位到 core resource)
- 攔截並取消核心事件

---

### 原則七：Async-First，Not Real-Time-First — 非同步優先，非即時優先

> 對應 Product Vision §3 (Async-first，不是 real-time-first)、Session Note 記錄的架構方向

**所有更新持久化、可回溯、非同步。Real-time 通知只在需要行動時觸發，而非作為資訊流水帳。**

#### 理由

1. **跨時區協作** — Yuki 的痛點：時差 = 錯過會議 = 被排除在外。Async 設計讓參與不依賴同時在線
2. **減少中斷** — Priya 需要 flow state。即時通知只有在她「需要行動」時才打斷她
3. **完整的 audit trail** — 所有決策、評論、狀態變更都有時間戳與作者，可以回答「為什麼這個任務卡住了三天？」
4. **Digest 模式** — 使用者可以選擇「每天一次 digest」而非「每分鐘一次通知」，降低認知負荷

#### 意涵

- 所有 mutation 都是持久化寫入後才 response (write-through)，不允許純 in-memory 的暫時狀態
- 通知分為兩個等級：
  - **Action required** (需要使用者回應) → real-time 推送 (email / push / Slack)
  - **Information** (純知悉) → 納入 digest，不即時推送
- 伺服器發送的事件是 at-least-once delivery，客戶端需要處理 idempotency
- Digest 的頻率可設定 (每天一次 / 每次登入 / 每 4 小時)
- 不使用 WebSocket 作為主要的資料同步機制 — REST API + 樂觀更新 + 背景 polling 即可滿足非同步需求

---

## Consequences

### Positive

1. **架構一致性** — 所有 future 功能開發都有明確的決策框架，減少反覆討論
2. **Plugin 生態系可期** — 固定擴展點讓第三方開發者可以安全地擴充功能
3. **低遷移成本** — Zero lock-in + API-first 確保使用者隨時可以離開，降低採用門檻
4. **可測試性高** — Event-driven + API-first 讓每個元件可以獨立測試
5. **資料安全** — Multi-tenant isolation 從第一天內建，不需要事後補救

### Negative

1. **前期開發成本較高** — Multi-tenant schema、event system、API-first 都需要在 MVP 階段投入
2. **部分 real-time 情境受限** — 協作編輯 (如多人同時編輯任務描述) 需要 extra 設計才能支援 async-first
3. **Eventual consistency 的 UX 挑戰** — 非同步事件表示使用者可能看到短暫的過期狀態，需要 UI 層處理
4. **Plugin 靈活性不如 Jira** — 固定擴展點無法滿足所有客製需求，部分團隊可能覺得不夠自由

### Mitigations

1. **MVP 階段可以使用 single-tenant 實作，但 schema 必須預留 workspace_id**，降低前期實作成本
2. **Eventual consistency 的 UI 處理**：所有資料顯示時附加「上次更新時間」，讓使用者知道數據時效
3. **Plugin 受限是設計選擇 (opinionated)**，與產品定位一致。需要高度客製的團隊不是我們的 target user

---

## References

- Product Vision §5: API-first：產品本身就是 API
- Product Vision §10: 在固定點擴展，而不是處處開洞
- Product Vision §11: 零鎖定，隨時可遷出
- Product Vision §12: Workspace Isolation + Multi-tenant from Day One
- Product Vision §13: Observability as UX
- Product Vision §3: Async-first，不是 real-time-first
- Session Note: 2026-06-20-initial-setup.md (Decisions 區塊記載架構方向)
- ADR-002: Dual-UI 架構 (同一份數據，兩種視界)

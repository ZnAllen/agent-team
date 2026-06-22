# Product Vision

> 最後更新：2026-06-20
> 作者：Product Manager

---

## Mission

> **協助小型產品團隊順暢協作、自動化開發流程、並讓所有人——無論技術背景——都能一目瞭然專案狀態。讓團隊把時間花在真正重要的工作上，而不是更新工具。**

我們的信念是：最好的專案管理工具，是那些讓你幾乎感覺不到它存在的工具。當開發者 push 程式碼時，任務自動前進；當設計師交付 Figma 稿時，團隊立刻知道哪些設計已就緒；當 PM 打開儀表板時，看到的是 shipping 進度而不是需要手動整理的狀態。

我們不是要做「另一個 Jira」或「Linear 的克隆」。我們要做的是 **以開發流程為核心、讓設計與管理順暢參與的團隊協作層**——開發者擁有 git-native 的速度體驗，非開發者擁有任務導向的清晰視角。同一份數據，兩種視界。

---

## Target Users

### 團隊輪廓

| 面向 | 描述 |
|------|------|
| **規模** | 5–15 人小型團隊（開發 + 設計 + PM） |
| **特性** | 混合角色團隊：開發者、設計師、非技術 PM 共同協作；扁平組織、資訊透明需求高 |
| **現狀** | 平均使用 **4.3 種工具** 管理開發流程（GitHub + Slack + Jira/Linear + Notion + Figma + CI），工具間切換疲勞嚴重 |
| **最大痛點** | 流程 overhead：每人每週花 **2.5+ 小時** 在更新工具狀態；83% 開發者認為「git 自動更新狀態」是決定性因素；跨角色資訊斷層——設計師與 PM 無法自然融入開發者 workflow |

### 角色 Personas

#### Alex — 技術主管 (Engineering Lead)

> 「我不想成為團隊的瓶頸，但我需要知道每個人在做什麼，而不必一個一個去問。」

- **背景：** 8 人新創的 tech lead，每天寫程式、review PR、做架構決策
- **痛點：** Jira workflow 太重、工具是為管理者設計不是為開發者設計、Slack/Notion/GitHub 之間不斷切換
- **決定性需求：** 零配置上線、鍵盤驅動、非同步站立會議內建

#### Priya — 全端工程師 (Full-Stack Engineer)

> 「我只想進入 flow state，不要有人為了狀態更新打斷我。」

- **背景：** 12 人團隊的開發者，獨自負責 end-to-end 功能
- **痛點：** 被 Slack 追問已處理的任務、過度設計的欄位（story points / sprint points / epic links）、手動更新不反映現實的狀態
- **決定性需求：** 任務狀態根據 git 活動自動更新、極簡 UI、只在她需要行動時才發出通知

#### Marcus — 兼職 PM / 創辦人 (Part-Time PM / Founder)

> 「我需要知道什麼卡住團隊，而不是又要開一個站立會議。」

- **背景：** 技術創辦人兼 CTO，現在花更多時間在規劃而非寫程式
- **痛點：** 所有事情在工具上看起來都一樣重要——沒有信號/雜訊分離；無法快速看到「這週 shipped 什麼」vs「什麼卡住了」；估時永遠不準
- **決定性需求：** Now / Next / Later 的輕量規劃、自動週期分析（shipped vs planned、cycle time trends）、連結到任務的輕量目標

#### Yuki — 遠端合約開發者 (Remote Contractor)

> 「我加入團隊時不想學一套新的 workflow，也不想因為時差錯過所有討論。」

- **背景：** 跨時區兼職前端工程師，同時與 2–3 個團隊合作
- **痛點：** 每個團隊有不同的工具設定（客製 workflow、47 種狀態）；時差 = 錯過站立會議 = 被排除在 loop 之外；不知道 offline 期間發生了什麼
- **決定性需求：** Async-first（所有溝通是書面的）、digest 模式（「這是昨天發生的事」）、輕量的專案 context 繼承

#### Sophia — 產品設計師 (Product Designer)

> 「我只想知道我設計的功能什麼時候上線、開發到哪了、什麼時候需要我支援。」

- **背景：** 8 人團隊中唯一的設計師，使用 Figma 產出設計稿，與 3–4 位開發者協作
- **痛點：** 設計交付後就進入黑洞——不知道開發進度、PR 審查時才發現偏離設計、需要手動追每個任務狀態；看到 branch 名稱和 commit hash 完全沒有意義
- **決定性需求：** 視覺化任務看板、Figma 整合（任務自動連結設計稿）、開發進度一目瞭然（不需要理解 git）

#### Jamie — 非技術 PM (Non-Technical Product Manager)

> 「給我路線圖和進度，不要給我 commit log。」

- **背景：** 10 人團隊的非技術 PM，負責產品規劃與 stakeholders 溝通，不做開發
- **痛點：** 任務工具充斥技術術語（sprint points / epics / milestones）；無法快速回答「這週會 shipping 什麼？」；需要手動整理狀態給老闆看；看不見設計與開發之間的依賴關係
- **決定性需求：** 純粹的任務視圖（無 git 概念）、Now / Next / Later 路線圖、自動 shipped vs planned 報告、blocker 熱點視覺化

---

## Success Metrics

### 北極星指標 (North Star)

> **團隊每週花在「管理工作」的時間減少 70%**（從 ~2.5 hrs/人/週降到 ~0.75 hrs/人/週）

### 關鍵結果 (OKRs)

| 指標 | 當前基準 | 目標（6 個月） | 衡量方式 |
|------|---------|---------------|---------|
| **手動狀態更新次數** | 每天每人 ~8 次 | ≤1 次（僅初始指派） | 工具內部追蹤 |
| **工具切換次數** | 4.3 工具/天 | ≤2 工具/天（GitHub + 本工具） | 使用者調查 |
| **團隊可視性耗時** | 每天 ~15 min 查看狀態 | ≤2 min（打開 digest 即知） | 工具內部追蹤 |
| **新成員上手時間** | 2–3 天（含設定） | ≤30 分鐘 | 引導流程完成率 |
| **NPS（開發者滿意度）** | Jira 平均 NPS: -38 | ≥+30 | 季度調查 |
| **自動化準確率** | N/A（全新功能） | git 狀態預測準確率 ≥95% | 工具內部比對 |
| **每週活躍用戶率** | N/A | 團隊成員 DAU/MAU ≥80% | 產品分析 |

### 反指標 (Counter Metrics)

我們同時追蹤這些指標以避免錯誤的激勵：

- ❌ **通知疲勞**：如果每位用戶每天收到超過 10 條通知，代表我們產生太多雜訊 → 需要調整通知策略
- ❌ **功能棄用率**：如果某個功能上線後 4 週內使用率 <20%，代表它解決的是假問題 → 重新評估
- ❌ **流程僵化**：如果團隊開始抱怨「又要更新這個工具了」，代表我們正在變成下一個 Jira

---

## Key Principles

### 產品層級

#### 1. 🧬 Git-native 不是選項，是核心
工具的每一層都理解 git 工作流。分支代表任務、PR 代表審查、merge 代表完成。不要「整合」git——**以 git 為基礎設計整個狀態模型**。83% 的使用者說這是決定性因素——這就是我們的 moat。

#### 2. 🏔 Opinionated 簡潔勝過彈性
我們選擇 4 個欄位（Backlog / Doing / In Review / Done）而不是 47 個客製狀態。我們選擇 Now / Next / Later 而不是複雜的 sprint 設定。**彈性是給企業用的，小型團隊需要的是方向和 momentum。** 如果有 10% 的團隊需要客製化，我們提供 plugin 擴展點，而不是內建 100 個開關。

#### 3. 🌊 Async-first，不是 real-time-first
團隊不應該為了同步資訊而開會。所有的任務更新、評論、決策都應該是**持久化、可回溯、非同步**的。Real-time 通知只在需要行動時觸發（你的 PR 被 blocked 了、有人 @了你），而不是「誰 push 了程式碼」的流水帳。

#### 4. ⚡ 速度是功能，不是優化
任何頁面載入超過 **200ms** 就是 bug。不要有 skeleton loading——用樂觀更新 (optimistic UI)。使用者不應該等待工具。Linear 已經證明了「速度本身就是一個 killer feature」。

#### 5. 🔌 API-first：產品本身就是 API
所有的功能都要有 API 端點。UI 只是 API 的一個客戶端。這確保了：
- 可以被 CI/CD pipeline 呼叫（「Close task #42 on merge」）
- 可以被 GitHub Actions / Slack 整合
- 使用者沒有 lock-in——資料隨時可以匯出

#### 6. 🔭 Dual UI：同一份數據，兩種視界
開發者看到的是 branch、PR、commit——因為這才是他們的工作單位。設計師與 PM 看到的是任務、狀態、進度——因為他們不需要（也不應該需要）理解 git。**不是兩套產品，而是同一份數據的兩種呈現。** 技術視角忠實反映 git workflow，簡單視角隱藏所有實作細節。使用者選擇自己的視角，但團隊共享同一份真實。

### 設計層級（來自 Design Reviewer）

#### 7. 🎯 Precision over personality
精確的資訊層級、克制的視覺語言。單一 accent color、dark-first 主題（背景 `#0f0f0f`）、shadow-as-border（參考 Vercel 手法）。**不要**使用 Tailwind indigo、漸層、emoji 作為 icon、或是左框線卡片——這些是 AI 生成的 slop 信號。

#### 8. 📐 資訊密度與清晰度並存
開發者需要在一個畫面看到足夠的 context。使用克制的排版層級（參考 Craft Typography Hierarchy）、恰到好處的留白、不需要 hover 才能看到的關鍵資訊。

#### 9. 🧘 冷靜的動畫 (Calm Motion)
動畫只在有意義的狀態轉換時使用（任務完成、建立、歸檔）。持續時間 ≤300ms，尊重 `prefers-reduced-motion`。不要有彈跳、旋轉、或「慶祝」效果。

### 架構層級（來自 Architecture Guardian）

#### 10. 🧩 在固定點擴展，而不是處處開洞
不要讓使用者修改核心流程。擴展點只能在：
- **Events**：hook 到任務建立、狀態轉換、評論等事件
- **UI Slots**：在指定的位置插入自訂元件
- **Data Sync**：透過 webhook 或 API 同步到外部系統

#### 11. 🏗 零鎖定，隨時可遷出
所有資料以 **Markdown 作為 canonical format**。匯出功能不是加進去的功能——是核心架構的一部分。使用者應該能在 5 分鐘內把全部資料匯出為可讀的 Markdown 文件。

#### 12. 🔒 Workspace Isolation + Multi-tenant from Day One
每個 workspace 的資料完全隔離。schema 設計從第一天就支援多租戶。這不是「以後再處理」的問題——這是資料模型的基本假設。

#### 13. 👁 Observability as UX
團隊應該能看到自己的工作流數據（cycle time、throughput、blocker 熱點），不是因為我們提供了「報表功能」，而是因為這些數據是 UX 的一部分。Marcus 應該打開 tool 就知道「這週 shipping 速度正常嗎？」

---

## Current Focus

### 現在在做什麼 (Now)

#### P0 — 核心自動化循環
> 目標：讓使用者首次體驗「開箱即用，git 自動驅動任務」

- [ ] **Git 自動狀態推論** — 根據 branch / commit / PR / merge 活動自動轉換任務狀態（Todo → In Progress → In Review → Done），零手動操作
- [ ] **GitHub 深度整合** — OAuth 授權、webhook 監聽、PR description 中的 task ID 自動連結
- [ ] **極簡任務 CRUD** — 5 個欄位：標題、描述、狀態、負責人、關聯分支/PR。不能再多
- [ ] **樂觀回應架構** — 所有操作 <200ms 感覺延遲，失敗時優雅恢復

#### P1 — 團隊非同步可視性 + 雙視角協作
> 目標：讓 Alex 不用問就知道「誰在做什麼」，讓 Sophia 一看就知道設計進度，讓 Jamie 打開就看到路線圖

- [ ] **團隊視圖 (Team View)** — 一眼看到所有人當前的任務、狀態、阻塞項目
- [ ] **非同步 Digest** — 每日（或每次登入時）摘要：你離開期間發生了什麼、哪些需要你注意
- [ ] **輕量目標規劃** — Now / Next / Later 三層級，連結到任務，取代 sprint 和 story points
- [ ] **週期回顧** — 自動產生 shipped vs planned、cycle time、blocker 分析
- [ ] **Dual-View 架構** — 團隊視圖與任務列表支援「技術模式」與「簡潔模式」切換。非開發者可隱藏 branch、PR、commit 等 git 細節，聚焦於任務狀態與進度；開發者不受影響，繼續以 git 視角工作。同一份數據，不同 surface

### 下一步做什麼 (Next)

- **Slack / Discord 整合** — 在聊天工具中接收 digest 和通知，但不把聊天當作資料來源
- **Plugin 系統** — 事件 hook + UI slot 的文件化，讓社群可以擴展
- **CI 狀態整合** — 在任務上顯示關聯 PR 的 CI 通過/失敗狀態
- **手機 Web App** — 主要是讀取和輕量操作（評論、審閱 digest）
- **Figma 整合** — 在任務中嵌入 Figma 設計稿預覽、自動從 Figma 更新設計交付狀態（「設計已交付」、「準備開發」）、任務與設計稿雙向連結
- **視覺化看板視圖** — 以 Kanban 風格呈現任務，支援拖曳排序，適合視覺導向的 Sophia 與 Jamie

### 目前不做的 (Later / Not Now)

| 功能 | 原因 |
|------|------|
| **Gantt chart / 甘特圖** | 小型團隊不需要。老派 PM 工具的包袱。 |
| **Resource management / 資源管理** | 15 人以下的團隊不需要 capacity planning |
| **Time tracking / 計時** | 增加 overhead，違反 mission |
| **Custom workflows / 客製流程** | 會讓新成員 onboarding 變慢。用 plugin 取代 |
| **Real-time chat / 即時訊息** | 市場上已經有 Slack/Discord。我們不做另一個 |
| **AI 自動指派 / 自動預估** | 時機未到。先做好核心自動化再談 AI |

---

## 策略備註

### 我們的競爭定位

| 面向 | Jira | Linear | Notion Projects | 我們 |
|------|------|--------|----------------|------|
| 設定時間 | 2–3 天 | 30 分鐘 | 15 分鐘 | **10 分鐘** |
| 自動化程度 | 手動為主 | 半自動 | 手動 | **git 全自動** |
| 適合團隊 | 50+ 企業 | 10–50 成長型 | 全規模 | **5–15 小型團隊** |
| 設計哲學 | 功能完整 | 速度優先 | 彈性優先 | **opinionated 簡潔** |
| 資料鎖定 | 高 | 中 | 中 | **零鎖定 (Markdown export)** |

### 為什麼這個團隊會成功

1. **我們就是 target user**——我們是 5–15 人的小型開發團隊，沒有專職 PM，每天都在感受這些 pain point
2. **我們有清晰的敵人**——不是 Jira（它已經被討厭了），而是「手動更新狀態的 overhead」和「工具切換的疲勞」
3. **我們有明確的取捨**——我們選擇不做很多事，這讓我們能專注把少數幾件事做到極致

---

*本文件由 Product Manager 維護。重大變更需經過團隊 review 並更新 ADR。*

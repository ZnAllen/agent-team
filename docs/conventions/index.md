# 團隊通用約定

> **最後更新：** 2026-06-20
> **維護者：** tech-architect
>
> 這些約定適用於本團隊的**所有專案**。各個專案可能另有補充約定，存放於 `docs/conventions/<project-name>.md`。

---

## 1. 程式碼風格

### 1.1 格式化（自動化）

| 規則              | 設定                                        | 強制工具    |
|-------------------|---------------------------------------------|-------------|
| **縮排**          | 2 空格（不使用 Tab）                         | Prettier    |
| **引號**          | JS/TS 使用單引號（`'`）；JSX 使用雙引號      | Prettier    |
| **分號**          | 總是加上（`"semi": true`）                  | Prettier    |
| **尾隨逗號**      | ES5（物件、陣列、匯入 — 舊版 Node 的函式參數除外） | Prettier |
| **列印寬度**      | 100 字元                                    | Prettier    |
| **括號換行**      | `"bracketSameLine": false`（多行 JSX 的閉合 `>` 在新行） | Prettier |
| **箭頭函式括號**  | 總是加上（`(x) => x`，不可寫成 `x => x`）   | Prettier    |

請在你的編輯器中安裝 Prettier 插件，並啟用**儲存時自動格式化**。

### 1.2 命名約定（通用）

| 類別                    | 命名方式          | 範例                                  | 規則                           |
|-------------------------|-------------------|---------------------------------------|--------------------------------|
| **變數**                | `camelCase`       | `taskStatus`、`isLoading`             | 一律遵守                       |
| **函式**                | `camelCase`       | `getTaskById()`、`handleSubmit()`     | 一律遵守                       |
| **類別**                | `PascalCase`      | `TaskService`、`UserRepository`       | 一律遵守                       |
| **型別 / 介面**         | `PascalCase`      | `Task`、`CreateTaskInput`             | 介面不加 `I` 前綴 — 使用純名稱。|
| **列舉**                | `PascalCase`      | `TaskStatus`、`Priority`              | 列舉值使用 `SCREAMING_SNAKE` |
| **常數**                | `SCREAMING_SNAKE` | `MAX_TITLE_LENGTH`、`API_VERSION`     | 僅限真正的常數（頂層）          |
| **元件屬性（Props）**   | `camelCase`       | `<TaskCard taskId={id} />`            | 避免 `...props` — 明確解構       |

各框架特定的命名（React 元件、hooks、路由檔案、資料庫表格等）請見該專案的約定文件。

### 1.3 檔案組織規則

- **每個檔案只放一個元件**，關聯性高的小型子元件除外。
- **檔案保持在 300 行以內。** 若超過 300 行，請將邏輯抽離到獨立模組。
- **測試檔案與原始碼放在同一目錄：** `TaskCard.tsx` → `TaskCard.test.tsx`。
- **測試工具檔案**統一放在套件層級的 `__tests__/` 或 `test-utils/` 目錄下。
- **Index 檔案**僅重新匯出公開 API。Index 檔案中不得含有副作用。

### 1.4 匯入順序

請使用匯入排序工具（具體使用哪個插件請見各專案約定）。匯入順序如下：

```
1. Node 內建模組        (fs, path, crypto)
2. 外部套件              (react, next, @tanstack/react-query, hono)
3. 內部套件              (@acme/db, @acme/shared)
4. 內部絕對路徑          (@/components/..., @/lib/...)
5. 相對路徑              (./TaskCard, ../hooks/useAuth)
6. CSS 匯入              (./styles.css, globals.css)
```

各組之間空一行。除 React 和 Next.js 的匯出之外，禁止使用 default import。

### 1.5 TypeScript 嚴格模式規則

```jsonc
// tsconfig.json — 必須的嚴格設定
{
  "compilerOptions": {
    "strict": true,                    // 啟用所有嚴格檢查
    "noUncheckedIndexedAccess": true,  // 強制處理未定義的陣列存取
    "noImplicitReturns": true,         // 所有程式碼路徑必須有回傳值
    "noFallthroughCasesInSwitch": true,
    "exactOptionalPropertyTypes": false, // 須經團隊同意後方可設為 true
    "forceConsistentCasingInFileNames": true
  }
}
```

- **禁止使用 `as` 斷言** — 請改用 Zod 解析、型別守衛或 `satisfies`。
- **禁止使用 `any`** — 若型別未知，請使用 `unknown`，再透過 Zod 或型別守衛進行收窄。
- **公開 API 形狀使用 `interface`，聯集／工具型別使用 `type`。** 物件型別優先使用 `interface` 而非 `type`（錯誤訊息更佳、編譯速度更快）。

---

## 2. Git 工作流程

### 2.1 分支策略

- **主分支：** `main` — 永遠保持可部署狀態。受保護：禁止直接推送，需通過 PR + CI 通過 + 審查核准。
- **功能分支：** 從 `main` 分支出去，合併回 `main`。命名規則：

| 類型        | 前綴        | 範例                            |
|-------------|-------------|---------------------------------|
| 功能        | `feat/`     | `feat/task-crud`               |
| 錯誤修正    | `fix/`      | `fix/login-redirect`           |
| 維護        | `chore/`    | `chore/update-deps`            |
| 重構        | `refactor/` | `refactor/api-client`          |
| 文件        | `docs/`     | `docs/api-endpoints`           |
| 測試        | `test/`     | `test/auth-flow`               |
| 效能        | `perf/`     | `perf/query-optimization`      |

- 分支名稱在前綴之後使用 **kebab-case**。
- **保持分支短命**（少於 3 天）。若一個分支存活超過 3 天，請考慮拆分成較小的 PR。

### 2.2 提交訊息格式

使用 **Conventional Commits**（由 commitlint + husky 強制執行）：

```
<type>(<scope>): <簡短描述>

[選填：詳細說明]

[選填：結尾備註]
```

**類型：**

| 類型       | 用途                            |
|------------|---------------------------------|
| `feat`     | 新功能                          |
| `fix`      | 錯誤修正                        |
| `chore`    | 維護、工具、依賴                |
| `refactor` | 程式碼重構（不改變行為）        |
| `test`     | 新增或修改測試                  |
| `docs`     | 僅限文件                        |
| `style`    | 格式化、空白（不改變邏輯）      |
| `perf`     | 效能改善                        |
| `ci`       | CI/CD 設定變更                  |
| `revert`   | 還原先前的提交                  |

**Scope（範圍）** 視專案而定（有效範圍請見各專案約定）。

**範例：**

```
feat(api): add GET /tasks endpoint with pagination

Implement cursor-based pagination for task listing. Returns `nextCursor`
for the client to pass as query param.

Closes #42
```

```
fix(web): handle empty task list in TeamView

The TeamView component crashed when a user had no tasks assigned.
Added an empty state with CTA to create the first task.
```

### 2.3 Pull Request 工作流程

1. **從 `main` 建立功能分支**，並依上述命名規則命名。
2. **頻繁提交**，使用 Conventional Commits。無須在本機 squash — squash 在合併時進行。
3. **及早開啟 PR**（draft PR）以獲取早期回饋。完成後標記為「Ready for Review」。
4. **PR 標題**必須遵循 Conventional Commits 格式：`feat(api): add task CRUD endpoints`。
5. **PR 描述**必須包含：
   - 此 PR 的內容（1–2 句話）
   - UI 變更的截圖／螢幕錄影
   - 相關 Issue 的參考（例如 `Closes #42`）
   - 任何遷移步驟或環境變數變更
6. **審查前 CI 必須通過**：lint → type-check → test → build。
7. **至少 1 位團隊成員核准**（不包含作者本人）。
8. **Squash merge** 到 `main` — squash 的提交訊息即為 PR 標題。這有助於保持 `main` 的歷史記錄整潔。
9. **合併後刪除分支**（GitHub 自動刪除已啟用）。
10. **禁止對 `main` 或 `develop` 強制推送** — 永遠不可。若你是該功能分支的唯一貢獻者，則可接受強制推送。

### 2.4 程式碼審查 SLA

| PR 大小（變更行數） | 目標審查時間              |
|---------------------|---------------------------|
| < 50 行             | 4 個工作小時內            |
| 50–200 行           | 1 個工作日內              |
| 200–500 行          | 2 個工作日內              |
| > 500 行            | 考慮拆分 PR               |

**超過 400 行的 PR 必須在描述中說明理由。** 大型 PR 會拖慢審查速度並增加缺陷率。

### 2.5 Git 設定

```bash
git config --local pull.rebase true     # pull 時使用 rebase，避免產生 merge commit
git config --local fetch.prune true     # 清除過期的遠端追蹤分支
```

---

## 3. 測試

### 3.1 測試理念

```
          ╱  E2E (Playwright)  ╲          ← 關鍵使用者流程
         ╱   Integration (Vitest)  ╲      ← API 路由、資料庫查詢、認證流程
        ╱    Unit (Vitest)           ╲    ← 工具函式、hooks、元件、驗證
       ╱     Static (TypeScript)       ╲  ← 型別檢查 (tsc --noEmit)
```

| 層級        | 測試對象                                     | 執行頻率     |
|-------------|----------------------------------------------|--------------|
| Static      | 各處的型別安全性                             | 每次提交     |
| Unit        | 純函式、驗證 schema、工具函式                | 每次提交     |
| Integration | API 路由、資料庫查詢、認證流程               | 每次推送     |
| E2E         | 關鍵使用者流程                               | 合併前       |

### 3.2 覆蓋率要求

| 指標             | 最低門檻           |
|------------------|--------------------|
| **Statements**   | 80%                |
| **Branches**     | 75%                |
| **Functions**    | 80%                |
| **Lines**        | 80%                |

- 覆蓋率在 **CI 中檢查**。若 PR 使覆蓋率低於門檻，CI 將失敗。
- **不要追求 100% 覆蓋率** — 專注於有意義的測試。部分程式碼（樣板、設定檔）可跳過。
- **謹慎使用覆蓋率忽略註解**，且務必附上理由。

### 3.3 測試什麼

| 應測試的內容                          | 不應測試的內容                          |
|---------------------------------------|-----------------------------------------|
| 商業邏輯（純函式、工具函式）          | 瑣碎的 getter/setter                    |
| 驗證 schema                           | 函式庫內部實作                          |
| 自訂 hooks（使用 `renderHook`）       | 第三方 UI 原語（上游已測試）             |
| API 路由行為（狀態碼、錯誤）          | CSS / 樣式                             |
| 資料庫查詢邏輯（搭配測試資料庫）      | 第三方 API 行為（在邊界處 mock）         |
| 認證中介層（受保護路由）              | OAuth 提供者內部實作                    |
| 元件渲染（smoke + 狀態覆蓋）          | 實作細節（測試行為，而非實作）           |
| 錯誤狀態與邊界情況                    | 僅快樂路徑                               |

### 3.4 什麼該 Mock（與不該 Mock）

| 應 Mock 的對象                   | 不應 Mock 的對象                         |
|----------------------------------|------------------------------------------|
| HTTP 層（API 路由使用 MSW）      | 資料庫驅動程式（使用測試 DB 容器）       |
| 外部 API（GitHub OAuth 等）      | 驗證 schema                              |
| 檔案系統 / 環境變數              | 純工具函式（直接測試它們）               |
| 時間（使用 `vi.useFakeTimers()`）| 元件內部（使用 Testing Library）          |

- **傾向使用整合測試**，而非對 API 路由和資料庫查詢使用 mock 的單元測試。
- **測試檔案必須具備冪等性** — 重複執行多次應產生相同結果。
- **每個測試檔案**必須自行清理（資料庫記錄、mock、計時器）。

### 3.5 測試檔案約定

- **單元／整合測試：** 與原始碼放在同一目錄：`src/lib/formatDate.ts` → `src/lib/formatDate.test.ts`。
- **E2E 測試：** 放在 `apps/web/e2e/` 目錄下，使用 `.spec.ts` 副檔名。
- **測試檔案必須具備冪等性** — 不應依賴測試的執行順序。

*各工具特定設定（Vitest、Playwright 等）請見該專案的約定文件。*

---

## 4. 審查標準

### 4.1 必備檢查（每個 PR）

每個 PR 在合併前必須通過以下檢查。這些由 CI 和審查清單強制執行。

| # | 檢查項目                | 說明                                              | 檢查者     |
|---|-------------------------|---------------------------------------------------|------------|
| 1 | **Lint 通過**           | ESLint — 無警告、無錯誤                            | CI         |
| 2 | **型別檢查通過**        | `tsc --noEmit` — 無型別錯誤                        | CI         |
| 3 | **測試通過**            | `pnpm test` — 所有測試綠燈 + 覆蓋率達標             | CI         |
| 4 | **建置通過**            | `pnpm build` — 正式環境建置成功                    | CI         |
| 5 | **無機密資訊**          | 無硬編碼的 API 金鑰、 token、密碼                 | 審查者     |
| 6 | **無 `console.log`**   | 正式程式碼中無除錯用日誌                           | 審查者     |
| 7 | **無 `any`**           | 不得使用 `any` 型別斷言（請用 `unknown`）          | 審查者     |
| 8 | **錯誤處理**            | 每個錯誤路徑皆有處理（try/catch、`.catch()`、error boundary） | 審查者 |
| 9 | **載入與空狀態**        | 每個資料擷取元件皆處理載入中、無資料、錯誤等狀態    | 審查者     |
| 10 | **無無效程式碼**       | 無註解掉的程式碼、未使用的匯入、未使用的變數       | 審查者     |
| 11 | **無障礙性**           | 圖片有 `alt` 文字、表單有標籤、顏色非唯一識別方式  | 審查者     |
| 12 | **PR 描述**            | 描述完整：內容、原因、截圖、關聯 Issue             | 審查者     |

### 4.2 審查清單 — 通用

審查者在審查 PR 時應逐一檢視以下問題：

- [ ] 此 PR 是否只做一件事？（若非，請要求拆分。）
- [ ] PR 標題是否符合 Conventional Commits 格式？
- [ ] 是否有 TODO / FIXME / HACK 註解需要在合併前處理？
- [ ] 此次變更是否有對應的 Issue 或 ADR？
- [ ] 變數／函式名稱是否具有描述性？（避免 `x`、`temp`、`data`。）
- [ ] 函式是否少於 30 行？（若超過，請抽離 helper。）
- [ ] 是否有 magic number / magic string？（請抽離為常數。）
- [ ] 是否有邏輯重複？（DRY，但寧可重複也不要錯誤的抽象化。）
- [ ] 副作用是否被隔離並加以說明？
- [ ] 是否無 `as` 斷言？（請使用 Zod 或型別守衛。）
- [ ] 是否無 `any`？（請使用 `unknown` + 收窄。）
- [ ] 函式回傳型別是否明確？（尤其是公開 API 函式。）
- [ ] 狀態機是否使用 discriminated unions？

*各框架特定的審查項目（React、Hono、資料庫、UI/UX）請見該專案的約定文件。*

### 4.3 審查禮儀

- **保持友善與建設性。** 以建議的方式表達回饋（「要不要試試……？」），而非命令式語氣。
- **說明每個評論背後的「原因」**，而不只是「修正這裡」。
- **區分小建議與阻擋性問題。** 樣式偏好請加前綴 `nit:`，正確性／安全問題請加前綴 `blocker:`。
- **作者須回覆每一則評論。** 只有在處理或討論過後方可標記為已解決。
- **若 PR 有超過 10 則評論，** 建議進行同步討論以加速進度。
- **拒絕「橡皮圖章式」審查** — 每次審查都必須經過深思熟慮。一旦核准，你即共同承擔此變更的責任。
- **使用 GitHub 的「Request Changes」** 標記阻擋性問題，「Comment」用於小建議或一般意見。

### 4.4 何時合併

| 條件                                   | 動作                                        |
|----------------------------------------|---------------------------------------------|
| CI 通過 + 1 人核准                     | ✅ 合併（squash）                            |
| CI 通過 + 0 人核准                     | ❌ 不可合併                                  |
| CI 失敗                                | ❌ 先修正 CI                                 |
| PR 為 draft 狀態                       | ❌ 不可合併                                  |
| 審查者要求變更                         | ❌ 修改後必須重新請求審查                     |
| PR > 400 行且未附理由                   | ⚠️ 合併前先討論                             |
| 包含資料庫遷移                         | ⚠️ 合併前確認有回滾策略                     |
| 變更環境變數／機密                     | ⚠️ 先更新 `.env.example` 及相關文件          |

---

## 5. 知識持久化

### 5.1 原則

- **學習後必須評估是否留下記錄。** 每次使用 websearch 學到新東西後，問自己兩個問題：
  1. 這是**持久性知識**嗎？（不是今天的新聞或單一事件）
  2. 這對我們的**專案有幫助**嗎？（直接影響技術棧、架構、流程或品質）
- **只有兩個答案都是 Yes 才寫入。** 寧可漏掉也不要製造雜訊。
- **寫入正確的位置：**

| 知識類型 | 寫入位置 |
|---------|---------|
| 新技術／工具評估 | `docs/session-notes/daily-tech-YYYY-MM-DD.md` 的「Action Items」 |
| 影響架構的決定 | 新建 ADR到 `docs/decisions/` |
| 新的約定／模式 | 更新 `docs/conventions/` |
| 設計決策 | 更新 `docs/design/` |
| 用戶洞察 | 更新 `docs/research/` |
| 跨 session 的重點 | 同時寫入 `memory-project`（向量記憶） |

### 5.2 職責歸屬

- **memory-keeper** 負責中央掃描後的自動篩選、持久化與清理
- **各 agent** 負責自己領域的發現：code-reviewer 發現新的 lint 規則 → 更新 conventions；security-reviewer 發現新攻擊向量 → 更新安全相關文件
- **big-pickle (Lead)** 覆核持久化結果，但不需事前批准

### 5.3 過時清理

持久化新知識前必須先檢查是否讓既有知識過時：

| 情境 | 處理方式 |
|------|---------|
| 同主題有新版本 | **原地更新**（覆蓋舊內容，不要疊加） |
| 新發現與舊慣例矛盾 | **直接更新**舊慣例或標記為已棄用 |
| 技術已被淘汰 | **移除或封存**相關參考 |
| 對應的向量記憶實體 | **一併清理** `memory-project` 中完全被取代的實體 |

清理原則：知識庫的目標是**精準且即時**，不是累積。寧可刪掉過時的，也不要留著誤導人。

---

*各框架特定約定存放於該專案的獨立文件中（例如 `productivity-tool.md`）。*

*本文件由 tech-architect 維護。更新需經團隊討論，重大變更需撰寫 ADR。過往影響這些約定的決策請參閱 `docs/decisions/`。*

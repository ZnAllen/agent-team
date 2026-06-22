# 生產力工具 — 專案慣例

> **適用於：** 以 git 原生、非同步優先的生產力工具。
> **技術棧：** Next.js 15+ (App Router) + Hono + PostgreSQL 16 (upgrading to 18) + Drizzle ORM + Tailwind CSS v4.x + shadcn/ui + Zustand + TanStack Query。
> **另見：** `docs/conventions/index.md` 中適用於所有專案的通用慣例。

---

## 1. 技術棧

### 1.1 技術棧對照表

| 層級          | 技術                    | 角色                                        |
|--------------|-------------------------|---------------------------------------------|
| **前端**     | Next.js 15+ (App Router) | SSR、RSC、客戶端元件（視需要）               |
|              | TypeScript (嚴格模式)     | 全程式碼庫的型別安全                         |
|              | Tailwind CSS v4.x         | 工具優先的樣式系統                           |
|              | shadcn/ui                | 元件基礎（基於 Radix）                       |
| **後端**     | Hono + TypeScript        | REST API 伺服器（獨立於 Next.js）            |
|              | Zod                      | 請求驗證與型別生成                           |
| **資料庫**   | PostgreSQL 16（預計升級至 18） | 主要資料儲存（PG 18 已釋出，含 AIO、UUIDv7 等重要功能） |
|              | Drizzle ORM              | Schema、遷移、查詢（非 Prisma）              |
|              | Drizzle Kit              | 遷移檔案生成與推送（Drizzle v1.0.0-rc.3 已釋出，效能大幅提升） |
| **驗證**     | NextAuth.js v5           | 身分驗證（GitHub OAuth）                     |
| **狀態**     | TanStack Query v5        | 伺服器狀態（資料擷取、快取、同步）           |
|              | Zustand v5               | 客戶端狀態（UI 狀態、僅限本機的資料）        |
| **測試**     | Vitest                   | 單元測試與整合測試                           |
|              | Playwright               | E2E 測試                                     |
|              | MSW（選用）               | 測試中的 API 模擬                            |
| **單體倉庫** | pnpm workspaces          | 依賴管理與工作區腳本                         |
| **CI/CD**    | GitHub Actions           | 語法檢查、測試、建置、部署管線               |
| **基礎設施** | Docker Compose           | 本機開發環境                                 |
|              | Railway（後端）           | Hono API 部署                                |
|              | Vercel（前端）            | Next.js 部署                                 |
| **可觀測性** | Sentry                   | 錯誤追蹤                                     |
|              | OpenTelemetry            | 分散式追蹤與指標                             |

### 1.2 版本政策

- **TypeScript：** `5.9+` 最新穩定版（2025-08 釋出）。啟用嚴格模式（`tsconfig.json` 中設定 `strict: true`）。TypeScript 6.0 即將作為 7.0 的過渡版本，屆時需關注棄用通知。
- **Node.js：** `>=22 LTS`（目前為 24.x LTS，代號 Krypton）。Node 26.x 已為 Current。請對照 `.nvmrc` 檔案。**注意：** 2026-06 更新 — Node 24.17.0 為安全更新，修復 11 個 CVE（含 2 個 High），建議團隊鎖定 `>=24.17.0`。
- **pnpm：** `>=9.x`。使用 `corepack enable` 管理 pnpm 版本。
- 所有依賴鎖定**次要版本**（`package.json` 中使用 `~1.2.3`）。重大升級須通過 ADR。
- 每週執行 `pnpm update --interactive` 以保持依賴為最新版本。

### 1.3 框架慣例

- **僅使用 Next.js App Router。** 不使用 Pages Router。所有路由置於 `app/` 下。
- **預設使用伺服器元件。** 僅在需要互動性（hooks、事件處理器、瀏覽器 API）時才使用 `"use client"`。
- **Hono 路由**遵循 `routes/` 下的檔案分組（例如 `routes/tasks.ts`、`routes/auth.ts`）。
- **Drizzle schema** 檔案置於 `packages/db/src/schema/`，每個領域實體一個檔案。
- **shadcn/ui** 元件置於 `apps/web/src/components/ui/`。請勿手動修改——重新執行 CLI 來更新。
- **環境變數**在啟動時以 Zod 進行驗證（每個應用程式中的 `env.ts`）。

### 1.4 單體倉庫結構（草案）

> ⚠️ 本專案尚未開始編碼。以下結構為規劃中的佈局。

```
project-root/
├── apps/
│   ├── web/               # Next.js 應用程式
│   │   ├── src/
│   │   │   ├── app/       # App Router 頁面與佈局
│   │   │   ├── components/# React 元件
│   │   │   ├── hooks/     # 自訂 hooks
│   │   │   ├── lib/       # 工具函式、API 客戶端
│   │   │   └── providers/ # Context 提供者
│   │   └── ...config 檔案
│   └── api/               # Hono API 伺服器
│       ├── src/
│       │   ├── routes/    # 路由處理器
│       │   ├── middleware/ # Hono 中介層
│       │   ├── lib/       # 工具函式
│       │   └── index.ts   # 進入點
│       └── ...config 檔案
├── packages/
│   ├── db/                # Drizzle schema、遷移、DB 客戶端
│   │   ├── src/
│   │   │   ├── schema/    # 資料表定義
│   │   │   ├── migrations/# 產生的遷移檔案
│   │   │   └── index.ts   # DB 客戶端匯出
│   │   └── drizzle.config.ts
│   ├── shared/            # 共用型別、驗證 schema、常數
│   │   └── src/
│   │       ├── types/     # 領域型別（Task、User、Project 等）
│   │       ├── validators/# 共用 Zod schema
│   │       └── constants/ # 列舉、魔術字串
│   └── config/            # 共用的 ESLint、TSConfig、Tailwind 設定
│       ├── eslint/
│       ├── typescript/
│       └── tailwind/
├── docker-compose.yml     # 本機 Postgres + API
├── pnpm-workspace.yaml
├── .nvmrc
├── .github/
│   └── workflows/         # GitHub Actions
└── .opencode/             # 專案專屬記憶（視需要）
```

---

## 2. 命名慣例（框架專屬）

以下為 `docs/conventions/index.md` 中通用命名規則的補充：

| 類別                    | 慣例              | 範例                                |
|-----------------------|-------------------|------------------------------------|
| **React 元件**        | `PascalCase`      | `TaskCard.tsx`、`UserAvatar.tsx`   |
| **React Hooks**       | `camelCase` + `use` 前綴 | `useTasks()`、`useAuth()`  |
| **檔案 — 元件**       | `PascalCase.tsx`  | `TaskCard.tsx`                     |
| **檔案 — 工具函式**   | `camelCase.ts`    | `formatDate.ts`、`apiClient.ts`    |
| **檔案 — hooks**      | `camelCase.ts`    | `useAuth.ts`                       |
| **檔案 — 路由**       | `kebab-case`      | `task-comments.ts`                 |
| **檔案 — DB schema**  | `snake_case.ts`   | `task_assignees.ts`                |
| **DB 資料表 / 欄位**  | `snake_case`      | `created_at`、`updated_by`         |

---

## 3. React 元件模式

- **伺服器元件（預設）：** 不使用 `"use client"`、不使用 hooks、不使用事件處理器。
- **客戶端元件：** 在檔案頂端加上 `"use client"`。保持儘可能精簡——將資料擷取向上推至伺服器元件。
- **務必使用明確的 `interface` 定義 props**（避免使用 `React.FC<Props>`——優先使用帶有解構 props 的常規函式）。
- **禁止使用預設匯出**。請使用具名匯出。

```tsx
// ✅ 良好
interface TaskCardProps {
  taskId: string;
  title: string;
}

export function TaskCard({ taskId, title }: TaskCardProps) {
  return <div>{title}</div>;
}

// ❌ 不佳
const TaskCard: React.FC<{ taskId: string }> = ({ taskId }) => { ... };
export default TaskCard;
```

---

## 4. 狀態管理

- **伺服器狀態 → TanStack Query。** 所有從 API 取得的資料都透過 `useQuery` / `useMutation` 處理。元件中不得在 TanStack Query 之外使用 `fetch`。
- **客戶端狀態 → Zustand。** 僅 UI 相關的狀態（彈窗開關、側邊欄摺疊、篩選條件）置於 Zustand store 中。
- **不使用 Redux。** Zustand 更簡潔且足以滿足需求。
- **Zustand store** 置於 `apps/web/src/stores/`，每個 store 一個檔案。
- **TanStack Query hooks** 置於 `apps/web/src/hooks/`，每個領域一個檔案（例如 `useTasks.ts` 匯出 `useTasks()`、`useCreateTask()` 等）。

---

## 5. CSS / Tailwind

- **不使用純 CSS 檔案**，`globals.css` 除外（僅包含 Tailwind 指令與 CSS 自訂屬性）。
- **直接在 JSX 中使用 Tailwind 工具類別。** 在提煉成 CSS class 之前，先考慮提煉成元件。
- **shadcn/ui** 使用 `cn()` 輔助函式處理 class 合併。合併條件 class 時務必使用 `cn()`。
- **自訂顏色**置於 `tailwind.config.ts` 的 `theme.extend.colors` 下——使用 Open Design 的設計權杖名稱（例如 `accent`、`surface`、`muted`）。
- **不使用 `@apply`**，除非是在罕見的 `@layer components` 區塊中定義元件 class（且更建議直接建立 React 元件來替代）。

---

## 6. 錯誤處理

- **Hono API：** 所有路由回傳 `{ success: boolean, data?: T, error?: string }`。使用共用的回應輔助函式。
- **Next.js：** 伺服器元件透過 `error.tsx` 邊界頁面處理錯誤。客戶端元件使用 TanStack Query 的 `onError`。
- **正式環境程式碼中絕不使用 `console.log`**。請使用記錄器（後端用 Pino，前端用 `console.error` + Sentry）。
- **每個元件務必處理錯誤狀態**（參閱 Open Design 的狀態涵蓋範圍）。

---

## 7. 測試（工具專屬）

### 7.1 測試指令

```bash
# 執行所有測試（從根目錄）
pnpm test

# 執行特定套件的測試
pnpm --filter @acme/web test

# 以監看模式執行測試（開發期間）
pnpm test -- --watch

# 執行測試並產生涵蓋率報告
pnpm test -- --coverage

# 僅執行型別檢查
pnpm type-check

# 僅執行語法檢查
pnpm lint

# 執行 E2E 測試（需先啟動開發伺服器）
pnpm test:e2e
```

### 7.2 測試指南

- **API 測試**：啟動 Hono 測試實例並使用 `app.request()`——無需模擬 HTTP 層。
- **DB 測試**：使用真實的 PostgreSQL 實例（Docker Compose 服務），並在測試執行前套用 Drizzle 遷移。
- **E2E 測試**：使用 Playwright 的 `page.route()` 模擬 GitHub OAuth，避免在 CI 中需要真實的 OAuth 憑證。

### 7.3 Playwright E2E 指南

- 針對**專用測試環境**執行（非正式環境、非本機開發環境）。
- 使用 `@smoke` 標記關鍵路徑的 **E2E 測試**（每個 PR 執行），使用 `@full` 標記完整套件的測試（每日夜間執行）。
- 已驗證的測試使用 **`test.use({ storageState: 'e2e/.auth/user.json' })`**。
- **保持 E2E 測試聚焦**——測試使用者流程，而非實作細節。
- **使用 `page.getByRole()`** 作為選擇器（以無障礙為優先）。

### 7.4 Vitest 設定

```ts
// vitest.config.ts — 關鍵設定
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',     // 前端測試則使用 'jsdom'
    setupFiles: ['./src/test-setup.ts'],
    coverage: {
      provider: 'v8',
      thresholds: {
        statements: 80,
        branches: 75,
        functions: 80,
        lines: 80,
      },
    },
  },
});
```

---

## 8. 審查核對清單 — 框架專屬

以下為生產力工具專用的額外審查項目（補充 `index.md` 中的通用核對清單）。

### React / Next.js

- [ ] 元件的邊界是否正確？（伺服器元件 vs 客戶端元件。）
- [ ] 是否盡可能使用伺服器元件？
- [ ] `use client` 元件是否精簡？（其中不包含資料擷取——將其推向伺服器端。）
- [ ] 列表中的 key 是否穩定？（動態列表不使用 `index` 作為 key。）
- [ ] 是否存在不必要的重新渲染？（檢查 `useMemo`/`useCallback` 的使用情況。）
- [ ] `useEffect` 的依賴是否正確？（無遺漏依賴、無無限迴圈。）
- [ ] 匯入樹是否乾淨？（客戶端元件中未匯入伺服器端程式碼。）

### API (Hono)

- [ ] 所有輸入是否皆以 Zod 驗證？
- [ ] 錯誤回應是否一致（`{ success: false, error: string }`）？
- [ ] 狀態碼是否語義正確？（201 表示建立、204 表示刪除、400 表示驗證失敗、401 表示未驗證、404 表示找不到、409 表示衝突、500 表示伺服器錯誤。）
- [ ] 敏感欄位是否已從回應中排除？（回應中不含密碼、權杖。）
- [ ] 列表端點是否實作了分頁？（優先使用游標分頁。）
- [ ] 路由處理器是否少於 50 行？（超出時請提取服務層。）

### 資料庫

- [ ] 遷移是否有復原計畫？（向下遷移或還原策略。）
- [ ] 是否針對查詢模式建立了索引？（在開發環境中檢查 `EXPLAIN ANALYZE`。）
- [ ] 是否定義了外鍵與約束？
- [ ] 敏感欄位是否已加密或排除在 SELECT 之外？
- [ ] 是否避免了 N+1 查詢？（積極使用 Drizzle 的 `with` / `join`。）

### 安全性

*參考：OWASP Top 10:2025 (A01-A10)，詳見 `docs/session-notes/daily-tech-2026-06-21.md` 安全領域。*

- [ ] 使用者是否被授權執行此操作？（所有權檢查、角色檢查；OWASP A01 — Broken Access Control 仍為第一大風險，包含 BOLA/BFLA。）
- [ ] 使用者輸入是否已淨化？（Zod 驗證 + 參數化查詢；OWASP A05 — Injection。）
- [ ] 公開端點是否已套用速率限制？
- [ ] 正式環境中的 CORS 設定是否具限制性？（正式環境不使用 `Access-Control-Allow-Origin: *`。**注意：** Hono CORS middleware 若設 `credentials: true` 而未明確指定 `origin`，會反射任何 origin → 需修正，參見 CVE-2025 相關修復。）
- [ ] Session 權杖是否安全儲存？（僅限 HTTP 的 cookie，不使用 localStorage。）
- [ ] **依賴安全性：** 是否定期掃描第三方套件漏洞？是否建立 SBOM？(OWASP A03 — Software Supply Chain Failures 新進榜，發生率最高。)
- [ ] **異常處理：** 是否所有例外路徑皆有完善處理？（OWASP A10 — Mishandling of Exceptional Conditions 新進榜。）

### UI / UX

- [ ] UI 是否遵循設計系統？（shadcn/ui、來自 tailwind config 的自訂權杖。）
- [ ] 是否涵蓋所有 5 種狀態？（載入中、空資料、錯誤、有資料、邊界情況——參閱 Open Design 的 `craft/state-coverage.md`。）
- [ ] 是否具備響應式設計？（檢查手機、平板、桌面的斷點。）
- [ ] 是否遵循 `prefers-reduced-motion`？（若使用者偏好減少動畫則不播放動畫。）
- [ ] 表單是否已驗證？（客戶端 + 伺服器端，參閱 Open Design 的 `craft/form-validation.md`。）
- [ ] 無障礙是否通過 Lighthouse 檢測？（`aria-*`、角色、焦點管理。）
- [ ] 色彩是否具備無障礙性？（一般文字對比度 ≥ 4.5:1，大字型 ≥ 3:1。）

---

*本文件由技術架構師維護。更新需要團隊討論，（重大變更）須通過 ADR。*

# ADR-008: `@agent-team/create-app` — 專案 scaffolds 產生器 CLI

**日期：** 2026-06-21
**狀態：** 已接受
**作者：** tech-architect
**實作參考：** code-writer-c

---

## Context

我們團隊同時維護多個遵守相同慣例的專案（API-First、Multi-Tenant、TypeScript strict、特定 monorepo 結構、測試要求等）。目前建立新專案需要手動複製貼上樣板檔案，既容易遺漏約定、也缺乏一致性。

其他團隊（如 `create-t3-app`、`create-next-app`）已驗證 CLI scaffolding 能顯著降低新專案啟動成本。我們需要一個符合**團隊自身慣例**的專屬產生器。

**時機：** 產品願景（product-vision.md）已定義明確的技術棧與架構原則。本 CLI 將這些原則編碼為可重現的 scaffold，確保每個新專案從第一天就遵循 ADR-006、產品慣例（productivity-tool.md）與通用慣例（index.md）。

---

## Decision

建立 `@agent-team/create-app` — 一個 Node.js CLI 工具，透過互動式 prompt 產生完整的 monorepo scaffold。

### 技術選型

| 面向 | 選擇 | 理由 |
|------|------|------|
| **執行時** | `tsx` (TypeScript 直接執行) | 無需建置步驟，開發迭代快；與團隊 TypeScript 優先策略一致 |
| **參數解析** | `minimist` | 輕量、無依賴、已廣泛使用；`--yes` flag 可跳過所有 prompt |
| **提示 UI** | `@clack/prompts` | 比 `inquirer` 更現代的 UX（spinner、cancel handling、美麗輸出）；包體更小；符合團隊設計品質要求 |
| **模板引擎** | 純字串取代 `{{variable}}` | 無需 EJS/Handlebars 依賴；模板即為最終檔案（不含模板語法雜訊）；方便他人閱讀與修改 |
| **測試框架** | Vitest (與團隊一致) | 與 monorepo 測試策略一致；`--snapshot` 可測試產生結果 |
| **發布方式** | npm package `@agent-team/create-app` | 可透過 `pnpm create @agent-team/app` 或 `npx @agent-team/create-app` 呼叫 |
| **Node 版本** | `>=18` (LTS) | 涵蓋 `tsx` 需求；與產品 `>=22` 分開是為了讓 CLI 能在更多環境執行 |

### 不使用

| 技術 | 不使用的理由 |
|------|-------------|
| `inquirer` | `@clack/prompts` 更現代、更輕量、更美觀 |
| EJS / Handlebars | 增加依賴與認知負荷；`{{variable}}` 取代已足夠 |
| `commander.js` | `minimist` 已滿足需求；本 CLI 只有少數 flags 不需要 subcommand 架構 |
| TypeScript 編譯 (`tsc`) | `tsx` 直接執行原始碼，減少 CI/CD 步驟 |
| Plop / Hygen | 太重；我們只需要產生整個目錄樹而非增補單一檔案 |
| `execa` / `zx` | 本 CLI 不需要執行 shell 指令（僅產生檔案） |

---

## Template Architecture

### 目錄結構

所有模板位於 `packages/create-app/templates/`，目錄結構反映最終輸出：

```
templates/
├── root/                    # 根目錄檔案
│   ├── _package.json
│   ├── _pnpm-workspace.yaml
│   ├── _tsconfig.json
│   ├── _.env.example
│   ├── _.gitignore
│   ├── _vitest.config.ts
│   ├── _.prettierrc
│   ├── _.nvmrc
│   └── _README.md
├── apps/
│   ├── api/                 # Hono API server
│   │   ├── _package.json
│   │   ├── _tsconfig.json
│   │   └── src/
│   │       ├── _index.ts
│   │       ├── _env.ts
│   │       ├── lib/
│   │       │   ├── _response.ts        # { success, data?, error? } helpers
│   │       │   ├── _error-handler.ts    # Global error middleware
│   │       │   └── _pagination.ts       # Cursor pagination helper
│   │       ├── middleware/
│   │       │   ├── _cors.ts
│   │       │   └── _workspace.ts        # Multi-tenant middleware
│   │       └── routes/
│   │           └── _health.ts
│   └── web/                 # Next.js App Router
│       ├── _package.json
│       ├── _tsconfig.json
│       ├── _next.config.ts
│       ├── _tailwind.config.ts
│       ├── _postcss.config.mjs
│       └── src/
│           ├── app/
│           │   ├── _layout.tsx
│           │   ├── _page.tsx
│           │   └── _globals.css
│           ├── components/
│           │   └── ui/      # Empty, for shadcn/ui
│           ├── hooks/        # Empty
│           ├── lib/
│           │   ├── _api-client.ts
│           │   └── _utils.ts
│           └── providers/    # Empty
├── packages/
│   ├── shared/              # Shared types, validators, constants
│   │   ├── _package.json
│   │   ├── _tsconfig.json
│   │   └── src/
│   │       ├── _index.ts
│   │       ├── types/
│   │       │   ├── _api.ts
│   │       │   └── _index.ts
│   │       ├── validators/
│   │       │   └── _index.ts
│   │       └── constants/
│   │           └── _index.ts
│   └── db/                  # Drizzle schema + migrations
│       ├── _package.json
│       ├── _tsconfig.json
│       ├── _drizzle.config.ts
│       └── src/
│           ├── _index.ts
│           ├── _client.ts
│           └── schema/
│               ├── _base.ts           # Base columns, timestamps, workspace_id
│               ├── _users.ts
│               └── _workspaces.ts
├── _github/                 # Note: underscore to avoid dotfile issues
│   └── workflows/
│       ├── _ci.yml
│       └── _deploy.yml
├── _docker-compose.yml
└── _.opencode/
    └── _README.md
```

**命名慣例：** 模板檔案以底線前綴（`_filename`）區別於實際檔名。Generator 會移除底線並將 `.hbs` 或 `_` 轉換為最終檔名。

### 模板變數

所有變數使用 `{{variable}}` 語法。Generator 遍歷每個檔案內容並取代。

**完整變數清單：**

| 變數 | 類型 | 來源 | 範例值 |
|------|------|------|--------|
| `{{project_name}}` | `string` | prompt | `my-app` |
| `{{project_name_pascal}}` | `string` | 自動推導 | `MyApp` |
| `{{package_manager}}` | `"pnpm" | "npm" | "bun"` | prompt | `pnpm` |
| `{{database}}` | `"postgres" | "sqlite" | "none"` | prompt | `postgres` |
| `{{ci}}` | `"github" | "none"` | prompt | `github` |
| `{{deploy_target}}` | `"vercel" | "railway" | "fly" | "none"` | prompt | `vercel` |
| `{{include_seed}}` | `boolean` | prompt | `false` |
| `{{include_docker}}` | `boolean` | prompt | `true` |
| `{{year}}` | `number` | 自動 | `2026` |
| `{{node_version}}` | `string` | 自動 | `22` |
| `{{has_web}}` | `boolean` | 固定 `true` | `true` |
| `{{has_api}}` | `boolean` | 固定 `true` | `true` |
| `{{include_db}}` | `boolean` | 衍生 (`database !== "none"`) | `true` |
| `{{has_ci}}` | `boolean` | 衍生 (`ci !== "none"`) | `true` |
| `{{has_docker}}` | `boolean` | 衍生 | `true` |
| `{{has_deploy}}` | `boolean` | 衍生 (`deploy_target !== "none"`) | `true` |
| `{{db_driver}}` | `string` | 衍生 | `postgres` |
| `{{db_port}}` | `number` | 衍生 | `5432` |
| `{{db_container}}` | `string` | 衍生 | `postgres:16-alpine` |
| `{{acme_scope}}` | `string` | 從 project_name 推導 | `@my-app` |

### 條件式內容

部分模板區段需條件性包含。由於模板引擎為純字串取代，條件邏輯在 Generator 層處理：

- Generator 會先移除不適用的區塊（例如 `{{#if include_db}}...{{/if}}` 在 `include_db=false` 時整段移除），然後進行變數取代。
- 或者，Generator 在複製檔案時即跳過條件性檔案（如 `deploy.yml` 僅在 `ci === "github" && include_docker` 時複製）。

**實作策略（推薦）：** Generator 使用兩階段處理：
1. **檔案選擇** — 根據 config 決定複製哪些檔案（跳過 `.opencode/` 若無 seed、跳過 `deploy.yml` 若無 deploy 等）
2. **內容取代** — 對每個已選檔案讀入記憶體，依序執行 `str.replaceAll('{{var}}', val)`，然後決定最終輸出位置

---

## Prompt Flow

### Flags (minimist)

| Flag | 別名 | 類型 | 預設 | 說明 |
|------|------|------|------|------|
| `--yes` | `-y` | `boolean` | `false` | 跳過所有 prompt，使用預設值 |
| `--name` | `-n` | `string` | — | 直接指定專案名稱 |
| `--dir` | `-d` | `string` | `./{{name}}` | 輸出目錄 |
| `--package-manager` | `--pm` | `string` | `pnpm` | 套件管理器 |
| `--database` | `--db` | `string` | `postgres` | 資料庫選擇 |
| `--ci` | — | `string` | `github` | CI 選擇 |
| `--deploy` | — | `string` | `vercel` | 部署目標 |
| `--seed` | — | `boolean` | `false` | 是否包含 seed |
| `--docker` | — | `boolean` | `false` | 是否包含 Docker |

### Interactive Prompts (`@clack/prompts`)

流程：

```
┌─ ╭──────────────────────╮
│  │  @agent-team/create-app   │
│  │  依照團隊慣例建立新專案     │
│  ╰──────────────────────╯
│
├─ ◇  Project name (kebab-case):
│  │  my-awesome-app
│  │  ✔ 驗證：只接受 /^[a-z][a-z0-9-]*$/
│
├─ ◇  Package manager:
│  │  ● pnpm (recommended)
│  │  ○ npm
│  │  ○ bun
│
├─ ◇  Database:
│  │  ● PostgreSQL (recommended)
│  │  ○ SQLite
│  │  ○ Skip (no database)
│
├─ ◇  CI / CD:
│  │  ● GitHub Actions
│  │  ○ Skip
│
├─ ◇  Deploy target:
│  │  ○ Vercel (web)
│  │  ● Railway (api + db)
│  │  ○ Fly.io
│  │  ○ None
│
├─ ◇  Include seed data feature?
│  │  ● Yes / ○ No
│
├─ ◇  Include Docker Compose?
│  │  ● Yes / ○ No
│
├─ ◇  Confirm:
│  │  Project:  my-awesome-app
│  │  Package:  pnpm
│  │  Database: PostgreSQL
│  │  CI:       GitHub Actions
│  │  Deploy:   Railway
│  │  Seed:     Yes
│  │  Docker:   Yes
│  │
│  │  ● Yes, looks good / ○ No, cancel
│
├─ ◇  Scaffolding... ▒▒▒▒▒▒▒▒░░░ 72%
│
├─ ✔  Done! Created my-awesome-app
│
├─ ◇  Next steps:
│     cd my-awesome-app
│     pnpm install
│     cp .env.example .env
│     pnpm dev
└─
```

### 驗證規則

| 欄位 | 規則 | 錯誤訊息 |
|------|------|----------|
| `project_name` | `^[a-z][a-z0-9-]*$` | 「名稱必須是小寫 kebab-case (字母開頭，只能包含小寫字母、數字、連字號)」 |
| `project_name` | 長度 1–64 | 「名稱長度需在 1–64 字元之間」 |
| 輸出目錄 | 不可已存在非空目錄 | 「目錄 {{dir}} 已存在且非空。請選擇不同名稱或目錄」 |
| 所有 prompt | Cancel (Ctrl+C) | 優雅結束，不寫入任何檔案 |

### 預設值 (`--yes` mode)

當 `--yes` 或 `-y` 傳入時：

| 變數 | 預設值 |
|------|--------|
| `project_name` | `my-app`（或 `--name` 值） |
| `package_manager` | `pnpm` |
| `database` | `postgres` |
| `ci` | `github` |
| `deploy_target` | `vercel` |
| `include_seed` | `false` |
| `include_docker` | `false` |

---

## File Generation Logic

### Generator 核心流程

```
Input: Config object (from prompts + CLI flags)
  │
  ▼
[1] Validate config
  │  . project_name matches kebab-case
  │  . output directory is writable and empty
  │
  ▼
[2] Resolve template variables
  │  . Compute derived values (has_*, db_*, acme_scope, etc.)
  │  . Build variable map
  │
  ▼
[3] Walk template tree (templates/)
  │  . For each file/folder:
  │    + Check skip-if rules (see below)
  │    + If skipped -> continue
  │    + If folder -> mkdir -p in output
  │    + If file -> read + replace + write
  │
  ▼
[4] Post-processing
  │  . Rename files (strip `_` prefix)
  │  . Optional: `pnpm install` (user chooses)
  │  . Optional: `git init` (user chooses)
  │
  ▼
[5] Print success + next steps
```

### Skip-if 規則（檔案選擇）

| 範本路徑 | 跳過條件 |
|----------|----------|
| `packages/db/**/*` | `database === "none"` |
| `.github/workflows/**/*` | `ci === "none"` |
| `.github/workflows/deploy.yml` | `deploy_target === "none"` |
| `docker-compose.yml` | `!include_docker` |
| `packages/db/src/schema/seed*.ts` | `!include_seed` |
| `apps/web/src/app/` | 永不跳過（web 始終產生） |
| `apps/api/src/` | 永不跳過（api 始終產生） |
| `apps/web/src/components/ui/` | 始終複製（空的，預留給 shadcn/ui） |

### Replace 引擎實作

```typescript
// 核心取代函式（純字串，無模板引擎）
function renderTemplate(content: string, vars: Record<string, string>): string {
  let result = content;
  for (const [key, value] of Object.entries(vars)) {
    result = result.replaceAll(`{{${key}}}`, String(value));
  }
  return result;
}
```

**注意：** 為避免 `{{` 在非變數情境（如 JSX、Zod literal）造成誤判，所有模板中的 `{{` 和 `}}` 若需保留應寫為 `\{{` 和 `}}`（escape 規則）。Replace 引擎會先處理 escaped forms 再處理一般 forms。

### 輸出目錄結構確認

Generator 完成後，最終目錄結構應匹配 `productivity-tool.md` 中定義的 monorepo 佈局（§1.4），並將套件前綴設為 `@{{project_name}}/`（例如 `@my-app/db`、`@my-app/shared`）：

```
my-app/
├── apps/
│   ├── api/          # Hono API server
│   └── web/          # Next.js App Router
├── packages/
│   ├── shared/       # Shared types, validators, constants
│   └── db/           # Drizzle schema + migrations (only if database != none)
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── deploy.yml (only if deploy_target != none)
├── docker-compose.yml (only if include_docker)
├── .opencode/        (only if include_seed)
│   └── README.md
├── package.json
├── pnpm-workspace.yaml
├── tsconfig.json
├── .env.example
├── .gitignore
├── .prettierrc
├── .nvmrc
├── vitest.config.ts
└── README.md
```

---

## What Each Template Must Encode (Conventions)

### TypeScript Strictness

所有 `tsconfig.json` 模板必須包含（來自 `index.md` §1.5）：

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "forceConsistentCasingInFileNames": true,
    "exactOptionalPropertyTypes": false
  }
}
```

### API Response Format

所有 API 路由模板使用統一回應輔助（`apps/api/src/lib/response.ts`）：

```typescript
// 所有 API handler 必須透過這些 function 回傳
export function success<T>(data: T, status = 200) { ... }
export function error(message: string, status = 400) { ... }
```

回傳格式：
```json
{ "success": true, "data": { ... } }
{ "success": false, "error": "message" }
```

### Multi-Tenant Schema

所有 `packages/db/src/schema/` 中的實體 table 模板，`_base.ts` 提供基底欄位：

```typescript
export const baseColumns = {
  workspace_id: text('workspace_id').notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull().$onUpdate(() => new Date()),
};
```

並在 queries 中產生 `where(eq(table.workspace_id, workspaceId))` 模板。

### API Versioning

路由檔案模板掛載於 `/api/v1/` 路徑下（`apps/api/src/index.ts` 範本）：

```typescript
const app = new Hono().basePath('/api/v1');
```

### CORS Configurable via Env

`apps/api/src/middleware/cors.ts` 模板使用 `CORS_ORIGIN` 環境變數：

```typescript
app.use('/api/*', cors({
  origin: env.CORS_ORIGIN?.split(',') ?? '*',
  credentials: true,
}));
```

### Error Handler

`apps/api/src/lib/error-handler.ts` 模板包含：

```typescript
app.onError((err, c) => {
  console.error(err);
  return c.json({ success: false, error: err.message }, 500);
});
```

### Tailwind v4 with OKLCH

`apps/web/tailwind.config.ts` 模板使用 OKLCH 色彩格式：

```typescript
export default {
  theme: {
    extend: {
      colors: {
        accent: 'oklch(0.65 0.2 260)',      // Blue accent
        surface: 'oklch(0.15 0.01 260)',     // Dark surface
        muted: 'oklch(0.3 0.02 260)',        // Muted text
      },
    },
  },
};
```

---

## Test Plan for the CLI Itself

### 測試策略

| 層級 | 工具 | 測試對象 |
|------|------|----------|
| Unit | Vitest | Prompt validation, config resolution, variable derivation, template rendering |
| Integration | Vitest + tmp dir | Full scaffold generation with snapshot comparison |
| E2E | Vitest (child_process) | Running CLI with `--yes` flag and verifying output structure |

### 測試案例

#### Unit Tests

| # | 測試 | 斷言 |
|---|------|------|
| 1 | `validateProjectName('my-app')` | 回傳 `true` |
| 2 | `validateProjectName('My App')` | 回傳錯誤字串 |
| 3 | `validateProjectName('_hello')` | 回傳錯誤字串 |
| 4 | `validateProjectName('a'.repeat(65))` | 回傳錯誤字串 |
| 5 | `resolveConfig({ database: 'postgres' })` | `include_db === true`, `db_driver === 'postgres'` |
| 6 | `resolveConfig({ database: 'none' })` | `include_db === false` |
| 7 | `resolveConfig({ projectName: 'my-app' })` | `acmeScope === '@my-app'` |
| 8 | `resolveConfig({ projectName: 'my-app' })` | `projectNamePascal === 'MyApp'` |
| 9 | `renderTemplate('Hello {{name}}', { name: 'World' })` | `'Hello World'` |
| 10 | `renderTemplate('{{a}} {{b}}', { a: 'x', b: 'y' })` | `'x y'` |
| 11 | `renderTemplate('\\{{keep}}', { keep: 'nope' })` | `'{{keep}}'` (escape 處理) |

#### Integration Tests (Snapshot)

| # | 情境 | config | 方式 |
|---|------|--------|------|
| 1 | 完整安裝 (postgres + github + vercel + seed + docker) | `--yes` | Snapshot 比較產生目錄 vs golden fixture |
| 2 | 最小安裝 (sqlite + none + none) | `--yes --db sqlite --ci none --deploy none` | Snapshot 比較 |
| 3 | 無資料庫 | `--yes --db none` | 驗證 `packages/db/` 不存在 |
| 4 | 無 Docker | `--yes --docker false` | 驗證 `docker-compose.yml` 不存在 |
| 5 | 無 CI | `--yes --ci none` | 驗證 `.github/` 不存在 |
| 6 | npm 作為套件管理器 | `--yes --pm npm` | 驗證 `package.json` 中 scripts 使用 npm |

#### E2E Tests

| # | 測試 | 步驟 |
|---|------|------|
| 1 | CLI 可執行 | `node packages/create-app/dist/index.js --yes --dir /tmp/test-app` |
| 2 | CLI 接受 pipe | `echo "my-app\npnpm\npostgres\ngithub\nvercel\nn\nn" | node dist/index.js` |
| 3 | CLI 取消 gracefully | 模擬 Ctrl+C，確認無殘留檔案 |

### Snapshot Fixtures

鑑於產生的檔案數量較多，建議使用 **directory snapshot**（比對目錄結構與關鍵檔案內容）：

```
test/__fixtures__/
├── full/              # 完整選項的 golden output
│   ├── .gitignore
│   ├── package.json
│   └── ...
├── minimal/           # 最小選項的 golden output
│   ├── .gitignore
│   ├── package.json
│   └── ...
└── no-db/             # 無資料庫的 golden output
    └── ...
```

Snapshot 使用 `vitest` 的 `toMatchSnapshot()` 比對每個檔案的**內容**，而非僅比對檔案存在性。

### CI Integration

CLI 自身的測試應在 monorepo 的 CI 中執行：
- `pnpm --filter @agent-team/create-app test` — unit + integration
- 在 publish 前自動執行

---

## Relationship to ADR-006 Principles

本 CLI 直接編碼了 ADR-006 的 7 項原則：

| 原則 | CLI 中的體現 |
|------|-------------|
| **API-First** | 預設產生 Hono API server；所有 mutation 模板使用 RESTful resource 路徑；API response format 統一 |
| **Multi-Tenant from Day One** | 所有 DB schema 模板包含 `workspace_id` 基底欄位；API workspace middleware 模板 |
| **Zero Lock-In** | Scaffold 使用業界標準技術棧（無封閉生態系）；Markdown export 預留 |
| **Event-Driven** | `packages/shared/` 預留事件型別定義位置；Seed 功能包含 event stub |
| **Observability as UX** | CORS + error handler 模板包含 logging；`.env.example` 預留 observability 變數 |
| **Extend at Fixed Points** | 目錄結構預留 plugin 擴展點（`packages/` 層級）；API routes 分層清晰 |
| **Async-First** | 所有 mutation 模板設計為 write-through；無 WebSocket 模板 |

---

## NPM Package & Distribution

### package.json

```json
{
  "name": "@agent-team/create-app",
  "version": "0.1.0",
  "type": "module",
  "bin": {
    "create-app": "./src/index.ts"
  },
  "files": [
    "src/",
    "templates/"
  ],
  "scripts": {
    "test": "vitest run",
    "test:watch": "vitest"
  },
  "dependencies": {
    "@clack/prompts": "^0.7",
    "minimist": "^1.2"
  },
  "devDependencies": {
    "tsx": "^4",
    "vitest": "^2",
    "typescript": "^5.5",
    "@types/minimist": "^1.2"
  },
  "publishConfig": {
    "access": "public"
  },
  "engines": {
    "node": ">=18"
  }
}
```

**注意：** `dependencies` 僅包含 `@clack/prompts` 和 `minimist`，保持輕量。`tsx` 為 devDependency。

### 發布策略

CLI 需要能在使用者環境中無需 `tsx` 即執行。因此需要建置步驟：

```json
{
  "scripts": {
    "build": "esbuild src/index.ts --bundle --platform=node --outfile=dist/index.js --external:@clack/prompts --external:minimist",
    "prepublishOnly": "pnpm build",
    "postpublish": "rm -rf dist"
  }
}
```

`bin/run.js` 入口薄殼：
```javascript
#!/usr/bin/env node
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';
import { spawn } from 'node:child_process';

const __dirname = dirname(fileURLToPath(import.meta.url));
const entry = resolve(__dirname, '../dist/index.js');
spawn(process.execPath, [entry], { stdio: 'inherit', env: { ...process.env } });
```

---

## Implementation Brief (for code-writer-c)

### 需要建立的完整檔案清單

#### CLI 工具本體 (`packages/create-app/`)

| # | 檔案 | 說明 |
|---|------|------|
| 1 | `packages/create-app/package.json` | Package 定義，bin, scripts, dependencies |
| 2 | `packages/create-app/tsconfig.json` | Strict TSConfig for the CLI itself |
| 3 | `packages/create-app/README.md` | CLI 使用說明 |
| 4 | `packages/create-app/build.mjs` | esbuild 打包腳本 |
| 5 | `packages/create-app/bin/run.js` | CLI 入口薄殼 (#!/usr/bin/env node) |
| 6 | `packages/create-app/src/index.ts` | 主入口：flags -> prompts -> generate |
| 7 | `packages/create-app/src/config.ts` | Config 型別, defaults, 驗證函式 |
| 8 | `packages/create-app/src/prompts.ts` | `@clack/prompts` 問題定義 + 驗證 |
| 9 | `packages/create-app/src/generator.ts` | 檔案產生邏輯 (walk tree, replace, write) |
| 10 | `packages/create-app/src/renderer.ts` | `{{variable}}` 取代引擎 |
| 11 | `packages/create-app/src/utils.ts` | kebab-to-pascal, 目錄檢查, 路徑輔助 |

#### 模板檔案 (50 files)

**Root templates (9 files):**

| # | 檔案路徑 | 條件 |
|---|----------|------|
| 12 | `templates/root/_package.json` | 始終 |
| 13 | `templates/root/_pnpm-workspace.yaml` | 始終 |
| 14 | `templates/root/_tsconfig.json` | 始終 |
| 15 | `templates/root/_.env.example` | 始終 |
| 16 | `templates/root/_.gitignore` | 始終 |
| 17 | `templates/root/_.prettierrc` | 始終 |
| 18 | `templates/root/_.nvmrc` | 始終 |
| 19 | `templates/root/_vitest.config.ts` | 始終 |
| 20 | `templates/root/_README.md` | 始終 (動態內容) |

**apps/api/ templates (11 files):**

| # | 檔案路徑 | 條件 |
|---|----------|------|
| 21 | `templates/apps/api/_package.json` | 始終 |
| 22 | `templates/apps/api/_tsconfig.json` | 始終 |
| 23 | `templates/apps/api/src/_index.ts` | 始終 |
| 24 | `templates/apps/api/src/_env.ts` | 始終 |
| 25 | `templates/apps/api/src/lib/_response.ts` | 始終 |
| 26 | `templates/apps/api/src/lib/_error-handler.ts` | 始終 |
| 27 | `templates/apps/api/src/lib/_pagination.ts` | 始終 |
| 28 | `templates/apps/api/src/middleware/_cors.ts` | 始終 |
| 29 | `templates/apps/api/src/middleware/_workspace.ts` | 始終 |
| 30 | `templates/apps/api/src/routes/_health.ts` | 始終 |
| 31 | `templates/apps/api/src/_index.test.ts` | 始終 |

**apps/web/ templates (10 files):**

| # | 檔案路徑 | 條件 |
|---|----------|------|
| 32 | `templates/apps/web/_package.json` | 始終 |
| 33 | `templates/apps/web/_tsconfig.json` | 始終 |
| 34 | `templates/apps/web/_next.config.ts` | 始終 |
| 35 | `templates/apps/web/_tailwind.config.ts` | 始終 |
| 36 | `templates/apps/web/_postcss.config.mjs` | 始終 |
| 37 | `templates/apps/web/src/app/_layout.tsx` | 始終 |
| 38 | `templates/apps/web/src/app/_page.tsx` | 始終 |
| 39 | `templates/apps/web/src/app/_globals.css` | 始終 |
| 40 | `templates/apps/web/src/lib/_api-client.ts` | 始終 |
| 41 | `templates/apps/web/src/lib/_utils.ts` | 始終 |

**packages/shared/ templates (7 files):**

| # | 檔案路徑 | 條件 |
|---|----------|------|
| 42 | `templates/packages/shared/_package.json` | 始終 |
| 43 | `templates/packages/shared/_tsconfig.json` | 始終 |
| 44 | `templates/packages/shared/src/_index.ts` | 始終 |
| 45 | `templates/packages/shared/src/types/_api.ts` | 始終 |
| 46 | `templates/packages/shared/src/types/_index.ts` | 始終 |
| 47 | `templates/packages/shared/src/validators/_index.ts` | 始終 |
| 48 | `templates/packages/shared/src/constants/_index.ts` | 始終 |

**packages/db/ templates (9 files, conditional):**

| # | 檔案路徑 | 條件 |
|---|----------|------|
| 49 | `templates/packages/db/_package.json` | `include_db` |
| 50 | `templates/packages/db/_tsconfig.json` | `include_db` |
| 51 | `templates/packages/db/_drizzle.config.ts` | `include_db` |
| 52 | `templates/packages/db/src/_index.ts` | `include_db` |
| 53 | `templates/packages/db/src/_client.ts` | `include_db` |
| 54 | `templates/packages/db/src/schema/_base.ts` | `include_db` |
| 55 | `templates/packages/db/src/schema/_users.ts` | `include_db` |
| 56 | `templates/packages/db/src/schema/_workspaces.ts` | `include_db` |
| 57 | `templates/packages/db/src/_seed.ts` | `include_db && include_seed` |

**CI/CD templates (2 files, conditional):**

| # | 檔案路徑 | 條件 |
|---|----------|------|
| 58 | `templates/_github/workflows/_ci.yml` | `has_ci` |
| 59 | `templates/_github/workflows/_deploy.yml` | `has_ci && has_deploy` |

**Docker + Opencode (2 files, conditional):**

| # | 檔案路徑 | 條件 |
|---|----------|------|
| 60 | `templates/_docker-compose.yml` | `has_docker` |
| 61 | `templates/_.opencode/_README.md` | `include_seed` |

#### 測試檔案 (4 files)

| # | 檔案 | 說明 |
|---|------|------|
| 62 | `packages/create-app/test/prompts.test.ts` | 驗證函式測試 |
| 63 | `packages/create-app/test/config.test.ts` | Config 解析 + 變數推導測試 |
| 64 | `packages/create-app/test/renderer.test.ts` | 模板引擎單元測試 |
| 65 | `packages/create-app/test/generator.test.ts` | 完整產生測試 (含 snapshot) |

#### 總計

**65 個檔案**（11 CLI source + 50 templates + 4 test files）

### 實作步驟順序（建議）

1. 建立 `packages/create-app/package.json` + `tsconfig.json` + `build.mjs`
2. 建立 `src/config.ts` — 型別與預設值
3. 建立 `src/renderer.ts` — 取代引擎
4. 建立 `src/utils.ts` — 工具函式
5. 建立 `src/generator.ts` — 檔案產生邏輯
6. 建立 `src/prompts.ts` — 互動式問題
7. 建立 `src/index.ts` — 主入口
8. 建立 `bin/run.js` — 入口薄殼
9. 建立 templates/ 全部 50 個檔案（可平行進行）
10. 建立測試檔案
11. 整合至根 monorepo（更新 `pnpm-workspace.yaml`）
12. 執行 `pnpm install` 並驗證

---

## Consequences

### Positive

1. **一致性強制** — 每個新專案從第一天就符合所有團隊慣例
2. **降低啟動成本** — 新專案從「數小時的拷貝/設定」變成「30 秒的 CLI」
3. **慣例即程式碼** — 團隊慣例更新後，只需更新 templates/ 即可反映到所有新專案
4. **可測試** — Golden snapshot 確保模板變更不會意外破壞結構
5. **符合 ADR-006** — 所有 7 項原則直接編碼在 scaffold 中
6. **Developer Experience** — `@clack/prompts` 提供美麗的 CLI UX，符合我們對品質的要求

### Negative

1. **維護成本** — templates/ 需要隨技術棧版本更新而同步更新
2. **客製化彈性受限** — 偏離預設技術棧的專案需要手動調整 scaffold
3. **CLI 自身的 type safety** — 模板中的 `{{variable}}` 沒有編譯期型別檢查

### Mitigations

1. **版本鎖定** — 每個模板使用 `~` 版本範圍，每週透過 renovate/dependabot 更新
2. **客製化路徑** — 提供 `--force` flag 讓進階使用者覆蓋特定檔案
3. **型別安全** — 在 generator.ts 中對所有變數名稱做 `keyof typeof vars` 檢查，避免拼寫錯誤

---

## Future Considerations (Not in Scope)

- **create-app 更新機制** — 已產生的專案不會自動更新模板（不在 MVP 範圍；使用 Renovate 管理依賴版本）
- **Plugins/addons** — 不支援從 scaffold 階段安裝第三方 plugin（不符 Extend at Fixed Points 原則）
- **遠端 template registry** — 所有模板本地打包在 npm 包中
- **UI 頁面樣板** — 不產生具體業務頁面（僅產生首頁 placeholder）
- **Authentication scaffold** — 不包含認證 middleware（需要業務決策）
- **Monorepo 內的工具發布** — 不包含 changeset / semantic-release 設定（依專案需求自行加入）

---

## References

- ADR-006: Architecture Principles (7 項原則)
- `docs/conventions/index.md` — 通用團隊慣例
- `docs/conventions/productivity-tool.md` — 生產力工具專屬慣例
- `docs/product-vision.md` — 產品願景
- `create-t3-app` — 啟發性的 CLI 設計模式
- `@clack/prompts` — 提示框架文件 (https://github.com/natemoo-re/clack)
- `tsx` — TypeScript 執行器 (https://github.com/privatenumber/tsx)
- `esbuild` — 建置工具 (https://esbuild.github.io/)
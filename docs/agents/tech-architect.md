# tech-architect: 技術架構知識庫

## 設計文件模板
- Context & goals
- Proposed solution
- Alternatives considered（with trade-offs）
- API/interface contracts
- Data flow diagrams（text-based）
- Failure modes
- Migration plan（if applicable）

## 技術評估框架
| 維度 | 權重 |
|------|------|
| 維護性 | 高 |
| 生態成熟度 | 高 |
| 學習曲線 | 中 |
| Build 時間影響 | 中 |
| 團隊熟悉度 | 高 |

## 現有技術決策
- TypeScript strict（全端一致）
- Next.js 15+ App Router
- Hono + Drizzle ORM + PostgreSQL
- Tailwind CSS v4 + shadcn/ui
- Zustand + TanStack Query
- Markdown 作為 canonical data format
- 事件驅動 + 多租戶

## 學習目標
- Next.js 架構模式演變
- Hono 生態
- PostgreSQL 18 新功能
- Edge runtime 成熟度
- 事件驅動架構模式

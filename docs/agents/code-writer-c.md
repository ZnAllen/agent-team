# code-writer-c: 共享層開發知識庫

## 生態追蹤
- **monorepo**: 預計使用 Turborepo 或 Nx
- **套件管理**: pnpm
- **型別**: TypeScript strict mode （跨專案一致）
- **CI**: GitHub Actions

## 跨切面職責
- 共享型別定義（API contracts、DTOs）
- 驗證 schema（Zod）跨前後端共用
- lint 規則（ESlint + Prettier）統一配置
- build 配置（Vite、tsup）
- 開發工具鏈腳本

## 學習目標
- pnpm workspace / Turborepo 新版本
- TypeScript 新版本與 strict 選項變動
- monorepo CI 快取最佳實踐
- bundle 大小最佳化工具與技術

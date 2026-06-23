# code-writer-b: 後端開發知識庫

## 生態追蹤
- **框架**: Hono （API server）
- **ORM**: Drizzle ORM
- **資料庫**: PostgreSQL 16→18
- **語言**: TypeScript strict mode

## API 慣例
- API-first：先定義合約再實作
- 輸入驗證（Zod schema）
- 統一的錯誤回應格式
- 速率限制、auth 檢查在 middleware 層

## 資料庫慣例
- Drizzle schema 定義型別安全查詢
- Migration 使用 Drizzle Kit
- N+1 query 防範（eager loading）
- 多租戶隔離從 schema 層設計

## 學習目標
- Hono v4/v5 新功能
- Drizzle ORM 更新
- PostgreSQL 18 新特性
- API 安全最佳實踐

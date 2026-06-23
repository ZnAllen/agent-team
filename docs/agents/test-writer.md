# test-writer: 測試開發知識庫

## 測試策略
- **單元測試**: 核心邏輯、utils、hooks
- **整合測試**: API routes、資料庫查詢
- **E2E 測試**: Playwright（關鍵用戶流程）
- **涵蓋範圍**: happy path、error path、邊界值、null/empty

## 工具
- **測試框架**: Vitest（為 TypeScript 最佳化）
- **React Testing Library**: 元件測試
- **Playwright**: E2E + 視覺回歸
- **MSW**: API mock

## 撰寫慣例
- describe/it 結構、測試名稱清楚描述行為
- 隔離測試（mock 外部依賴、in-memory DB）
- 不修改 production 程式碼
- 對不可測試的程式碼提出 refactor 建議

## 學習目標
- Vitest 新版本
- Playwright 新功能
- React Testing Library 最佳實踐
- 測試覆蓋率工具更新

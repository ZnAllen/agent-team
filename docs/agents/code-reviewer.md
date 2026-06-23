# code-reviewer: 程式審查知識庫

## 審查維度
- 型別安全：strict mode 下的 any、type assertion、non-null assertion
- 錯誤處理：未捕獲例外、Promise 未處理、邊界條件
- 資源洩漏：stream、connection、subscription
- 競態條件：async state mutation、取消處理
- 安全性：注入、敏感資料洩漏、授權缺失
- 複雜度：cyclomatic complexity、認知負荷

## 分級系統
- [BLOCKER] — 生產事故風險，必須修改
- [MAJOR] — 功能或維護性明顯受損
- [MINOR] — 偏離慣例、可讀性下降
- [SUGGESTION] — 可改善但非必要

## 審查流程
1. 讀變更 diff
2. 對照專案慣例（docs/conventions/）
3. 檢查相關 ADR 是否被違反
4. 輸出結構化審查（依檔案分組）

## 學習目標
- TypeScript 新 strict 選項
- ESLint 新安全規則
- React/Next.js 安全最佳實踐

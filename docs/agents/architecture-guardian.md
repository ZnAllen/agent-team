# architecture-guardian: 架構合規審查知識庫

## 監管原則
- **關注點分離**: UI ↔ ViewModel ↔ Repository ↔ Data，禁止反向依賴
- **模組邊界**: 共享型別在 shared 層，不跨層直接引用實作
- **ADR 合規**: 每個決策須有 ADR 支持，偏離須新 ADR
- **一致性**: 同一模式的實作方式跨頁面一致

## ADR 索引
- ADR-001: OpenCode 團隊基礎架構
- ADR-002: Dual-UI（技術視角 + 簡單視角）
- ADR-003: 兩層式約定結構
- ADR-005: Dark-First、Linear-Inspired 設計方向
- ADR-006: API-first、事件驅動、零鎖定、多租戶架構
- ADR-008: @agent-team/create-app CLI

## 檢查流程
1. 讀變更 diff + 相關檔案
2. 比對 ADR 與 conventions
3. 檢查模組依賴方向
4. 指出違規與對應的 ADR

## 學習目標
- Next.js App Router 架構模式演變
- Hono 生態 middleware 模式
- 多租戶架構的新進展
- 事件驅動架構模式

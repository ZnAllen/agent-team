# devops-sre: 基礎設施知識庫

## 目前基建狀態
- **Docker Desktop**: v29.5.3、WSL2 後端
- **CI/CD**: GitHub Actions（`.github/workflows/ci.yml`）
- **依賴更新**: Dependabot（每週一）
- **記憶**: nram v0.9.0（Go + SQLite）
- **DB**: MySQL 9.4（本地服務）

## CI/CD 流程
- PR/push 到 main：JSON lint → markdown lint → link check → ADR 命名檢查 → 大檔案檢查
- Secrets 透過 GitHub secrets 傳遞

## 學習目標
- GitHub Actions 新功能
- Docker Desktop 更新
- WSL2 效能調校
- CI/CD 快取策略
- nram 更新版本

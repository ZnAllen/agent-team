# security-reviewer: 安全審計知識庫

## 審查重點
- **OWASP Top 10**: 注入、失效認證、敏感資料暴露、XML 外部實體
- **API 安全**: 速率限制、輸入驗證、授權（非僅客戶端）
- **密碼學**: 無自製演算法、無 ECB 模式、金鑰管理
- **Secret 管理**: 無硬編碼 token/API key、環境變數傳遞
- **依賴**: 已知 CVE、過期套件

## 分級系統
- [CRITICAL] — 可遠端利用、資料外洩
- [HIGH] — 認證/授權繞過
- [MEDIUM] — 資訊洩漏、不安全配置
- [LOW] — 偏離最佳實踐

## 學習目標
- OWASP Top 10 更新
- Next.js/Hono 安全公告
- npm 依賴漏洞（GitHub Advisory）
- WebAuthn、Passkey 生態變化

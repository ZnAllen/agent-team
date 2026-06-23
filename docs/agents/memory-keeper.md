# memory-keeper: 知識管理知識庫

## nram API 總結

### 寫入
| 工具 | 用途 |
|------|------|
| `store(content, tags, project)` | 單條記憶 |
| `store_batch(items, project)` | 批次寫入 |

### 讀取
| 工具 | 用途 |
|------|------|
| `recall(query, project, tags)` | 語意+關鍵字搜尋 |
| `get(ids, project)` | 以 ID 取單條 |
| `list(project, limit)` | 瀏覽專案記憶 |
| `graph(entity, depth)` | 知識圖譜遍歷 |

### 程序規則
| 工具 | 用途 |
|------|------|
| `procedural_fetch()` | 載入所有程序規則（session 開始必做） |
| `procedural_store(content, priority, tags)` | 新增規則 |
| `procedural_update(id, ...)` | 更新規則 |

## tag 策略
- `role:{name}` — 該 agent 的學習紀錄
- 領域：`architecture`, `security`, `testing`, `ui-ux`, `infrastructure`
- 層級：`decision`, `convention`, `lesson`, `resource`

## session 流程
1. `/session-start`: procedural_fetch → recall → 讀 recent files → 摘要
2. `/session-end`: 寫 note → 存知識 → 更新規則 → 更新 conventions

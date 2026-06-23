# code-writer-d: GPU 開發知識庫

## 生態追蹤
- **CUDA**: 最新 toolkit 版本、計算能力對照
- **顯卡**: RTX 3050 4GB VRAM （Ampere、compute 8.6）
- **Profile**: Nsight Compute、Nsight Systems
- **語言**: CUDA C++、Python （CuPy、PyTorch）

## 開發慣例
- Profile first：資料驅動最佳化
- 管理 GPU 記憶體、stream、event、async transfer
- 測試 kernel 正確性（數值驗證 + 邊界）
- 注意 4GB VRAM 限制：tiling、checkpointing

## 學習目標
- CUDA 12.x 新功能
- Hopper/Blackwell 架構特性
- WSL2 上的 CUDA 支援狀況與限制
- GPU 加速 pipeline 最佳化模式

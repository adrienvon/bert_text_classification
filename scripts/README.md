# Installation Scripts

自动化安装脚本用于快速安装 BERT Text Classification 的依赖环境。支持两种 Python 环境管理方式：**Venv** 和 **Conda**。

## 文件说明

- `install.ps1` - Windows PowerShell 安装脚本（支持 Venv 和 Conda）
- `install.sh` - Linux/macOS Bash 安装脚本（支持 Venv 和 Conda）


---

## 使用方法

### 方案 A：Venv（推荐新手）

#### Windows

```powershell
# CPU 版本
.\scripts\install.ps1 -env_type venv -device cpu

# GPU 版本（CUDA 11.1）
.\scripts\install.ps1 -env_type venv -device gpu -cuda_version 111

# 其他 CUDA 版本
.\scripts\install.ps1 -env_type venv -device gpu -cuda_version 102  # CUDA 10.2
```

#### Linux / macOS

```bash
# CPU 版本
bash scripts/install.sh venv cpu

# GPU 版本（CUDA 11.1）
bash scripts/install.sh venv gpu 111

# 其他 CUDA 版本
bash scripts/install.sh venv gpu 102  # CUDA 10.2
```

**激活环境**:
- Windows: `.\venv\Scripts\Activate.ps1`
- Linux/Mac: `source venv/bin/activate`

---

### 方案 B：Conda（推荐已有 Conda 用户）

#### Windows

```powershell
# CPU 版本（环境名: bert_env）
.\scripts\install.ps1 -env_type conda -device cpu

# GPU 版本（CUDA 11.1）
.\scripts\install.ps1 -env_type conda -device gpu -cuda_version 111

# 自定义环境名
.\scripts\install.ps1 -env_type conda -device cpu -env_name mybert
```

#### Linux / macOS

```bash
# CPU 版本（环境名: bert_env）
bash scripts/install.sh conda cpu

# GPU 版本（CUDA 11.1）
bash scripts/install.sh conda gpu 111

# 自定义环境名
bash scripts/install.sh conda cpu mybert
```

**激活环境**:
```bash
conda activate bert_env        # 或自定义的环境名
conda activate mybert
```

---

## 脚本参数详解

### Windows PowerShell 脚本

```powershell
.\scripts\install.ps1 -env_type venv|conda -device cpu|gpu -cuda_version 102|110|111|113 -env_name bert_env
```

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `-env_type` | `venv` | 环境管理方式：`venv` 或 `conda` |
| `-device` | `cpu` | 计算设备：`cpu` 或 `gpu` |
| `-cuda_version` | `111` | GPU 版本的 CUDA 版本号 |
| `-env_name` | `bert_env` | Conda 环境名称 |

### Linux/macOS Bash 脚本

```bash
bash scripts/install.sh [env_type] [device] [cuda_version] [env_name]
```

| 位置 | 默认值 | 说明 |
|------|--------|------|
| $1 | `venv` | 环境管理方式：`venv` 或 `conda` |
| $2 | `cpu` | 计算设备：`cpu` 或 `gpu` |
| $3 | `111` | GPU 版本的 CUDA 版本号 |
| $4 | `bert_env` | Conda 环境名称 |

---

## 故障排除

### Windows 执行策略错误

如果遇到执行策略错误，运行：

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 查询 CUDA 版本

GPU 用户可以运行以下命令查看已安装的 CUDA 版本：

```bash
nvidia-smi
```

查看输出中的 "CUDA Version" 字段，选择对应的脚本参数：

- CUDA 10.2 → 参数 `102`
- CUDA 11.0 → 参数 `110`
- CUDA 11.1 → 参数 `111`
- CUDA 11.3 → 参数 `113`


---

## 脚本做了什么

1. ✅ 创建或检测 Python 环境（Venv 或 Conda）
2. ✅ 激活虚拟环境
3. ✅ 自动下载并安装正确版本的 PyTorch（CPU 或 GPU）
4. ✅ 安装所有必需的依赖包（使用 `requirements.txt`）
5. ✅ 验证安装成功
6. ✅ 显示后续步骤提示

---

## 支持的 PyTorch 版本

- **PyTorch 1.9.0**（核心库）
- **torchvision 0.10.0**（图像处理库）

---

## 手动安装

### Venv 方式

```bash
# 1. 创建虚拟环境
python3 -m venv venv

# 2. 激活环境
# Windows: .\venv\Scripts\Activate.ps1
# Linux/Mac: source venv/bin/activate

# 3. 安装 PyTorch（选择 CPU 或 GPU）
pip install torch==1.9.0+cpu -f https://download.pytorch.org/whl/torch_stable.html

# 或 GPU 版本（CUDA 11.1）
pip install --index-url https://download.pytorch.org/whl/cu111 torch==1.9.0+cu111 -f https://download.pytorch.org/whl/torch_stable.html

# 4. 安装其他依赖
pip install -r requirements.txt
```

### Conda 方式

```bash
# 1. 创建 Conda 环境
conda create -n bert_env python=3.9 -y

# 2. 激活环境
conda activate bert_env

# 3. 安装 PyTorch（选择 CPU 或 GPU）
conda install pytorch::pytorch torchvision -c pytorch

# 或指定版本
pip install torch==1.9.0+cpu -f https://download.pytorch.org/whl/torch_stable.html

# 4. 安装其他依赖
pip install -r requirements.txt
```

---

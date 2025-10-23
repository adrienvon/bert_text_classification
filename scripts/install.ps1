# Windows Auto-Install Script for BERT Text Classification
# Supports both Conda and Venv environments
# Usage: .\install.ps1 -env_type venv -device cpu
#        .\install.ps1 -env_type conda -device gpu -cuda_version 111
# Parameters:
#   -env_type: venv or conda (default: venv)
#   -device: cpu or gpu (default: cpu)
#   -cuda_version: 102 (10.2), 110, 111, 113 (default: 111)
#   -env_name: environment name for conda (default: bert_env)

param(
    [ValidateSet("venv", "conda")]
    [string]$env_type = "venv",
    [ValidateSet("cpu", "gpu")]
    [string]$device = "cpu",
    [ValidateSet("102", "110", "111", "113")]
    [string]$cuda_version = "111",
    [string]$env_name = "bert_env"
)

# Color output
function Write-Success {
    param([string]$message)
    Write-Host $message -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$message)
    Write-Host $message -ForegroundColor Red
}

function Write-Warning-Custom {
    param([string]$message)
    Write-Host $message -ForegroundColor Yellow
}

function Write-Info {
    param([string]$message)
    Write-Host $message -ForegroundColor Cyan
}

# Header
Write-Host "`n" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "BERT Text Classification - Auto Installer" -ForegroundColor Green
Write-Host "Environment: $env_type | Device: $device" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`n"

# ==================== VENV Setup ====================
if ($env_type -eq "venv") {
    Write-Info "[1/4] Setting up Python virtual environment (venv)..."
    
    # Check Python
    $python_version = python --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "❌ Python not found! Please install Python 3.7+ first."
        exit 1
    }
    Write-Host "✅ $python_version"
    
    # Create venv
    Write-Info "Creating virtual environment 'venv'..."
    python -m venv venv
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "❌ Failed to create virtual environment!"
        exit 1
    }
    Write-Success "✅ Virtual environment created"
    
    # Activate venv
    Write-Info "Activating virtual environment..."
    & .\venv\Scripts\Activate.ps1
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "❌ Failed to activate virtual environment!"
        exit 1
    }
    Write-Success "✅ Virtual environment activated"
    
    $pip_cmd = "pip"
    $python_cmd = "python"
}
# ==================== Conda Setup ====================
else {
    Write-Info "[1/4] Setting up Conda environment..."
    
    # Check conda
    $conda_version = conda --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "❌ Conda not found! Please install Anaconda or Miniconda first."
        Write-Error-Custom "   Download: https://www.anaconda.com/products/miniconda"
        exit 1
    }
    Write-Host "✅ $conda_version"
    
    # Create conda environment
    Write-Info "Creating Conda environment '$env_name' with Python 3.9..."
    conda create -n $env_name python=3.9 -y
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "❌ Failed to create Conda environment!"
        exit 1
    }
    Write-Success "✅ Conda environment created"
    
    # Activate conda environment
    Write-Info "Activating Conda environment..."
    conda activate $env_name
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "❌ Failed to activate Conda environment!"
        exit 1
    }
    Write-Success "✅ Conda environment activated: $env_name"
    
    $pip_cmd = "pip"
    $python_cmd = "python"
}

# ==================== Install PyTorch ====================
Write-Info "`n[2/4] Installing PyTorch..."


if ($device -eq "cpu") {
    Write-Warning-Custom "Installing PyTorch (CPU version)..."
    & $pip_cmd install torch==1.9.0+cpu torchvision==0.10.0+cpu -f https://download.pytorch.org/whl/torch_stable.html
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "❌ PyTorch CPU installation failed!"
        exit 1
    }
}
else {
    $cuda_map = @{
        "102" = @{name = "CUDA 10.2"; url = "cu102" }
        "110" = @{name = "CUDA 11.0"; url = "cu110" }
        "111" = @{name = "CUDA 11.1"; url = "cu111" }
        "113" = @{name = "CUDA 11.3"; url = "cu113" }
    }
    
    $cuda_info = $cuda_map[$cuda_version]
    Write-Warning-Custom "Installing PyTorch with $($cuda_info.name)..."
    
    & $pip_cmd install --index-url https://download.pytorch.org/whl/$($cuda_info.url) torch==1.9.0+$($cuda_info.url) torchvision==0.10.0+$($cuda_info.url) -f https://download.pytorch.org/whl/torch_stable.html
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "❌ PyTorch GPU installation failed!"
        exit 1
    }
}

# Verify PyTorch installation
Write-Info "`nVerifying PyTorch installation..."
& $python_cmd -c "import torch; print(f'PyTorch {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}')" 2>&1
Write-Success "✅ PyTorch installed successfully"

# ==================== Install Dependencies ====================
Write-Info "`n[3/4] Installing other dependencies..."
& $pip_cmd install -r requirements.txt
if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "❌ Dependency installation failed!"
    exit 1
}
Write-Success "✅ All dependencies installed"

# ==================== Verify Installation ====================
Write-Info "`n[4/4] Verifying installation..."
& $python_cmd -c @"
import torch
import transformers
import numpy
import sklearn
print('✅ All packages imported successfully')
print(f'   - PyTorch: {torch.__version__}')
print(f'   - Transformers: {transformers.__version__}')
print(f'   - NumPy: {numpy.__version__}')
"@ 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "❌ Verification failed!"
    exit 1
}

# Success message
Write-Success "`n========================================" 
Write-Success "✅ Installation Completed Successfully!"
Write-Success "========================================`n"

# Next steps
Write-Info "📝 Next Steps:"
Write-Host "   1. Download BERT model from:"
Write-Host "      https://huggingface.co/bert-base-chinese"
Write-Host "   2. Place model files in ./pretrained_bert folder"
Write-Host "   3. Prepare your data in ./data folder"

if ($env_type -eq "venv") {
    Write-Host "   4. Activate environment: .\venv\Scripts\Activate.ps1"
}
else {
    Write-Host "   4. Activate environment: conda activate $env_name"
}

Write-Host "   5. Run: python main.py --mode train --data_dir ./data --pretrained_bert_dir ./pretrained_bert"

if ($device -eq "gpu") {
    Write-Host "`n💡 GPU Mode: Training will be significantly faster!" -ForegroundColor Magenta
}

Write-Host "`n"

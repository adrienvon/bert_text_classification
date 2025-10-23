#!/bin/bash
# Linux/Mac Auto-Install Script for BERT Text Classification
# Supports both Conda and Venv environments
# Usage: bash install.sh venv cpu
#        bash install.sh conda gpu 111
# Parameters:
#   $1: venv or conda (default: venv)
#   $2: cpu or gpu (default: cpu)
#   $3: CUDA version - 102 (10.2), 110, 111, 113 (default: 111)
#   $4: environment name for conda (default: bert_env)

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Functions
success() {
    echo -e "${GREEN}$1${NC}"
}

error() {
    echo -e "${RED}$1${NC}"
}

warning() {
    echo -e "${YELLOW}$1${NC}"
}

info() {
    echo -e "${CYAN}$1${NC}"
}

# Parse arguments
ENV_TYPE=${1:-venv}
DEVICE=${2:-cpu}
CUDA_VERSION=${3:-111}
ENV_NAME=${4:-bert_env}

# Validate env_type
if [[ "$ENV_TYPE" != "venv" && "$ENV_TYPE" != "conda" ]]; then
    error "❌ Invalid environment type: $ENV_TYPE (must be 'venv' or 'conda')"
    exit 1
fi

# Validate device
if [[ "$DEVICE" != "cpu" && "$DEVICE" != "gpu" ]]; then
    error "❌ Invalid device: $DEVICE (must be 'cpu' or 'gpu')"
    exit 1
fi

# Validate CUDA version
if [[ "$DEVICE" == "gpu" && ! "$CUDA_VERSION" =~ ^(102|110|111|113)$ ]]; then
    error "❌ Invalid CUDA version: $CUDA_VERSION"
    error "   Supported: 102 (CUDA 10.2), 110, 111, 113"
    exit 1
fi

# Header
echo ""
success "========================================"
success "BERT Text Classification - Auto Installer"
success "Environment: $ENV_TYPE | Device: $DEVICE"
success "========================================"
success ""

# ==================== VENV Setup ====================
if [ "$ENV_TYPE" = "venv" ]; then
    info "[1/4] Setting up Python virtual environment (venv)..."
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        error "❌ Python3 not found! Please install Python 3.7+ first."
        exit 1
    fi
    
    PYTHON_VERSION=$(python3 --version)
    success "✅ $PYTHON_VERSION"
    
    # Create venv
    info "Creating virtual environment 'venv'..."
    python3 -m venv venv
    success "✅ Virtual environment created"
    
    # Activate venv
    info "Activating virtual environment..."
    source venv/bin/activate
    success "✅ Virtual environment activated"
    
    PIP_CMD="pip"
    PYTHON_CMD="python"

# ==================== Conda Setup ====================
else
    info "[1/4] Setting up Conda environment..."
    
    # Check conda
    if ! command -v conda &> /dev/null; then
        error "❌ Conda not found! Please install Anaconda or Miniconda first."
        error "   Download: https://www.anaconda.com/products/miniconda"
        exit 1
    fi
    
    CONDA_VERSION=$(conda --version)
    success "✅ $CONDA_VERSION"
    
    # Create conda environment
    info "Creating Conda environment '$ENV_NAME' with Python 3.9..."
    conda create -n $ENV_NAME python=3.9 -y
    success "✅ Conda environment created"
    
    # Activate conda environment
    info "Activating Conda environment..."
    eval "$(conda shell.bash hook)"
    conda activate $ENV_NAME
    success "✅ Conda environment activated: $ENV_NAME"
    
    PIP_CMD="pip"
    PYTHON_CMD="python"
fi

# ==================== Install PyTorch ====================
info ""
info "[2/4] Installing PyTorch..."

if [ "$DEVICE" = "cpu" ]; then
    warning "Installing PyTorch (CPU version)..."
    $PIP_CMD install torch==1.9.0+cpu torchvision==0.10.0+cpu -f https://download.pytorch.org/whl/torch_stable.html
    if [ $? -ne 0 ]; then
        error "❌ PyTorch CPU installation failed!"
        exit 1
    fi
else
    # GPU installation
    case $CUDA_VERSION in
        102)
            CUDA_URL="cu102"
            CUDA_NAME="CUDA 10.2"
            ;;
        110)
            CUDA_URL="cu110"
            CUDA_NAME="CUDA 11.0"
            ;;
        111)
            CUDA_URL="cu111"
            CUDA_NAME="CUDA 11.1"
            ;;
        113)
            CUDA_URL="cu113"
            CUDA_NAME="CUDA 11.3"
            ;;
    esac
    
    warning "Installing PyTorch with $CUDA_NAME..."
    $PIP_CMD install --index-url https://download.pytorch.org/whl/$CUDA_URL torch==1.9.0+$CUDA_URL torchvision==0.10.0+$CUDA_URL -f https://download.pytorch.org/whl/torch_stable.html
    if [ $? -ne 0 ]; then
        error "❌ PyTorch GPU installation failed!"
        exit 1
    fi
fi

# Verify PyTorch installation
info ""
info "Verifying PyTorch installation..."
$PYTHON_CMD << 'PYTHON_CHECK'
import torch
print(f'✅ PyTorch {torch.__version__}')
print(f'✅ CUDA available: {torch.cuda.is_available()}')
if torch.cuda.is_available():
    print(f'✅ CUDA version: {torch.version.cuda}')
    print(f'✅ GPU device: {torch.cuda.get_device_name(0)}')
PYTHON_CHECK

success "✅ PyTorch installed successfully"

# ==================== Install Dependencies ====================
info ""
info "[3/4] Installing other dependencies..."
$PIP_CMD install -r requirements.txt
if [ $? -ne 0 ]; then
    error "❌ Dependency installation failed!"
    exit 1
fi
success "✅ All dependencies installed"

# ==================== Verify Installation ====================
info ""
info "[4/4] Verifying installation..."
$PYTHON_CMD << 'VERIFY_CHECK'
import torch
import transformers
import numpy
import sklearn
print('✅ All packages imported successfully')
print(f'   - PyTorch: {torch.__version__}')
print(f'   - Transformers: {transformers.__version__}')
print(f'   - NumPy: {numpy.__version__}')
VERIFY_CHECK

if [ $? -ne 0 ]; then
    error "❌ Verification failed!"
    exit 1
fi

# Success message
echo ""
success "========================================"
success "✅ Installation Completed Successfully!"
success "========================================"
echo ""

# Next steps
info "📝 Next Steps:"
echo "   1. Download BERT model from:"
echo "      https://huggingface.co/bert-base-chinese"
echo "   2. Place model files in ./pretrained_bert folder"
echo "   3. Prepare your data in ./data folder"

if [ "$ENV_TYPE" = "venv" ]; then
    echo "   4. Activate environment: source venv/bin/activate"
else
    echo "   4. Activate environment: conda activate $ENV_NAME"
fi

echo "   5. Run: python main.py --mode train --data_dir ./data --pretrained_bert_dir ./pretrained_bert"

if [ "$DEVICE" = "gpu" ]; then
    echo ""
    warning "💡 GPU Mode: Training will be significantly faster!"
fi

echo ""

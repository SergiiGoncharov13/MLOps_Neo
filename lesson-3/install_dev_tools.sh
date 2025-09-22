#!/usr/bin/env bash
set -e
LOGFILE="install.log"

function log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOGFILE"
}

log "===Instalation started==="

if ! command -v docker &> /dev/null; then
    log "Docken not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y docker.io
else
    log "Docker already installed: $(docker --version)"
fi


if ! command -v docker-compose &> /dev/null; then
    log "Docken Compose  not found. Installing..."
    sudo apt-get install -y docker-compose
else
    log "Docker Compose already installed: $(docker-compose --version)"
fi


PYTHON_VERSION=$(python3 -V 2>&1 | awk '{print $2}')
if python3 -c 'import sys; exit(0 if sys.version_info >= (3,9) else 1)';
    log "Python OK: $PYTHON_VERSION"
else
    log "Python < 3.9, updating Python"
    sudo apt-get install -y python3.10 python3.10-venv python3.10-dev
fi


if ! command -v pip3 &> /dev/null; then
    log "pip not found. Installing..."
    sudo apt-get install -y python3-pip
else
    log "pip already installed: $(pip3 --version)"
fi


for pkg in torch torchvision pillow django; do
    if python3 -c "import $pkg" 2>/dev/null; then
        log "$pkg already installed"
    else
        log "$pkg not found. Installing..."
        pip3 install $pkg
    fi
done

log "===Instalation finished==="

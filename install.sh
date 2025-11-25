#!/usr/bin/env bash
set -e

echo "=== Aryan Dev OS – Base Web Dev Setup ==="

# 1. Update and install base tools
echo "[1/5] Updating APT and installing base packages..."
sudo apt update
sudo apt install -y \
  build-essential \
  curl \
  wget \
  git \
  ca-certificates \
  software-properties-common \
  apt-transport-https \
  gnupg \
  lsb-release

# 2. Install VS Code
echo "[2/5] Installing VS Code..."
if [ ! -f /usr/share/keyrings/packages.microsoft.gpg ]; then
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | sudo tee /usr/share/keyrings/packages.microsoft.gpg > /dev/null
fi

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | \
  sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

sudo apt update
sudo apt install -y code

# 3. Install Node.js (via nvm) + yarn + pnpm
echo "[3/5] Installing Node.js (LTS) via nvm..."

if [ ! -d "$HOME/.nvm" ]; then
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm install --lts
nvm use --lts

echo "[4/5] Installing global JS package managers (yarn, pnpm)..."
npm install -g yarn pnpm

# 4. Show versions
echo "[5/5] Installed tool versions:"
echo "Node:  $(node -v || echo 'not found')"
echo "npm:   $(npm -v || echo 'not found')"
echo "yarn:  $(yarn -v || echo 'not found')"
echo "pnpm:  $(pnpm -v || echo 'not found')"
echo "Code:  $(code --version | head -n 1 || echo 'not found')"

echo
echo "=== Aryan Dev OS – Web Dev base setup complete ==="
echo "Tip: open a NEW terminal so nvm autoloads correctly next time."

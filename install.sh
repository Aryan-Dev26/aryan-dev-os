#!/usr/bin/env bash
set -e

echo "==========================================="
echo "      Aryan Dev OS – Setup Script"
echo "   Web Dev + 3D + Game Dev Environment"
echo "==========================================="

# Small helper
log() {
  echo
  echo "👉 $1"
  echo "-------------------------------------------"
}

# 0. Cleanup any old/buggy VS Code repo configs (to avoid 'Signed-By' conflicts)
log "Cleaning up any old VS Code APT configs (if present)..."
sudo rm -f /etc/apt/sources.list.d/vscode.list /etc/apt/sources.list.d/vscode.list.save 2>/dev/null || true
sudo rm -f /usr/share/keyrings/microsoft.gpg 2>/dev/null || true

# 1. Base system update + tools
log "Updating APT and installing base packages..."
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

# 2. VS Code
log "Installing / verifying VS Code..."

if ! command -v code >/dev/null 2>&1; then
  if [ ! -f /usr/share/keyrings/packages.microsoft.gpg ]; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | \
      gpg --dearmor | sudo tee /usr/share/keyrings/packages.microsoft.gpg > /dev/null
  fi

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | \
    sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

  sudo apt update
  sudo apt install -y code
else
  echo "✅ VS Code already installed, skipping."
fi

# 3. Node.js via nvm + yarn + pnpm
log "Installing Node.js (LTS) via nvm and JS package managers..."

if [ ! -d "$HOME/.nvm" ]; then
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# Install Node LTS if not installed
if ! command -v node >/dev/null 2>&1; then
  nvm install --lts
fi
nvm use --lts

# Global JS managers
if ! command -v yarn >/dev/null 2>&1; then
  npm install -g yarn
fi

if ! command -v pnpm >/dev/null 2>&1; then
  npm install -g pnpm
fi

# 4. 3D & art tools – Blender, GIMP, Krita
log "Installing 3D & art tools (Blender, GIMP, Krita)..."
sudo apt install -y blender gimp krita

# 5. Godot (via snap)
log "Installing Godot game engine (via snap)..."
if ! command -v snap >/dev/null 2>&1; then
  echo "snapd is not installed, installing..."
  sudo apt install -y snapd
fi

if ! snap list | grep -q "^godot "; then
  sudo snap install godot --classic
else
  echo "✅ Godot already installed via snap, skipping."
fi

# 6. Docker + Docker Compose plugin
log "Installing Docker Engine & Docker Compose plugin..."

if ! command -v docker >/dev/null 2>&1; then
  # Create keyrings dir
  sudo install -m 0755 -d /etc/apt/keyrings

  # Add Docker GPG key
  if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
      sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
  fi

  # Add Docker repo
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  # Add current user to docker group
  sudo usermod -aG docker "$USER"
else
  echo "✅ Docker already installed, skipping."
fi

# 7. Versions summary
log "Summary of installed tool versions:"

echo "Node:   $(node -v 2>/dev/null || echo 'not found')"
echo "npm:    $(npm -v 2>/dev/null || echo 'not found')"
echo "yarn:   $(yarn -v 2>/dev/null || echo 'not found')"
echo "pnpm:   $(pnpm -v 2>/dev/null || echo 'not found')"
echo "Code:   $(code --version 2>/dev/null | head -n 1 || echo 'not found')"
echo "Blender:$(blender --version 2>/dev/null | head -n 1 || echo 'not found (check GUI menu)')"
echo "Godot:  $(godot --version 2>/dev/null || echo 'may be available via snap only / GUI')"
echo "Docker: $(docker --version 2>/dev/null || echo 'not found')"

echo
echo "==========================================="
echo "✅ Aryan Dev OS – Setup completed"
echo "   - Web Dev stack ready"
echo "   - 3D & Game Dev tools installed"
echo "   - Docker installed (relogin may be needed)"
echo "==========================================="
echo "ℹ Tip: Log out and log back in (or reboot) so docker group changes apply."
echo "ℹ Tip: Open a NEW terminal so nvm loads automatically."


#!/data/data/com.termux/files/usr/bin/env bash
set -e

echo "🚀 Device Setup Script"
echo "======================"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }

# Check if running on Termux
IS_TERMUX=false
if [ -f "/data/data/com.termux/files/usr/bin/pkg" ]; then
    IS_TERMUX=true
fi

echo ""
echo "Platform: $([ "$IS_TERMUX" = true ] && echo 'Termux/Android' || echo 'Linux/Unix')"
echo ""

# Step 1: Install required packages
echo "📦 Installing required packages..."
if [ "$IS_TERMUX" = true ]; then
    pkg update -y && pkg install -y gh git gnupg openssh
else
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y gh git gnupg openssh-client
    elif command -v brew &> /dev/null; then
        brew install gh git gnupg openssh
    fi
fi
success "Packages installed"

# Step 2: Setup SSH
echo ""
echo "🔑 Setting up SSH..."
if [ ! -f ~/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -C "device-setup" -f ~/.ssh/id_ed25519 -N ""
    success "SSH key generated"
else
    warn "SSH key already exists"
fi

# Add GitHub to known hosts
ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null
success "GitHub added to known hosts"

# Step 3: Authenticate GitHub CLI
echo ""
echo "🔗 Authenticating GitHub CLI..."
if command -v gh &> /dev/null; then
    if gh auth status &>/dev/null; then
        warn "GitHub CLI already authenticated"
    else
        echo "Please authenticate with GitHub CLI:"
        gh auth login -p ssh
    fi
    success "GitHub CLI ready"
else
    error "gh CLI not found, please install manually"
    exit 1
fi

# Step 4: Setup GPG
echo ""
echo "🔐 Setting up GPG..."
if command -v gpg &> /dev/null; then
    if gpg --list-keys "Secure Vault" &>/dev/null; then
        warn "GPG key already imported"
    else
        echo "Looking for GPG private key backup..."
        if [ -f ~/vault-private-key-backup.asc ]; then
            gpg --import ~/vault-private-key-backup.asc
            success "GPG key imported"
            
            # Set ultimate trust
            echo "Setting trust level..."
            echo -e "5\ny\n" | gpg --command-fd 0 --edit-key "Secure Vault" trust quit &>/dev/null || true
            success "GPG trust set"
        else
            error "GPG private key backup not found at ~/vault-private-key-backup.asc"
            echo "Please copy your key backup to this location and re-run the script"
        fi
    fi
else
    error "GPG not found, please install manually"
fi

# Step 5: Clone Secure Vault
echo ""
echo "🏦 Cloning secure vault..."
if [ -d ~/secure-vault ]; then
    warn "Secure vault already exists"
    cd ~/secure-vault && git pull
else
    gh repo clone godofecht/secure-vault ~/secure-vault
    success "Secure vault cloned"
fi

# Step 6: Test decryption
echo ""
echo "🔓 Testing credential decryption..."
cd ~/secure-vault
if gpg --decrypt credentials.gpg &>/dev/null; then
    success "Credentials decrypted successfully!"
    echo ""
    echo "To view credentials, run:"
    echo "  gpg --decrypt ~/secure-vault/credentials.gpg"
else
    error "Failed to decrypt credentials"
fi

# Step 7: Configure Git
echo ""
echo "📝 Configuring Git..."
git config --global user.email "vault@local"
git config --global user.name "Secure Vault"
success "Git configured"

# Summary
echo ""
echo "======================"
echo "✅ Setup Complete!"
echo "======================"
echo ""
echo "Next steps:"
echo "  1. View credentials: gpg --decrypt ~/secure-vault/credentials.gpg"
echo "  2. Register SSH key at: https://github.com/settings/keys"
echo "  3. Test GitHub access: gh repo view godofecht/secure-vault"
echo ""

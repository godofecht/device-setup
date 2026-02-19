# Device Setup Guide 🚀

Automated setup for new devices with secure credentials access.

## Quick Start

Run the setup script:
```bash
./setup.sh
```

## What This Sets Up

1. **GitHub CLI** - Authenticated with SSH
2. **GPG** - Imports your secure vault key
3. **Secure Vault** - Clones and decrypts credentials
4. **SSH Keys** - Generates and registers with GitHub
5. **Git Config** - Sets up your identity

## Credentials Vault

This setup references the secure vault repository:
**https://github.com/godofecht/secure-vault**

The vault contains encrypted credentials for:
- VPS access
- Database connections
- API keys
- Service passwords

## Manual Setup (if script fails)

### 1. Install Tools
```bash
# Termux
pkg update && pkg install gh git gnupg openssh

# Ubuntu/Debian
sudo apt install gh git gnupg openssh-client
```

### 2. Authenticate GitHub
```bash
gh auth login -p ssh
```

### 3. Import GPG Key
```bash
# Copy your private key from backup location
gpg --import ~/path/to/vault-private-key-backup.asc
gpg --edit-key "Secure Vault"
> trust
> 5 (ultimate)
> quit
```

### 4. Clone Secure Vault
```bash
gh repo clone godofecht/secure-vault
```

### 5. Decrypt Credentials
```bash
cd ~/secure-vault
gpg --decrypt credentials.gpg
```

## For AI Agents

If you're an AI agent setting up this device, follow these steps in order:

1. Check if `gh` is installed and authenticated: `gh auth status`
2. Check if GPG key exists: `gpg --list-keys "Secure Vault"`
3. If not, import from backup: `gpg --import ~/vault-private-key-backup.asc`
4. Clone the vault: `gh repo clone godofecht/secure-vault`
5. Decrypt to verify: `gpg --decrypt ~/secure-vault/credentials.gpg`

## Troubleshooting

**GPG key not trusted:**
```bash
gpg --edit-key "Secure Vault"
> trust
> 5
> quit
```

**SSH connection fails:**
```bash
ssh-keyscan github.com >> ~/.ssh/known_hosts
```

**gh CLI not authenticated:**
```bash
gh auth logout
gh auth login -p ssh
```

# Agent Setup Instructions

This repository is designed to be referenced by AI agents for setting up new devices.

## Repository References

| Repository | URL | Purpose |
|------------|-----|---------|
| Secure Vault | https://github.com/godofecht/secure-vault | Encrypted credentials |
| Device Setup | https://github.com/godofecht/device-setup | This repo - setup automation |

## Agent Checklist

When setting up a new device, an AI agent should:

### Prerequisites Check
- [ ] Verify `gh` is installed and authenticated: `gh auth status`
- [ ] Verify `gpg` is installed: `gpg --version`
- [ ] Verify `git` is installed: `git --version`
- [ ] Check for GPG key: `gpg --list-keys "Secure Vault"`

### If Not Set Up

1. **Run the automated setup:**
   ```bash
   git clone https://github.com/godofecht/device-setup.git ~/device-setup
   cd ~/device-setup
   chmod +x setup.sh
   ./setup.sh
   ```

2. **Or follow manual steps:**

   a. Install dependencies (Termux):
   ```bash
   pkg install gh git gnupg openssh
   ```

   b. Authenticate GitHub:
   ```bash
   gh auth login -p ssh
   ```

   c. Import GPG key from backup:
   ```bash
   gpg --import ~/vault-private-key-backup.asc
   ```

   d. Clone secure vault:
   ```bash
   gh repo clone godofecht/secure-vault ~/secure-vault
   ```

   e. Verify decryption works:
   ```bash
   gpg --decrypt ~/secure-vault/credentials.gpg
   ```

## Credentials Access

Once set up, credentials can be accessed via:

```bash
# Decrypt and view
gpg --decrypt ~/secure-vault/credentials.gpg

# Decrypt to file
gpg --decrypt ~/secure-vault/credentials.gpg > ~/credentials.txt

# Use in scripts
PASSWORD=$(gpg --decrypt ~/secure-vault/credentials.gpg 2>/dev/null | grep "Password:" | head -1 | cut -d: -f2 | tr -d ' ')
```

## Security Notes

- ⚠️ **NEVER** commit the GPG private key to any repository
- ⚠️ **NEVER** paste decrypted credentials in chat with AI agents
- ✅ The encrypted `credentials.gpg` file is safe to sync across devices
- ✅ The public key (`vault-public-key.asc`) is safe to share

## Troubleshooting for Agents

| Issue | Solution |
|-------|----------|
| `gh: command not found` | Install via `pkg install gh` or package manager |
| `gpg: decryption failed: No secret key` | Import private key: `gpg --import ~/vault-private-key-backup.asc` |
| `git: permission denied` | Fix with `chmod +x /data/data/com.termux/files/usr/libexec/git-core/*` |
| SSH connection fails | Run `ssh-keyscan github.com >> ~/.ssh/known_hosts` |

## Verification Commands

After setup, verify everything works:

```bash
# GitHub CLI
gh auth status
gh repo view godofecht/secure-vault

# GPG
gpg --list-keys "Secure Vault"
gpg --decrypt ~/secure-vault/credentials.gpg | head -5

# Git
git config --global user.name
git config --global user.email
```

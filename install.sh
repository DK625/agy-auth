#!/usr/bin/env bash
set -e

# =========================================================
# agi-auth Installer for Linux / macOS / WSL
# =========================================================

INSTALL_DIR="$HOME/.agi-auth"
BIN_DIR="$HOME/.local/bin"
TIMESTAMP=$(date +%s)
RAW_URL="https://raw.githubusercontent.com/DK625/agy-auth/main/bin/agi-auth?t=$TIMESTAMP"

echo -e "\033[1;36m==>\033[0m \033[1mInstalling / Updating agi-auth & agi shortcut...\033[0m"

# Create directories
mkdir -p "$INSTALL_DIR/bin"
mkdir -p "$BIN_DIR"
mkdir -p "$HOME/.gemini/accounts"

# Download binary (bypassing CDN cache)
if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$RAW_URL" -o "$INSTALL_DIR/bin/agi-auth"
elif command -v wget >/dev/null 2>&1; then
    wget -qO "$INSTALL_DIR/bin/agi-auth" "$RAW_URL"
else
    echo -e "\033[91m[Error] Neither curl nor wget found.\033[0m"
    exit 1
fi

chmod +x "$INSTALL_DIR/bin/agi-auth"
ln -sf "$INSTALL_DIR/bin/agi-auth" "$BIN_DIR/agi-auth"

# Setup Shell Profile (bash / zsh)
CONFIG_LINES="
# --- agi & agi-auth ---
export PATH=\"\$HOME/.local/bin:\$HOME/.agi-auth/bin:\$PATH\"
alias agi='agy --dangerously-skip-permissions'
"

for RC in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.bash_profile"; do
    if [ -f "$RC" ]; then
        if ! grep -q "agi-auth" "$RC"; then
            echo "$CONFIG_LINES" >> "$RC"
        fi
    fi
done

echo -e "\033[1;32m==> Installation / Update successful!\033[0m"
echo ""
echo -e "\033[1mUsage:\033[0m"
echo -e "  \033[36magi-auth login\033[0m          - Direct Google OAuth login & auto-save by Email"
echo -e "  \033[36magi-auth list\033[0m           - List all saved accounts, Email & Quota (5h/weekly)"
echo -e "  \033[36magi-auth switch <email>\033[0m - Switch to saved account (by Email or Alias)"
echo -e "  \033[36magi-auth remove <email>\033[0m - Remove a saved account"
echo -e "  \033[36magi\033[0m                     - Run agy with --dangerously-skip-permissions"
echo ""
echo -e "\033[90mRestart your terminal or run: source ~/.bashrc (or ~/.zshrc)\033[0m"

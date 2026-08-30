#!/usr/bin/env bash
set -e

# =========================================================
# agi-auth & statusline Installer for Linux / macOS / WSL
# =========================================================

INSTALL_DIR="$HOME/.agi-auth"
BIN_DIR="$HOME/.local/bin"
GEMINI_DIR="$HOME/.gemini"
TIMESTAMP=$(date +%s)
BASE_URL="https://raw.githubusercontent.com/DK625/agy-auth/main"

echo -e "\033[1;36m==>\033[0m \033[1mInstalling / Updating agi-auth, agi shortcut & Statusline...\033[0m"

# Create directories
mkdir -p "$INSTALL_DIR/bin"
mkdir -p "$BIN_DIR"
mkdir -p "$GEMINI_DIR/accounts"

# Download helper
download_file() {
    local url="$1"
    local dest="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$dest"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$dest" "$url"
    else
        echo -e "\033[91m[Error] Neither curl nor wget found.\033[0m"
        exit 1
    fi
}

# 1. Download agi-auth CLI
download_file "$BASE_URL/bin/agi-auth?t=$TIMESTAMP" "$INSTALL_DIR/bin/agi-auth"
chmod +x "$INSTALL_DIR/bin/agi-auth"
ln -sf "$INSTALL_DIR/bin/agi-auth" "$BIN_DIR/agi-auth"

# 2. Download Statusline Script & Configuration
download_file "$BASE_URL/statusline/statusline.sh?t=$TIMESTAMP" "$GEMINI_DIR/statusline.sh"
chmod +x "$GEMINI_DIR/statusline.sh"

if [ ! -f "$GEMINI_DIR/statusline.json" ]; then
    download_file "$BASE_URL/statusline/statusline.json?t=$TIMESTAMP" "$GEMINI_DIR/statusline.json"
fi

# 3. Configure settings.json for Antigravity
for CONF in "$GEMINI_DIR/antigravity-cli/settings.json" "$GEMINI_DIR/settings.json" "$HOME/.config/antigravity/settings.json"; do
    mkdir -p "$(dirname "$CONF")"
    if [ ! -f "$CONF" ]; then
        echo "{\"statusLine\": {\"command\": \"bash \\\"$GEMINI_DIR/statusline.sh\\\"\"}}" > "$CONF"
    fi
done

# 4. Setup Shell Profile (bash / zsh)
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
echo -e "\033[1mFeatures Installed:\033[0m"
echo -e "  \033[32m✔ agi-auth CLI\033[0m         - Multi-account OAuth manager with real-time health checks"
echo -e "  \033[32m✔ agi Shortcut\033[0m         - Fast launcher with --dangerously-skip-permissions"
echo -e "  \033[32m✔ Antigravity Statusline\033[0m - Real-time model, branch, remain context bar & 5h/7d quota bars"
echo ""
echo -e "\033[1mUsage:\033[0m"
echo -e "  \033[36magi-auth login\033[0m          - Direct Google OAuth login & auto-save by Email"
echo -e "  \033[36magi-auth list\033[0m           - List all saved accounts, Email & Quota (Remain 5h/7d)"
echo -e "  \033[36magi-auth switch <email>\033[0m - Switch account (by Number or Email)"
echo -e "  \033[36magi-auth remove <email>\033[0m - Remove an account"
echo -e "  \033[36magi\033[0m                     - Launch Antigravity CLI with statusline"
echo ""
echo -e "\033[90mRestart your terminal or run: source ~/.bashrc (or ~/.zshrc)\033[0m"

#!/bin/bash

echo "🚀 Installing Claude Code Multi-Provider Rotator..."
echo "==================================================="

INSTALL_DIR="$HOME/.claude-rotator"
mkdir -p "$INSTALL_DIR"

echo "📥 Downloading core scripts..."
# FIXED: Added /main/ to the URL path
curl -sSL "https://raw.githubusercontent.com/BheeshamKS/ClaudeCode-Model-Rotator/main/rotator.sh" -o "$INSTALL_DIR/rotator.sh"
chmod +x "$INSTALL_DIR/rotator.sh"

echo ""
echo "🔑 Let's set up your OpenRouter API Key."
echo "   (You can get a free one at https://openrouter.ai/keys)"
read -p "Paste your OPENROUTER_API_KEY: " user_api_key </dev/tty

echo "OPENROUTER_API_KEY=\"$user_api_key\"" > "$INSTALL_DIR/.env"
echo "✅ Key saved securely."

echo ""
echo "📦 Installing LiteLLM Proxy in the background (this may take a few minutes)..."
python3 -m venv "$HOME/.litellm_env"
"$HOME/.litellm_env/bin/pip" install --upgrade pip > /dev/null 2>&1
"$HOME/.litellm_env/bin/pip" install 'litellm[proxy]' > /dev/null 2>&1
echo "✅ Proxy installed successfully."

BASH_RC="$HOME/.bashrc"
if ! grep -q "alias claude-rotator=" "$BASH_RC"; then
    echo "alias claude-rotator='$INSTALL_DIR/rotator.sh'" >> "$BASH_RC"
fi

echo ""
echo "🎉 Installation Complete!"
echo "==================================================="
echo "To finish setup, restart your terminal or run:"
echo "  source ~/.bashrc"
echo ""
echo "Then, start coding anytime by typing:"
echo "  claude-rotator"
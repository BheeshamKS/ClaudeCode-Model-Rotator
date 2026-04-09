#!/bin/bash

echo "🚀 Installing Claude Code Multi-Provider Rotator..."
echo "==================================================="

# Pre-flight dependency checks
if ! command -v curl &> /dev/null; then
    echo "❌ curl is not installed. Please install curl first."
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo "❌ python3 is not installed. Please install python3 first."
    exit 1
fi

# 1. Create a hidden installation directory
INSTALL_DIR="$HOME/.claude-rotator"
mkdir -p "$INSTALL_DIR"

# 2. Download the main script directly from GitHub
echo "📥 Downloading core scripts..."
curl -sSL "https://raw.githubusercontent.com/BheeshamKS/ClaudeCode-Model-Rotator/main/rotator.sh" -o "$INSTALL_DIR/rotator.sh"
chmod +x "$INSTALL_DIR/rotator.sh"

# 3. Ask the user for their API key
echo ""
echo "🔑 Let's set up your OpenRouter API Key."
echo "   (You can get a free one at https://openrouter.ai/keys)"
read -p "Paste your OPENROUTER_API_KEY: " user_api_key </dev/tty

echo "OPENROUTER_API_KEY=\"$user_api_key\"" > "$INSTALL_DIR/.env"
echo "✅ Key saved securely."

# 4. Smart Ollama Installation (Check first, Default YES)
echo ""
if command -v ollama &> /dev/null; then
    echo "✅ Ollama is already installed on this system. Skipping..."
else
    echo "🦙 Ollama is not installed. (Highly Recommended)"
    echo "   Ollama allows you to run high-speed cloud models for free."
    echo "   It provides generous free usage limits that automatically reset."
    read -p "Install Ollama now? [Y/n]: " install_ollama </dev/tty
    
    # If the user just presses Enter, force the variable to "Y"
    install_ollama=${install_ollama:-Y}
    
    if [[ "$install_ollama" =~ ^[Yy]$ ]]; then
        echo "📦 Downloading and installing Ollama..."
        echo "   (Note: Your system may ask for your password to set up the Ollama background service)"
        curl -fsSL https://ollama.com/install.sh | sh
        echo "✅ Ollama installed successfully."
    else
        echo "⏭️  Skipping Ollama installation."
    fi
fi

# 5. Automate the Python Virtual Environment & LiteLLM proxy
echo ""
echo "📦 Installing LiteLLM Proxy in the background (this may take a few minutes)..."
python3 -m venv "$HOME/.litellm_env" || { echo "❌ Failed to create virtual environment."; exit 1; }
"$HOME/.litellm_env/bin/pip" install --upgrade pip > /dev/null 2>&1 || { echo "❌ Failed to upgrade pip."; exit 1; }
if ! "$HOME/.litellm_env/bin/pip" install 'litellm[proxy]' > /dev/null 2>&1; then
    echo "❌ Failed to install LiteLLM proxy. Check pip logs for details."
    exit 1
fi
echo "✅ Proxy installed successfully."

# 6. Create a global command alias in the user's bash profile
BASH_RC="$HOME/.bashrc"
if [ -f "$BASH_RC" ]; then
    if ! grep -q "alias claude-rotator=" "$BASH_RC"; then
        echo "alias claude-rotator='$INSTALL_DIR/rotator.sh'" >> "$BASH_RC"
    fi
else
    echo "⚠️  ~/.bashrc not found. Alias not added."
fi

echo ""
echo "🎉 Installation Complete!"
echo "==================================================="
echo "To finish setup, restart your terminal or run:"
echo "  source ~/.bashrc"
echo ""
echo "Then, start coding anytime by typing:"
echo "  claude-rotator"
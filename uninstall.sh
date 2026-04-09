#!/bin/bash

echo "🗑️  Uninstalling Claude Code Multi-Provider Rotator..."
echo "==================================================="

# 1. Clear custom API keys from Claude config (restore web login)
if command -v node &> /dev/null; then
    node -e '
    const fs = require("fs");
    const file = process.env.HOME + "/.claude.json";
    if (fs.existsSync(file)) {
        try {
            const data = JSON.parse(fs.readFileSync(file));
            delete data.customApiKey;
            fs.writeFileSync(file, JSON.stringify(data, null, 2));
        } catch(e) {}
    }'
fi

# 2. Delete the Rotator folder and the hidden LiteLLM proxy environment
rm -rf ~/.claude-rotator
rm -rf ~/.litellm_env
rm -f ~/.litellm_config.yaml

# 3. Remove the alias from shell profile
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS uses zsh by default
    SHELL_RC="$HOME/.zshrc"
    SED_INPLACE=(-i '')
else
    SHELL_RC="$HOME/.bashrc"
    SED_INPLACE=(-i)
fi

if [ -f "$SHELL_RC" ]; then
    sed "${SED_INPLACE[@]}" '/alias claude-rotator/d' "$SHELL_RC"
fi

echo "🗑️ Claude Code Rotator has been completely removed."
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "   Restart your terminal or run: source ~/.zshrc"
else
    echo "   Restart your terminal or run: source ~/.bashrc"
fi
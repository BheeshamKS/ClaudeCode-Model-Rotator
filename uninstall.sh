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

# 3. Remove the alias from their bash profile
if [ -f ~/.bashrc ]; then
    sed -i '/alias claude-rotator/d' ~/.bashrc
fi

echo "🗑️ Claude Code Rotator has been completely removed."
echo "   Restart your terminal or run: source ~/.bashrc"
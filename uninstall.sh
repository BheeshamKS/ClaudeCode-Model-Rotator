# 1. Restore the official Anthropic token (just in case they uninstall while the proxy is active)
[ -f ~/.claude.json.real ] && mv ~/.claude.json.real ~/.claude.json
[ -d ~/.claude.real ] && mv ~/.claude.real ~/.claude

# 2. Delete the Rotator folder and the hidden LiteLLM proxy environment
rm -rf ~/.claude-rotator
rm -rf ~/.litellm_env

# 3. Remove the alias from their bash profile
sed -i '/alias claude-rotator/d' ~/.bashrc

# 4. Reload the terminal
source ~/.bashrc

echo "🗑️ Claude Code Rotator has been completely removed."
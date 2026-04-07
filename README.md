# 🔄 Claude Code Multi-Provider Rotator
A lightweight, automated wrapper for the official Claude Code TUI.

By default, Anthropic's Claude Code locks you into their ecosystem. This tool uses a dynamic LiteLLM proxy and "Ghost Config" authentication to completely bypass the Anthropic firewall, allowing you to seamlessly code using free local models via Ollama Cloud and high-context free models via OpenRouter.

### ✨ Features
- Zero-Touch Proxy: Automatically builds and spins up a hidden Python translation server in the background and kills it when you exit.

- Ghost Config: Safely hides your official Anthropic web session so you don't lose your login when switching to free APIs.

- Native Ollama Support: Direct routing to Ollama Cloud for high-speed local models.

- Noob-Friendly Installer: Sets up everything, including the virtual environment and global terminal aliases, with one command.

.

## 🐧 OS Support: Native Linux (Ubuntu/Debian) or Windows via WSL2.
### 🚀 1-Click Installation (Recommended)

Open your terminal and paste this command:

```Bash
curl -sSL https://raw.githubusercontent.com/BheeshamKS/ClaudeCode-Model-Rotator/main/install.sh | bash
```

### During installation:

- The script downloads core files and checks for Ollama.

- It will ask for your OpenRouter API Key (Get it free at openrouter.ai).

- It builds the translation proxy and sets up the claude-rotator command.

## 💻 How to Use
Type this in any project folder:

```Bash
claude-rotator
```
⚠️ IMPORTANT: Authentication & Setup
Ignore the Auth Error: If you see a warning about authentication or "sk-ant-dummy" during the first run, it is nothing to worry about. This is a necessary part of how the proxy intercepts the request. Everything works fine.

First-Time Setup: When you use a new provider, Claude might ask you to choose a theme or confirm a custom API key. Just follow the prompts (select 1. Yes for custom keys) and you'll be dropped into the terminal.

## 🤖 Supported Models
This rotator is pre-configured with the best free coding models currently available that can handle Claude Code's massive background tool payloads.

### Ollama Cloud:

`qwen3.5:cloud`

`kimi-k2.5:cloud`

`glm-5:cloud`

`minimax-m2.7:cloud`

### OpenRouter (Free Tier):

`qwen/qwen3.6-plus:free`

`nvidia/nemotron-3-super-120b-a12b:free`

`stepfun/step-3.5-flash:free`

`arcee-ai/trinity-large-preview:free`

## 🛠️ Troubleshooting
"I keep getting Auth Conflicts!"
If you ever manually force-quit the terminal and the rotator didn't have time to clean up, your official Anthropic login might still be hidden. Just run `claude-rotator`, select Option 4 (Fix Auth Conflict), and your official login will be instantly restored.

"Where are my API keys saved?"
The installer securely saves your API keys in a hidden file located at `~/.claude-rotator/.env.` You can edit this file anytime if you need to update your OpenRouter key.

## How to Uninstall the Tool completely

run
```Bash
curl -sSL https://github.com/BheeshamKS/ClaudeCode-Model-Rotator/uninstall.sh | bash
```
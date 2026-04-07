# 🔄 Claude Code Multi-Provider Rotator
A lightweight, automated wrapper for the official Claude Code TUI.

By default, Anthropic's Claude Code locks you into their ecosystem. This tool uses a dynamic LiteLLM proxy and "Ghost Config" authentication to completely bypass the Anthropic firewall, allowing you to seamlessly code using free local models via Ollama Cloud and high-context free models via OpenRouter.

### ✨ Features
- Zero-Touch Proxy: Automatically builds and spins up a hidden Python translation server in the background and kills it when you exit.

- Ghost Config: Safely hides your official Anthropic web session so you don't lose your login when switching to free APIs.

- Native Ollama Support: Direct routing to Ollama Cloud for high-speed local models.

- Noob-Friendly Installer: Sets up everything, including the virtual environment and global terminal aliases, with one command.

## 🚀 1-Click Installation (Recommended)
You don't need to manually configure Python environments or edit configuration files. Just open your terminal and paste this single command:

```Bash
curl -sSL https://github.com/BheeshamKS/ClaudeCode-Model-Rotator/install.sh | bash
```

During installation:

- The script will download the core files.

- It will ask you to paste your OpenRouter API Key.

- It will quietly build the translation proxy in the background.

- Once it finishes, just restart your terminal!

## 💻 How to Use
Whenever you want to start coding, just open your terminal in your project folder and type:

```Bash
claude-rotator
```
You will be greeted with an interactive menu to select your provider and model.

⚠️ IMPORTANT: The "Dummy Key" Prompt
When you select OpenRouter, Claude Code will pop up a security warning asking if you want to use a custom API key called sk-ant-dummy.

You MUST select 1. Yes. This is a fake key we use to trick Claude into opening its doors. Once you hit Yes, our hidden proxy catches the fake key, throws it in the trash, attaches your real OpenRouter key, and connects you to the free models!

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
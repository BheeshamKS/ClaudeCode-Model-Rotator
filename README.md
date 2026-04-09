# 🔄 Claude Code Multi-Provider Rotator
A lightweight, automated wrapper for the official Claude Code TUI.

By default, Anthropic's Claude Code locks you into their ecosystem. This tool uses a dynamic LiteLLM proxy and "Ghost Config" authentication to completely bypass the Anthropic firewall, allowing you to seamlessly code using free local models via Ollama Cloud and high-context free models via OpenRouter.

### ✨ Features
- **Zero-Touch Proxy:** Automatically builds and spins up a hidden Python translation server in the background and kills it when you exit.

- **Ghost Config:** Safely hides your official Anthropic web session so you don't lose your login when switching to free APIs.

- **Native Ollama Support:** Direct routing to Ollama Cloud for high-speed local models.

- **Noob-Friendly Installer:** Sets up everything, including the virtual environment and global terminal aliases, with one command.

---

## 💻 OS Support

| OS | Status | Notes |
|---|---|---|
| Linux (Ubuntu/Debian) | Native | Works out of the box |
| macOS | Native | Works out of the box |
| Windows | Via WSL2 | Run inside a WSL terminal |

### Windows Setup (WSL2)
Your script is bash-based and won't run in a regular Windows terminal (CMD or PowerShell). The fix is WSL — it gives you a real Linux terminal inside Windows.

1. Open PowerShell as Administrator and run:
   ```
   wsl --install
   ```
2. Restart your PC, then open the **Ubuntu** app from the Start Menu.
3. Run the installer command below inside that Ubuntu terminal — everything works identically to Linux.

---

## 🚀 Installation

### Linux & macOS
Open your terminal and paste:

```bash
curl -sSL https://raw.githubusercontent.com/BheeshamKS/ClaudeCode-Model-Rotator/main/install.sh | bash
```

### Windows
Open your **WSL/Ubuntu terminal** and paste the same command:

```bash
curl -sSL https://raw.githubusercontent.com/BheeshamKS/ClaudeCode-Model-Rotator/main/install.sh | bash
```

### During installation:
- The script downloads core files and checks for Ollama.
- It will ask for your OpenRouter API Key (get one free at [openrouter.ai](https://openrouter.ai/keys)).
- It builds the translation proxy and sets up the `claude-rotator` command.

---

## 🖥️ How to Use
Type this in any project folder:

```bash
claude-rotator
```

> **Auth Warning:** If you see a warning about "sk-ant-dummy" or authentication on first run, ignore it — this is expected. The proxy intercepts the request and everything works fine.

> **First-Time Setup:** When using a new provider, Claude may ask you to confirm a custom API key. Select **1. Yes** and you'll be dropped into the terminal.

---

## 🤖 Supported Models
Pre-configured with the best free coding models that can handle Claude Code's massive background tool payloads.

### Ollama Cloud:
- `qwen3.5:cloud`
- `kimi-k2.5:cloud`
- `glm-5:cloud`
- `minimax-m2.7:cloud`

### OpenRouter (Free Tier):
- `qwen/qwen3.6-plus:free`
- `nvidia/nemotron-3-super-120b-a12b:free`
- `stepfun/step-3.5-flash:free`
- `arcee-ai/trinity-large-preview:free`

---

## 🛠️ Troubleshooting

**"I keep getting Auth Conflicts!"**
If you force-quit the terminal before the rotator could clean up, your official Anthropic login might still be hidden. Run `claude-rotator` and select **Option 4 (Fix Auth Conflict)** to instantly restore it.

**"Where are my API keys saved?"**
Your API keys are stored in `~/.claude-rotator/.env`. Edit this file anytime to update your OpenRouter key.

---

## 🗑️ Uninstall

```bash
curl -sSL https://raw.githubusercontent.com/BheeshamKS/ClaudeCode-Model-Rotator/main/uninstall.sh | bash
```

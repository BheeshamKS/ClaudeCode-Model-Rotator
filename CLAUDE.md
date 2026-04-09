# Claude Code Multi-Provider Rotator - Project Guide

## Project Overview
A bash-based wrapper that enables Claude Code TUI to work with multiple AI providers (Ollama Cloud, OpenRouter) by using a LiteLLM proxy and dynamic authentication management.

## Core Architecture

### Files
- `rotator.sh` - Main launcher script with provider selection and proxy management
- `install.sh` - One-click installer for setup and dependencies
- `uninstall.sh` - Complete removal script
- `.env` - API key storage (created at `~/.claude-rotator/.env`)

### Key Components

**1. Proxy Management**
- LiteLLM proxy runs on `http://0.0.0.0:4000`
- Started on-demand for OpenRouter mode
- Auto-killed on exit via `trap cleanup EXIT`

**2. Authentication Strategy**
- "Ghost Config": Hides official Anthropic session during proxy use
- Uses dummy key (`sk-ant-dummy`) with custom `ANTHROPIC_BASE_URL`
- Clears `~/.claude.json` custom keys to restore web login

**3. Provider Modes**
| Option | Provider | Auth Method |
|--------|----------|-------------|
| 1 | Official Claude | Default Anthropic auth |
| 2 | Ollama Cloud | Native `ollama launch claude` |
| 3 | OpenRouter | LiteLLM proxy + dummy key |

## Development Notes

### Environment Variables
- `ANTHROPIC_BASE_URL` - Override for API endpoint
- `ANTHROPIC_API_KEY` - API key (dummy for proxy mode)
- `OPENROUTER_API_KEY` - Stored in `~/.claude-rotator/.env`

### Configuration Files
- `~/.claude-rotator/.env` - User API keys
- `~/.litellm_config.yaml` - LiteLLM model routing (generated at runtime)
- `~/.claude.json` - Claude Code session (modified for auth switching)
- `~/.bashrc` - Global alias: `alias claude-rotator='$HOME/.claude-rotator/rotator.sh'`

### Supported Models (Pre-configured)
**Ollama Cloud:** `qwen3.5:cloud`, `kimi-k2.5:cloud`, `glm-5:cloud`, `minimax-m2.7:cloud`

**OpenRouter Free:** `qwen/qwen3.6-plus:free`, `nvidia/nemotron-3-super-120b-a12b:free`, `stepfun/step-3.5-flash:free`, `arcee-ai/trinity-large-preview:free`

## Common Issues
- **Auth Conflict:** Run Option 4 to restore official login
- **Proxy Stuck:** Kill process on port 4000 manually
- **Missing .env:** Re-run installer

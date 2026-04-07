#!/bin/bash

# ==========================================
# 0. AUTH & PROXY MANAGEMENT ("PROFILE SWAPPER")
# ==========================================
AUTH_FILE="$HOME/.claude.json"
AUTH_DIR="$HOME/.claude"
STATE_FLAG="$HOME/.claude-rotator.active"
PROXY_PID=""

hide_web_token() {
    # Only swap if we aren't already in proxy mode
    if [ ! -f "$STATE_FLAG" ]; then
        echo "🛡️  Switching to Proxy Profile..."
        
        # 1. Save the official Anthropic login safely
        [ -f "$AUTH_FILE" ] && mv "$AUTH_FILE" "$AUTH_FILE.real"
        [ -d "$AUTH_DIR" ] && mv "$AUTH_DIR" "$AUTH_DIR.real"

        # 2. Load the Proxy memory if it exists. 
        # (If it doesn't exist, Claude stays blank and asks for setup)
        [ -f "$AUTH_FILE.proxy" ] && mv "$AUTH_FILE.proxy" "$AUTH_FILE"
        [ -d "$AUTH_DIR.proxy" ] && mv "$AUTH_DIR.proxy" "$AUTH_DIR"

        touch "$STATE_FLAG"
    fi
}

restore_web_token() {
    # Only restore if we are currently in proxy mode
    if [ -f "$STATE_FLAG" ]; then
        echo "🔓 Saving setup and restoring Official Claude session..."
        
        # 1. Snapshot the current state! 
        # (When you exit Claude, this permanently saves your Yes/No choice)
        [ -f "$AUTH_FILE" ] && mv "$AUTH_FILE" "$AUTH_FILE.proxy"
        [ -d "$AUTH_DIR" ] && mv "$AUTH_DIR" "$AUTH_DIR.proxy"

        # 2. Restore the official Anthropic login
        [ -f "$AUTH_FILE.real" ] && mv "$AUTH_FILE.real" "$AUTH_FILE"
        [ -d "$AUTH_DIR.real" ] && mv "$AUTH_DIR.real" "$AUTH_DIR"

        rm -f "$STATE_FLAG"
    fi
}

cleanup() {
    restore_web_token
    if [ -n "$PROXY_PID" ]; then
        echo "🛑 Shutting down LiteLLM proxy..."
        kill $PROXY_PID 2>/dev/null
    fi
}
trap cleanup EXIT

# ==========================================
# 1. LOAD API KEYS
# ==========================================
# Load from the installer's .env file
if [ -f "$HOME/.claude-rotator/.env" ]; then
    set -a; source "$HOME/.claude-rotator/.env"; set +a
else
    echo "❌ Error: .env file not found! Run the installer again."
    exit 1
fi

export OPENROUTER_API_KEY=$(echo "$OPENROUTER_API_KEY" | tr -d '"' | tr -d "'")

# ==========================================
# 2. MODELS
# ==========================================
OLLAMA_MODELS=(
    "qwen3.5:cloud"
    "kimi-k2.5:cloud"
    "glm-5:cloud"
    "minimax-m2.7:cloud"
)

OPENROUTER_MODELS=(
    "qwen/qwen3.6-plus:free"
    "nvidia/nemotron-3-super-120b-a12b:free"
    "stepfun/step-3.5-flash:free"
    "arcee-ai/trinity-large-preview:free"
)

# ==========================================
# 3. INTERACTIVE MENU
# ==========================================
clear
echo "🔄 Claude Code TUI - Multi-Provider Rotator"
echo "-------------------------------------------"
echo "1) Official Claude (Anthropic Web)"
echo "2) Ollama Cloud"
echo "3) OpenRouter (via LiteLLM Proxy)"
echo "4) 🛠️  Fix Auth Conflict (Restore Web Token)"
echo "5) Exit"
read -p "Select Provider [1-5]: " provider_choice

case $provider_choice in
    1)
        echo -e "\n🚀 Launching Official Claude..."
        restore_web_token
        unset ANTHROPIC_BASE_URL
        unset ANTHROPIC_API_KEY
        claude
        ;;
    2)
        echo -e "\n☁️  Available Ollama Cloud Models:"
        select model in "${OLLAMA_MODELS[@]}"; do
            if [[ -n $model ]]; then
                echo -e "\n🚀 Launching Ollama Cloud: $model"
                restore_web_token
                unset ANTHROPIC_BASE_URL
                unset ANTHROPIC_API_KEY
                ollama launch claude --model "$model"
                break
            else
                echo "Invalid selection."
            fi
        done
        ;;
    3)
        echo -e "\n🌐 Available OpenRouter Models:"
        select model in "${OPENROUTER_MODELS[@]}"; do
            if [[ -n $model ]]; then
                echo -e "\n⚙️  Configuring Proxy Firewall..."
                hide_web_token
                
                if [[ "$model" != openrouter/* ]]; then
                    target_model="openrouter/$model"
                else
                    target_model="$model"
                fi

                cat <<EOF > ~/.litellm_config.yaml
model_list:
  - model_name: "$model"
    litellm_params:
      model: "$target_model"
      api_key: "$OPENROUTER_API_KEY"
EOF
                
                echo "⚙️  Booting LiteLLM Translation Server..."
                ~/.litellm_env/bin/litellm --config ~/.litellm_config.yaml --port 4000 > /dev/null 2>&1 &
                PROXY_PID=$!
                sleep 3
                
                echo "🚀 Launching OpenRouter in Claude Code..."
                export ANTHROPIC_BASE_URL="http://0.0.0.0:4000"
                export ANTHROPIC_API_KEY="sk-ant-dummy"
                
                claude --model "$model"
                break
            else
                echo "Invalid selection."
            fi
        done
        ;;
    4)
        restore_web_token
        echo "✅ Official Claude login restored."
        ;;
    5)
        exit 0
        ;;
    *)
        echo "Invalid choice. Exiting."
        ;;
esac
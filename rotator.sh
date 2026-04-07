#!/bin/bash

# ==========================================
# 0. PROXY MANAGEMENT & SURGICAL AUTH
# ==========================================
PROXY_PID=""

# SURGICAL STRIKE: Instead of hiding the whole config file (which causes Claude 
# to delete the OS Keychain token), we use Node.js to surgically delete ONLY 
# the dummy key right before you want to use the Official Web Login.
clear_custom_keys() {
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
}

cleanup() {
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
echo "4) 🛠️  Clear Custom API Keys (Restore Web Login)"
echo "5) Exit"
read -p "Select Provider [1-5]: " provider_choice

case $provider_choice in
    1)
        echo -e "\n🚀 Launching Official Claude..."
        # Surgically remove the dummy key so it falls back to your OS Keychain web login
        clear_custom_keys
        unset ANTHROPIC_BASE_URL
        unset ANTHROPIC_API_KEY
        claude
        ;;
    2)
        # SAFETY CHECK: Is Ollama actually installed?
        if ! command -v ollama &> /dev/null; then
            echo -e "\n❌ Ollama is not installed on this machine."
            echo "   To use local/cloud models, please install Ollama first:"
            echo "   👉 Download: https://ollama.com/download"
            echo -e "\nExiting."
            exit 1
        fi

        echo -e "\n☁️  Available Ollama Cloud Models:"
        select model in "${OLLAMA_MODELS[@]}"; do
            if [[ -n $model ]]; then
                echo -e "\n🚀 Launching Ollama Cloud: $model"
                clear_custom_keys
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
        clear_custom_keys
        echo "✅ Custom keys cleared. Your Official Claude login is ready."
        ;;
    5)
        exit 0
        ;;
    *)
        echo "Invalid choice. Exiting."
        ;;
esac
#!/bin/bash

# ==========================================
# 0. PROXY MANAGEMENT & SURGICAL AUTH
# ==========================================
PROXY_PID=""

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
if [ -f "$HOME/.claude-rotator/.env" ]; then
    set -a; source "$HOME/.claude-rotator/.env"; set +a
else
    echo "❌ Error: .env file not found! Run the installer again."
    exit 1
fi

OPENROUTER_API_KEY=$(echo "$OPENROUTER_API_KEY" | tr -d '"' | tr -d "'")
export OPENROUTER_API_KEY

# ==========================================
# 2. OPENROUTER MODELS
# ==========================================
OPENROUTER_MODELS=(
    "qwen/qwen3.6-plus:free"
    "nvidia/nemotron-3-super-120b-a12b:free"
    "stepfun/step-3.5-flash:free"
    "arcee-ai/trinity-large-preview:free"
)

# ==========================================
# 3. TUI MENU WITH ARROW KEY NAVIGATION
# ==========================================

# Terminal setup
cleanup_tui() {
    show_cursor
    tput sgr0
    tput rmcup  # Exit alternate screen
}
trap cleanup_tui EXIT
trap cleanup EXIT

hide_cursor() { tput civis; }
show_cursor() { tput cnorm; }
clear_screen() { tput clear; tput home; }

# Main menu options
MENU_OPTIONS=(
    "Official Claude (Anthropic Web)"
    "Ollama (Native Launcher)"
    "OpenRouter (via LiteLLM Proxy)"
    "Clear Custom API Keys (Restore Web Login)"
)

# OpenRouter model selection
OPENROUTER_MODEL_OPTIONS=("${OPENROUTER_MODELS[@]}")

render_menu() {
    clear_screen
    hide_cursor

    # ASCII Art
    echo -e "\e[36m"
    echo "  ████ ████  ████  ████ █████ ████ █████ ████ ████ "
    echo "  █    █     █  █  █  █   █   █  █   █   █  █ █  █ "
    echo "  █    █     █ █   █  █   █   ████   █   █  █ █ █  "
    echo "  ████ ████  █  █  ████   █   █  █   █   ████ █  █ "         
    echo -e "\e[90m  ────────────────────────────────────────────────\e[0m"
    echo ""

    for i in "${!MENU_OPTIONS[@]}"; do
        if [ $i -eq $selected ]; then
            echo -e "  \e[36m❯ \e[1m${MENU_OPTIONS[$i]}\e[0m"
        else
            echo -e "  \e[90m  ${MENU_OPTIONS[$i]}\e[0m"
        fi
    done

    echo ""
    echo -e "\e[90m  ↑/↓ Navigate  •  Enter Select  •  q Quit\e[0m"
    echo ""
}

render_model_selector() {
    clear_screen
    hide_cursor
    echo -e "🌐 \e[1mSelect OpenRouter Model\e[0m"
    echo -e "\e[90m─────────────────────────────────────────────\e[0m"
    echo ""

    for i in "${!OPENROUTER_MODEL_OPTIONS[@]}"; do
        if [ $i -eq $model_selected ]; then
            echo -e "  \e[36m❯ \e[1m${OPENROUTER_MODEL_OPTIONS[$i]}\e[0m"
        else
            echo -e "  \e[90m  ${OPENROUTER_MODEL_OPTIONS[$i]}\e[0m"
        fi
    done

    echo ""
    echo -e "\e[90m  ↑/↓ Navigate  •  Enter Select  •  q Back\e[0m"
}

# Handle key input
handle_menu_key() {
    case "$1" in
        $'\x1b[A') # Up arrow
            ((selected--))
            [ $selected -lt 0 ] && selected=$((${#MENU_OPTIONS[@]} - 1))
            ;;
        $'\x1b[B') # Down arrow
            ((selected++))
            [ $selected -ge ${#MENU_OPTIONS[@]} ] && selected=0
            ;;
        $'\x1b[C') # Right arrow - treat as enter
            return 0
            ;;
        $'\x1b[D') # Left arrow - treat as back
            return 1
            ;;
        $'') # Enter
            return 0
            ;;
        q|Q) # Quit
            show_cursor
            exit 0
            ;;
    esac
    return 1
}

handle_model_key() {
    case "$1" in
        $'\x1b[A') # Up arrow
            ((model_selected--))
            [ $model_selected -lt 0 ] && model_selected=$((${#OPENROUTER_MODEL_OPTIONS[@]} - 1))
            ;;
        $'\x1b[B') # Down arrow
            ((model_selected++))
            [ $model_selected -ge ${#OPENROUTER_MODEL_OPTIONS[@]} ] && model_selected=0
            ;;
        $'') # Enter
            return 0
            ;;
        q|Q) # Back to main menu
            return 1
            ;;
    esac
    return 1
}

# Enter alternate screen and start
tput smcup  # Enter alternate screen
clear_screen
hide_cursor

# Main menu loop
selected=0
render_menu

while IFS= read -r -n 1 key; do
    read -r -t 0.03 -n 2 extra 2>/dev/null || true
    full_key="${key}${extra}"

    if handle_menu_key "$full_key"; then
        break
    fi
    render_menu
done

clear
show_cursor

# Execute selected option
case $selected in
    0)
        echo -e "\n🚀 Launching Official Claude..."
        clear_custom_keys
        unset ANTHROPIC_BASE_URL
        unset ANTHROPIC_API_KEY
        claude
        ;;
    1)
        if ! command -v ollama &> /dev/null; then
            echo -e "\n❌ Ollama is not installed."
            exit 1
        fi

        echo -e "\n🦙 Passing control to Ollama Native Launcher..."
        clear_custom_keys
        unset ANTHROPIC_BASE_URL
        unset ANTHROPIC_API_KEY
        ollama launch claude
        ;;
    2)
        # OpenRouter model selection
        model_selected=0
        while IFS= read -r -n 1 key; do
            read -r -t 0.03 -n 2 extra 2>/dev/null || true
            full_key="${key}${extra}"

            if handle_model_key "$full_key"; then
                break
            fi
            render_model_selector
        done

        if [ $model_selected -ge 0 ] && [ $model_selected -lt ${#OPENROUTER_MODEL_OPTIONS[@]} ]; then
            model="${OPENROUTER_MODEL_OPTIONS[$model_selected]}"
            clear
            echo -e "\n⚙️  Configuring Proxy Firewall..."

            cat <<EOF > ~/.litellm_config.yaml
model_list:
  - model_name: "$model"
    litellm_params:
      model: "openrouter/$model"
      api_key: "$OPENROUTER_API_KEY"
EOF

            echo "⚙️  Booting LiteLLM Translation Server..."
            ~/.litellm_env/bin/litellm --config ~/.litellm_config.yaml --port 4000 > /tmp/litellm.log 2>&1 &
            PROXY_PID=$!

            echo "⏳ Waiting for proxy to start..."
            for i in {1..20}; do
                if curl -s http://0.0.0.0:4000/health > /dev/null 2>&1; then
                    echo "✅ Proxy ready"
                    break
                fi
                if [ $i -eq 20 ]; then
                    echo "❌ Proxy failed to start. Check /tmp/litellm.log for details."
                    kill $PROXY_PID 2>/dev/null
                    exit 1
                fi
                sleep 0.5
            done

            echo "🚀 Launching OpenRouter in Claude Code..."
            export ANTHROPIC_BASE_URL="http://0.0.0.0:4000"
            export ANTHROPIC_API_KEY="sk-ant-dummy"
            claude --model "$model"
        fi
        ;;
    3)
        clear_custom_keys
        echo -e "\n✅ Custom keys cleared. Your Official Claude login is ready."
        sleep 2
        exec "$0"  # Restart the menu
        ;;
esac
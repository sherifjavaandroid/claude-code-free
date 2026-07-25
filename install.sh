#!/usr/bin/env bash
# Claude Code Free installer (macOS / Linux) — Qwen / Kimi / DeepSeek
# Run from the repo folder:  bash install.sh
set -e

echo "== Claude Code Free installer (Qwen / Kimi / DeepSeek) =="

# 0) Ensure Node.js / npm
if ! command -v npm >/dev/null 2>&1; then
  echo "Node.js/npm not found — installing Node.js..."
  if command -v conda >/dev/null 2>&1; then
    conda install -y nodejs
  elif command -v apt-get >/dev/null 2>&1; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
  elif command -v brew >/dev/null 2>&1; then
    brew install node
  else
    echo "Could not auto-install Node. Install Node.js 18+ from https://nodejs.org then re-run."
    exit 1
  fi
fi

# 1) Claude Code CLI
if ! command -v claude >/dev/null 2>&1; then
  echo "Installing Claude Code (npm i -g @anthropic-ai/claude-code)..."
  npm install -g @anthropic-ai/claude-code 2>/dev/null || sudo npm install -g @anthropic-ai/claude-code
else
  echo "Claude Code already installed."
fi

RC="$HOME/.bashrc"; [ -f "$HOME/.zshrc" ] && RC="$HOME/.zshrc"

# 2) Provider-switch functions (idempotent block in the shell rc)
MARK_BEGIN="# >>> claude-code-free >>>"
MARK_END="# <<< claude-code-free <<<"
sed -i.bak "/$MARK_BEGIN/,/$MARK_END/d" "$RC" 2>/dev/null || true
cat >> "$RC" <<'BLOCK'
# >>> claude-code-free >>>
claude-qwen()     { ANTHROPIC_BASE_URL=http://31.97.35.212:8001 ANTHROPIC_AUTH_TOKEN="$QWEN_TOKEN"     ANTHROPIC_MODEL=qwen3-coder-plus ANTHROPIC_SMALL_FAST_MODEL=qwen3-coder-plus claude "$@"; }
claude-kimi()     { ANTHROPIC_BASE_URL=http://31.97.35.212:8066 ANTHROPIC_AUTH_TOKEN="$KIMI_TOKEN"     ANTHROPIC_MODEL=kimi             ANTHROPIC_SMALL_FAST_MODEL=kimi             claude "$@"; }
claude-deepseek() { ANTHROPIC_BASE_URL=http://31.97.35.212:8000 ANTHROPIC_AUTH_TOKEN="$DEEPSEEK_TOKEN" ANTHROPIC_MODEL=deepseek-chat    ANTHROPIC_SMALL_FAST_MODEL=deepseek-chat    claude "$@"; }
# <<< claude-code-free <<<
BLOCK
echo "Installed provider commands into $RC"

# 3) Tokens
echo ""
echo "Get each token from your browser (F12 > Application > Local Storage):"
echo "  Qwen     -> chat.qwen.ai      -> key 'token'"
echo "  Kimi     -> kimi.com          -> key 'refresh_token'"
echo "  DeepSeek -> chat.deepseek.com -> key 'userToken' (copy its 'value')"
echo "Leave blank to keep the current value."
echo ""
add_var () { [ -z "$2" ] && return; grep -v "^export $1=" "$RC" > "$RC.tmp" 2>/dev/null || true; mv "$RC.tmp" "$RC" 2>/dev/null || true; echo "export $1=\"$2\"" >> "$RC"; export "$1"="$2"; }
read -r -p "QWEN_TOKEN: " q;     add_var QWEN_TOKEN "$q"
read -r -p "KIMI_TOKEN: " k;     add_var KIMI_TOKEN "$k"
read -r -p "DEEPSEEK_TOKEN: " d; add_var DEEPSEEK_TOKEN "$d"

echo ""
echo "Done! Restart your terminal (or 'source $RC'), then:"
echo "  claude-qwen       # Qwen3-Coder"
echo "  claude-kimi       # Kimi"
echo "  claude-deepseek   # DeepSeek"

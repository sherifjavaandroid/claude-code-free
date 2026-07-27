#Requires -Version 5
# Claude Code Free installer (Windows) — Qwen / Kimi / DeepSeek / ChatGPT
# Run from the repo folder:  powershell -ExecutionPolicy Bypass -File .\install.ps1

Write-Host "== Claude Code Free installer (Qwen / Kimi / DeepSeek / ChatGPT) ==" -ForegroundColor Cyan

# 1) Claude Code CLI
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Claude Code (npm i -g @anthropic-ai/claude-code)..." -ForegroundColor Yellow
    npm install -g @anthropic-ai/claude-code
} else {
    Write-Host "Claude Code already installed." -ForegroundColor Green
}

# 2) Install the provider-switch functions + auto-load from the PowerShell profile
$dest = Join-Path $env:USERPROFILE ".claude-free"
if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Force -Path $dest | Out-Null }
Copy-Item (Join-Path $PSScriptRoot "claude-providers.ps1") (Join-Path $dest "claude-providers.ps1") -Force

$loader = '. "$HOME\.claude-free\claude-providers.ps1"'
$profDir = Split-Path $PROFILE
if (-not (Test-Path $profDir)) { New-Item -ItemType Directory -Force -Path $profDir | Out-Null }
if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE | Out-Null }
if ((Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue) -notlike "*claude-providers.ps1*") {
    Add-Content -Path $PROFILE -Value "`r`n$loader" -Encoding utf8
    Write-Host "Added loader to PowerShell profile." -ForegroundColor Green
}

# 3) Tokens (reuse the same env vars as codex-free; leave blank to keep existing)
Write-Host "`nGet each token from your browser (F12 > Application > Local Storage):" -ForegroundColor Cyan
Write-Host "  Qwen     -> chat.qwen.ai      -> key 'token'"
Write-Host "  Kimi     -> kimi.com          -> key 'refresh_token'"
Write-Host "  DeepSeek -> chat.deepseek.com -> key 'userToken' (copy its 'value')"
Write-Host "  ChatGPT  -> not a browser token: the access key for the ChatGPT proxy"
Write-Host "              (ask whoever runs the server, or set your own CHATGPT_API_KEY"
Write-Host "               when self-hosting github.com/sherifjavaandroid/chat-gpt)"
Write-Host "Leave a field blank to keep the current value.`n" -ForegroundColor DarkGray

$q = Read-Host "QWEN_TOKEN"
if ($q) { [Environment]::SetEnvironmentVariable("QWEN_TOKEN", $q.Trim(), "User") }
$k = Read-Host "KIMI_TOKEN"
if ($k) { [Environment]::SetEnvironmentVariable("KIMI_TOKEN", $k.Trim(), "User") }
$d = Read-Host "DEEPSEEK_TOKEN"
if ($d) { [Environment]::SetEnvironmentVariable("DEEPSEEK_TOKEN", $d.Trim(), "User") }
$c = Read-Host "CHATGPT_TOKEN"
if ($c) { [Environment]::SetEnvironmentVariable("CHATGPT_TOKEN", $c.Trim(), "User") }

Write-Host "`nDone! Open a NEW terminal, then run:" -ForegroundColor Green
Write-Host "  claude-qwen       # Qwen3-Coder"
Write-Host "  claude-kimi       # Kimi"
Write-Host "  claude-deepseek   # DeepSeek"
Write-Host "  claude-chatgpt    # ChatGPT (GPT-5.4 Thinking Mini)"
Write-Host "`nTip: run from inside your project folder." -ForegroundColor DarkGray

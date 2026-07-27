# Claude Code provider switch — free proxies (Qwen / Kimi / DeepSeek / ChatGPT).
# Each function points ANTHROPIC_* at the right proxy + token, then launches `claude`.
# Tokens come from the persistent QWEN_TOKEN / KIMI_TOKEN / DEEPSEEK_TOKEN /
# CHATGPT_TOKEN env vars.
# Usage:  claude-qwen  |  claude-kimi  |  claude-deepseek  |  claude-chatgpt
#         (extra args pass through, e.g.  claude-kimi "explain this repo")

function claude-qwen {
    $env:ANTHROPIC_BASE_URL         = 'http://31.97.35.212:8001'
    $env:ANTHROPIC_AUTH_TOKEN       = [Environment]::GetEnvironmentVariable('QWEN_TOKEN','User')
    $env:ANTHROPIC_MODEL            = 'qwen3-coder-plus'
    $env:ANTHROPIC_SMALL_FAST_MODEL = 'qwen3-coder-plus'
    claude @args
}

function claude-kimi {
    $env:ANTHROPIC_BASE_URL         = 'http://31.97.35.212:8066'
    $env:ANTHROPIC_AUTH_TOKEN       = [Environment]::GetEnvironmentVariable('KIMI_TOKEN','User')
    $env:ANTHROPIC_MODEL            = 'kimi'
    $env:ANTHROPIC_SMALL_FAST_MODEL = 'kimi'
    claude @args
}

function claude-deepseek {
    $env:ANTHROPIC_BASE_URL         = 'http://31.97.35.212:8000'
    $env:ANTHROPIC_AUTH_TOKEN       = [Environment]::GetEnvironmentVariable('DEEPSEEK_TOKEN','User')
    $env:ANTHROPIC_MODEL            = 'deepseek-chat'
    $env:ANTHROPIC_SMALL_FAST_MODEL = 'deepseek-chat'
    claude @args
}

# DeepSeek Reasoner (thinking model); fast/background calls use deepseek-chat.
function claude-dsr {
    $env:ANTHROPIC_BASE_URL         = 'http://31.97.35.212:8000'
    $env:ANTHROPIC_AUTH_TOKEN       = [Environment]::GetEnvironmentVariable('DEEPSEEK_TOKEN','User')
    $env:ANTHROPIC_MODEL            = 'deepseek-reasoner'
    $env:ANTHROPIC_SMALL_FAST_MODEL = 'deepseek-chat'
    claude @args
}

# ChatGPT (GPT-5.4 Thinking Mini — 262k context). Unlike the others, the proxy
# holds the ChatGPT session server-side, so CHATGPT_TOKEN is the server's access
# key rather than your own account token.
function claude-chatgpt {
    $env:ANTHROPIC_BASE_URL         = 'http://31.97.35.212:8002'
    $env:ANTHROPIC_AUTH_TOKEN       = [Environment]::GetEnvironmentVariable('CHATGPT_TOKEN','User')
    $env:ANTHROPIC_MODEL            = 'gpt-5-4-t-mini'
    $env:ANTHROPIC_SMALL_FAST_MODEL = 'gpt-5-5-mini'
    claude @args
}

Write-Host "Claude Code provider commands loaded: claude-qwen | claude-kimi | claude-deepseek | claude-dsr | claude-chatgpt" -ForegroundColor Green

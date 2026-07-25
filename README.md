# Claude Code Free — Qwen · Kimi · DeepSeek

Use **[Claude Code](https://docs.anthropic.com/en/docs/claude-code)** for **free**
with **Qwen**, **Kimi**, and **DeepSeek** — no Anthropic API bill. Install once,
add your tokens, then pick a model with `claude-qwen` / `claude-kimi` /
`claude-deepseek`.

Claude Code speaks Anthropic's **Messages API**. These proxies expose a native
`POST /v1/messages` endpoint that forwards your own free chat.qwen.ai / kimi.com
/ chat.deepseek.com session token. You bring your own free-account token per
provider — nothing is shared or stored.

| Command | Model | Provider |
|---|---|---|
| `claude-qwen` | Qwen3-Coder (`qwen3-coder-plus`) | Qwen |
| `claude-kimi` | Kimi | Kimi |
| `claude-deepseek` | DeepSeek Chat | DeepSeek |
| `claude-dsr` | DeepSeek Reasoner (thinking) | DeepSeek |

---

# From zero to running

## 0. Prerequisites
Install **[Node.js](https://nodejs.org) 18+** (`node -v`).

## 1. Get this repo
```bash
git clone https://github.com/sherifjavaandroid/claude-code-free.git
cd claude-code-free
```

## 2. Run the installer
Installs Claude Code, adds the provider commands to your shell, and asks for tokens.

**Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```
**macOS / Linux:**
```bash
bash install.sh
```

## 3. Get your tokens
Log in to each site, open **DevTools (F12) → Application → Local Storage →** the
site, and copy the value:

| Provider | Site | Local Storage key | Copy |
|---|---|---|---|
| **Qwen** | <https://chat.qwen.ai> | `token` | the whole value (`eyJ...`) |
| **Kimi** | <https://kimi.com> | `refresh_token` | the whole value (`eyJ...`) |
| **DeepSeek** | <https://chat.deepseek.com> | `userToken` | the inner **`value`** string |

Paste each when the installer asks (leave blank to skip / keep existing).

## 4. Run Claude Code with any model
Open a **new terminal**, `cd` into your project, then:
```bash
claude-qwen        # Qwen3-Coder
claude-kimi        # Kimi
claude-deepseek    # DeepSeek Chat
claude-dsr         # DeepSeek Reasoner (thinking)
```

---

# Troubleshooting the install

| You see | Why | Fix |
|---|---|---|
| `claude-qwen: command not found` | the new shell functions aren't loaded yet | Run **`source ~/.zshrc`** (or `~/.bashrc`), or open a **new terminal**. Then `claude-qwen`. |
| `npm: command not found` | Node.js isn't installed | Install Node 18+ — `conda install -y nodejs`, or `sudo apt install -y nodejs npm`, or from <https://nodejs.org>. (The latest `install.sh` auto-installs it.) |
| `powershell: command not found` (Linux/macOS) | that's the Windows installer | Use **`bash install.sh`**, not `install.ps1`. |
| Plain `claude` shows a **"Select login method"** screen | plain `claude` has no proxy configured | Don't run `claude` directly — use **`claude-qwen`** / `claude-kimi` / `claude-deepseek`; those set the backend + token before launching. |
| First run shows a theme / "trust this folder" prompt | normal Claude Code onboarding | Accept it — it appears once. |
| `unauthorized` / auth error mid-session | token expired or wrong | Grab a fresh token and update the env var (see below). |

---

# Changing / updating tokens

When a provider starts failing with an auth error, grab a fresh token (Step 3)
and update its env var — **no reinstall needed**.

**Windows:**
```powershell
[Environment]::SetEnvironmentVariable("QWEN_TOKEN", "NEW_TOKEN", "User")   # then open a new terminal
```
**macOS / Linux** — edit the `export QWEN_TOKEN=...` line in `~/.zshrc` (or
`~/.bashrc`) and `source` it. Or re-run the installer.

---

# How it works

```
Claude Code ──(Anthropic Messages API)──► proxy /v1/messages ──► Qwen / Kimi / DeepSeek
             ANTHROPIC_BASE_URL + your token forwarded upstream
```

Each `claude-<provider>` command sets `ANTHROPIC_BASE_URL` (the proxy),
`ANTHROPIC_AUTH_TOKEN` (your token env var), and `ANTHROPIC_MODEL`, then launches
`claude`. The proxy emulates tool use so Claude Code can edit files and run
commands.

**Self-host the proxies:** the default URLs point at a shared server. To run your
own, deploy the proxy repos on a VPS (they expose `/v1/messages`, `/v1/responses`,
and `/v1/chat/completions`) and change the IP in `claude-providers.ps1` /
`install.sh`:
- Qwen: <https://github.com/sherifjavaandroid/qwen-code-cli>
- Kimi: <https://github.com/sherifjavaandroid/kimi-free-api>
- DeepSeek: <https://github.com/sherifjavaandroid/ai-api>

---

# Limitations & fair use

- **Free-tier daily limits** apply per provider account.
- **Tool use is emulated** through prompt formatting — great for most tasks, not
  perfect on very long agent runs (retry or simplify).
- **Experimental**: these are unofficial reverse-proxies of each provider's web
  app and an emulated Anthropic endpoint; behavior can differ from the real
  Anthropic API. Use your own account and don't abuse it.
- Not affiliated with Anthropic, Alibaba/Qwen, Moonshot/Kimi, or DeepSeek.

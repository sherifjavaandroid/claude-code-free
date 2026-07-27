# Claude Code Free — Qwen · Kimi · DeepSeek · ChatGPT

Use **[Claude Code](https://docs.anthropic.com/en/docs/claude-code)** for **free**
with **Qwen**, **Kimi**, **DeepSeek**, and **ChatGPT** — no Anthropic API bill.
Install once, add your tokens, then pick a model with `claude-qwen` /
`claude-kimi` / `claude-deepseek` / `claude-chatgpt`.

Claude Code speaks Anthropic's **Messages API**. These proxies expose a native
`POST /v1/messages` endpoint that forwards your own free chat.qwen.ai / kimi.com
/ chat.deepseek.com session token. You bring your own free-account token per
provider — nothing is shared or stored.

| Command | Model | Provider | Context |
|---|---|---|---|
| `claude-qwen` | Qwen3-Coder (`qwen3-coder-plus`) | Qwen | |
| `claude-kimi` | Kimi | Kimi | |
| `claude-deepseek` | DeepSeek Chat | DeepSeek | |
| `claude-dsr` | DeepSeek Reasoner (thinking) | DeepSeek | |
| `claude-chatgpt` | GPT-5.4 Thinking Mini (`gpt-5-4-t-mini`) | ChatGPT | ~24k\* |

> **ChatGPT works differently from the other three.** ChatGPT is behind
> Cloudflare and needs a full browser **cookie jar**, not a single token, so the
> proxy holds *one* ChatGPT session **server-side** — everyone hitting that
> server shares that account's quota. `CHATGPT_TOKEN` is therefore the proxy's
> **access key**, not your own account token: ask whoever runs the server, or
> [self-host](#self-host-the-proxies) and set your own. The other three forward
> your personal token and share nothing.
>
> \* The model's own window is 262k, but the usable figure is far lower: ChatGPT's
> backend rejects large request bodies with **413** (measured — 100k chars fine,
> 150k rejected), which is a *transport* limit and has nothing to do with context.
> The proxy compresses the tool definitions to fit and drops the oldest turns when
> it has to, so long sessions lose early history. `/compact` early on long tasks.

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

**ChatGPT** is the exception — there's nothing to copy from a browser. Its
`CHATGPT_TOKEN` is the access key of the proxy you're pointing at (see the note
at the top). Leave it blank if you aren't using `claude-chatgpt`.

Paste each when the installer asks (leave blank to skip / keep existing).

## 4. Run Claude Code with any model
Open a **new terminal**, `cd` into your project, then:
```bash
claude-qwen        # Qwen3-Coder
claude-kimi        # Kimi
claude-deepseek    # DeepSeek Chat
claude-dsr         # DeepSeek Reasoner (thinking)
claude-chatgpt     # ChatGPT — GPT-5.4 Thinking Mini, 262k context
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
| anything wrong with **`claude-chatgpt`** | ChatGPT is the odd one out — server-side session, shared quota | See [Troubleshooting `claude-chatgpt`](#troubleshooting-claude-chatgpt) below |

---

# Troubleshooting `claude-chatgpt`

ChatGPT has failure modes the other three don't, because its session lives on the
server rather than being your own forwarded token.

## `401 invalid api key`

`CHATGPT_TOKEN` isn't the proxy's access key. It is **not** a browser token — there
is nothing to copy from DevTools. Get the key from whoever runs the server, or set
`CHATGPT_API_KEY` on your own deployment.

Check what you have, and test it without launching Claude Code at all:
```bash
echo ${#CHATGPT_TOKEN}          # length; 5 means the old "local" placeholder
curl -si http://31.97.35.212:8002/v1/models -H "x-api-key: $CHATGPT_TOKEN" | head -1
```
```powershell
[Environment]::GetEnvironmentVariable('CHATGPT_TOKEN','User').Length
(Invoke-WebRequest "http://31.97.35.212:8002/v1/models" `
  -Headers @{ "x-api-key" = [Environment]::GetEnvironmentVariable('CHATGPT_TOKEN','User') } `
  -UseBasicParsing).StatusCode
```
`200` means the key is good; `401` means it's wrong.

**Stale-token note.** On **Windows**, `claude-chatgpt` reads the token from the User
environment *every time it runs*, so updating it takes effect immediately — no new
terminal needed. On **macOS/Linux** the function reads the shell's `$CHATGPT_TOKEN`,
so after changing it you must `source ~/.zshrc` (or `~/.bashrc`) or open a new
terminal. (Codex, in the sibling `codex-free` repo, reads the process environment on
every platform and *does* need a fresh terminal — a common source of confusion if you
use both.)

## `session not authenticated`

The server's ChatGPT cookies expired. Only the server operator can fix it, by
re-exporting `cookies.txt`; it's re-read per request, so no restart is needed.

## `rate limited by ChatGPT ... the account's quota is spent`

That ChatGPT account hit its free-tier cap, and it is **shared by everyone using that
server**. The proxy already falls back from the premium slugs to the mini tiers
automatically, so seeing this means every tier is exhausted. Wait, or switch provider
(`claude-qwen`, `claude-deepseek`).

## `request too large for ChatGPT (HTTP 413)`

The conversation outgrew ChatGPT's request-body limit — which is a *transport* limit,
unrelated to the model's context window. Run `/compact` or `/clear` and continue.

## It says it did something it didn't

e.g. *"Created `add.py` and ran it — output: 5"* when no file exists. The GPT-5 models
do this more than the other providers; the proxy detects most cases and silently
re-asks, but it isn't perfect. If a result looks suspiciously tidy, verify the file
actually changed. Explicit prompts help: "create X, **then run it to verify**" works
far better than "create X".

## Does it fill up my chatgpt.com history?

No. Each request opens a new upstream conversation, which would otherwise add a
sidebar entry *per request*, so the proxy marks them as not-saved — they never appear
in the sidebar and 404 on direct fetch. It also opts those turns out of training.

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

<a id="self-host-the-proxies"></a>
**Self-host the proxies:** the default URLs point at a shared server. To run your
own, deploy the proxy repos on a VPS (they expose `/v1/messages`, `/v1/responses`,
and `/v1/chat/completions`) and change the IP in `claude-providers.ps1` /
`install.sh`:
- Qwen: <https://github.com/sherifjavaandroid/qwen-code-cli> — port 8001
- Kimi: <https://github.com/sherifjavaandroid/kimi-free-api> — port 8066
- DeepSeek: <https://github.com/sherifjavaandroid/ai-api> — port 8000
- ChatGPT: <https://github.com/sherifjavaandroid/chat-gpt> — port 8002

Self-hosting ChatGPT (Python, needs your cookie jar):
```bash
git clone https://github.com/sherifjavaandroid/chat-gpt.git
cd chat-gpt && python -m venv .venv && .venv/bin/pip install -r requirements.txt
# export your chatgpt.com cookies as JSON (Cookie-Editor extension) to cookies.txt
chmod 600 cookies.txt
SERVER_PORT=8002 CHATGPT_API_KEY=pick-a-secret .venv/bin/python server.py
```
Set `CHATGPT_API_KEY` whenever the port is reachable from the internet — the
ChatGPT session lives on the server, so an open port spends your account's quota.
That secret is what users put in `CHATGPT_TOKEN`.

---

# Limitations & fair use

- **Free-tier daily limits** apply per provider account. For ChatGPT the limit is
  shared across everyone using that server, and the strongest slugs (`gpt-5-5`,
  `gpt-5-3`) are usually exhausted on a free account — hence the mini default.
- **Tool use is emulated** through prompt formatting — great for most tasks, not
  perfect on very long agent runs (retry or simplify). The GPT-5 models behind
  `claude-chatgpt` are the most prone to answering without calling a tool at all
  — refusing ("I can't access your filesystem"), narrating ("I'll check that"),
  or even reporting work they never did ("Created add.py, output: 5"). The proxy
  detects these and re-asks, which recovers most of them, but expect the
  occasional turn to need a nudge. Prefer explicit prompts ("run `python add.py`
  to verify") over open-ended ones.
- **Experimental**: these are unofficial reverse-proxies of each provider's web
  app and an emulated Anthropic endpoint; behavior can differ from the real
  Anthropic API. Use your own account and don't abuse it.
- Not affiliated with Anthropic, Alibaba/Qwen, Moonshot/Kimi, DeepSeek, or OpenAI.

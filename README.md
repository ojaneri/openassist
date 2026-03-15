# OpenAssist

**Autonomous Linux AI Assistant powered by OpenRouter**

By [Osvaldo J. Filho](https://perito.digital) · [LinkedIn](https://linkedin.com/in/ojaneri) · [Instagram](https://instagram.com/peritosegurancadainformacao)

---

## Overview

OpenAssist is a command-line tool that turns natural language instructions into Linux shell commands — executed autonomously by an AI model. You describe what you want done; the AI figures out which commands to run, executes them one at a time, reads the output, and keeps going until the task is complete.

It communicates with AI models through the [OpenRouter](https://openrouter.ai) API, requiring no local GPU or model installation. The entire tool is a single Python file with no third-party dependencies.

---

## Features

- **Natural language task execution** — describe a task in plain English; the AI breaks it down into shell commands and runs them
- **Iterative autonomous loop** — the AI reads each command's output before deciding the next step
- **Model fallback chain** — if the primary model fails or times out, OpenAssist automatically tries a list of fallback models
- **Command safety system** — detects destructive commands (`rm`, `shutdown`, `fdisk`, …) and interactive commands (`vim`, `top`, `python`, …); prompts for confirmation or blocks them
- **Whitelist support** — pre-approve trusted commands so they run without confirmation
- **Session persistence** — every task and result is logged to `SESSION.md`; resuming a session gives the AI full context of previous work
- **Context window management** — automatically compresses and truncates history to stay within the model's token limit (~120k tokens)
- **No external dependencies** — uses only Python standard library (Python 3.6+)

---

## Requirements

- Python 3.6 or higher
- An [OpenRouter API key](https://openrouter.ai/keys) (free tier available)
- Git (optional, for version-controlled session logs)

---

## Installation

```bash
git clone https://github.com/ojaneri/openrouter-cline.git
cd openrouter-cline
chmod +x openassist
```

Set your API key:

```bash
export OPENROUTER_API_KEY="your-key-here"
```

To make the key permanent, add the line above to your `~/.bashrc` or `~/.zshrc`.

---

## Usage

### Start an interactive session

```bash
./openassist
```

### Pass a task directly

```bash
./openassist "show disk usage for each directory in /var"
```

### Use a specific model

```bash
./openassist "meta-llama/llama-3.3-70b-instruct:free" "list all running services"
```

If the first argument contains a `/`, it is treated as a model name; the second argument is the task.

---

## Interactive Commands

Once the assistant is running, you can type these commands at the prompt:

| Command | Description |
|---|---|
| `/help` | Show all available commands |
| `/status` | Show current session stats (tokens, model, iteration count) |
| `/config` | Show active configuration values |
| `/clear` | Clear session history (`SESSION.md`) and start fresh |
| `/resetmodel` | Forget cached model and fall back to default |
| `/timeout_cmd N` | Set shell command timeout in seconds (default: 360) |
| `/timeout_api N` | Set API call timeout in seconds (default: 30) |
| `/maxiter N` | Set maximum commands per task (default: 30, range: 5–100) |
| `/exit` or `/quit` | Exit the program |

---

## Configuration Files

| File | Purpose |
|---|---|
| `~/.openassist.cfg` | Command whitelist — one command name per line |
| `~/.openassist_model.cfg` | Last successfully used model (auto-saved) |
| `SESSION.md` | Full session log (created in the working directory) |
| `OPENROUTER_API_KEY` env var | API authentication |

### Whitelist example (`~/.openassist.cfg`)

```
git
cat
echo
ls
find
df
ps
```

Commands listed here will run without asking for confirmation.

---

## How It Works

```
You type a task
       ↓
OpenAssist sends it to the AI model via OpenRouter API
       ↓
AI responds with a single JSON command + explanation
       ↓
OpenAssist validates the command (safety checks, whitelist)
       ↓
Asks for confirmation if needed → executes the command
       ↓
Output is captured and sent back to the AI
       ↓
AI decides the next command or marks the task as complete
       ↓
Loop repeats until done (or iteration limit reached)
```

The AI communicates exclusively in structured JSON:

**Command step:**
```json
{
  "command": "du -sh /var/*",
  "explanation": "Show disk usage per subdirectory in /var",
  "reason": "User asked for disk usage breakdown"
}
```

**Task complete:**
```json
{
  "status": "SUMMARY",
  "message": "Disk usage for /var directories has been displayed above."
}
```

---

## Default and Fallback Models

OpenAssist uses the following model chain (free tier):

| Priority | Model |
|---|---|
| Default | `qwen/qwen3-coder:free` |
| Fallback 1 | `meta-llama/llama-3.3-70b-instruct:free` |
| Fallback 2 | `qwen/qwen3-next-80b-a3b-instruct:free` |
| Fallback 3 | `openai/gpt-oss-120b:free` |
| Fallback 4 | `mistralai/mistral-small-3.1-24b-instruct:free` |
| Fallback 5 | `google/gemma-3-27b-it:free` |
| Fallback 6 | `openrouter/free` |

The last successful model is cached in `~/.openassist_model.cfg` and reused on the next run. Use `/resetmodel` to clear the cache.

---

## Safety

OpenAssist includes several layers of protection:

- **Destructive command detection** — commands like `rm`, `dd`, `mkfs`, `fdisk`, `shutdown`, `kill`, and others require explicit user confirmation
- **Interactive command blocking** — commands that require a terminal UI (`vim`, `nano`, `top`, `htop`, `python`, `mysql`, etc.) are rejected; the AI is prompted to use non-interactive alternatives
- **One command per iteration** — the AI cannot batch-execute multiple commands in a single response
- **Timeout protection** — both API calls and shell commands have configurable timeouts to prevent hangs
- **User confirmation flow** — for any unapproved command, you choose `[y]es`, `[n]o`, `[a]lways` (add to whitelist), or `[q]uit`

---

## Example Use Cases

```
"Create a compressed backup of /etc and save it to /tmp"
"Find all files larger than 100MB in /home and list them by size"
"Show the 10 most CPU-intensive processes right now"
"Check if nginx is running and show its error log tail"
"Count how many lines each .py file in this directory has"
"Set up a simple cron job to run a cleanup script every night at 2am"
```

---

## Troubleshooting

| Problem | Solution |
|---|---|
| `OPENROUTER_API_KEY not defined` | Run `export OPENROUTER_API_KEY="your-key"` |
| API timeout errors | Increase with `/timeout_api 60` |
| Commands hang or time out | Increase with `/timeout_cmd 600` |
| Context too large warning | Run `/clear` to reset the session |
| AI tries an interactive command | It will be blocked; the AI is re-prompted automatically |
| Command not in whitelist | Press `[a]` at the confirmation prompt to add it permanently |

---

## License

MIT — free for personal and commercial use.

---

## Author

**Osvaldo J. Filho**
- Website: [perito.digital](https://perito.digital)
- LinkedIn: [linkedin.com/in/ojaneri](https://linkedin.com/in/ojaneri)
- Instagram: [instagram.com/peritosegurancadainformacao](https://instagram.com/peritosegurancadainformacao)

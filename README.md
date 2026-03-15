# OpenAssist

**Autonomous Linux AI Assistant powered by OpenRouter**

By [Osvaldo J. Filho](https://perito.digital) · [LinkedIn](https://linkedin.com/in/ojaneri) · [Instagram](https://instagram.com/peritosegurancadainformacao)

---

## What is OpenAssist?

OpenAssist is a command-line tool that turns natural language instructions into Linux shell commands — executed autonomously by an AI model. You describe what you want done; the AI figures out which commands to run, executes them one at a time, reads the output, and keeps going until the task is complete.

It communicates with AI models through the [OpenRouter](https://openrouter.ai) API, requiring no local GPU or model installation. The entire tool is a single Python file with **zero third-party dependencies**.

The **Skills system** extends OpenAssist with specialized domain knowledge: load a skill and the AI gains structured methodology, guardrails, phase-by-phase instructions, and curated command templates for a specific task type — from penetration testing to security auditing to OSINT.

---

## Features

- **Natural language task execution** — describe a task in plain English; the AI breaks it into shell commands and runs them
- **Skills system** — extend the AI with specialized domain knowledge via `skill-*.json` files
- **Iterative autonomous loop** — the AI reads each command's output before deciding the next step
- **Model fallback chain** — if the primary model fails, OpenAssist automatically tries a list of fallback models
- **Command safety system** — detects destructive and interactive commands; prompts for confirmation or blocks them
- **Whitelist support** — pre-approve trusted commands to run without confirmation
- **Session persistence** — every task and result logged to `SESSION.md`; resuming gives the AI full context
- **Context window management** — automatically compresses history to stay within the model's token limit (~120k tokens)
- **No external dependencies** — Python standard library only (Python 3.6+)

---

## Requirements

- Python 3.6 or higher
- An [OpenRouter API key](https://openrouter.ai/keys) (free tier available)
- Linux / macOS with Bash

---

## Getting an OpenRouter API Key

OpenAssist uses [OpenRouter](https://openrouter.ai) as its AI backend. OpenRouter gives you access to dozens of models (including free-tier models) through a single API key.

**Steps to get your key:**

1. Go to [openrouter.ai](https://openrouter.ai) and create a free account
2. Navigate to **[Keys](https://openrouter.ai/keys)** in the dashboard
3. Click **Create Key**, give it a name (e.g., `openassist`), and copy the generated key
4. The key starts with `sk-or-v1-...`

**Free tier models available:** OpenRouter offers several powerful free-tier models (no billing required):
- `qwen/qwen3-coder:free` — default model used by OpenAssist
- `meta-llama/llama-3.3-70b-instruct:free`
- `mistralai/mistral-small-3.1-24b-instruct:free`
- And more at [openrouter.ai/models](https://openrouter.ai/models?q=:free)

---

## Installation

### Option 1 — Install to /opt/openassist (recommended)

```bash
git clone https://github.com/ojaneri/openassist.git
cd openassist
chmod +x install.sh
./install.sh
```

The installer will:
- Ask for your OpenRouter API key if not set
- Copy the binary to `/opt/openassist/`
- Add `/opt/openassist` to your `PATH` in `~/.bashrc` / `~/.zshrc`
- Copy all `skill-*.json` files to `~/.openassist/`

After installation, open a new terminal and run:

```bash
openassist
```

### Option 2 — Run directly from the repo

```bash
git clone https://github.com/ojaneri/openassist.git
cd openassist
chmod +x openassist
export OPENROUTER_API_KEY="sk-or-v1-your-key-here"
./openassist
```

### Set your API key permanently

```bash
echo 'export OPENROUTER_API_KEY="sk-or-v1-your-key-here"' >> ~/.bashrc
source ~/.bashrc
```

---

## Usage

### Start an interactive session

```bash
openassist
```

### Pass a task directly

```bash
openassist "show disk usage for each directory in /var"
```

### Use a specific model

```bash
openassist "meta-llama/llama-3.3-70b-instruct:free" "list all running services"
```

If the first argument contains `/`, it is treated as a model name; the second argument is the task.

### Load a skill

```bash
openassist "use skill audit to audit this server for PCI-DSS compliance"
openassist "run skill osint on domain example.com"
openassist "perform a pentest on 192.168.1.10"
```

---

## Interactive Commands

Once the assistant is running, type these commands at the prompt:

| Command | Description |
|---|---|
| `/help` | Show all available commands |
| `/status` | Show current session stats (tokens, model, iteration count) |
| `/config` | Show active configuration values |
| `/clear` | Clear session history and start fresh |
| `/resetmodel` | Forget cached model and fall back to default |
| `/timeout_cmd N` | Set shell command timeout in seconds (default: 360) |
| `/timeout_api N` | Set API call timeout in seconds (default: 30) |
| `/maxiter N` | Set maximum commands per task (default: 30, range: 5–100) |
| `/exit` or `/quit` | Exit the program |

---

## Configuration Files

| File | Purpose |
|---|---|
| `~/.openassist/config.cfg` | Command whitelist — one command name per line |
| `~/.openassist/model.cfg` | Last successfully used model (auto-saved) |
| `~/.openassist/skill-*.json` | Installed skills directory |
| `SESSION.md` | Full session log (created in the working directory) |
| `OPENROUTER_API_KEY` env var | API authentication |

### Whitelist example (`~/.openassist/config.cfg`)

```
git
cat
echo
ls
find
df
ps
```

Commands listed here run without asking for confirmation.

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

## Skills

Skills are JSON files (`skill-<name>.json`) stored in `~/.openassist/` that inject specialized domain knowledge and methodology into the AI model. When you reference a skill in a task, OpenAssist loads the full skill definition — including phases, guardrails, key commands, and step-by-step instructions — into the AI's context.

### Available Skills

---

### `audit` — Security & Compliance Audit

**File:** `skill-audit.json`
**Type:** `security_audit`
**Frameworks:** PCI-DSS v4.0, HIPAA Security Rule, LGPD (Lei 13.709/2018), ISO 27001:2022, SOC 2 Type II, CIS Controls v8

Automated security auditing of Linux servers. Performs 6 structured phases:

| Phase | Name | Description |
|---|---|---|
| 1 | Coleta de Logs | Extract and consolidate system, auth, and application logs |
| 2 | Análise de Acessos | Audit logins, sudo commands, failed attempts, active sessions |
| 3 | Auditoria de Permissões | Find SUID/SGID binaries, world-writable files, orphaned files |
| 4 | Verificação de Compliance | Automated checklist for PCI-DSS, HIPAA, LGPD, ISO 27001 |
| 5 | Detecção de Anomalias | Detect suspicious logins, brute-force IPs, privilege escalations |
| 6 | Geração de Relatório | HTML executive report with scores, findings, and remediation plan |

**Severity Levels:**

| Level | Score | SLA | Examples |
|---|---|---|---|
| CRITICAL | 9.0–10.0 | Immediate | Root SSH active, world-writable SUID, no password on admin |
| HIGH | 7.0–8.9 | 48 hours | Weak password policy, unnecessary services running |
| MEDIUM | 4.0–6.9 | 7 days | Log retention too short, missing file integrity monitoring |
| LOW | 0.1–3.9 | 30 days | Outdated documentation, missing security banners |

**Usage:**
```bash
openassist "use skill audit to audit this server for PCI-DSS and LGPD compliance"
openassist "run a full security audit and generate the HTML report"
```

**Outputs:** `/tmp/audit/audit_report_<hostname>_<date>.html`, `/tmp/audit/findings_detailed_<date>.json`

**Guardrails:** Never modifies logs, never disables auditd, redacts passwords in output, max 100k log lines per file, max depth 5 on `find` commands.

---

### `pentest` — Penetration Testing

**File:** `skill-pentest.json`
**Type:** `security_assessment`
**Frameworks:** PTES, OWASP Testing Guide v4.2, NIST SP 800-115, OSSTMM, MITRE ATT&CK

Full-cycle penetration testing following the Penetration Testing Execution Standard (PTES), mapped to MITRE ATT&CK techniques.

| Phase | Name | MITRE Tactics | Key Tools |
|---|---|---|---|
| 1 | Reconnaissance | TA0043 | theHarvester, Nmap, Gobuster, Amass |
| 2 | Vulnerability Analysis | Reconnaissance | Nuclei, testssl.sh, Nikto, OpenVAS |
| 3 | Exploitation | Initial Access, Execution | Metasploit, SQLmap, Hydra |
| 4 | Post-Exploitation | Privilege Escalation, Collection | LinPEAS, Impacket, Mimikatz |
| 5 | Lateral Movement | Lateral Movement | NetExec, wmiexec, psexec |
| 6 | Reporting | — | HTML report with evidence and remediation |

**Usage:**
```bash
openassist "use skill pentest on target 192.168.1.10 — authorized scope"
openassist "perform reconnaissance phase of pentest on example.com"
```

**Guardrails:** Requires explicit user approval before exploitation, max risk level 2 on SQLmap, forbidden commands include `--dump-all`, `--os-shell`, DROP/DELETE/TRUNCATE on databases, max 20 req/s, 5 concurrent connections.

---

### `osint` — Open Source Intelligence

**File:** `skill-osint.json`
**Type:** `intelligence_gathering`
**Frameworks:** OSINT Framework, PTES Reconnaissance, OPSEC Guidelines, MITRE ATT&CK TA0043

Passive and semi-passive OSINT collection on persons, organizations, domains, or infrastructure using only public sources.

| Phase | Name | Key Tools |
|---|---|---|
| 1 | Target Profiling | theHarvester, Sherlock, Holehe, Maigret |
| 2 | Infrastructure Mapping | Amass, Subfinder, Shodan CLI, dnsx, httpx |
| 3 | Leaked Credentials & Exposure | h8mail, gitleaks, GitDorker |
| 4 | Web & Social Footprint | SpiderFoot, metagoofil, waybackurls, Photon |
| 5 | Correlation & Analysis | Maltego CE, SpiderFoot HX API |
| 6 | Reporting | HTML report with exposure score and IOCs in STIX 2.1 |

**Usage:**
```bash
openassist "use skill osint to investigate domain example.com"
openassist "run osint on username johndoe across all social platforms"
```

**Guardrails:** Passive by default, never accesses systems without authorization, no scraping in violation of ToS, no data collection on minors, requires scope confirmation before starting.

---

### `email` — Automated Email via SMTP

**File:** `skill-email.json`
**Type:** `automation`
**Frameworks:** SMTP Protocol, RFC 5321, MIME Standards

Send emails from the command line using Python's built-in `smtplib`. Supports plain text, HTML, attachments, and bulk sending. Authentication always via environment variables — never hardcoded.

| Phase | Name | Description |
|---|---|---|
| 1 | Configuração | Auto-detect SMTP provider from sender domain |
| 2 | Composição | Compose email body in plain text or HTML |
| 3 | Anexos | Attach files with size validation (max 25MB) |
| 4 | Envio | Authenticate and send via TLS (mandatory) |
| 5 | Confirmação | Verify delivery and generate audit log |

**Supported providers:** Gmail, Outlook, Hotmail, Yahoo, iCloud, and any custom SMTP server.

**Required environment variables:**
```bash
export EMAIL_SENDER="you@gmail.com"
export EMAIL_PASSWORD="your-app-password"
```

**Usage:**
```bash
openassist "use skill email to send a report to admin@example.com with attachment /tmp/audit/report.html"
openassist "send HTML email to team@example.com with the contents of /tmp/summary.html"
```

**Guardrails:** TLS required, passwords never logged, max 10 emails per execution, max 50 recipients per email, 2-second delay between bulk emails.

---

## Skill File Format

Skills are JSON files named `skill-<name>.json` and placed in `~/.openassist/`. Below is the full schema:

```json
{
  "name": "skill-name",
  "version": "1.0",
  "description": "One-line description of what this skill does",
  "frameworks": ["Framework A", "Framework B"],
  "type": "skill_category",
  "approval_required": false,
  "max_iterations": 30,

  "phases": [
    {
      "id": 1,
      "name": "Phase Name",
      "description": "What this phase does",
      "tools": ["tool1", "tool2"],
      "outputs": ["output_file_<date>.json"],
      "requires_approval": false
    }
  ],

  "guardrails": {
    "rate_limiting": {
      "max_requests_per_second": 5
    },
    "security": {
      "forbidden_actions": ["action_a", "action_b"]
    },
    "output_formats": {
      "required": ["json"],
      "forbidden": ["plaintext_passwords"]
    }
  },

  "key_commands": {
    "phase_name": {
      "command_label": "actual shell command with <placeholders>"
    }
  },

  "instructions": "# SKILL NAME\n\nFull Markdown instructions for the AI...",

  "author": {
    "name": "Your Name",
    "website": "https://yoursite.com"
  },
  "last_updated": "YYYY-MM-DD"
}
```

### Schema Fields

| Field | Required | Description |
|---|---|---|
| `name` | Yes | Skill identifier (matches filename: `skill-<name>.json`) |
| `version` | Yes | Semantic version string |
| `description` | Yes | One-line summary shown in skill listing |
| `frameworks` | No | Standards/methodologies this skill follows |
| `type` | Yes | Category: `security_audit`, `security_assessment`, `intelligence_gathering`, `automation`, etc. |
| `approval_required` | Yes | If `true`, AI must ask user before executing commands |
| `max_iterations` | Yes | Maximum AI iterations for this skill (overrides global setting) |
| `phases` | Yes | Ordered list of execution phases |
| `phases[].id` | Yes | Phase number (1-based) |
| `phases[].name` | Yes | Human-readable phase name |
| `phases[].description` | Yes | What this phase accomplishes |
| `phases[].tools` | No | Tools/commands used in this phase |
| `phases[].outputs` | No | Expected output files (use `<placeholder>` for dynamic parts) |
| `phases[].requires_approval` | No | Override approval requirement for this specific phase |
| `guardrails` | No | Constraints the AI must respect: rate limits, forbidden actions, output formats |
| `key_commands` | No | Curated commands injected into AI context for each phase |
| `instructions` | Yes | Full Markdown methodology loaded into AI context when skill is active |
| `author` | No | Skill author information |
| `last_updated` | No | ISO date of last update |

### Installing a Custom Skill

1. Create your `skill-<name>.json` file following the schema above
2. Copy it to `~/.openassist/`:
   ```bash
   cp skill-myskill.json ~/.openassist/
   ```
3. Invoke it in OpenAssist:
   ```bash
   openassist "use skill myskill to ..."
   ```

OpenAssist automatically loads all `skill-*.json` files from `~/.openassist/` on startup.

---

## Default and Fallback Models

OpenAssist uses the following model chain:

| Priority | Model |
|---|---|
| Default | `qwen/qwen3-coder:free` |
| Fallback 1 | `meta-llama/llama-3.3-70b-instruct:free` |
| Fallback 2 | `qwen/qwen3-next-80b-a3b-instruct:free` |
| Fallback 3 | `openai/gpt-oss-120b:free` |
| Fallback 4 | `mistralai/mistral-small-3.1-24b-instruct:free` |
| Fallback 5 | `google/gemma-3-27b-it:free` |
| Fallback 6 | `openrouter/free` |

The last successful model is cached in `~/.openassist/model.cfg` and reused on the next run. Use `/resetmodel` to clear the cache.

---

## Safety

OpenAssist includes several layers of protection:

- **Destructive command detection** — `rm`, `dd`, `mkfs`, `fdisk`, `shutdown`, `kill`, and others require explicit confirmation
- **Interactive command blocking** — `vim`, `nano`, `top`, `htop`, `python`, `mysql`, etc. are rejected; the AI is re-prompted to use non-interactive alternatives
- **One command per iteration** — the AI cannot batch-execute multiple commands in a single response
- **Timeout protection** — both API calls and shell commands have configurable timeouts
- **User confirmation flow** — for unapproved commands, choose `[y]es`, `[n]o`, `[a]lways` (whitelist), or `[q]uit`
- **Skill guardrails** — each skill defines additional forbidden actions, rate limits, and output format restrictions enforced at the AI prompt level

---

## Example Tasks

```
"Create a compressed backup of /etc and save it to /tmp"
"Find all files larger than 100MB in /home, list by size"
"Show the 10 most CPU-intensive processes right now"
"Check if nginx is running and show its error log tail"
"Use skill audit to check PCI-DSS compliance on this server"
"Use skill osint to investigate the domain example.com"
"Use skill pentest on 192.168.1.10 — I have authorization"
"Send the audit report to security@company.com using skill email"
```

---

## Troubleshooting

| Problem | Solution |
|---|---|
| `OPENROUTER_API_KEY not defined` | Run `export OPENROUTER_API_KEY="sk-or-v1-..."` |
| API timeout errors | Increase with `/timeout_api 60` |
| Commands hang or time out | Increase with `/timeout_cmd 600` |
| Context too large warning | Run `/clear` to reset the session |
| AI tries an interactive command | It will be blocked; the AI is re-prompted automatically |
| Command not in whitelist | Press `[a]` at the confirmation prompt to add it permanently |
| Skill not found | Make sure `skill-<name>.json` is in `~/.openassist/` |
| `openassist: command not found` | Run `source ~/.bashrc` or open a new terminal after install |

---

## License

MIT — free for personal and commercial use.

---

## Author

**Osvaldo J. Filho**
- Website: [perito.digital](https://perito.digital)
- LinkedIn: [linkedin.com/in/ojaneri](https://linkedin.com/in/ojaneri)
- Instagram: [instagram.com/peritosegurancadainformacao](https://instagram.com/peritosegurancadainformacao)

# Get Shit Done Agency (GSD Agency)

**Stop vibecoding. Start shipping.**

This project is a powerful synthesis of two distinct paradigms: the strict, spec-driven methodology of **Get Shit Done**, combined with the deep, specialized domain expertise of **Agency Agents**.

By combining these concepts, you get a roster of **51 highly specialized AI experts** executing tasks within a rigid, spec-driven framework. Your AI assistant will no longer guess what to do; instead, it will plan, execute atomically, and verify empirically.

---

## The Agency: 51 AI Specialists Ready to Transform Your Workflow

A complete AI agency at your fingertips. From frontend wizards to Reddit community ninjas, from whimsy injectors to reality checkers. Each agent is a specialized expert with personality, processes, and proven deliverables.

### Designed for Quality

- **Specialized:** Deep expertise in their domain (not generic prompt templates).
- **Personality-Driven:** Unique voice, communication style, and approach.
- **Deliverable-Focused:** Real code, processes, and measurable outcomes.
- **Production-Ready:** Battle-tested workflows and success metrics.

### The Divisions
*Here is a preview of the 9 divisions you can access:*

| Division             | Focus                         | Agent Examples                                               |
| -------------------- | ----------------------------- | ------------------------------------------------------------ |
| **Engineering (7)**  | Building the future           | Frontend Developer, Backend Architect, AI Engineer           |
| **Design (6)**       | Beautiful, usable, delightful | UI Designer, UX Researcher, Whimsy Injector                  |
| **Marketing (8)**    | Growing your audience         | Growth Hacker, Content Creator, TikTok Strategist            |
| **Product (3)**      | Building the right thing      | Sprint Prioritizer, Trend Researcher, Feedback Synthesizer   |
| **Project Mgmt (5)** | Keeping trains running        | Studio Producer, Project Shepherd, Senior Project Manager    |
| **Testing (7)**      | Breaking things safely        | Reality Checker, Evidence Collector, Performance Benchmarker |
| **Support (6)**      | The operational backbone      | Support Responder, Analytics Reporter, Finance Tracker       |
| **Spatial (6)**      | The immersive future          | XR Interface Architect, visionOS Spatial Engineer            |
| **Specialized (3)**  | Unique experts                | Agents Orchestrator, LSP/Index Engineer                      |

---

## Getting Started (Zero Dependency CLI)

This tool is built entirely with native scripts, meaning there are no dependencies to install.

### Option 1: One-Liner [RECOMMENDED]

Use these commands from inside **ANY** project directory to instantly compose your GSD Agency config without manually cloning the entire repository.

#### Windows (PowerShell)
```powershell
Invoke-RestMethod https://raw.githubusercontent.com/BIJJUDAMA/get-shit-done-agency/main/bin/gsd-init.ps1 | Invoke-Expression
```

#### Linux / macOS (Bash)
```bash
curl -sL https://raw.githubusercontent.com/BIJJUDAMA/get-shit-done-agency/main/bin/gsd-init.sh | bash
```

> [!NOTE]
> These commands automatically download the latest GSD Agency library to `~/.gsd-agency` if it doesn't already exist, keeping your project directories clean.

### Option 2: Manual Clone
If you prefer to have a local copy of the repository:
1. Clone the repository: `git clone https://github.com/BIJJUDAMA/get-shit-done-agency.git`
2. Run the initialization script from your target project directory:
   - **Windows:** `powershell -ExecutionPolicy Bypass -File C:\path\to\gsd-init.ps1`
   - **Linux/macOS:** `bash /path/to/gsd-init.sh`

---

## How to Use It

When you run the script, it will guide you through an interactive bridge to configure your agent.

1. **Select a Role:** Choose from the 51 specialized personas.
2. **Environment Auto-Detection:** The script will automatically detect if you are using `.gemini`, `.cursor`, `.claude`, etc., based on your project files. If it can't, it will ask you.

The script dynamically bridges the chosen persona with the GSD Agency methodology rules. It outputs a finalized system instructions file (like `GEMINI.md` or `.cursorrules`) directly into your project.

### Headless Mode

You can bypass the interactive prompts entirely:

```bash
bash bin/gsd-init.sh --role=engineering-senior-developer --env=claude
```

---

## The Workflow Commands

Once your agent is configured and the system context file is in your project, the agent operates entirely through **slash commands sent via chat**. You do not need to run any more CLI tools to use the workflow. 

| Command    | Action                                                                                               |
| ---------- | ---------------------------------------------------------------------------------------------------- |
| `/plan`    | Forces the AI to decompose your requirements into executable, atomic phases before writing any code. |
| `/execute` | Tells the AI to implement the current phase safely, with atomic checkpoints.                         |
| `/verify`  | Requires the AI to validate the implemented work empirically (e.g., test outputs, curl commands).    |
| `/map`     | Instructs the AI to analyze your codebase and document the system architecture.                      |
| `/pause`   | Instructs the AI to dump its current session state for a clean handoff so context isn't lost.        |

> **Note:** These are typed directly as text chat messages to your AI assistant (e.g., Claude Desktop, Gemini, Cursor). They do not require any command-line execution or plugins.

---

## Core Rules of the Methodology

When the AI assumes its persona, it strictly follows the GSD Agency methodology:

1. **Planning Lock:** No code is written until a `SPEC.md` is finalized.
2. **State Persistence:** The AI maintains a `STATE.md` to remember decisions across sessions.
3. **Context Hygiene:** If the AI fails multiple times, it triggers a state dump and asks for a fresh session context. 
4. **Empirical Validation:** The AI must provide concrete proof that its code works (no "trust me").

---

## Recommended .gitignore

To isolate the GSD Agency toolkit and prevent methodology or state files from being committed to your project, add the following to your `.gitignore`:

```text
# GSD Methodology & State
.gsd/
STATE.md
ROADMAP.md
SPEC.md
PROJECT_RULES.md
ARCHITECTURE.md
STACK.md
GSD-STYLE.md
VERSION
CHANGELOG.md
model_capabilities.yaml

# Agent Configurations
.claude.md
.gemini/
.cursorrules
INSTRUCTIONS.md

# Toolkit Directories (if cloned locally)
.agent/
adapters/
agency-agents/
bin/
docs/
scripts/
```

---

## Credits

This toolkit would not exist without the incredible open-source work of two distinct projects. We have combined them here into a unified developer experience:

- **[agency-agents](https://github.com/msitarzewski/agency-agents)**: Created by Michael Sitarzewski (`@msitarzewski`). Provided the highly tuned, specialized AI personas that act as the domain experts in this workflow.
- **[get-shit-done](https://github.com/toonight/get-shit-done-for-antigravity)**: Created by `glittercowboy` (later adapted by `toonight`). Provided the strict spec-driven methodology, the atomic workflow rules, and the initial concept for the context engineering layer. 

Thank you to the original authors for developing the foundations of structured AI coding.
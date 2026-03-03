# Get Shit Done (GSD) Agency

**Stop vibecoding. Start shipping.**

This project is a powerful synthesis of two distinct paradigms: the strict, spec-driven methodology of **Get Shit Done**, combined with the deep, specialized domain expertise of **Agency Agents**.

By combining these concepts, you get a roster of **51 highly specialized AI experts** executing tasks within a rigid, spec-driven framework. Your AI assistant will no longer guess what to do; instead, it will plan, execute atomically, and verify empirically.

---

## The Agency: 51 AI Specialists Ready to Transform Your Workflow

A complete AI agency at your fingertips. Each agent is a specialized expert with a unique personality, specific processes, and proven deliverable standards.

### Designed for Quality

- **Specialized:** Deep expertise in their domain (not generic prompt templates).
- **Personality-Driven:** Unique voice, communication style, and approach.
- **Deliverable-Focused:** Real code, processes, and measurable outcomes.
- **Production-Ready:** Battle-tested workflows and success metrics.

### The 9 Divisions
*A preview of the expertise you can access:*

| Division             | Focus                         | Examples                                                     |
| -------------------- | ----------------------------- | ------------------------------------------------------------ |
| **Engineering (7)**  | Building the future           | Frontend Developer, Backend Architect, DevOps Automator      |
| **Design (6)**       | Beautiful, usable, delightful | UI Designer, UX Researcher, Brand Guardian                   |
| **Marketing (8)**    | Growing your audience         | Growth Hacker, TikTok Strategist, Reddit Community Builder   |
| **Product (3)**      | Building the right thing      | Sprint Prioritizer, Trend Researcher, Feedback Synthesizer   |
| **Project Mgmt (5)** | Keeping trains running        | Studio Producer, Project Shepherd, Senior Project Manager    |
| **Testing (7)**      | Breaking things safely        | Reality Checker, Evidence Collector, Performance Benchmarker |
| **Support (6)**      | The operational backbone      | Support Responder, Analytics Reporter, Finance Tracker       |
| **Spatial (6)**      | The immersive future          | XR Interface Architect, macOS Spatial Metal Engineer         |
| **Specialized (3)**  | Unique experts                | Agents Orchestrator, LSP/Index Engineer                      |

---

## Getting Started (Zero Dependency Setup)

This toolkit bridges your chosen persona directly into your project directory using native scripts. No deep global installations required.

### 1. Initialize the GSD Methodology in Your Project

Run these one-liners from inside **your target project directory** to instantly compose your GSD Agency configuration. 

> **Important:** This will securely download the methodology templates and prompt files to your project without impacting your global environment. It automatically grabs `PROJECT_RULES.md`, `GSD-STYLE.md`, and sample `.gitignore` rules for you.

#### Windows (PowerShell)
```powershell
Invoke-RestMethod https://raw.githubusercontent.com/BIJJUDAMA/get-shit-done-agency/main/bin/gsd-init.ps1 | Invoke-Expression
```

#### Linux / macOS (Bash)
```bash
curl -sL https://raw.githubusercontent.com/BIJJUDAMA/get-shit-done-agency/main/bin/gsd-init.sh | bash
```

### 2. Follow the Interactive Setup
1. **Select a Role:** The script lists the 51 specialized personas. Choose the expert you need.
2. **Environment Auto-Detection:** The script automatically detects if you are using `.gemini`, `.cursor`, `.claude`, etc.

The script dynamically bridges the chosen persona with the rigorous GSD Agency methodology rules and outputs a finalized system instructions file directly into your workspace.

**Headless Mode:**
```bash
bash bin/gsd-init.sh --role=engineering-senior-developer --env=claude
```

---

## The Workflow Commands

The true power of the GSD Agency lies in its extensive set of slash commands. Once initialized, the AI operates entirely through these commands sent via standard chat.

These commands enforce disciplined execution and project hygiene. 

### Core Engineering & Execution

**The Strategist:** Decompose requirements into executable phases in `ROADMAP.md` before coding.
```text
/plan
```

**The Engineer:** Safely implement the current phase from `STATE.md` using atomic checkpoints.
```text
/execute
```

**The Auditor:** Empirically validate the implemented work against the specs (e.g., test outputs).
```text
/verify
```

Engage systematic debugging protocols with persistent state tracking.
```text
/debug
```

**The Architect:** Analyze the codebase, update `ARCHITECTURE.md` and `STACK.md` with dependency graphs.
```text
/map
```

Context hygiene: Dump the AI's current session state for a clean handoff to avoid context loss.
```text
/pause
```

Restore context and progress from a previous session state snapshot.
```text
/resume
```

### Project & Milestone Management

Initialize a new project directory with deep context gathering.
```text
/new-project
```

Create a new overarching milestone broken down into distinct phases.
```text
/new-milestone
```

Audit a milestone for quality, completeness, and edge-cases.
```text
/audit-milestone
```

Create remediation plans to address gaps found during the audit.
```text
/plan-milestone-gaps
```

Mark the current milestone as complete and securely archive it.
```text
/complete-milestone
```

### Phase Operations

Clarify scope, approach, and risks of a phase *before* formal planning.
```text
/discuss-phase
```

Perform deep technical investigations required for an upcoming phase.
```text
/research-phase
```

Append a new phase to the end of your current `ROADMAP.md`.
```text
/add-phase
```

Insert a phase between existing phases (automatically renumbers subsequent phases).
```text
/insert-phase
```

Safely remove a phase from the roadmap, triggering necessary dependency impact analysis.
```text
/remove-phase
```

Check current position in the roadmap and determine immediate next steps.
```text
/progress
```

Review the foundational assumptions made during phase planning.
```text
/list-phase-assumptions
```

### Task Tracking & Utils

Rapidly capture a specific task or follow-up item for later.
```text
/add-todo
```

List and review all pending todo items across the project.
```text
/check-todos
```

Instruct the AI to search the web for external documentation.
```text
/web-search
```

### Toolkit Operations

Install the latest GSD workflow files directly from GitHub.
```text
/install
```

Update existing GSD toolkit files to their latest repo versions.
```text
/update
```

Show recent GSD paradigm changes and new feature announcements.
```text
/whats-new
```

Display an overview of all available commands and their usage.
```text
/help
```

---

## Core Rules of the Methodology

When the AI assumes its persona, it strictly follows the canonical rules defined in `PROJECT_RULES.md`:

1. **Spec-Driven Planning Lock:** No implementation code is written until a `SPEC.md` is explicitly finalized.
2. **State Persistence:** The AI continuously maintains a `STATE.md` document to remember decisions, progress, and blockers across separate chat sessions.
3. **Context Hygiene:** If the AI encounters cascading failures, it utilizes the Context Health Monitor to trigger a state dump and request a fresh session to prevent cognitive degradation.
4. **Empirical Validation:** The AI must provide concrete, empirical proof that its code works via terminal outputs, screenshots, or test results. "Trust me, it works" is strictly forbidden.

---

## Recommended `.gitignore`

When you run the init scripts, it's highly recommended you copy the `.gitignore-GSD-agency-sample` contents into your primary `.gitignore` to prevent GSD context files from polluting your git history:

```text
# --- Methodology & State Management ---
.gsd/
STATE.md
ROADMAP.md
SPEC.md
PROJECT_RULES.md
ARCHITECTURE.md
STACK.md
GSD-STYLE.md

# --- Agent Configurations & Adapters ---
.claude.md
.gemini/
.cursorrules
INSTRUCTIONS.md
```

---

## Credits

This unified methodology represents the convergence of specialized persona design and rigid execution frameworks:

- **[agency-agents](https://github.com/msitarzewski/agency-agents)**: Created by Michael Sitarzewski (`@msitarzewski`). Brought 51 highly tuned, specialized AI personas that act as the diverse domain experts.
- **[get-shit-done](https://github.com/toonight/get-shit-done-for-antigravity)**: Originally conceptualized by `glittercowboy`, expanded by `toonight`. Provided the strict spec-driven methodologies, context engineering patterns, and the foundational atomic workflow rules.

Thank you to the original authors for constructing the building blocks of professional-grade AI developer environments.
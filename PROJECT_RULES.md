# PROJECT_RULES.md — GSD Canonical Rules

> **Single Source of Truth** for the Get Shit Done methodology.
>
> Model-agnostic. All adapters and extensions reference this file.

---

## Core Protocol

**SPEC → PLAN → EXECUTE → VERIFY → COMMIT**

1. **SPEC**: Define requirements in `.gsd/SPEC.md` until status is `FINALIZED`
2. **PLAN**: Decompose into phases in `.gsd/ROADMAP.md`, then detailed plans
3. **EXECUTE**: Implement with atomic commits per task
4. **VERIFY**: Prove completion with empirical evidence
5. **COMMIT**: One task = one commit, message format: `type(scope): description`

**Planning Lock**: No implementation code until SPEC.md contains "Status: FINALIZED".

---

## Proof Requirements

Every change requires verification evidence. For v1.0.0, verification should be performed inside the **GSD Sandbox** (Docker).

| Change Type   | Required Proof                 |
| ------------- | ------------------------------ |
| API endpoint  | curl/HTTP response (Sandbox)   |
| UI change     | Screenshot                     |
| Build/compile | Command output (Sandbox)       |
| Test          | Test runner output (Sandbox)   |
| Config        | Verification command (Sandbox) |

**Never accept**: "It looks correct", "This should work", "I've done similar before".

**Always require**: Captured output from `gsd_sandbox`, screenshot, or test result.

---

## Search-First Discipline

**Before reading any file completely:**

1. **Search first** — Use grep, ripgrep, or IDE search to find relevant snippets
2. **Evaluate snippets** — Determine if full file read is justified
3. **Targeted reads** — Only read specific line ranges when needed

**Benefits:**

- Reduces context pollution
- Faster understanding of large codebases
- Prevents reading irrelevant code

**Anti-pattern**: Reading entire files "to understand the context" without searching first.

---

## Wave Execution

Plans are grouped into **waves** based on dependencies:

| Wave | Characteristic                    | Execution                      |
| ---- | --------------------------------- | ------------------------------ |
| 1    | Foundation tasks, no dependencies | Run in parallel                |
| 2    | Depends on Wave 1                 | Wait for Wave 1, then parallel |
| 3    | Depends on Wave 2                 | Wait for Wave 2, then parallel |

**Wave Completion Protocol:**

1. All tasks in wave verified
2. State snapshot created
3. Commit all wave work
4. Update STATE.md with position

---

## State Snapshots

At the end of each wave or significant work block, create a state snapshot:

```markdown
## Wave N Summary

**Objective:** {what this wave aimed to accomplish}

**Changes:**

- {change 1}
- {change 2}

**Files Touched:**

- {file1}
- {file2}

**Verification:**

- {command}: {result}

**Risks/Debt:**

- {any concerns}

**Next Wave TODO:**

- {item 1}
- {item 2}
```

---

## Model Independence

**Absolute Rule**: No rule, workflow, or skill may require a specific model provider.

**Allowed:**

- Optional adapters with provider-specific enhancements
- Capability-based recommendations (e.g., "use a reasoning model for planning")
- Examples mentioning specific models as illustrations

**Forbidden:**

- Hard dependencies on provider features
- Breaking behavior when a specific model is unavailable
- Duplicating canonical rules in adapters

**Adapter Pattern:**

```
adapters/
├── CLAUDE.md    # Optional Claude enhancements
├── GEMINI.md    # Optional Gemini enhancements
└── GPT_OSS.md   # Optional GPT/OSS enhancements
```

Each adapter must begin with:

> "Everything in this file is optional. For canonical rules, see PROJECT_RULES.md."

---

## Commit Conventions

**Format:**

```
type(scope): description
```

**Types:**

| Type       | Usage                                 |
| ---------- | ------------------------------------- |
| `feat`     | New feature                           |
| `fix`      | Bug fix                               |
| `docs`     | Documentation only                    |
| `refactor` | Code restructure (no behavior change) |
| `test`     | Adding/updating tests                 |
| `chore`    | Maintenance, dependencies             |

**Rules:**

- One task = one commit
- Verify before commit
- Scope = phase number for phase work (e.g., `feat(phase-1): ...`)

---

## Repository Structure

```
PROJECT_RULES.md          # ← This file (canonical rules)
GSD-STYLE.md              # Style and conventions

.agent/
├── workflows/            # Slash commands (/plan, /execute, etc.)
└── skills/               # Agent specializations

.gemini/                  # Gemini-specific configuration
.gsd/                     # Project state and artifacts
├── SPEC.md               # Requirements (must be FINALIZED)
├── ROADMAP.md            # Phases and progress
├── STATE.md              # Session memory
├── templates/            # Document templates
└── examples/             # Usage examples

adapters/                 # Optional model-specific enhancements
docs/                     # Operational documentation
scripts/                  # Utility scripts
```

---

## Context Management

**Context Quality Thresholds:**

| Usage  | Quality                                 |
| ------ | --------------------------------------- |
| 0-30%  | **PEAK** — Comprehensive, thorough work |
| 30-50% | **GOOD** — Solid, confident output      |
| 50-70% | **DEGRADING** — Efficiency mode         |
| 70%+   | **POOR** — Rushed, incomplete           |

**Context Hygiene Rules:**

- Keep plans under 50% context usage
- Fresh context for each plan execution
- After 3 debugging failures → state dump → fresh session
- STATE.md = memory across sessions

---

## Command Dictionary (v1.0.0)

### `/plan` (Requirement Decomposition)

Analyze requirements and write a detailed `SPEC.md`. Break work into atomic, executable phases. Update `STATE.md`.

### `/execute` (Atomic Implementation)

Implement _only_ the current phase from `STATE.md`. No scope creep.

### `/verify` (Empirical Grounding)

1. Generate a test script.
2. Run inside `gsd_sandbox`: `docker exec gsd_sandbox <command>`.
3. Only mark `[COMPLETED]` if output proves success.

### `/map` (AST & Dependency Graphing)

Trace actual imports/exports. Generate a Mermaid.js graph in `ARCHITECTURE.md`. Only read files connected on the graph.

### `/sync` (Human-AI Reconciliation)

1. Read `.gsd/PENDING_SYNC.md` (populated by git post-commit hook).
2. Reconcile manual changes with `STATE.md`.
3. Update `ARCHITECTURE.md` graph.

### `/escalate` (Anti-Hallucination Protocol)

**Trigger**: `/verify` fails 3 times OR user types `/escalate`.
Rule: Stop coding. No apologies.

1. Mark phase `[BLOCKED]` in `STATE.md`.
2. Generate `ESCALATION_REPORT.md` (Goal, Approaches, Errors, Hypothesis, Required Persona).
3. Provide handoff prompt for a fresh session.

### `/handoff` (Context Compression)

Compress working context into `HANDOFF.yaml`. Detail phase, achieved objectives, files modified, and next steps.

---

## Token Efficiency Rules

**Goal:** Minimize token consumption while maintaining output quality.

**Loading Rules:**

- Search first (grep, ripgrep) before full read.
- Use outline for files >200 lines.
- Reference summaries instead of re-reading.

**Budget Thresholds:**

- 0-50%: Proceed normally.
- 50-70%: Switch to outline mode.
- 70%+: State dump + fresh session required.

---

## Quick Reference (v1.0.0)

```
Before coding    → SPEC.md must be FINALIZED
Before file read → Search first, then targeted read
After each task  → Commit + update STATE.md
After 3 failures → /escalate (State dump + fresh session)
Before "Done"    → Empirical proof (Sandbox) captured
Manual changes   → /sync to update brain
Persona switch   → /handoff (Generate HANDOFF.yaml)
```

---

_GSD Methodology — Model-Agnostic Edition_
_Reference implementation for multi-LLM environments_

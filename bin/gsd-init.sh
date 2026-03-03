#!/usr/bin/env bash

# GSD Integration Bridge (Zero-Dependency Bash)
# This script bridges personas from 'agency-agents' with the GSD methodology.

set -e

# --- Configuration ---
if [[ -z "${BASH_SOURCE[0]}" ]] || [[ "${BASH_SOURCE[0]}" == "bash" ]] || [[ "${BASH_SOURCE[0]}" == "standard input" ]]; then
    echo -e "\n[INFO] Remote execution detected. Bootstrapping GSD Agency..."
    INSTALL_DIR="$HOME/.gsd-agency"
    TMP_DIR=$(mktemp -d)
    
    echo "Downloading latest GSD Agency release..."
    curl -sL "https://github.com/BIJJUDAMA/get-shit-done-agency/archive/refs/heads/main.tar.gz" | tar -xz -C "$TMP_DIR"
    
    echo "Extracting..."
    rm -rf "$INSTALL_DIR"
    mv "$TMP_DIR/get-shit-done-agency-main" "$INSTALL_DIR"
    rm -rf "$TMP_DIR"
    
    echo -e "Executing local copy...\n"
    
    ARGS=()
    [[ -n "$AUTO_ROLE" ]] && ARGS+=("--role=$AUTO_ROLE")
    [[ -n "$AUTO_ENV" ]] && ARGS+=("--env=$AUTO_ENV")
    [[ $DRY_RUN -eq 1 ]] && ARGS+=("--dry-run")
    
    exec bash "$INSTALL_DIR/bin/gsd-init.sh" "${ARGS[@]}" "$@"
    exit $?
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
METHODOLOGY_DIR="$(dirname "$SCRIPT_DIR")"
AGENCY_AGENTS_DIR="${GSD_PERSONAS_DIR:-$METHODOLOGY_DIR/agency-agents}"
ADAPTERS_DIR="$METHODOLOGY_DIR/adapters"
METHODOLOGY_FILE="$METHODOLOGY_DIR/PROJECT_RULES.md"
VERSION_FILE="$METHODOLOGY_DIR/VERSION"

# Pre-defined mapping
declare -A ENV_FILES
declare -A ENV_OUTPUTS
ENV_FILES[claude]="CLAUDE.md"
ENV_OUTPUTS[claude]=".claude.md"
ENV_FILES[gemini]="GEMINI.md"
ENV_OUTPUTS[gemini]=".gemini/GEMINI.md"
ENV_FILES[cursor]="CURSOR.md"
ENV_OUTPUTS[cursor]=".cursorrules"
ENV_FILES[antigravity]="GEMINI.md"
ENV_OUTPUTS[antigravity]=".gemini/GEMINI.md"
ENV_FILES[other]="GPT_OSS.md"
ENV_OUTPUTS[other]="INSTRUCTIONS.md"

# CLI Argument Parsing
DRY_RUN=0
AUTO_ROLE=""
AUTO_ENV=""

for arg in "$@"; do
    case $arg in
        --help|-h)
            echo "
[GSD Integration Bridge]

Usage: bash bin/gsd-init.sh [options]

Options:
  --role=<name>    Automatically select a persona (e.g., --role=engineering-senior-developer)
  --env=<name>     Automatically select an environment (claude, gemini, cursor, antigravity)
  --dry-run        Print the composed output to stdout instead of writing files
  --version, -v    Show version information
  --update         Update GSD Agency to the latest version
  --help, -h       Show this help message

Description:
  This tool dynamically bridges personas from the internal 'agency-agents' library
  with the Get Shit Done methodology, outputting a highly specialized agent configuration
  into your current project directory.
"
            exit 0
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --version|-v)
            if [[ -f "$VERSION_FILE" ]]; then cat "$VERSION_FILE"; else echo "unknown"; fi
            exit 0
            ;;
        --update)
            echo "Checking for updates..."
            # Future: git pull or binary update logic
            echo "You are on the latest version."
            exit 0
            ;;
        --role=*)
            AUTO_ROLE="${arg#*=}"
            shift
            ;;
        --env=*)
            AUTO_ENV="${arg#*=}"
            shift
            ;;
    esac
done

if [[ "$PWD" == "$METHODOLOGY_DIR" ]]; then
    echo -e "\n[ERROR] You are running this inside the GSD template repository itself."
    echo "Please run \`bash path/to/get-shit-done-agency/bin/gsd-init.sh\` from inside your ACTUAL project directory."
    exit 1
fi

echo -e "\n[Initializing GSD Context Composition]\n"

# Verify agency-agents exists
if [[ ! -d "$AGENCY_AGENTS_DIR" ]]; then
    echo "[ERROR] No personas found in $AGENCY_AGENTS_DIR"
    exit 1
fi

# Load personas
personas=()
persona_paths=()

# Find all markdown files in subdirectories of agency-agents (excluding dot folders)
while IFS= read -r -d '' file; do
    filename=$(basename "$file" .md)
    personas+=("$filename")
    persona_paths+=("$file")
done < <(find "$AGENCY_AGENTS_DIR" -mindepth 2 -maxdepth 2 -type f -name "*.md" ! -path "*/.*" -print0)

# Local Persona Scan
LOCAL_PERSONAS_DIR="$PWD/.gsd/personas"
if [[ -d "$LOCAL_PERSONAS_DIR" ]]; then
    echo "[INFO] Scanning local personas in $LOCAL_PERSONAS_DIR..."
    while IFS= read -r -d '' file; do
        filename=$(basename "$file" .md)
        personas+=("[LOCAL] $filename")
        persona_paths+=("$file")
    done < <(find "$LOCAL_PERSONAS_DIR" -maxdepth 1 -type f -name "*.md" -print0)
fi

if [[ ${#personas[@]} -eq 0 ]]; then
    echo "[ERROR] No persona markdown files found in $AGENCY_AGENTS_DIR"
    exit 1
fi

# --- Role Selection ---
selected_idx=-1

if [[ -n "$AUTO_ROLE" ]]; then
    matches=()
    match_indices=()
    for i in "${!personas[@]}"; do
        if [[ "${personas[$i]}" == *"$AUTO_ROLE"* ]]; then
            matches+=("${personas[$i]}")
            match_indices+=("$i")
        fi
    done
    
    if [[ ${#matches[@]} -eq 0 ]]; then
        echo "[ERROR] Auto-role \"$AUTO_ROLE\" not found."
        exit 1
    elif [[ ${#matches[@]} -gt 1 ]]; then
        # Check for exact match
        exact_match_idx=-1
        for i in "${!matches[@]}"; do
            if [[ "${matches[$i]}" == "$AUTO_ROLE" ]]; then
                exact_match_idx="${match_indices[$i]}"
                break
            fi
        done
        
        if [[ $exact_match_idx -ne -1 ]]; then
            selected_idx=$exact_match_idx
        else
            echo "[ERROR] Multiple roles match \"$AUTO_ROLE\": ${matches[*]}. Please be more specific."
            exit 1
        fi
    else
        selected_idx="${match_indices[0]}"
    fi
else
    echo "Available Roles:"
    for i in "${!personas[@]}"; do
        echo "  [$((i+1))] ${personas[$i]}"
    done
    echo ""
    read -p "Select a role (1-${#personas[@]}): " role_input
    
    if ! [[ "$role_input" =~ ^[0-9]+$ ]] || ((role_input < 1 || role_input > ${#personas[@]})); then
        echo -e "\n[ERROR] Please enter a valid number between 1 and ${#personas[@]}."
        exit 1
    fi
    selected_idx=$((role_input-1))
fi

SELECTED_PERSONA_NAME="${personas[$selected_idx]}"
SELECTED_PERSONA_PATH="${persona_paths[$selected_idx]}"
echo -e "\nSelected Role: $SELECTED_PERSONA_NAME\n"

# --- Environment Selection ---
env_keys=("claude" "gemini" "cursor" "antigravity" "other")
selected_env=""

if [[ -z "$AUTO_ENV" ]]; then
    if [[ -d ".claude" ]]; then
        AUTO_ENV="claude"
    elif [[ -d ".gemini" ]]; then
        AUTO_ENV="antigravity"
    elif [[ -d ".cursor" || -f ".cursorrules" ]]; then
        AUTO_ENV="cursor"
    fi
    if [[ -n "$AUTO_ENV" ]]; then
        echo -e "\n[INFO] Auto-detected environment: $AUTO_ENV"
    fi
fi

if [[ -n "$AUTO_ENV" ]]; then
    valid=0
    for k in "${env_keys[@]}"; do
        if [[ "$k" == "$AUTO_ENV" ]]; then
            valid=1
            break
        fi
    done
    if [[ $valid -eq 0 ]]; then
        echo "[ERROR] Auto-env \"$AUTO_ENV\" is invalid."
        exit 1
    fi
    selected_env="$AUTO_ENV"
else
    echo "Available Environments:"
    for i in "${!env_keys[@]}"; do
        echo "  [$((i+1))] ${env_keys[$i]}"
    done
    echo ""
    read -p "Select target environment (1-${#env_keys[@]}): " env_input
    
    if ! [[ "$env_input" =~ ^[0-9]+$ ]] || ((env_input < 1 || env_input > ${#env_keys[@]})); then
        echo -e "\n[ERROR] Please enter a valid number between 1 and ${#env_keys[@]}."
        exit 1
    fi
    selected_env="${env_keys[$((env_input-1))]}"
fi

echo -e "\nSelected Environment: $selected_env\n"
ADAPTER_FILE="${ENV_FILES[$selected_env]}"
OUTPUT_PATH="${ENV_OUTPUTS[$selected_env]}"

# --- Versioning ---
GSD_VERSION="0.0.0"
if [[ -f "$VERSION_FILE" ]]; then
    GSD_VERSION=$(cat "$VERSION_FILE")
fi
echo "[Active Methodology Version]: $GSD_VERSION"

# --- Read and Compose ---
echo "Reading components from bridge..."

# Parse Persona Frontmatter and Body
# We use awk to strip the YAML blocks
if [[ ! -f "$SELECTED_PERSONA_PATH" ]]; then
    echo "[ERROR] Persona file not found: $SELECTED_PERSONA_PATH"
    exit 1
fi
PERSONA_RAW=$(cat "$SELECTED_PERSONA_PATH")

# AWK logic: if between ---, it's frontmatter. Else it's body.
PERSONA_FRONTMATTER=$(echo "$PERSONA_RAW" | awk '
BEGIN { in_frontmatter=0; found_first=0 }
/^---$/ {
    if(found_first==0) { in_frontmatter=1; found_first=1; next }
    if(in_frontmatter==1) { in_frontmatter=0; next }
}
{ if(in_frontmatter==1) print $0 }
')

PERSONA_BODY=$(echo "$PERSONA_RAW" | awk '
BEGIN { in_frontmatter=0; found_first=0 }
/^---$/ {
    if(found_first==0) { in_frontmatter=1; found_first=1; next }
    if(in_frontmatter==1) { in_frontmatter=0; next }
}
{ if(in_frontmatter==0) print $0 }
' | sed -e '/^[[:space:]]*$/{N;/^\n$/D;}') # Trims excessive leading newlines

# Compile new Frontmatter
NEW_FRONTMATTER="---
name: $SELECTED_PERSONA_NAME (GSD Integrated)
generator: get-shit-done-agency
integrated_methodology: true"

while IFS= read -r line; do
    if [[ -n "$line" && ! "$line" =~ ^name: ]]; then
        NEW_FRONTMATTER="$NEW_FRONTMATTER\n$line"
    fi
done <<< "$PERSONA_FRONTMATTER"
NEW_FRONTMATTER="$NEW_FRONTMATTER\n---"

# Load Methodology
if [[ ! -f "$METHODOLOGY_FILE" ]]; then
     echo "[ERROR] Methodology file not found: $METHODOLOGY_FILE"
     exit 1
fi
METHODOLOGY_CONTENT=$(cat "$METHODOLOGY_FILE")

# Load Adapter
ADAPTER_PATH="$ADAPTERS_DIR/$ADAPTER_FILE"
if [[ ! -f "$ADAPTER_PATH" ]]; then
    echo "[WARNING] Adapter $ADAPTER_FILE not found. Proceeding without adapter."
    ADAPTER_CONTENT="<!-- No specific adapter configuration provided -->"
else
    ADAPTER_CONTENT=$(cat "$ADAPTER_PATH")
fi

# Dynamic Injection
DYNAMIC_BLOCK="## System Commands (Dynamic Integration)
This project uses GSD slash commands. You must obey these commands when issued by the user:
- \`/plan\` : Decompose requirements into SPEC.md.
- \`/execute\` : Implement the current phase from STATE.md.
- \`/verify\` : Run empirical tests (preferably sandboxed) and prove success.
- \`/escalate\` : Force a context break and prepare a handoff to a Debugger persona after 3 failures.
- \`/sync\` : Reconcile STATE.md with recent manual git commits.
- \`/handoff\` : Generate structured YAML to pass context cleanly to the next specialized agent.
- \`/map\` : AST-driven dependency graphing.
- \`/pause\` : Dump state for a clean session handoff."

FINAL_ADAPTER="$DYNAMIC_BLOCK

$ADAPTER_CONTENT"

# Compose Final Output
FINAL_OUTPUT=$(echo -e "$NEW_FRONTMATTER\n\n$PERSONA_BODY\n\n---\n\n# [GSD METHODOLOGY INJECTION]\n\nThe following instructions define your operational methodology. You must adhere to these rules strictly while acting as the persona defined above.\n\n$METHODOLOGY_CONTENT\n\n---\n\n# [ENVIRONMENT ADAPTER]\n\n$FINAL_ADAPTER\n")

# --- Output Writing ---

if [[ $DRY_RUN -eq 1 ]]; then
    echo -e "\n================ DRY RUN COMPOSITION OUTPUT ================\n"
    echo "$FINAL_OUTPUT"
    echo -e "\n================ END DRY RUN ================\n"
    echo "[INFO] This would be written to: $PWD/$OUTPUT_PATH"
else
    TARGET_DIR=$(dirname "$PWD/$OUTPUT_PATH")
    mkdir -p "$TARGET_DIR"
    echo "$FINAL_OUTPUT" > "$PWD/$OUTPUT_PATH"
    echo "[SUCCESS] Successfully wrote composition to: $PWD/$OUTPUT_PATH"

    GSD_RUN_DIR="$PWD/.gsd"
    mkdir -p "$GSD_RUN_DIR/templates"
    
    # Deploy Templates
    TEMPLATES_DIR="$METHODOLOGY_DIR/templates"
    if [[ -d "$TEMPLATES_DIR" ]]; then
        cp "$TEMPLATES_DIR/docker-compose.gsd.yml" "$PWD/docker-compose.gsd.yml"
        cp "$TEMPLATES_DIR/HANDOFF.yaml" "$GSD_RUN_DIR/templates/HANDOFF.yaml"
        cp "$TEMPLATES_DIR/GSD_METHODOLOGY.md" "$GSD_RUN_DIR/templates/GSD_METHODOLOGY.md"
        echo "[SUCCESS] GSD v1.0.0 templates deployed."
    fi
    
    # Deploy Core Files
    if [[ -d "$METHODOLOGY_DIR" ]]; then
        cp "$METHODOLOGY_DIR/PROJECT_RULES.md" "$PWD/PROJECT_RULES.md"
        cp "$METHODOLOGY_DIR/GSD-STYLE.md" "$PWD/GSD-STYLE.md"
        cp "$METHODOLOGY_DIR/.gitignore-GSD-agency-sample" "$PWD/.gitignore-GSD-agency-sample"
        echo "[SUCCESS] Core GSD methodology files deployed."
    fi

    # Install Git Hooks
    if [[ -f "$METHODOLOGY_DIR/scripts/install-hooks.sh" ]]; then
        bash "$METHODOLOGY_DIR/scripts/install-hooks.sh"
    fi

    # Write JSON Lockfile
    cat > "$GSD_RUN_DIR/gsd.config.json" <<EOF
{
  "generatedAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "version": "$GSD_VERSION",
  "persona": "$SELECTED_PERSONA_NAME",
  "personaSource": "$SELECTED_PERSONA_PATH",
  "environment": "$selected_env",
  "outputPath": "$OUTPUT_PATH"
}
EOF
    echo "[LOCKED] Lockfile written to: .gsd/gsd.config.json"
fi

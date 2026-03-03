#!/bin/bash
# GSD Agency: Git Hook Installer

HOOKS_DIR=".git/hooks"
POST_COMMIT="$HOOKS_DIR/post-commit"

if [[ ! -d ".git" ]]; then
    echo "[ERROR] Not a git repository. Skip hook installation."
    exit 1
fi

mkdir -p .gsd

echo "Installing GSD post-commit hook..."

cat <<'EOF' > "$POST_COMMIT"
#!/bin/bash
# GSD Agency: Post-Commit State Sync

SYNC_FILE=".gsd/PENDING_SYNC.md"
mkdir -p .gsd

# Extract the latest commit details
COMMIT_HASH=$(git rev-parse --short HEAD)
COMMIT_MSG=$(git log -1 --pretty=format:%B)
FILES_CHANGED=$(git diff-tree --no-commit-id --name-status -r HEAD)

# Format the payload for the AI
cat <<EOF_SYNC > "$SYNC_FILE"
# Human Context Sync Required

**Trigger Event:** Manual Git Commit
**Commit Hash: $COMMIT_HASH**
**Message: $COMMIT_MSG**

## Files Modified:
\`\`\`text
$FILES_CHANGED
\`\`\`

**Action Required:** Read this file, reconcile these changes against \`STATE.md\`, and await the \`/sync\` command.
EOF_SYNC

echo "✓ GSD Agency: PENDING_SYNC.md updated for AI context."
EOF

chmod +x "$POST_COMMIT"
echo "[SUCCESS] GSD Git hooks installed."

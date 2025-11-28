#!/bin/bash
# Session Start Helper
# Outputs context for an AI agent starting a new session
# Usage: ./scripts/session_start.sh [project_dir]

PROJECT_DIR="${1:-.}"

cd "$PROJECT_DIR" || { echo "❌ Cannot access: $PROJECT_DIR"; exit 1; }

# Verify required files exist
if [ ! -f "claude-progress.txt" ]; then
    echo "❌ Missing: claude-progress.txt"
    echo "   This doesn't look like a long-running-agent project."
    exit 1
fi

if [ ! -f "feature_list.json" ]; then
    echo "❌ Missing: feature_list.json"
    exit 1
fi

echo "═══════════════════════════════════════════════════════════════"
echo "                    SESSION START CONTEXT                       "
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📁 Project: $(basename "$(pwd)")"
echo "📍 Path: $(pwd)"
echo ""

# Git status
echo "─────────────────────────────────────────────────────────────────"
echo "📋 GIT STATUS"
echo "─────────────────────────────────────────────────────────────────"
echo "Branch: $(git branch --show-current 2>/dev/null || echo 'not a git repo')"
echo ""
echo "Recent commits:"
git log --oneline -5 2>/dev/null || echo "No commits yet"
echo ""

# Progress summary
echo "─────────────────────────────────────────────────────────────────"
echo "📝 PROGRESS LOG (last session)"
echo "─────────────────────────────────────────────────────────────────"
# Get the last session entry (everything after the last "## Session")
awk '/^## Session/{p=1; content=""} p{content=content"\n"$0} END{print content}' claude-progress.txt | head -50
echo ""

# Feature status
echo "─────────────────────────────────────────────────────────────────"
echo "📊 FEATURE STATUS"
echo "─────────────────────────────────────────────────────────────────"
TOTAL=$(grep -c '"id":' feature_list.json 2>/dev/null || echo "0")
PASSING=$(grep -c '"passes": true' feature_list.json 2>/dev/null || echo "0")
echo "Progress: $PASSING / $TOTAL features passing"
echo ""

echo "Incomplete features (next priorities):"
# Extract incomplete features using grep/sed (works without jq)
grep -B5 '"passes": false' feature_list.json | grep -E '"id"|"description"|"priority"' | head -15
echo ""

# Environment check
echo "─────────────────────────────────────────────────────────────────"
echo "🔧 ENVIRONMENT"
echo "─────────────────────────────────────────────────────────────────"
if [ -x "./init.sh" ]; then
    echo "init.sh: ✓ exists and executable"
else
    echo "init.sh: ⚠️  missing or not executable"
fi

# Check for running processes on common ports
for port in 3000 5000 8000 8080; do
    if lsof -ti:$port > /dev/null 2>&1; then
        echo "Port $port: ⚠️  something running"
    fi
done
echo ""

echo "═══════════════════════════════════════════════════════════════"
echo "                      YOUR INSTRUCTIONS                         "
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "1. Run: ./init.sh"
echo "2. Pick ONE incomplete feature from above"
echo "3. Implement and test it end-to-end"
echo "4. Update feature_list.json (passes: true)"
echo "5. Append session summary to claude-progress.txt"
echo "6. Commit: git commit -am 'feat(FXXX): description'"
echo ""
echo "Remember: ONE feature per session. Test before marking done."
echo ""

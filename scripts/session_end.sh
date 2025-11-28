#!/bin/bash
# Session End Validator
# Checks that the agent properly updated state before ending
# Usage: ./scripts/session_end.sh [project_dir]

PROJECT_DIR="${1:-.}"

cd "$PROJECT_DIR" || { echo "❌ Cannot access: $PROJECT_DIR"; exit 1; }

echo "═══════════════════════════════════════════════════════════════"
echo "                   SESSION END VALIDATION                       "
echo "═══════════════════════════════════════════════════════════════"
echo ""

ERRORS=0
WARNINGS=0

# Check 1: Git status
echo "🔍 Checking git status..."
if git diff --quiet 2>/dev/null; then
    if git diff --cached --quiet 2>/dev/null; then
        echo "   ✓ All changes committed"
    else
        echo "   ⚠️  Staged changes not committed"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo "   ❌ Uncommitted changes detected"
    git status --short
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Check 2: Recent commit
echo "🔍 Checking recent commits..."
LAST_COMMIT=$(git log -1 --format="%H %s" 2>/dev/null)
if [ -n "$LAST_COMMIT" ]; then
    COMMIT_AGE=$(git log -1 --format="%cr" 2>/dev/null)
    echo "   Last commit ($COMMIT_AGE):"
    echo "   $(git log -1 --oneline)"
    
    # Check if commit message references a feature
    if echo "$LAST_COMMIT" | grep -qiE "F[0-9]{3}|feat|fix"; then
        echo "   ✓ Commit references feature ID"
    else
        echo "   ⚠️  Commit should reference feature ID (e.g., F001)"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo "   ❌ No commits found"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Check 3: Progress file updated
echo "🔍 Checking progress file..."
if [ -f "claude-progress.txt" ]; then
    # Check if file was modified recently (within last hour)
    PROGRESS_MOD=$(stat -c %Y claude-progress.txt 2>/dev/null || stat -f %m claude-progress.txt 2>/dev/null)
    NOW=$(date +%s)
    AGE=$((NOW - PROGRESS_MOD))
    
    if [ $AGE -lt 3600 ]; then
        echo "   ✓ Progress file updated recently"
    else
        echo "   ⚠️  Progress file may not have been updated this session"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    # Check for session entry
    SESSION_COUNT=$(grep -c "^## Session" claude-progress.txt)
    echo "   Sessions logged: $SESSION_COUNT"
else
    echo "   ❌ Progress file missing"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Check 4: Feature list
echo "🔍 Checking feature list..."
if [ -f "feature_list.json" ]; then
    TOTAL=$(grep -c '"id":' feature_list.json 2>/dev/null || echo "0")
    PASSING=$(grep -c '"passes": true' feature_list.json 2>/dev/null || echo "0")
    echo "   Features: $PASSING / $TOTAL passing"
    
    if [ "$PASSING" -gt 0 ]; then
        echo "   ✓ At least one feature marked passing"
    else
        echo "   ⚠️  No features marked as passing yet"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo "   ❌ Feature list missing"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Check 5: App health (optional)
echo "🔍 Checking app health..."
HEALTHY=false
for port in 3000 5000 8000 8080; do
    if curl -s "http://localhost:$port" > /dev/null 2>&1 || \
       curl -s "http://localhost:$port/health" > /dev/null 2>&1; then
        echo "   ✓ App responding on port $port"
        HEALTHY=true
        break
    fi
done
if ! $HEALTHY; then
    echo "   ⚠️  No app detected on common ports (may be expected)"
fi
echo ""

# Summary
echo "═══════════════════════════════════════════════════════════════"
echo "                        SUMMARY                                 "
echo "═══════════════════════════════════════════════════════════════"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✅ Session ended cleanly!"
    echo ""
    echo "Next session should:"
    echo "  1. Run: ./init.sh"
    echo "  2. Read: claude-progress.txt"
    echo "  3. Pick next feature from: feature_list.json"
elif [ $ERRORS -eq 0 ]; then
    echo "⚠️  Session ended with $WARNINGS warning(s)"
    echo "   Consider addressing warnings before next session."
else
    echo "❌ Session ended with $ERRORS error(s) and $WARNINGS warning(s)"
    echo "   Please fix errors before ending session!"
fi
echo ""

exit $ERRORS

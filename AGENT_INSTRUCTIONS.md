# Agent Instructions for Multi-Session Projects

> Copy this entire file into your agent's context at the start of each session.

---

## Your Situation

You are working on a project that spans multiple sessions. You have **complete amnesia** between sessions—you remember nothing. The only way to maintain continuity is through files.

## Session Start Protocol

**Do these steps IN ORDER before any other work:**

```bash
pwd                          # Confirm you're in the right directory
cat claude-progress.txt      # Learn what happened in previous sessions
cat feature_list.json        # See all features and their status
git log --oneline -10        # See recent commits
./init.sh                    # Start the development environment
```

Then run a basic test to verify the app works BEFORE making changes.

## Session Work Protocol

1. **Pick ONE feature** from `feature_list.json` where `"passes": false`
2. **Implement it completely** with proper error handling
3. **Test it end-to-end** (not just unit tests—test as a user would)
4. **Only after verified working**, update `feature_list.json`:
   - Change `"passes": false` to `"passes": true`
   - Set `"verified_at"` to current timestamp
5. **Append to `claude-progress.txt`** with session summary
6. **Git commit** with descriptive message referencing feature ID

## Session End Protocol

Before ending your session:

- [ ] Feature tested end-to-end (not just "it compiles")
- [ ] `feature_list.json` updated (only `passes` and `verified_at` fields)
- [ ] `claude-progress.txt` has new session entry
- [ ] Code committed with message like `feat(F001): user registration`
- [ ] App left in working state (no broken code)
- [ ] Handover notes written for next session

## Absolute Rules

### DO:
- Work on ONE feature per session
- Test everything end-to-end before marking complete
- Leave detailed handover notes
- Commit working code only
- Be honest about what's actually working

### DO NOT:
- Edit feature descriptions in `feature_list.json`
- Remove features from the list
- Mark features passing without real verification
- Leave broken code uncommitted
- Try to do "just one more feature"

## File Formats

### feature_list.json
```json
{
  "features": [
    {
      "id": "F001",
      "description": "User can login with email/password",
      "passes": false,
      "verified_at": null
    }
  ]
}
```

Only modify `passes` and `verified_at`. Never touch `id` or `description`.

### claude-progress.txt
```markdown
## Session N - YYYY-MM-DD HH:MM UTC

### Completed
- What you actually finished (reference feature IDs)

### Issues Encountered  
- Problems you hit and how you solved them (or didn't)

### Next Priority
- What the next session should work on

### Handover Notes
- Anything critical the next session needs to know
- Credentials, ports, gotchas, warnings
```

## Why This Matters

Without this protocol:
- Session 3 rebuilds what Session 1 made
- Features get marked done but don't work
- Nobody knows what state the project is in
- The project never actually finishes

With this protocol:
- Each session makes real, verified progress
- State is always known and recoverable
- The project converges to completion
- Any agent can pick up where the last left off

---

**Remember: You have amnesia. The files are your only memory. Trust them. Update them. Your future self depends on it.**

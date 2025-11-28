# Long-Running Agent Template

A universal pattern for AI agents that work across multiple sessions without losing context.  

## The Problem

LLMs have amnesia between sessions. Ask Claude/GPT/Gemini to build something complex, and by session 3 it's forgotten what it built in session 1.

## The Solution

**Externalize state into files the agent reads/writes every session.**

```
Session 1: Agent reads nothing → creates state files → commits
Session 2: Agent reads state → picks ONE task → updates state → commits  
Session 3: Agent reads state → picks ONE task → updates state → commits
...
Session N: Project complete, all features passing
```

## Quick Start

```bash
# Clone this template
git clone https://github.com/YOUR_USERNAME/long-running-agent-template.git
cd long-running-agent-template

# Create a new project
./scripts/new_project.sh my-awesome-app ~/projects

# Start working
cd ~/projects/my-awesome-app
cat claude-progress.txt      # See current state
cat feature_list.json        # See what needs doing
```

## Core Files

Every project using this pattern has three files:

| File | Purpose | Agent Rules |
|------|---------|-------------|
| `feature_list.json` | All requirements with pass/fail status | Only modify `passes` field |
| `claude-progress.txt` | Human-readable session log | Append only, never delete |
| `init.sh` | Dev environment startup | Run at session start |

## Teaching Any Agent

### Option A: System Prompt (Copy-Paste)

Add this to your agent's system prompt:

```markdown
## Multi-Session Protocol

You have amnesia between sessions. At the START of every session:
1. Run: cat claude-progress.txt
2. Run: cat feature_list.json  
3. Run: ./init.sh
4. Pick ONE feature where passes=false
5. Implement it fully with tests
6. Update feature_list.json (only change passes to true)
7. Append session summary to claude-progress.txt
8. Git commit with descriptive message

RULES:
- ONE feature per session, no exceptions
- Test end-to-end before marking passes=true
- Never edit feature descriptions
- Always leave code in working state
```

### Option B: Skill File

Point your agent to read `AGENT_INSTRUCTIONS.md` at session start.

### Option C: Wrapper Script

Use the provided session scripts:

```bash
# Start of session - shows agent what to do
./scripts/session_start.sh /path/to/project

# End of session - validates state was updated
./scripts/session_end.sh /path/to/project
```

## File Formats

### feature_list.json

```json
{
  "project_name": "My App",
  "features": [
    {
      "id": "F001",
      "category": "functional",
      "priority": "critical",
      "description": "User can create account with email/password",
      "steps": [
        "Navigate to /register",
        "Enter valid email and password",
        "Click submit",
        "Verify account created"
      ],
      "passes": false,
      "verified_at": null
    }
  ]
}
```

**Why JSON?** Models are less likely to accidentally corrupt structured data. Markdown checkboxes invite freeform editing → drift.

### claude-progress.txt

```markdown
# Project Progress

## Session 1 - 2025-01-15 10:00 UTC

### Completed
- Set up project scaffold
- Created feature list with 20 features

### Next Priority
- F001: User registration

### Environment Notes
- Backend: port 8000
- Frontend: port 3000
```

### init.sh

```bash
#!/bin/bash
set -e

# Kill stale processes
lsof -ti:3000 | xargs kill -9 2>/dev/null || true

# Install deps
npm install

# Start servers
npm run dev &

echo "✅ Ready: http://localhost:3000"
```

## Feature ID Conventions

| Range | Category |
|-------|----------|
| F001-F099 | Core functionality |
| F100-F199 | Integrations |
| F200-F299 | UI/UX |
| F300-F399 | Performance |
| F400-F499 | Security |
| F500+ | Infrastructure |

## Priority Levels

- `critical` - MVP blocker
- `high` - Production requirement  
- `medium` - Important enhancement
- `low` - Nice to have

## Common Failure Modes

| Problem | Cause | Fix |
|---------|-------|-----|
| Agent tries to build everything at once | No feature list constraints | Enforce ONE feature per session |
| Agent marks things done that don't work | No testing requirement | Require e2e test before passes=true |
| Next session confused | Poor handover notes | Mandate progress file update |
| Code broken between sessions | No clean state rule | Always commit working code |
| Features mysteriously change | Editing descriptions | JSON structure + rules prevent this |

## Works With

- **Claude** (claude.ai, API, Claude Code)
- **GPT-4** (ChatGPT, API)
- **Gemini** (AI Studio, API)
- **Local models** (Ollama, llama.cpp)
- **Agent frameworks** (LangChain, AutoGPT, CrewAI)
- **Any LLM that can read/write files**

## Project Structure

```
long-running-agent-template/
├── README.md                 # You are here
├── AGENT_INSTRUCTIONS.md     # Minimal prompt for any agent
├── templates/
│   ├── feature_list.json     # Template feature tracker
│   ├── progress.txt          # Template progress log
│   └── init.sh              # Template startup script
├── scripts/
│   ├── new_project.sh       # Create new project from template
│   ├── session_start.sh     # Session start helper
│   └── session_end.sh       # Session end validator
└── examples/
    └── trading-dashboard/   # Example project
```

## License

MIT - Use however you want.



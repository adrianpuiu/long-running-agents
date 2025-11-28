#!/bin/bash
# Trading Analytics Dashboard - Development Environment Initialization
# Run this at the start of each coding session

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_ROOT"

echo "🔄 Initializing Trading Analytics Dashboard..."
echo ""

# ============================================
# CLEANUP: Kill any stale processes
# ============================================
cleanup_ports() {
    echo "🧹 Cleaning up stale processes..."
    local ports=("5173" "8000")
    for port in "${ports[@]}"; do
        lsof -ti:$port 2>/dev/null | xargs kill -9 2>/dev/null || true
    done
}
cleanup_ports

# ============================================
# BACKEND: Python/FastAPI
# ============================================
setup_backend() {
    echo "🐍 Setting up Python backend..."
    
    cd "$PROJECT_ROOT/backend"
    
    # Create venv if not exists
    if [ ! -d "venv" ]; then
        python3 -m venv venv
    fi
    
    # Activate and install deps
    source venv/bin/activate
    pip install -q -r requirements.txt 2>/dev/null || pip install -r requirements.txt
    
    # Start FastAPI server
    echo "🚀 Starting FastAPI server on port 8000..."
    uvicorn main:app --host 0.0.0.0 --port 8000 --reload > /tmp/backend.log 2>&1 &
    BACKEND_PID=$!
    echo "   Backend PID: $BACKEND_PID"
    
    cd "$PROJECT_ROOT"
}

# ============================================
# FRONTEND: React/Vite
# ============================================
setup_frontend() {
    echo "⚛️  Setting up React frontend..."
    
    cd "$PROJECT_ROOT/frontend"
    
    # Install deps if needed
    if [ ! -d "node_modules" ]; then
        npm install --silent 2>/dev/null || npm install
    fi
    
    # Start Vite dev server
    echo "🚀 Starting Vite dev server on port 5173..."
    npm run dev > /tmp/frontend.log 2>&1 &
    FRONTEND_PID=$!
    echo "   Frontend PID: $FRONTEND_PID"
    
    cd "$PROJECT_ROOT"
}

# ============================================
# HEALTH CHECK
# ============================================
wait_for_servers() {
    echo ""
    echo "⏳ Waiting for servers to be ready..."
    
    local max_wait=30
    local waited=0
    local backend_ready=false
    local frontend_ready=false
    
    while [ $waited -lt $max_wait ]; do
        if ! $backend_ready && curl -s http://localhost:8000/health > /dev/null 2>&1; then
            backend_ready=true
            echo "   ✓ Backend ready"
        fi
        
        if ! $frontend_ready && curl -s http://localhost:5173 > /dev/null 2>&1; then
            frontend_ready=true
            echo "   ✓ Frontend ready"
        fi
        
        if $backend_ready && $frontend_ready; then
            break
        fi
        
        sleep 1
        waited=$((waited + 1))
    done
    
    if ! $backend_ready; then
        echo "   ⚠️  Backend may not be ready - check /tmp/backend.log"
    fi
    
    if ! $frontend_ready; then
        echo "   ⚠️  Frontend may not be ready - check /tmp/frontend.log"
    fi
}

# ============================================
# MAIN
# ============================================

# Check if directories exist (first run detection)
if [ ! -d "$PROJECT_ROOT/backend" ] || [ ! -d "$PROJECT_ROOT/frontend" ]; then
    echo "⚠️  Project structure not yet created."
    echo "   This is expected for Session 2 (first coding session)."
    echo "   Create backend/ and frontend/ directories first."
    echo ""
    echo "📋 Quick status:"
    echo "   Git branch: $(git branch --show-current 2>/dev/null || echo 'not a git repo')"
    echo "   Last commit: $(git log -1 --oneline 2>/dev/null || echo 'no commits')"
    exit 0
fi

setup_backend
setup_frontend
wait_for_servers

# ============================================
# STATUS REPORT
# ============================================
echo ""
echo "✅ Development environment ready"
echo ""
echo "   Frontend:  http://localhost:5173"
echo "   Backend:   http://localhost:8000"
echo "   API Docs:  http://localhost:8000/docs"
echo ""
echo "   Logs:"
echo "     Backend:  /tmp/backend.log"
echo "     Frontend: /tmp/frontend.log"
echo ""
echo "📋 Quick status:"
echo "   Git branch: $(git branch --show-current 2>/dev/null || echo 'not a git repo')"
echo "   Last commit: $(git log -1 --oneline 2>/dev/null || echo 'no commits')"
echo ""
echo "📝 Session checklist:"
echo "   [ ] Read claude-progress.txt"
echo "   [ ] Check feature_list.json for next feature"
echo "   [ ] Pick ONE feature to implement"
echo "   [ ] Test end-to-end before marking complete"
echo ""

#!/bin/bash
# Development Environment Initialization
# Run this at the start of EVERY coding session
# Customize this file for your project's tech stack

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_ROOT"

echo "🔄 Initializing development environment..."
echo ""

# ============================================
# CLEANUP: Kill stale processes
# ============================================
cleanup_ports() {
    echo "🧹 Cleaning up stale processes..."
    # Add your project's ports here
    local ports=("3000" "5000" "8000" "8080")
    for port in "${ports[@]}"; do
        lsof -ti:$port 2>/dev/null | xargs kill -9 2>/dev/null || true
    done
}
cleanup_ports

# ============================================
# DEPENDENCIES: Install if needed
# ============================================
install_deps() {
    # Node.js
    if [ -f "package.json" ]; then
        echo "📦 Checking Node.js dependencies..."
        npm install --silent 2>/dev/null || npm install
    fi
    
    # Python
    if [ -f "requirements.txt" ]; then
        echo "🐍 Checking Python dependencies..."
        if [ -d "venv" ]; then
            source venv/bin/activate
        fi
        pip install -q -r requirements.txt 2>/dev/null || pip install -r requirements.txt
    fi
    
    # Go
    if [ -f "go.mod" ]; then
        echo "🐹 Checking Go dependencies..."
        go mod download
    fi
    
    # Rust
    if [ -f "Cargo.toml" ]; then
        echo "🦀 Checking Rust dependencies..."
        cargo fetch --quiet
    fi
}
install_deps

# ============================================
# DATABASE: Setup if needed
# ============================================
setup_database() {
    # Prisma (Node.js)
    if [ -f "prisma/schema.prisma" ]; then
        echo "🗄️ Running Prisma migrations..."
        npx prisma migrate dev 2>/dev/null || true
    fi
    
    # Django
    if [ -f "manage.py" ]; then
        echo "🗄️ Running Django migrations..."
        python manage.py migrate --run-syncdb 2>/dev/null || true
    fi
    
    # SQLAlchemy / Alembic
    if [ -f "alembic.ini" ]; then
        echo "🗄️ Running Alembic migrations..."
        alembic upgrade head 2>/dev/null || true
    fi
}
setup_database

# ============================================
# SERVERS: Start development servers
# ============================================
start_servers() {
    # Customize these for your project
    
    # Example: Node.js / React / Vite
    # if [ -f "package.json" ]; then
    #     echo "🚀 Starting frontend..."
    #     npm run dev > /tmp/frontend.log 2>&1 &
    # fi
    
    # Example: Python / FastAPI / Flask
    # if [ -f "main.py" ]; then
    #     echo "🚀 Starting backend..."
    #     python main.py > /tmp/backend.log 2>&1 &
    # fi
    
    echo "⚠️  No servers configured - customize start_servers() in init.sh"
}
start_servers

# ============================================
# HEALTH CHECK
# ============================================
wait_for_ready() {
    echo ""
    echo "⏳ Waiting for servers..."
    sleep 2
    
    # Customize health checks for your endpoints
    # Example:
    # if curl -s http://localhost:3000/health > /dev/null 2>&1; then
    #     echo "   ✓ Frontend ready"
    # fi
}
wait_for_ready

# ============================================
# STATUS REPORT
# ============================================
echo ""
echo "✅ Development environment ready"
echo ""
echo "📋 Git status:"
echo "   Branch: $(git branch --show-current 2>/dev/null || echo 'not a git repo')"
echo "   Commit: $(git log -1 --oneline 2>/dev/null || echo 'no commits')"
echo ""
echo "📝 Session checklist:"
echo "   [ ] Read claude-progress.txt"
echo "   [ ] Check feature_list.json"
echo "   [ ] Pick ONE feature"
echo "   [ ] Test before marking complete"
echo ""

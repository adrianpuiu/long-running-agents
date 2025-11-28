#!/bin/bash
# Create a new project from the long-running-agent template
# Usage: ./scripts/new_project.sh <project_name> [output_dir]

set -e

PROJECT_NAME="${1:-my-project}"
OUTPUT_DIR="${2:-.}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="$(dirname "$SCRIPT_DIR")/templates"

# Validate
if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: $0 <project_name> [output_dir]"
    echo "Example: $0 my-awesome-app ~/projects"
    exit 1
fi

PROJECT_PATH="$OUTPUT_DIR/$PROJECT_NAME"

if [ -d "$PROJECT_PATH" ]; then
    echo "❌ Error: Directory already exists: $PROJECT_PATH"
    exit 1
fi

echo "🚀 Creating new long-running agent project: $PROJECT_NAME"
echo "   Location: $PROJECT_PATH"
echo ""

# Create project directory
mkdir -p "$PROJECT_PATH"

# Get current timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DATE_HUMAN=$(date -u +"%Y-%m-%d %H:%M")

# Copy and customize feature_list.json
sed -e "s/PROJECT_NAME/$PROJECT_NAME/g" \
    -e "s/CREATED_DATE/$TIMESTAMP/g" \
    "$TEMPLATE_DIR/feature_list.json" > "$PROJECT_PATH/feature_list.json"
echo "✅ Created feature_list.json"

# Copy and customize progress.txt
sed -e "s/PROJECT_NAME/$PROJECT_NAME/g" \
    -e "s/SESSION_DATE/$DATE_HUMAN/g" \
    "$TEMPLATE_DIR/progress.txt" > "$PROJECT_PATH/claude-progress.txt"
echo "✅ Created claude-progress.txt"

# Copy init.sh
cp "$TEMPLATE_DIR/init.sh" "$PROJECT_PATH/init.sh"
chmod +x "$PROJECT_PATH/init.sh"
echo "✅ Created init.sh (executable)"

# Create .gitignore
cat > "$PROJECT_PATH/.gitignore" << 'EOF'
# Dependencies
node_modules/
venv/
.venv/
__pycache__/
*.pyc
target/
vendor/

# Build
dist/
build/
*.egg-info/

# Environment
.env
.env.local
.env.*.local

# IDE
.idea/
.vscode/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log
/tmp/

# Database
*.db
*.sqlite
*.sqlite3

# Coverage
coverage/
.coverage
htmlcov/
EOF
echo "✅ Created .gitignore"

# Copy agent instructions
cp "$(dirname "$SCRIPT_DIR")/AGENT_INSTRUCTIONS.md" "$PROJECT_PATH/AGENT_INSTRUCTIONS.md"
echo "✅ Created AGENT_INSTRUCTIONS.md"

# Initialize git
cd "$PROJECT_PATH"
git init -q
git add .
git commit -q -m "Initial project scaffold

Created with long-running-agent template.
Session: 1 (Initializer)

Next: Expand feature_list.json with project requirements"
echo "✅ Initialized git repository"

echo ""
echo "✅ Project '$PROJECT_NAME' created successfully!"
echo ""
echo "Next steps:"
echo "  cd $PROJECT_PATH"
echo "  # Edit feature_list.json with your project's features"
echo "  # Customize init.sh for your tech stack"
echo "  # Start coding sessions!"
echo ""
echo "Session start command:"
echo "  cat claude-progress.txt && cat feature_list.json"
echo ""

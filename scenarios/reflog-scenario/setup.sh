#!/bin/bash

# Setup script for Reflog Recovery scenario
# This creates a repository with commits that will be "lost" via hard reset

echo "🔧 Setting up Reflog Recovery Scenario..."

# Create demo directory
mkdir -p reflog-recovery-demo
cd reflog-recovery-demo

# Initialize repository
git init
echo "Repository initialized"

# Create initial commit
echo "# Reflog Recovery Demo" > README.md
git add README.md
git commit -m "chore: initial commit"

# Create main branch commits
echo "Main application structure" > app.py
git add app.py
git commit -m "feat: add application skeleton"

echo "Database configuration" > config.py
git add config.py
git commit -m "feat: add database config"

# Tag this as "safe state"
git tag before-feature

# Simulate feature development
echo "User model" > models/user.py
mkdir -p models
echo "User model implementation" > models/user.py
git add models/user.py
git commit -m "feat: create user model"

echo "Authentication service" > services/auth.py
mkdir -p services
echo "JWT authentication" > services/auth.py
git add services/auth.py
git commit -m "feat: implement JWT authentication"

echo "Login endpoint" >> app.py
git add app.py
git commit -m "feat: add login endpoint"

echo "Registration endpoint" >> app.py
git add app.py
git commit -m "feat: add registration endpoint"

echo "Password hashing utilities" > utils/crypto.py
mkdir -p utils
echo "Bcrypt password hashing" > utils/crypto.py
git add utils/crypto.py
git commit -m "feat: add password hashing"

# Show current state
echo ""
echo "✅ Setup complete! Current commits:"
git log --oneline --graph

# Tag the current state
git tag before-disaster

echo ""
echo "📌 Now simulating disaster..."
echo "Running: git reset --hard before-feature"
echo ""

# Simulate the disaster
git reset --hard before-feature

echo "💥 DISASTER! 5 commits have been 'lost'!"
echo ""
echo "Current state:"
git log --oneline

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 YOUR MISSION:"
echo "   1. Use 'git reflog' to find the lost commits"
echo "   2. Recover all 5 feature commits"
echo "   3. Verify recovery with 'git log'"
echo ""
echo "💡 HINT: The lost commits are still in Git's object database!"
echo "   Look for HEAD@{X} entries in the reflog."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

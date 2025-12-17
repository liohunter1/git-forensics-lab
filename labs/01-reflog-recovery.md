# Lab 1: Reflog Recovery from Hard Reset

## 🎯 Objective

Learn to recover lost commits after an accidental `git reset --hard` using Git's reflog.

---

## 📋 Scenario Setup

You're working on a critical feature with multiple commits. Your colleague asks you to check something on the main branch. In a hurry, you run:

```bash
git reset --hard origin/main
```

**Panic**: You just lost 15 commits representing 3 days of work! The feature branch was never pushed to remote.

---

## 🔍 Understanding the Problem

### What Happened?

1. `git reset --hard origin/main` moved `HEAD` and branch pointer to `origin/main`
2. Your working directory was replaced with `origin/main` state
3. All uncommitted changes were **permanently lost**
4. **However**: Committed changes are still in Git's object database

### Git Internals

Git maintains a **reflog** (reference log) that tracks every movement of `HEAD`:

```
HEAD@{0} -> Current position
HEAD@{1} -> Previous position
HEAD@{2} -> Position before that
...
```

Objects are only garbage-collected after ~90 days (configurable via `gc.reflogExpire`).

---

## 🛠️ Solution

### Step 1: View the Reflog

```bash
git reflog
```

**Output**:
```
a1b2c3d (HEAD -> main) HEAD@{0}: reset: moving to origin/main
e4f5g6h HEAD@{1}: commit: feat: add user dashboard component
i7j8k9l HEAD@{2}: commit: feat: implement user service layer
m9n0o1p HEAD@{3}: commit: feat: create database schema
...
q2r3s4t HEAD@{15}: commit: feat: initialize user authentication feature
```

### Step 2: Identify Target Commit

The commit **before** the reset is `e4f5g6h` (`HEAD@{1}`). This was the tip of your feature branch.

### Step 3: Recover Commits

**Option A: Hard Reset to Lost Commit**

```bash
git reset --hard e4f5g6h
```

This moves `HEAD` and branch pointer back to the lost commit.

**Option B: Create New Branch**

```bash
git branch feature/user-auth e4f5g6h
git checkout feature/user-auth
```

This preserves `main` at `origin/main` and creates a branch with your work.

**Option C: Cherry-Pick Individual Commits**

```bash
git cherry-pick e4f5g6h
git cherry-pick i7j8k9l
# Continue for all needed commits
```

Useful if you only need some of the lost commits.

### Step 4: Verify Recovery

```bash
git log --oneline --graph -n 20
```

**Expected Output**:
```
* e4f5g6h (HEAD -> feature/user-auth) feat: add user dashboard component
* i7j8k9l feat: implement user service layer
* m9n0o1p feat: create database schema
...
* q2r3s4t feat: initialize user authentication feature
* u4v5w6x (origin/main, main) Merge pull request #123
```

All commits recovered! ✅

---

## 🧪 Hands-On Exercise

### Setup

Run this script to simulate the scenario:

```bash
#!/bin/bash
# setup-reflog-scenario.sh

# Initialize repository
git init reflog-recovery-demo
cd reflog-recovery-demo

# Create initial commits
echo "# Project" > README.md
git add README.md
git commit -m "chore: initial commit"

# Simulate feature development
for i in {1..5}; do
    echo "Feature $i" >> feature.txt
    git add feature.txt
    git commit -m "feat: add feature $i"
done

# Create a tag to mark "safe" state
git tag before-disaster

# Simulate accidental reset
git reset --hard HEAD~5

echo "Disaster! 5 commits lost."
echo "Use git reflog to recover."
```

### Your Task

1. Run the setup script
2. Use `git reflog` to find lost commits
3. Recover all 5 feature commits
4. Verify with `git log`

### Verification

```bash
# Should show all 5 feature commits
git log --oneline | grep "feat: add feature"
```

---

## 📊 Advanced Scenarios

### Scenario A: Reflog Entry Expired

If commits are older than 90 days:

```bash
# Check reflog expiration settings
git config gc.reflogExpire        # Default: 90 days
git config gc.reflogExpireUnreachable  # Default: 30 days

# Extend expiration
git config gc.reflogExpire "1 year"

# Disable garbage collection temporarily
git config gc.auto 0
```

### Scenario B: Finding Specific Commit by Message

```bash
# Search reflog for commit message pattern
git reflog --grep="user authentication"

# Output:
# e4f5g6h HEAD@{1}: commit: feat: add user authentication
```

### Scenario C: Recover from Specific Date

```bash
# Find commits from 2 days ago
git reflog --since="2 days ago"

# Reset to state from yesterday 3pm
git reset --hard 'master@{yesterday 3pm}'
```

---

## 🎓 Key Takeaways

1. **Reflog is Local**: Each clone has its own reflog. Lost commits cannot be recovered from remote.

2. **Commits Are Permanent** (Sort of): Until garbage collection, all commits remain in `.git/objects`.

3. **Prevention**:
   - Always push work-in-progress to remote: `git push origin feature/my-work`
   - Use `git stash` for temporary changes
   - Create backup branches before risky operations: `git branch backup`

4. **Reflog Commands**:
   ```bash
   git reflog                        # View all reflog entries
   git reflog show branch-name       # Reflog for specific branch
   git reflog --date=relative        # Show relative dates
   git reflog --all                  # All refs, not just HEAD
   ```

5. **Related Commands**:
   ```bash
   git fsck --lost-found             # Find dangling commits
   git show <commit-sha>             # View commit details
   git diff HEAD@{1} HEAD@{3}        # Compare reflog states
   ```

---

## 🚀 Next Steps

- **Lab 2**: Interactive Rebase for Semantic History
- **Lab 3**: Three-Way Merge Conflict Resolution
- **Lab 4**: Detached HEAD Recovery

---

## 📚 References

- [Git Reflog Documentation](https://git-scm.com/docs/git-reflog)
- [Git Internals - Git Objects](https://git-scm.com/book/en/v2/Git-Internals-Git-Objects)
- [How to recover lost commits with git reflog](https://www.atlassian.com/git/tutorials/rewriting-history/git-reflog)

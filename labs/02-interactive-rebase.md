# Lab 2: Interactive Rebase for Semantic History

## 🎯 Objective

Transform a messy commit history into clean, semantic commits following Conventional Commits specification.

---

## 📋 Scenario

You've been working on a feature branch for 2 weeks with rapid iteration. The commit history looks like this:

```
* e7f8a9b (HEAD -> feature/payment) asdf
* d6e7f8a fixed lint error
* c5d6e7f wip
* b4c5d6e added stripe integration
* a3b4c5d oops forgot file
* 91a2b3c stripe webhook handler
* 81a2b3c cleanup
* 71a2b3c payment processing
* 61a2b3c wip
* 51a2b3c started payment feature
* (main) ...
```

**Problem**: This history is:
- Non-semantic (messages like "wip", "asdf")
- Too granular (23 commits for one feature)
- Difficult to review
- Breaks CI/CD pipelines that parse commit messages

**Goal**: Squash into 3 clean commits:
1. `feat: implement Stripe payment integration`
2. `feat: add payment webhook handlers`
3. `feat: create payment dashboard UI`

---

## 🔍 Understanding Interactive Rebase

### What is Interactive Rebase?

Interactive rebase (`git rebase -i`) allows you to:
- **Reorder** commits
- **Squash** multiple commits into one
- **Edit** commit messages
- **Drop** unnecessary commits
- **Split** large commits

### How It Works

1. Git replays commits one-by-one from a base
2. You specify actions for each commit
3. Git executes actions in order
4. History is rewritten

### Commands

```
pick    = use commit as-is
reword  = use commit, but edit message
edit    = use commit, but stop for amending
squash  = combine with previous commit, edit message
fixup   = like squash, but discard message
drop    = remove commit
```

---

## 🛠️ Solution

### Step 1: Identify Rebase Base

```bash
# Find commit where feature branched from main
git merge-base feature/payment main
# Output: 41a2b3c

# Or count commits
git log --oneline main..feature/payment | wc -l
# Output: 10 commits
```

### Step 2: Start Interactive Rebase

```bash
git rebase -i main
# Or: git rebase -i HEAD~10
```

### Step 3: Editor Opens

**Original**:
```
pick 51a2b3c started payment feature
pick 61a2b3c wip
pick 71a2b3c payment processing
pick 81a2b3c cleanup
pick 91a2b3c stripe webhook handler
pick a3b4c5d oops forgot file
pick b4c5d6e added stripe integration
pick c5d6e7f wip
pick d6e7f8a fixed lint error
pick e7f8a9b asdf
```

**Modified** (Grouping by Semantic Feature):
```
# First feature: Stripe integration
pick 51a2b3c started payment feature
squash 61a2b3c wip
squash 71a2b3c payment processing
squash 81a2b3c cleanup
squash b4c5d6e added stripe integration
squash c5d6e7f wip
squash d6e7f8a fixed lint error
squash e7f8a9b asdf

# Second feature: Webhook handlers
pick 91a2b3c stripe webhook handler
squash a3b4c5d oops forgot file

# Third feature would go here if we had dashboard commits
```

### Step 4: Save and Continue

Git will prompt for new commit messages for each squashed group.

**Commit 1**:
```
feat: implement Stripe payment integration

- Initialize Stripe SDK with API keys
- Create PaymentService class with charge/refund methods
- Add payment status tracking in database
- Implement error handling for failed transactions
- Add comprehensive logging for audit trail

Closes #234
```

**Commit 2**:
```
feat: add Stripe webhook handlers

- Implement webhook signature verification
- Handle payment_intent.succeeded event
- Handle payment_intent.failed event
- Store webhook events for debugging
- Add retry logic for failed webhook processing

Closes #235
```

### Step 5: Verify Result

```bash
git log --oneline main..feature/payment
```

**Output**:
```
* 9z8y7x6 (HEAD -> feature/payment) feat: add Stripe webhook handlers
* 5w4v3u2 feat: implement Stripe payment integration
```

Perfect! Clean semantic history ✅

---

## 🧪 Hands-On Exercise

### Setup Script

```bash
#!/bin/bash
# setup-rebase-scenario.sh

git init rebase-demo
cd rebase-demo

# Create main branch
echo "# Payment System" > README.md
git add README.md
git commit -m "chore: initial commit"

# Create messy feature branch
git checkout -b feature/payment

echo "Stripe SDK initialized" >> payment.py
git add payment.py
git commit -m "started payment stuff"

echo "Process payment method" >> payment.py
git add payment.py
git commit -m "wip"

echo "Handle errors" >> payment.py
git add payment.py
git commit -m "asdf"

echo "Webhook handler" >> webhook.py
git add webhook.py
git commit -m "webhooks"

echo "Fix typo" >> webhook.py
git add webhook.py
git commit -m "oops"

echo "Verify signatures" >> webhook.py
git add webhook.py
git commit -m "security"

git log --oneline
```

### Your Task

1. Run setup script
2. Use `git rebase -i main` to:
   - Squash first 3 commits into: `feat: implement Stripe payment processing`
   - Squash last 3 commits into: `feat: add secure webhook handlers`
3. Verify with `git log --oneline`

### Expected Result

```
* a1b2c3d (HEAD -> feature/payment) feat: add secure webhook handlers
* e4f5g6h feat: implement Stripe payment processing
* i7j8k9l (main) chore: initial commit
```

---

## 📊 Advanced Techniques

### Technique 1: Autosquash

Mark commits for automatic squashing:

```bash
# During development, create fixup commits
git commit --fixup=a1b2c3d

# Later, autosquash during rebase
git rebase -i --autosquash main
```

Git automatically marks fixup commits for squashing!

### Technique 2: Exec Command

Run commands between commits:

```bash
# In rebase editor
pick a1b2c3d feat: add payment processing
exec npm test
pick e4f5g6h feat: add webhook handlers
exec npm test
```

Rebase aborts if any test fails, allowing you to fix issues at that commit.

### Technique 3: Split Commit

```bash
# In rebase editor
edit a1b2c3d Large commit to split

# After rebase pauses
git reset HEAD^
git add file1.py
git commit -m "feat: add payment validation"
git add file2.py
git commit -m "feat: add payment logging"
git rebase --continue
```

---

## ⚠️ Important Warnings

### 1. Never Rebase Public History

```bash
# ❌ DANGER: If feature/payment was already pushed and others pulled it
git rebase -i main  # This will break collaborators' repos!

# ✅ SAFE: Only rebase branches you alone work on
# OR coordinate with team and they'll need to:
git fetch
git reset --hard origin/feature/payment
```

### 2. Always Use --force-with-lease

```bash
# ❌ BAD: Can overwrite others' work
git push --force

# ✅ GOOD: Fails if remote has unexpected changes
git push --force-with-lease
```

### 3. Create Backup Branch

```bash
# Before risky rebase
git branch backup-feature-payment

# If rebase goes wrong
git reset --hard backup-feature-payment
```

---

## 🎓 Key Takeaways

1. **Semantic Commits Improve**:
   - Code review efficiency
   - Changelog generation
   - CI/CD pipeline integration
   - Git bisect accuracy

2. **Conventional Commits Format**:
   ```
   <type>(<scope>): <subject>
   
   <body>
   
   <footer>
   ```
   
   Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

3. **Best Practices**:
   - Rebase before pushing to remote
   - Each commit should be atomic (one logical change)
   - Commit messages should explain "why", not "what"
   - Keep commits small for easy bisecting

4. **Useful Commands**:
   ```bash
   git rebase -i HEAD~n                # Rebase last n commits
   git rebase -i --root                # Rebase entire history
   git rebase --abort                  # Cancel rebase
   git rebase --continue               # Continue after resolving conflicts
   git rebase --skip                   # Skip current commit
   ```

---

## 🚀 Next Steps

- **Lab 3**: Three-Way Merge Conflict Resolution
- **Lab 4**: Detached HEAD Recovery
- **Lab 5**: Git Bisect for Bug Hunting

---

## 📚 References

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Git Rebase Documentation](https://git-scm.com/docs/git-rebase)
- [Atlassian: Rewriting History](https://www.atlassian.com/git/tutorials/rewriting-history/git-rebase)
- [Git Autosquash](https://git-scm.com/docs/git-rebase#Documentation/git-rebase.txt---autosquash)

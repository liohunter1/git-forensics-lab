<div align="center">

# 🔍 Git Forensics Lab

**Advanced Git Mastery: Recovering from Chaos, Mastering History, and Resolving Complex Conflicts**

[![Expertise Level](https://img.shields.io/badge/Level-Expert-red)](https://git-scm.com/)
[![Git](https://img.shields.io/badge/Git-2.40+-orange.svg)](https://git-scm.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

*A comprehensive collection of real-world Git crisis scenarios and their solutions,  
demonstrating deep understanding of Git internals and repository state management.*

</div>

---

## 📖 Purpose

This repository serves as a **technical portfolio** demonstrating expert-level Git proficiency required for:

- **Open Source Maintainers** managing complex contribution workflows
- **DevOps Engineers** recovering from repository disasters
- **Senior Engineers** mentoring teams on Git best practices
- **Technical Interviewers** assessing candidate Git expertise

Each lab scenario is a real-world "chaos case" that has been engineered, broken, and resolved using advanced Git techniques.

---

## 🎯 Core Competencies Demonstrated

| Competency | Scenario | Git Commands Used |
|------------|----------|-------------------|
| **Reflog Recovery** | Recover lost commits after accidental `git reset --hard` | `git reflog`, `git reset`, `git cherry-pick` |
| **Interactive Rebase** | Clean up messy commit history into semantic commits | `git rebase -i`, `git commit --fixup`, `git rebase --autosquash` |
| **Merge Conflict Resolution** | Resolve 3-way merge with conflicting architectural changes | `git merge`, `git diff`, `git mergetool` |
| **Detached HEAD Recovery** | Recover work from detached HEAD state | `git reflog`, `git branch`, `git checkout` |
| **Broken History Repair** | Fix repository with non-linear history and duplicate commits | `git filter-branch`, `git rebase --onto` |
| **Bisect Debugging** | Identify commit that introduced a bug in 1000+ commit history | `git bisect`, `git bisect run` |

---

## 🧪 Lab Scenarios

### Lab 1: Reflog Recovery from Hard Reset

**Scenario**: You accidentally ran `git reset --hard HEAD~5` and lost critical commits.

**Challenge**: Recover the lost commits without any remote backup.

**Solution Path**:
```bash
# View reflog to find lost commits
git reflog

# Output:
# a1b2c3d HEAD@{0}: reset: moving to HEAD~5
# e4f5g6h HEAD@{1}: commit: feat: add user authentication
# i7j8k9l HEAD@{2}: commit: fix: resolve memory leak

# Recover lost commits
git reset --hard e4f5g6h

# Verify recovery
git log --oneline -n 10
```

**Key Learnings**:
- Reflog is a local log of all HEAD movements
- Commits are not immediately garbage collected
- Can recover up to 90 days (default `gc.reflogExpire`)

**[View Full Lab Report →](labs/01-reflog-recovery.md)**

---

### Lab 2: Interactive Rebase for Semantic History

**Scenario**: Feature branch has 23 commits with messages like "wip", "fix typo", "asdf".

**Challenge**: Squash into 3 semantic commits following Conventional Commits.

**Before**:
```
* e7f8a9b (HEAD -> feature/auth) asdf
* d6e7f8a fix typo
* c5d6e7f wip
* b4c5d6e add login endpoint
* a3b4c5d wip
* ...
```

**After**:
```
* a1b2c3d (HEAD -> feature/auth) feat: implement user authentication system
* e4f5g6h feat: add JWT token generation and validation
* i7j8k9l feat: create login and registration endpoints
```

**Solution Path**:
```bash
# Start interactive rebase from common ancestor
git rebase -i main

# In editor, mark commits for squashing:
# pick b4c5d6e add login endpoint
# squash c5d6e7f wip
# squash d6e7f8a fix typo
# squash e7f8a9b asdf

# Write clean commit message
# Save and exit

# Force push (if already pushed)
git push --force-with-lease
```

**Key Learnings**:
- `--force-with-lease` safer than `--force`
- Interactive rebase rewrites history (coordinate with team)
- Semantic commits improve readability and CI/CD integration

**[View Full Lab Report →](labs/02-interactive-rebase.md)**

---

### Lab 3: Three-Way Merge Conflict Resolution

**Scenario**: Two feature branches modified the same architectural component differently.

**Setup**:
- `feature/rest-api`: Refactored service layer to use REST
- `feature/grpc-api`: Refactored same service layer to use gRPC
- Both branches diverged from `main` 2 weeks ago

**Challenge**: Merge both approaches into a unified abstraction.

**Conflict Example**:
```python
<<<<<<< HEAD (feature/rest-api)
class UserService:
    def __init__(self, rest_client: RESTClient):
        self.client = rest_client
        
    def get_user(self, user_id: str) -> User:
        response = self.client.get(f"/users/{user_id}")
        return User(**response.json())
=======
class UserService:
    def __init__(self, grpc_client: GRPCClient):
        self.client = grpc_client
        
    def get_user(self, user_id: str) -> User:
        request = user_pb2.GetUserRequest(id=user_id)
        response = self.client.GetUser(request)
        return User.from_proto(response)
>>>>>>> feature/grpc-api
```

**Resolution**: Implement Strategy Pattern

```python
class UserService:
    def __init__(self, client: Union[RESTClient, GRPCClient]):
        """Supports both REST and gRPC clients via duck typing."""
        self.client = client
        
    def get_user(self, user_id: str) -> User:
        if isinstance(self.client, RESTClient):
            response = self.client.get(f"/users/{user_id}")
            return User(**response.json())
        elif isinstance(self.client, GRPCClient):
            request = user_pb2.GetUserRequest(id=user_id)
            response = self.client.GetUser(request)
            return User.from_proto(response)
        else:
            raise ValueError(f"Unsupported client type: {type(self.client)}")
```

**Solution Steps**:
```bash
# Attempt merge
git merge feature/grpc-api

# Resolve conflicts
git status  # View conflicted files
git diff    # Examine conflicts

# Edit files to resolve
# Test resolution
pytest tests/

# Complete merge
git add .
git commit -m "Merge feature/grpc-api: unified client abstraction"
```

**Key Learnings**:
- Three-way merges require understanding both branches' intent
- Architectural conflicts often require new abstractions
- Always run tests after conflict resolution

**[View Full Lab Report →](labs/03-merge-conflicts.md)**

---

### Lab 4: Detached HEAD Recovery

**Scenario**: Checked out specific commit to test a bug fix, made additional commits, lost track of branch.

**Challenge**: Preserve commits made in detached HEAD state.

**Solution**:
```bash
# Realize you're in detached HEAD
git status
# HEAD detached at a1b2c3d

# View commits made
git log --oneline -n 5

# Create branch to save work
git branch recovery-branch

# Return to main branch
git checkout main

# Merge or cherry-pick commits
git merge recovery-branch
```

**[View Full Lab Report →](labs/04-detached-head.md)**

---

### Lab 5: Git Bisect for Bug Hunting

**Scenario**: Production bug introduced somewhere in last 200 commits.

**Challenge**: Identify exact commit that introduced the bug.

**Solution**:
```bash
# Start bisect
git bisect start

# Mark current commit as bad
git bisect bad

# Mark last known good commit
git bisect good v2.3.0

# Git checks out middle commit
# Run test
npm test

# If test fails
git bisect bad

# If test passes
git bisect good

# Repeat until Git identifies commit
# Bisect found first bad commit: a1b2c3d

# Reset to original state
git bisect reset
```

**Automated Bisect**:
```bash
git bisect start HEAD v2.3.0
git bisect run npm test
# Git automatically finds bad commit
```

**[View Full Lab Report →](labs/05-git-bisect.md)**

---

## 🛠️ Repository Structure

```
git-forensics-lab/
├── labs/
│   ├── 01-reflog-recovery.md
│   ├── 02-interactive-rebase.md
│   ├── 03-merge-conflicts.md
│   ├── 04-detached-head.md
│   ├── 05-git-bisect.md
│   └── 06-filter-branch.md
├── scenarios/
│   ├── reflog-scenario/       # Reproducible scenario setup
│   ├── rebase-scenario/
│   └── merge-scenario/
├── scripts/
│   ├── setup-scenarios.sh     # Automate scenario creation
│   └── verify-solutions.sh    # Test solution validity
└── README.md
```

---

## 🎓 Learning Outcomes

After completing these labs, you will:

✅ **Understand Git Internals**: Objects, refs, reflog, and the DAG structure  
✅ **Master History Rewriting**: Interactive rebase, filter-branch, and amend  
✅ **Recover from Disasters**: Lost commits, broken merges, and corrupted repos  
✅ **Implement Best Practices**: Conventional commits, semantic versioning, and clean history  
✅ **Debug Efficiently**: Bisect, blame, and log archaeology  

---

## 📚 Additional Resources

### Recommended Reading
- [Pro Git Book (Chapter 10: Git Internals)](https://git-scm.com/book/en/v2/Git-Internals-Plumbing-and-Porcelain)
- [Git Reflog Documentation](https://git-scm.com/docs/git-reflog)
- [Atlassian Git Tutorials (Advanced)](https://www.atlassian.com/git/tutorials/advanced-overview)

### Tools
- **lazygit**: TUI for Git with visual diff and commit management
- **git-extras**: Collection of useful Git utilities
- **tig**: Text-mode interface for Git

---

## 🤝 Contributing

Found a better solution? Have a new chaos scenario? Contributions welcome!

1. Fork the repository
2. Create scenario branch (`git checkout -b scenario/new-chaos`)
3. Document the problem and solution
4. Submit PR with test script

---

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

---

<div align="center">

**Built to demonstrate Git mastery for senior engineering roles**

*Proving expertise beyond `git add`, `git commit`, `git push`*

</div>

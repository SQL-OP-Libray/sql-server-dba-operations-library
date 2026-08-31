# 🔍 Review & Approval Process

To maintain enterprise-grade quality across all published manuals and scripts, every contribution undergoes a structured review process prior to being merged into `main` and compiled into the monthly PDF release.

---

## 🔄 Workflow Lifecycle


```

[ Contributor PR ] ➡️ [ Phase 1: Automated Checks ] ➡️ [ Phase 2: Peer & Technical Review ] ➡️ [ Phase 3: Approval & Merge ] ➡️ [ Phase 4: PDF Compilation ]

```

---

## 📋 Review Stages

### Phase 1: Initial Triage & Verification
Upon PR submission, the maintainer checks:
* PR follows formatting and branching guidelines.
* No sensitive data, proprietary code, or production credentials are present.
* The PR targets the correct directory (e.g., `01-Foundation/...`).

### Phase 2: Technical & Operational Review
Submissions are evaluated against four criteria:
1. **Accuracy:** Are T-SQL scripts, Extended Events, or DMV queries syntax-correct and optimal?
2. **Safety:** Will this script cause performance degradation (e.g., high CPU, blocking) if run in production?
3. **Clarity:** Is the documentation clear, unambiguous, and easy to follow?
4. **Reproducibility:** Can another DBA execute these steps in a test environment and achieve the same result?

### Phase 3: Approval & Merge
* At least **1 maintainer approval** is required before merging into `main`.
* The author may be asked to make inline updates based on review feedback.
* Once approved, the branch is merged into `main`.

### Phase 4: End-of-Month Freeze & PDF Release
* Content for the active manual is frozen **5 days before month-end**.
* The final Markdown files are reviewed for layout, formatting, and completeness.
* The content is compiled into the official monthly PDF release.

---

## 🏷️ Pull Request Labels

Maintainers categorize PRs using the following labels:
* `content` – Markdown documentation updates
* `script` – T-SQL or PowerShell scripts
* `review-needed` – Pending maintainer review
* `changes-requested` – Requires contributor revision
* `approved` – Ready to merge
* `ready-for-pdf` – Staged for end-of-month PDF release

```

# 🤝 Contributing to the SQL Server DBA Operations Library
Thank you for helping build a community-driven library of production-ready SQL Server operational standards! This document outlines how our monthly collaboration works and how to structure your contributions.

---

## 🗓️ The Monthly Manual Model
We focus on building **one operational manual per month**:

* **One Active Branch:** Work for the active month occurs on a dedicated monthly branch (e.g., `manual-aug-2026`). 
* **Targeting Pull Requests:** Always submit your PRs targeting the active monthly branch, **not** `main`.
* **Month-End PDF Release:** At month-end, the content is frozen, merged to `main`, and published as a downloadable PDF guide.

---

## ✍️ Writing Style & Standards
Our goal is to create actionable documentation that DBAs can rely on in critical moments:

* **Practical & Real-World:** Focus on clear operational steps rather than textbook theory.
* **Junior-Friendly:** Write unambiguous instructions with clear context so junior and mid-level DBAs can execute them safely.
* **Safety First:** Never include sensitive information, production passwords, real server names, or proprietary company data.

---

## 🏗️ Required Documentation Structure
Every operational manual follows a standardized structure. Ensure your contributions align with these core sections:

1. **Purpose:** Why this manual exists and what operational problem it solves.
2. **Scope:** Systems, versions, and environments covered.
3. **Roles & Responsibilities:** Who executes, reviews, and approves these tasks.
4. **Procedures:** Step-by-step instructions for implementation and operations.
5. **Checklists:** Actionable, quick-reference lists for daily/monthly workflows.
6. **Risks & Mitigation:** Common pitfalls, performance impacts, and rollback steps.
7. **Validation:** Verification steps or queries to confirm success.
8. **Metrics & KPIs:** Operational metrics to measure health and compliance.

---

## 🛠️ Scripts, Diagrams, & Examples
We strongly encourage hands-on assets!

* **Automation Scripts:** Add T-SQL queries (`.sql`) or PowerShell scripts (`.ps1`) to the manual's `/Scripts` folder. Include comments explaining complex code.
* **Diagrams & Architecture:** Flowcharts, process diagrams, and visual aids (Markdown or Mermaid format) are welcome.
* **Real-World Examples:** Share anonymized scenarios, edge cases, and practical tips in `Community-Contributions.md`.

---

## 🔀 Pull Request Guidelines

1. **Keep PRs Focused:** Submit small, incremental PRs addressing specific sections or scripts rather than massive single commits.
2. **Clear Titles & Descriptions:** Use descriptive PR titles (e.g., `content: Add Database Inventory section to August Draft`).
3. **Link Issues:** If your PR addresses an existing issue, reference it in the description (e.g., `Fixes #12`).
4. **Review Process:** Once submitted, maintainers will review your PR for safety, syntax, and clarity before merging.

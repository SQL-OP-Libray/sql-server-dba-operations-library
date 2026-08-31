# 📚 SQL Server DBA Operations Library

A community-powered operational library for SQL Server database administrators. Every month, we collaboratively build, review, and release one production-ready operational manual alongside automation scripts, checklists, and downloadable PDF documentation.

---

## 🎯 Vision

Technical skill keeps systems alive; standardized documentation keeps teams alive. The **SQL Server DBA Operations Library** bridges the gap between ad-hoc troubleshooting and enterprise-grade operations. We empower DBAs, engineers, and architects to deploy consistent, production-ready operational standards across any SQL Server environment.

---

## 🗓️ Delivery Model & Monthly Cadence

* **1 Manual Per Month:** Publicly collaborated on throughout the month.
* **Community Contributions:** Open via Pull Requests for scripts, checklists, and documentation.
* **Month-End PDF Release:** Compiled into a clean, downloadable PDF guide at the end of each month.

---

## 🗺️ Release Roadmap

| Target | Manual Title | Directory Path | Status |
| :--- | :--- | :--- | :--- |
| **August 2026** | **SQL Server Inventory Template** | `01-Foundation/SQL-Server-Inventory-Template` | 🔄 *In Progress* |
| September 2026 | Backup & Recovery SOP | `02-Operations/` | 📅 *Planned* |
| October 2026 | Migration & Deployment Runbook | `03-Deployment/` | 📅 *Planned* |
| November 2026 | Disaster Recovery Runbook | `04-HA-DR/` | 📅 *Planned* |
| December 2026 | Monitoring & Performance Standards | `05-Advanced/` | 📅 *Planned* |

---

## 🗂️ Repository Structure

```text
/SQL-Server-DBA-Operations-Library
│
├── 00-Governance
│   ├── Contribution-Guidelines.md
│   ├── Review-Process.md
│   └── Monthly-Release-Calendar.md
│
├── 01-Foundation
│   ├── SQL-Server-Inventory-Template
│   │   ├── Outline.md
│   │   ├── Draft.md
│   │   ├── Community-Contributions.md
│   │   ├── Scripts
│   │   │   ├── Inventory-PowerShell.ps1
│   │   │   ├── Inventory-TSQL.sql
│   │   │   └── Inventory-Checks.sql
│   │   └── Final-PDF
│   └── DBA-Operational-Handbook
│
├── 02-Operations
│   └── Backup-Recovery-SOP
│
├── 03-Deployment
│   └── Migration-Runbook
│
├── 04-HA-DR
│   └── DR-Runbook
│
├── 05-Advanced
│   └── Monitoring-Standards
│
└── README.md

```

---

## 📜 Contribution Rules

We welcome contributions from DBAs, DevOps engineers, and SQL Server enthusiasts of all experience levels.

1. **Be Practical:** Focus on real-world operational steps over theory.
2. **Be Clear:** Write documentation accessible to junior DBAs.
3. **Be Safe:** **Never** include production credentials, sensitive server names, or proprietary data.
4. **Be Structured:** Ensure every contribution includes its **Purpose**, **Steps**, **Validation**, and **Risks**.

---

## 🔒 Access & Submissions

This repository is currently private and available to approved community contributors upon request.

### How to Request Access

1. Send a request with your GitHub username (via LinkedIn DM or direct request).
2. Once added as a collaborator, you will receive an invitation email to access the repository.

### How to Submit Changes

1. Accept your collaborator invitation.
2. Clone the repository locally or work directly on GitHub.
3. Create a feature branch for your work:
`git checkout -b feature/august-inventory-script`
4. Commit and push your changes:
`git commit -m 'Add T-SQL inventory script'`
`git push origin feature/august-inventory-script`
5. Open a **Pull Request** targeting the `main` branch for review.

Refer to `00-Governance/Contribution-Guidelines.md` for full review guidelines.

---

## 📄 Rights & Usage

This project is currently provided as a private community resource without a formal open-source license. All rights are reserved by the author. You are welcome to view, request access, and contribute, but public redistribution or commercial re-licensing is strictly restricted.

```

```

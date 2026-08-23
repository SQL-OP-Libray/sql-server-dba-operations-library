# 🤝 Contribution Guidelines

Welcome to the **SQL Server DBA Operations Library**! This document outlines the standards and rules for contributing documentation, scripts, and operational templates to this repository.

---

## 🎯 Core Principles

1. **Be Practical:** Focus on real-world operational scenarios over abstract theory.
2. **Be Clear:** Write step-by-step instructions that a junior or mid-level DBA can execute safely.
3. **Be Safe:** **Never** include production credentials, actual IP addresses, company names, or sensitive infrastructure data in commits.
4. **Be Structured:** Ensure documentation follows standard formatting (Purpose, Scope, Prerequisites, Steps, Validation, Risks).

---

## 📥 How to Contribute

Because this is a **private community repository**, access is granted upon request:

### 1. Request Access
Send your GitHub username via LinkedIn DM or direct contact. Once invited, accept your repository collaborator email invitation.

### 2. Branching Strategy
* **Never** push directly to the `main` branch.
* Create a feature branch off `main` using the following naming convention:
  * Content/Manuals: `feature/august-inventory-draft`
  * Scripts: `script/tsql-inventory-check`
  * Fixes: `fix/typo-governance`

### 3. Submitting a Pull Request (PR)
1. Push your branch to the repository:
   ```bash
   git push origin feature/your-branch-name

```

2. Open a **Pull Request** targeting `main`.
3. Complete the PR template with a clear description of what was added or updated.

---

## 📜 Script Contribution Rules

If you are contributing T-SQL or PowerShell scripts:

* **Safety First:** Scripts must default to read-only operations or prompt/warn before making destructive changes.
* **Formatting:**
* **T-SQL:** Use uppercase for keywords (`SELECT`, `FROM`, `WHERE`, `JOIN`). Include comments explaining complex queries.
* **PowerShell:** Follow standard `Verb-Noun` conventions (e.g., `Get-SqlInstanceInventory.ps1`).


* **Compatibility:** State supported SQL Server versions explicitly (e.g., SQL Server 2016+).
* **Error Handling:** Include basic error handling (`TRY...CATCH` in T-SQL, `-ErrorAction` in PowerShell).

---

## ⚠️ Content Safety & Sanitization

Before submitting any code or markdown, verify that:

* Hostnames are anonymized (e.g., `SQLPROD01`, `SQLDR01`).
* Sample IP addresses use reserved RFC blocks (e.g., `192.0.2.x` or `10.0.0.x`).
* Domain names use placeholders (e.g., `domain.local` or `contoso.com`).

```

# 📄 SQL Server Inventory Template — Community Draft

> **Status:** 🔄 *Draft in Progress*  
> **Target Release:** August 2026  
> **Maintainer:** Zadig & Community Contributors

---

## 1. Purpose
*<!-- Contributor Note: Add operational context on why inventory management matters. -->*
An outdated or incomplete database inventory is one of the most critical hidden risks in enterprise IT infrastructure. Without a centralized, reliable source of truth for every SQL Server instance, database administration teams face severe operational vulnerabilities during production outages, security audits, disaster recovery (DR) drills, and infrastructure migrations.

The primary objective of the SQL Server Inventory Standard is to establish a unified, accurate, and continually updated repository of metadata across all SQL Server instances—whether hosted on-premises, across virtualized infrastructure, or within multi-cloud environments.

Key Operational Objectives

Accelerated Incident Management (MTTR): Drastically reduce Mean Time to Resolution during production outages by providing on-call DBAs immediate visibility into server specifications, application ownership, patch levels, and underlying storage layouts.

Continuous Audit & Compliance Readiness: Maintain an audit-ready baseline for compliance frameworks (SOC 2, ISO 27001, HIPAA, PCI-DSS) by tracking security configurations, authentication modes, patch baselines, and data retention policies.

Proactive Risk & End-of-Life (EOL) Management: Identify unsupported database engines, missing cumulative updates (CUs), unsafe configuration settings (e.g., clr enabled, default max server memory), and unhedged database risks before they trigger service degradation.

Disaster Recovery & Node Parity: Ensure failover nodes, AlwaysOn Availability Groups, and warm standby environments maintain matching build versions, collation settings, SQL Agent jobs, and security logins across secondary sites.

License & Capacity Optimization: Track CPU core counts, allocated memory, and edition distribution (Enterprise vs. Standard) to prevent licensing penalties and eliminate wasted compute resources.

## 2. Scope
*<!-- Contributor Note: Detail covered platforms (On-Prem, Azure VM, AWS EC2, Managed Instances). -->*

## 3. Roles & Responsibilities
*<!-- Contributor Note: Outline RACI matrix for maintaining inventory accuracy. -->*

## 4. Inventory Categories
### 4.1 Server & OS Layer
### 4.2 Engine & Instance Layer
### 4.3 Database & Storage Layer
### 4.4 High Availability & DR Configuration
### 4.5 Security & Compliance

## 5. Standard Inventory Fields
*<!-- Contributor Note: Define target schema for inventory tables. -->*

## 6. Inventory Collection Procedures
*<!-- Contributor Note: Explain execution workflow for included T-SQL & PowerShell scripts. -->*

## 7. Validation Steps
*<!-- Contributor Note: Detail query checks to identify missing or outdated entries. -->*

## 8. Review Cadence
*<!-- Contributor Note: Outline operational schedules for monthly/quarterly reviews. -->*

## 9. Risk Assessment Checklist
*<!-- Contributor Note: Add risk triggers (e.g., SQL Server 2012 EOL, missing backups). -->*

## 10. Best Practices
*<!-- Contributor Note: Add guidelines on inventory automation and documentation hygiene. -->*

## 11. Metrics & KPIs
*<!-- Contributor Note: Add sample KPIs for tracking inventory health. -->*

## 12. Appendices
*<!-- Contributor Note: Reference scripts located in the /Scripts folder. -->*

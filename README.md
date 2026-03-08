# 🗄️ SQL Testing Portfolio Project

**Test Cycle Version:** 1.0
**Test Execution Period:** 2026-03-07 – Present
**Tester:** GCarlomagno

---

## 📌 Project Overview

This repository demonstrates practical SQL data validation skills applied in a QA context.

The objective of this project is to validate backend data correctness, consistency, and relational integrity using SQL queries that reflect real-world QA scenarios performed after UI or API actions.

The project includes full QA documentation artifacts:

- Structured SQL validation scenarios with QA context
- Local SQLite test database with schema and seed data
- Execution evidence (screenshots)

All artifacts follow standardized documentation conventions to simulate real project-level QA execution.

---

## 🛠 Environment

The SQL validation scenarios were executed against a local SQLite database created specifically for QA testing purposes.

The database simulates a simplified application backend with users and orders tables, reflecting realistic data structures found in production systems.

---

## 🧪 Testing Scope

### Included

- Data correctness validation after UI and API actions
- Duplicate record prevention checks
- Relational integrity validation (foreign key consistency)
- Aggregated data accuracy (totals, counts)
- NULL and invalid field detection
- Order lifecycle status validation
- Data anomaly investigation queries

### Excluded

- Performance testing
- Security testing
- Multi-database compatibility testing
- Stored procedures and triggers

---

## 🔍 Testing Approach

Testing was performed using a structured SQL validation methodology including:

- Targeted SELECT queries to verify data after simulated UI actions
- Aggregation queries using COUNT, SUM, GROUP BY, and HAVING
- JOIN queries to validate relational integrity between tables
- Negative validation to detect anomalies and data defects
- Exploratory backend investigation queries

---

## 📂 Repository Structure

The documentation is organized as follows:

- `/docs/` – SQL validation scenarios with QA context and query documentation
- `/database/` – SQLite database files including schema, seed data, and generated database

---

## 🎯 Skills Demonstrated

- SQL SELECT, WHERE, JOIN, GROUP BY, HAVING, ORDER BY
- Data validation after UI and API actions
- Relational integrity verification
- Duplicate and anomaly detection
- Aggregated data validation
- NULL and invalid value detection
- Backend QA mindset and data investigation
- Local SQLite database setup and execution

---

## 🧪 Validation Scenarios

| Scenario ID | Description | Type |
|-------------|-------------|------|
| 3.1 | Validate new user registration | Positive |
| 3.2 | Validate duplicate email prevention | Negative |
| 3.3 | Validate latest registered user | Positive |
| 3.4 | Validate order linked to correct user | Relational |
| 3.5 | Validate total number of orders per user | Aggregation |
| 3.6 | Validate total order amount per user | Aggregation |
| 3.7 | Detect orphan orders | Integrity |
| 3.8 | Validate completed orders | Lifecycle |
| 3.9 | Detect users with NULL critical fields | Anomaly |
| 3.10 | Detect invalid or negative order amounts | Anomaly |
| 3.11 | Detect duplicate orders for the same user | Anomaly |
| 3.12 | Detect inconsistent order status and amount | Anomaly |

Full validation documentation is available in [docs/SQL-for-QA.md](docs/SQL-for-QA.md).

---

## 🗃️ Database Setup

The local test database can be recreated using the following commands:

```bash
sqlite3 qa-test-database.db
.read schema.sql
.read seed-data.sql
```

Database files are available in the `/database/` directory.

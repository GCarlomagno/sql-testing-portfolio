# SQL for QA — Data Validation Scenarios

---

## 1. Purpose

This document demonstrates practical SQL queries used by QA engineers to validate backend data after performing UI or API actions.

The focus is on verifying:

- Data correctness  
- Data consistency  
- Relational integrity  
- Duplicate prevention  
- Aggregated accuracy  

All queries reflect realistic validation scenarios performed during manual or API testing.

---

## 2. Test Database Assumption

For demonstration purposes, we assume a simplified application database with the following tables:

### users
- id (INT)
- name (VARCHAR)
- email (VARCHAR)
- status (VARCHAR)
- created_at (TIMESTAMP)

### orders
- id (INT)
- user_id (INT)
- product_name (VARCHAR)
- amount (DECIMAL)
- status (VARCHAR)
- created_at (TIMESTAMP)

---

## 3. Core Validation Scenarios

### 3.1 Scenario - Validate New User Registration

**QA Context:**  
After registering a new user via the UI, verify that the record was correctly inserted into the database.

**Validation Goals:**
- User record exists
- Email stored correctly
- Status set to 'ACTIVE'
- created_at timestamp populated

**SQL Query:**

```sql
SELECT id, name, email, status, created_at
FROM users
WHERE email = 'testuser@email.com';
```
**What QA Validates:**

- Exactly one record is returned
- status = 'ACTIVE'
- created_at IS NOT NULL
- Email value matches the one used during registration

### 3.2 Scenario - Validate Duplicate Email Prevention

**QA Context:**  
The application should prevent multiple accounts from being created with the same email address.

**Validation Goal:**
Ensure only one record exists for a specific email.

**SQL Query:**

```sql
SELECT COUNT(*) AS total_records
FROM users
WHERE email = 'testuser@email.com';
```

**What QA Validates:**

- COUNT must return 1  
- If COUNT > 1 → Data integrity defect  
- If COUNT = 0 → Registration persistence failure  

### 3.3 Scenario - Validate Latest Registered User

**QA Context:**  
After registering a new user, verify that it appears as the most recent record in the database.

**Validation Goal:**
Ensure the latest inserted user matches the one created during testing.

**SQL Query:**

```sql
SELECT id, name, email, created_at
FROM users
ORDER BY created_at DESC;
```

**What QA Validates:**

- The first record in the result set matches the test email
- created_at timestamp reflects the recent registration time
- No unexpected records appear after the test action

### 3.4 Scenario - Validate Order Linked to Correct User

**QA Context:**  
After a user places an order via the UI or API, verify that the order is correctly linked to the corresponding user in the database.

**Validation Goal:**
Ensure the order references the correct user_id and relational integrity is maintained.

**SQL Query:**

```sql
SELECT u.id AS user_id,
       u.email,
       o.id AS order_id,
       o.amount,
       o.status
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE u.email = 'testuser@email.com';
```

**What QA Validates:**

- Order exists for the correct user
- user_id in orders table matches users.id
- amount reflects the UI transaction
- Order status is correct (e.g., 'CREATED' or 'PAID')

### 3.5 Scenario - Validate Total Number of Orders per User

**QA Context:**  
After placing multiple orders, verify that the total number of orders associated with a user matches the expected count.

**Validation Goal:**
Ensure aggregation reflects correct number of related records.

**SQL Query:**

```sql
SELECT u.email,
       COUNT(o.id) AS total_orders
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE u.email = 'testuser@email.com'
GROUP BY u.email;
```

**What QA Validates:**

- total_orders matches the number of orders created during testing
- No unexpected duplicate records exist
- Aggregation logic reflects actual transactional activity

### 3.6 Scenario - Validate Total Order Amount per User

**QA Context:**  
After placing multiple orders, verify that the total monetary amount recorded in the database matches the expected sum of transactions.

**Validation Goal:**  
Ensure aggregated financial data is accurate.

**SQL Queries:**

List individual orders for the user:

```sql
SELECT id,
       product_name,
       amount,
       status
FROM orders
WHERE user_id = (
    SELECT id
    FROM users
    WHERE email = 'testuser@email.com'
);
```

**What QA Validates:**

- Individual orders exist for the user created during testing
- Each order amount matches the expected transaction values
- total_spent equals the sum of individual order amounts
- No incorrect duplication inflates the total
- Monetary precision is preserved (no rounding anomalies)

### 3.7 Scenario - Detect Orphan Orders (Data Integrity Check)

**QA Context:**  
Verify that every order in the database is linked to an existing user.  
Orders referencing non-existent users indicate a serious relational integrity issue.

**Validation Goal:**
Identify orders with invalid or missing user references.

**SQL Query:**

```sql
SELECT o.id AS order_id,
       o.user_id
FROM orders o
LEFT JOIN users u ON o.user_id = u.id
WHERE u.id IS NULL;
```

**What QA Validates:**

- Query should return zero rows
- Any returned record indicates a broken foreign key relationship
- Such issues may lead to reporting inconsistencies or system errors

### 3.8 Scenario - Validate Completed Orders

**QA Context:**  
After completing an order payment, verify that the order status is correctly updated in the database.

**Validation Goal:**
Ensure orders reflect the correct lifecycle state.

**SQL Query:**

```sql
SELECT id, user_id, status
FROM orders
WHERE status = 'COMPLETED';
```

**What QA Validates:**

- Recently paid orders appear with status = 'PAID'
- No paid orders remain in incorrect states such as 'CREATED'
- Status transitions reflect business rules correctly

### 3.9 Scenario - Detect Users With NULL Critical Fields

**QA Context:**  
After user registration or profile updates, records may be saved incorrectly due to partial inserts, backend validation failures, or unexpected system errors.

**Validation Goal:**
Identify users with missing critical information required for proper account operation.

**SQL Query:**

```sql
SELECT id, name, email, status, created_at
FROM users
WHERE email IS NULL
   OR status IS NULL
   OR created_at IS NULL;
```
**What QA Validates:**

- User records missing mandatory information
- Backend validation failures during user creation
- Data corruption or incomplete persistence

### 3.10 Scenario - Detect Invalid or Negative Order Amounts

**QA Context:**  
Order totals recorded in the database must reflect valid financial transactions.  
Backend calculation errors, discount logic issues, or data corruption could result in invalid values.

**Validation Goal:**
Identify orders where the recorded amount is invalid.

**SQL Query:**

```sql
SELECT id, user_id, amount, status, created_at
FROM orders
WHERE amount IS NULL
   OR amount <= 0;
```  

### 3.11 Scenario - Detect Duplicate Orders for the Same User

**QA Context:**  
Users may accidentally trigger multiple order submissions due to double taps, network retries, or backend processing issues.  
Such situations can create duplicate orders that should not exist.

**Validation Goal:**
Identify potential duplicate orders created for the same user at the same time.

**SQL Query:**

```sql
SELECT user_id,
       created_at,
       COUNT(*) AS order_count
FROM orders
GROUP BY user_id, created_at
HAVING COUNT(*) > 1;
```

### 3.12 Scenario - Detect Inconsistent Order Status and Amount

**QA Context:**  
Orders should follow valid business rules.  
For example, an order marked as `PAID` should always have a valid positive monetary value.

**Validation Goal:**
Detect orders where the lifecycle status does not match the financial value recorded.

**SQL Query:**

```sql
SELECT id, user_id, amount, status, created_at
FROM orders
WHERE status = 'PAID'
  AND (amount IS NULL OR amount <= 0);
```

---

## 4. Data Anomaly Investigation Queries

These queries represent QA exploratory backend validation when investigating issues.

Unlike standard validation checks, these queries help detect abnormal patterns in system data that may indicate defects, integration issues, or unexpected application behavior.


### 4.1 Scenario - Detect Duplicate Orders for the Same Product

**QA Context:**  
Users may accidentally trigger duplicate purchases due to network retries or double taps.

**Validation Goal:**
- Identify multiple orders for the same user and product
- Detect potential duplicate transactions

**SQL Query:**

```sql
SELECT user_id,
       product_name,
       COUNT(*) AS order_count
FROM orders
GROUP BY user_id, product_name
HAVING COUNT(*) > 1;
```

**What QA Investigates:**

- Multiple orders created for the same product
- Possible UI double submission
- Retry logic failures during network instability

### 4.2 Scenario - Detect Orders With Invalid Status Values

**QA Context:**  
Backend systems may introduce unexpected status values due to integration issues or faulty deployments.

**Validation Goal:**
Identify orders containing unexpected lifecycle states.

**SQL Query:**

```sql
SELECT id,
       user_id,
       status
FROM orders
WHERE status NOT IN ('CREATED','PAID','CANCELLED','COMPLETED');
```

**What QA Investigates:**

- Unknown order states
- Deployment inconsistencies
- Backend workflow validation errors

### 4.3 Scenario - Detect Suspiciously Large Transactions

**QA Context:**  
Incorrect pricing calculations or integration issues may generate unrealistic order totals.

**Validation Goal:**
Identify orders with unusually high transaction values.

**SQL Query:**

```sql
SELECT id,
       user_id,
       amount
FROM orders
WHERE amount > 1000;
```
**What QA Investigates:**

- Pricing calculation defects
- Currency conversion issues
- Corrupted or abnormal financial data

---

## 5. Key SQL Concepts Used

- SELECT  
- WHERE  
- COUNT  
- ORDER BY  
- JOIN  
- GROUP BY  
- HAVING  
- SUM

---

## 6. QA Mindset

The purpose of these queries is not development analysis.

They are used to validate:

- UI action → database reflection  
- Business rule enforcement  
- Data integrity  
- Prevention of inconsistent states  

### 6.1 Data Anomaly Mindset (What Can Go Wrong?)

In addition to validating expected results, QA should actively search for anomalies that may indicate backend issues, such as:

- **Missing critical values:** NULL in required fields (email, status, created_at)
- **Invalid numeric values:** totals that are zero, negative, or NULL
- **Duplicate transactions:** double taps, network retries, missing idempotency (multiple operations result the same as performing it once)
- **Inconsistent state:** status values that do not match other fields (e.g., PAID with 0 total)

These checks improve defect detection and make database validation more investigation-oriented.

---

## 7. Local Test Database Environment

To execute the validation scenarios described in this document, a local SQLite database was created.

### Database Location

docs/sql-validation/database/

### Database Files

The database environment is defined by the following files:

- `schema.sql` – defines the database structure (tables, constraints, relationships)
- `seed-data.sql` – inserts controlled test data used for validation scenarios
- `qa-test-database.db` – the generated SQLite database file

### Database Schema

The database contains the following tables.

**users**

- id (INTEGER PRIMARY KEY AUTOINCREMENT)
- name (TEXT NOT NULL)
- email (TEXT UNIQUE NOT NULL)
- status (TEXT NOT NULL)
- created_at (DATETIME DEFAULT CURRENT_TIMESTAMP)

**orders**

- id (INTEGER PRIMARY KEY AUTOINCREMENT)
- user_id (INTEGER NOT NULL)
- product_name (TEXT NOT NULL)
- amount (DECIMAL NOT NULL)
- status (TEXT NOT NULL)
- created_at (DATETIME DEFAULT CURRENT_TIMESTAMP)

Orders reference users through a foreign key relationship:

orders.user_id → users.id

### Database Initialization

The database can be recreated with the following commands:

```bash
sqlite3 qa-test-database.db
.read schema.sql
.read seed-data.sql
```

---

## 8. Execution Evidence

The SQL validation scenarios defined in this document were executed against the local SQLite test database.

The execution included:

- User registration verification
- Duplicate email validation
- Latest user retrieval
- Order-to-user relational validation
- Order aggregation checks
- Financial total validation
- Relational integrity verification

Execution screenshots are available in:

`evidence/week4/day4/`

These results demonstrate practical backend validation performed by QA engineers after UI or API actions.
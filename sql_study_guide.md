# SQL Study Guide

> Simple explanations for non-native English speakers.
> Examples use standard SQL (PostgreSQL style). Small differences in other databases are noted.

## Table of Contents

1. [Sample Data](#1-sample-data)
2. [WHERE](#2-where)
3. [JOIN Types](#3-join-types)
4. [COALESCE](#4-coalesce)
5. [UNION](#5-union)
6. [EXCEPT](#6-except)
7. [WITH (CTE)](#7-with-cte)
8. [Order of Operations](#8-order-of-operations)
9. [Indexes](#9-indexes)
10. [Window Functions](#10-window-functions)
11. [Exercise: Symmetric Difference (A not B + B not A)](#11-exercise-symmetric-difference)
12. [Query Optimization Techniques](#12-query-optimization-techniques)
13. [Views and Materialized Views](#13-views-and-materialized-views)
14. [Concurrency: Same Record at the Same Time](#14-concurrency)
15. [CASE Statement](#15-case-statement)
16. [OVER Clause](#16-over-clause)
17. [Quick Vocabulary](#17-quick-vocabulary)

---

## 1. Sample Data

We use these tables in many examples.

**`products`**

| product_id | name     | category    |
|-----------:|----------|-------------|
| 1          | Laptop   | Electronics |
| 2          | Phone    | Electronics |
| 3          | Tablet   | Electronics |
| 4          | Desk     | Furniture   |
| 5          | Chair    | Furniture   |

**`sales`**

| sale_id | product_id | quantity | sale_date  |
|--------:|-----------:|---------:|------------|
| 1       | 1          | 10       | 2026-01-05 |
| 2       | 2          | 25       | 2026-01-06 |
| 3       | 3          | 5        | 2026-01-07 |
| 4       | 4          | 8        | 2026-01-08 |
| 5       | 5          | 12       | 2026-01-09 |

---

## 2. WHERE

**Definition:** `WHERE` filters **rows** before they are grouped or returned.

```sql
SELECT name, category
FROM products
WHERE category = 'Electronics';
```

**Common operators:**

| Operator            | Meaning                | Example                          |
|---------------------|------------------------|----------------------------------|
| `=`, `<>`, `<`, `>` | Compare values         | `quantity > 10`                  |
| `AND`, `OR`, `NOT`  | Combine conditions     | `quantity > 5 AND quantity < 20` |
| `IN`                | Value is in a list     | `category IN ('A', 'B')`         |
| `BETWEEN`           | Value is in a range    | `quantity BETWEEN 5 AND 10`      |
| `LIKE`              | Match a text pattern   | `name LIKE 'L%'`                 |
| `IS NULL`           | Check for missing data | `email IS NULL`                  |

**Important notes:**

- Use `IS NULL`, **not** `= NULL`. `NULL` means "unknown", so `NULL = NULL` is not true.
- `WHERE` filters **rows**. `HAVING` filters **groups** (after `GROUP BY`).

```sql
-- WHERE filters rows, HAVING filters groups
SELECT product_id, SUM(quantity) AS total
FROM sales
WHERE sale_date >= '2026-01-01'   -- filter rows first
GROUP BY product_id
HAVING SUM(quantity) > 10;        -- filter groups after
```

---

## 3. JOIN Types

**Definition:** A `JOIN` combines rows from two tables using a related column.

Let's say **A = left table** and **B = right table**.

| JOIN type          | Returns                                                      |
|--------------------|--------------------------------------------------------------|
| `INNER JOIN`       | Only rows that match in **both** tables                      |
| `LEFT JOIN`        | **All** rows from A + matches from B (no match → `NULL`)     |
| `RIGHT JOIN`       | **All** rows from B + matches from A (no match → `NULL`)     |
| `FULL OUTER JOIN`  | **All** rows from both tables (no match → `NULL`)            |
| `CROSS JOIN`       | Every row of A with every row of B (all combinations)        |
| `SELF JOIN`        | A table joined with **itself**                               |

**Mini example data** (used in the short examples below):

| table_a (id) | table_b (id) |
|:------------:|:------------:|
| 1            | 2            |
| 2            | 3            |
| 3            | 4            |

### INNER JOIN

**What it does:** Keeps only the rows that have a match in **both** tables. Rows without a match are removed.

```sql
SELECT p.name, s.quantity
FROM products p
INNER JOIN sales s ON s.product_id = p.product_id;
```

**Short example:**

```sql
SELECT a.id AS a_id, b.id AS b_id
FROM table_a a
INNER JOIN table_b b ON a.id = b.id;
```

| a_id | b_id |
|-----:|-----:|
| 2    | 2    |
| 3    | 3    |

### LEFT JOIN

**What it does:** Keeps **all** rows from the left table (A). If there is no match in B, the B columns are `NULL`. Useful to find rows **without** a match.

```sql
-- Products that have never been sold
SELECT p.name
FROM products p
LEFT JOIN sales s ON s.product_id = p.product_id
WHERE s.sale_id IS NULL;
```

**Short example:**

```sql
SELECT a.id AS a_id, b.id AS b_id
FROM table_a a
LEFT JOIN table_b b ON a.id = b.id;
```

| a_id | b_id |
|-----:|-----:|
| 1    | NULL |
| 2    | 2    |
| 3    | 3    |

### RIGHT JOIN

**What it does:** Keeps **all** rows from the right table (B). If there is no match in A, the A columns are `NULL`. It is the same as `LEFT JOIN` but in the other direction. Most people just swap the tables and use `LEFT JOIN`.

**Short example:**

```sql
SELECT a.id AS a_id, b.id AS b_id
FROM table_a a
RIGHT JOIN table_b b ON a.id = b.id;
```

| a_id | b_id |
|-----:|-----:|
| 2    | 2    |
| 3    | 3    |
| NULL | 4    |

### FULL OUTER JOIN

**What it does:** Keeps **all** rows from **both** tables. Where there is no match, the missing side is `NULL`.

```sql
SELECT a.id AS a_id, b.id AS b_id
FROM table_a a
FULL OUTER JOIN table_b b ON a.id = b.id;
```

**Short example (result of the query above):**

| a_id | b_id |
|-----:|-----:|
| 1    | NULL |
| 2    | 2    |
| 3    | 3    |
| NULL | 4    |

> MySQL does not support `FULL OUTER JOIN`. Use `LEFT JOIN` `UNION` `RIGHT JOIN` instead.

### CROSS JOIN

**What it does:** Combines **every** row of A with **every** row of B. There is no `ON` condition. The result has A rows × B rows.

```sql
-- Every size with every color
SELECT s.size, c.color
FROM sizes s
CROSS JOIN colors c;
```

**Short example** (`sizes` = S, M and `colors` = Red, Blue):

| size | color |
|------|-------|
| S    | Red   |
| S    | Blue  |
| M    | Red   |
| M    | Blue  |

### SELF JOIN

**What it does:** Joins a table with **itself**. Give the table two different aliases so SQL can tell them apart. Useful for hierarchies, like employees and managers.

```sql
-- Employees and their managers (same table)
SELECT e.name AS employee, m.name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id;
```

**Short example** (Ana has no manager; Ben's manager is Ana):

| employee | manager |
|----------|---------|
| Ana      | NULL    |
| Ben      | Ana     |

### Common mistake

If you put a filter on the right table in `WHERE`, a `LEFT JOIN` can behave like an `INNER JOIN`. Put that filter in the `ON` clause instead.

```sql
-- Keeps all products, even those without sales in 2026
SELECT p.name, s.quantity
FROM products p
LEFT JOIN sales s
  ON s.product_id = p.product_id
 AND s.sale_date >= '2026-01-01';
```

---

## 4. COALESCE

**Definition:** `COALESCE` returns the **first value that is not `NULL`** from a list.

```sql
COALESCE(value1, value2, value3, ...)
```

**Examples:**

```sql
SELECT COALESCE(NULL, NULL, 'hello', 'world');  -- 'hello'

-- Replace NULL with a default value
SELECT name, COALESCE(phone, 'No phone') AS phone
FROM customers;

-- Avoid NULL in math (NULL + 5 = NULL)
SELECT COALESCE(SUM(quantity), 0) AS total
FROM sales
WHERE product_id = 999;
```

**Short example:**

```sql
SELECT name, COALESCE(phone, 'No phone') AS phone
FROM customers;
```

| name | phone    |
|------|----------|
| Ana  | 555-1234 |
| Ben  | No phone |

Ana has a phone, so her value is returned. Ben's phone is `NULL`, so `'No phone'` is returned.

**When to use it:**

- Show a default value instead of `NULL`.
- Pick the first available value (e.g., mobile phone, then home phone, then work phone).

---

## 5. UNION

**Definition:** `UNION` combines the results of two or more `SELECT` queries into one result.

| Command     | Duplicates                 | Speed  |
|-------------|----------------------------|--------|
| `UNION`     | **Removes** duplicates     | Slower |
| `UNION ALL` | **Keeps** duplicates       | Faster |

```sql
SELECT name FROM customers
UNION
SELECT name FROM suppliers;
```

**Rules:**

1. Both queries must have the **same number of columns**.
2. The columns must have **compatible data types**, in the same order.
3. Column names come from the **first** query.

> Use `UNION ALL` when you know there are no duplicates, or when duplicates are fine. It is faster because it skips the duplicate check.

---

## 6. EXCEPT

**Definition:** `EXCEPT` returns rows from the **first** query that are **not** in the **second** query. It also removes duplicates.

```sql
SELECT product_id FROM products
EXCEPT
SELECT product_id FROM sales;
-- Products that were never sold
```

**Notes:**

- Same column rules as `UNION`.
- Order matters: `A EXCEPT B` is **not** the same as `B EXCEPT A`.
- Oracle uses `MINUS` instead of `EXCEPT`.
- MySQL supports `EXCEPT` only in version 8.0.31 and later.
- `INTERSECT` is the opposite idea: rows that are in **both** queries.

```mermaid
flowchart LR
    A["A EXCEPT B = only in A"]
```

---

## 7. WITH (CTE)

**Definition:** `WITH` creates a **CTE** (Common Table Expression). A CTE is a **temporary named result** that you can use in the main query. Think of it as a "temporary view" that lives for one query.

**Why use it?**

- Makes long queries **easier to read**.
- You can **reuse** the same result several times.
- Allows **recursive** queries.

```sql
WITH total_by_product AS (
    SELECT product_id, SUM(quantity) AS total
    FROM sales
    GROUP BY product_id
)
SELECT p.name, t.total
FROM total_by_product t
JOIN products p ON p.product_id = t.product_id
WHERE t.total > 10;
```

**Multiple CTEs:**

```sql
WITH
a AS (SELECT ...),
b AS (SELECT ... FROM a)   -- b can use a
SELECT * FROM b;
```

**Recursive CTE** (for trees, like employees and managers):

```sql
WITH RECURSIVE org AS (
    SELECT employee_id, name, manager_id, 1 AS level
    FROM employees
    WHERE manager_id IS NULL           -- starting point

    UNION ALL

    SELECT e.employee_id, e.name, e.manager_id, o.level + 1
    FROM employees e
    JOIN org o ON e.manager_id = o.employee_id   -- repeat step
)
SELECT * FROM org;
```

---

## 8. Order of Operations

### Written order vs. execution order

You **write** a query in this order, but the database **runs** it in a different order (logical order):

| Step | Clause       | What it does                          |
|-----:|--------------|---------------------------------------|
| 1    | `FROM` / `JOIN` | Choose and combine tables          |
| 2    | `WHERE`      | Filter rows                           |
| 3    | `GROUP BY`   | Make groups                           |
| 4    | `HAVING`     | Filter groups                         |
| 5    | `SELECT`     | Choose columns, calculate expressions (window functions run here) |
| 6    | `DISTINCT`   | Remove duplicate rows                 |
| 7    | `ORDER BY`   | Sort the result                       |
| 8    | `LIMIT` / `OFFSET` / `TOP` | Cut the result          |

### Why does it matter?

1. **Column aliases:** You **cannot** use a `SELECT` alias in `WHERE`, because `WHERE` runs **before** `SELECT`. You **can** use it in `ORDER BY`.

   ```sql
   -- ERROR
   SELECT quantity * 2 AS double_qty
   FROM sales
   WHERE double_qty > 10;

   -- OK
   SELECT quantity * 2 AS double_qty
   FROM sales
   WHERE quantity * 2 > 10
   ORDER BY double_qty;
   ```

2. **WHERE vs. HAVING:** `WHERE` cannot use aggregate functions (`SUM`, `COUNT`) because groups do not exist yet. Use `HAVING`.

3. **Window functions:** They run in `SELECT`, so you **cannot** filter them in `WHERE`. Use a CTE or subquery.

4. **Performance:** Filter early with `WHERE` so fewer rows go into `GROUP BY` and `JOIN`.

5. **Correct results:** A filter in `WHERE` and a filter in `HAVING` can give **different** results.

> Note: This is the *logical* order. The database optimizer may run things in a different physical order, but the result must be the same.

---

## 9. Indexes

### What is an index?

An **index** is a special data structure (usually a **B-tree**) that helps the database **find rows faster**, like the index at the back of a book. Without an index, the database reads the **whole table** (a *full table scan*).

```sql
CREATE INDEX idx_sales_product_id ON sales (product_id);
```

### When to use an index

Use an index on columns that are often used in:

- `WHERE` filters
- `JOIN` conditions (foreign keys)
- `ORDER BY` / `GROUP BY`
- Columns with **high selectivity** (many different values, like `email`)

### When NOT to use an index

- **Small tables** (a full scan is already fast).
- Columns with **few different values** (like `gender` or `is_active`).
- Tables with **many writes** (`INSERT`, `UPDATE`, `DELETE`). Every index must be updated, so writes become slower.
- Columns that are rarely used in queries.

### Trade-off

| Benefit                | Cost                              |
|------------------------|-----------------------------------|
| Faster `SELECT`        | Slower `INSERT`/`UPDATE`/`DELETE` |
| Faster `JOIN`, `ORDER BY` | Uses more disk space           |

### Main types of indexes

| Type                | Description                                                       |
|---------------------|-------------------------------------------------------------------|
| **Primary key**     | Unique, not null. Usually creates an index automatically.         |
| **Unique**          | Does not allow duplicate values.                                  |
| **Composite**       | Index on **several columns**. Column order matters.               |
| **Clustered**       | Defines the physical order of the rows. Only **one** per table.   |
| **Non-clustered**   | Separate structure that points to the rows. **Many** per table.   |
| **Covering**        | Contains all columns the query needs, so the table is not read.   |

### Composite index: column order matters

```sql
CREATE INDEX idx_sales_prod_date ON sales (product_id, sale_date);
```

- Works well for: `WHERE product_id = 1`
- Works well for: `WHERE product_id = 1 AND sale_date > '2026-01-01'`
- Usually **not** useful for: `WHERE sale_date > '2026-01-01'` alone (the first column is missing). This is called the **leftmost prefix rule**.

### Can a table have more than one index?

**Yes.** A table can have **many indexes**: for example, one per column, or several composite indexes. Remember:

- Only **one clustered index** per table (in databases that use this term, like SQL Server and MySQL InnoDB).
- Many non-clustered indexes are allowed.
- For one query, the optimizer usually chooses the **best** index for each table. Some databases can combine several indexes (for example, PostgreSQL uses *bitmap index scans*).
- More indexes = slower writes and more storage. Create only the indexes you need.

### Things that can stop an index from being used

```sql
-- Function on the column: index NOT used
WHERE UPPER(name) = 'LAPTOP'

-- Leading wildcard: index NOT used
WHERE name LIKE '%top'

-- Implicit type conversion: index may NOT be used
WHERE phone = 5551234   -- phone is VARCHAR
```

Use `EXPLAIN` to check whether your index is used.

---

## 10. Window Functions

**Definition:** SQL window functions allow performing calculations across a set of rows that are related to the current row, without collapsing the result into a single value (unlike `GROUP BY`).

```sql
function_name(...) OVER (
    PARTITION BY column   -- split rows into groups (optional)
    ORDER BY column       -- order inside each group (optional)
)
```

- `PARTITION BY` = like `GROUP BY`, but rows are not merged.
- `ORDER BY` = order of rows inside each partition.

### Common window functions

| Function         | What it does                                                |
|------------------|-------------------------------------------------------------|
| `ROW_NUMBER()`   | Unique number for each row: 1, 2, 3, 4                      |
| `RANK()`         | Rank with ties; **skips** numbers after a tie: 1, 2, 2, 4   |
| `DENSE_RANK()`   | Rank with ties; **does not skip**: 1, 2, 2, 3               |
| `LAG(col, n)`    | Value from `n` rows **before**                              |
| `LEAD(col, n)`   | Value from `n` rows **after**                               |
| `SUM() OVER`     | Running total or total per partition                        |
| `NTILE(n)`       | Split rows into `n` equal buckets                           |

### Example: running total

```sql
SELECT sale_date,
       quantity,
       SUM(quantity) OVER (ORDER BY sale_date) AS running_total
FROM sales;
```

### Exercise: Second best-selling product per category

**Problem:** You have a list of sales, and products have categories. Get the **second** best-selling product in each category.

**Step 1.** Calculate total sold per product.
**Step 2.** Rank products inside each category (highest sales first).
**Step 3.** Keep only rank = 2.

```sql
WITH product_totals AS (
    SELECT p.product_id,
           p.name,
           p.category,
           SUM(s.quantity) AS total_sold
    FROM products p
    JOIN sales s ON s.product_id = p.product_id
    GROUP BY p.product_id, p.name, p.category
),
ranked AS (
    SELECT *,
           DENSE_RANK() OVER (
               PARTITION BY category
               ORDER BY total_sold DESC
           ) AS rnk
    FROM product_totals
)
SELECT category, name, total_sold
FROM ranked
WHERE rnk = 2;
```

**Result with our sample data:**

| category    | name   | total_sold |
|-------------|--------|-----------:|
| Electronics | Laptop | 10         |
| Furniture   | Desk   | 8          |

**Why a CTE?** Window functions cannot be used in `WHERE` (see [Order of Operations](#8-order-of-operations)), so we calculate the rank first and filter after.

**`ROW_NUMBER` vs. `DENSE_RANK` for this exercise:**

| Function       | If two products tie for 1st place...          |
|----------------|-----------------------------------------------|
| `ROW_NUMBER`   | One tied product gets 2 (random choice)       |
| `RANK`         | There is **no** rank 2 (next one is 3)        |
| `DENSE_RANK`   | The next product gets rank 2 (usually best)   |

Choose based on your business rule. Always tell your interviewer which one you chose and why.

---

## 11. Exercise: Symmetric Difference

**Problem:** Get the elements that are in **A and not in B**, plus the elements that are in **B and not in A**.

This is called the **symmetric difference**.

```
 A = {1, 2, 3}      B = {3, 4, 5}
 Result = {1, 2, 4, 5}      (3 is in both, so it is removed)
```

### Solution 1: `EXCEPT` + `UNION ALL`

```sql
(SELECT id FROM table_a
 EXCEPT
 SELECT id FROM table_b)

UNION ALL

(SELECT id FROM table_b
 EXCEPT
 SELECT id FROM table_a);
```

> `UNION ALL` is safe here because the two parts can never overlap.

### Solution 2: `FULL OUTER JOIN`

```sql
SELECT COALESCE(a.id, b.id) AS id
FROM table_a a
FULL OUTER JOIN table_b b ON a.id = b.id
WHERE a.id IS NULL
   OR b.id IS NULL;
```

**How it works:** If `a.id` is `NULL`, the row exists only in B. If `b.id` is `NULL`, the row exists only in A.

### Solution 3: `NOT EXISTS` (works in almost every database)

```sql
SELECT id FROM table_a a
WHERE NOT EXISTS (SELECT 1 FROM table_b b WHERE b.id = a.id)

UNION ALL

SELECT id FROM table_b b
WHERE NOT EXISTS (SELECT 1 FROM table_a a WHERE a.id = b.id);
```

> Avoid `NOT IN` when the subquery can return `NULL`. It can return **no rows** by mistake. `NOT EXISTS` is safer.

---

## 12. Query Optimization Techniques

**First rule:** Measure before you optimize. Use `EXPLAIN` (or `EXPLAIN ANALYZE`) to see the **execution plan**.

```sql
EXPLAIN ANALYZE
SELECT * FROM sales WHERE product_id = 1;
```

### Checklist

| # | Technique                           | Why / How                                                                 |
|--:|-------------------------------------|---------------------------------------------------------------------------|
| 1 | **Use indexes wisely**              | Index columns used in `WHERE`, `JOIN`, `ORDER BY`.                        |
| 2 | **Avoid `SELECT *`**                | Select only the columns you need. Less data to read and send.             |
| 3 | **Filter early**                    | Use `WHERE` to reduce rows before `JOIN` and `GROUP BY`.                  |
| 4 | **Do not use functions on indexed columns** | `WHERE YEAR(date) = 2026` blocks the index. Use `date >= '2026-01-01' AND date < '2027-01-01'`. |
| 5 | **Avoid leading wildcards**         | `LIKE '%abc'` cannot use a normal index. `LIKE 'abc%'` can.               |
| 6 | **Use `EXISTS` instead of `IN`** for big subqueries | `EXISTS` can stop at the first match.                       |
| 7 | **Use `UNION ALL` instead of `UNION`** | Skips the slow duplicate removal.                                      |
| 8 | **Use `LIMIT`**                     | Do not return more rows than you need.                                    |
| 9 | **Avoid `OR` on different columns** | Can block index use. Consider `UNION ALL` of two queries.                 |
| 10 | **Use proper data types**          | Compare `INT` with `INT`. Avoid implicit conversions.                     |
| 11 | **Avoid correlated subqueries**    | A subquery that runs once per row is slow. Use a `JOIN` or window function. |
| 12 | **Use CTEs for readability**       | Some databases materialize CTEs, others do not. Check your engine.        |
| 13 | **Keep statistics updated**        | Run `ANALYZE` (PostgreSQL) or `UPDATE STATISTICS` (SQL Server).           |
| 14 | **Partition big tables**           | Split by date or region. Queries read only the needed partitions.         |
| 15 | **Pagination with keyset**         | `WHERE id > last_id LIMIT 20` is faster than a big `OFFSET`.              |
| 16 | **Batch writes**                   | Insert many rows in one statement instead of many separate ones.          |
| 17 | **Use materialized views / caching** | For heavy reports that do not need real-time data.                      |

### Example: bad vs. good

```sql
-- Bad: function on column, SELECT *
SELECT * FROM sales
WHERE EXTRACT(YEAR FROM sale_date) = 2026;

-- Good: range condition, only needed columns
SELECT sale_id, product_id, quantity
FROM sales
WHERE sale_date >= '2026-01-01'
  AND sale_date <  '2027-01-01';
```

### What to look for in an execution plan

- **Seq Scan / Table Scan** on a big table → maybe you need an index.
- **Big difference** between estimated rows and real rows → old statistics.
- **Sort** or **Hash** steps that use a lot of memory → check your `ORDER BY` and `JOIN`.

---

## 13. Views and Materialized Views

### View

**Definition:** A **view** is a **saved query** with a name. It stores **no data**. Every time you query the view, the database runs the saved query again.

```sql
CREATE VIEW electronics_sales AS
SELECT p.name, s.quantity, s.sale_date
FROM products p
JOIN sales s ON s.product_id = p.product_id
WHERE p.category = 'Electronics';

SELECT * FROM electronics_sales;
```

**Uses:**

- Simplify complex queries.
- **Security:** show only some columns or rows to some users.
- Hide table structure changes.

### Materialized View

**Definition:** A **materialized view** is a saved query **plus its stored results** (like a snapshot). You read the stored data, so it is **fast**, but the data can be **old** until you refresh it.

```sql
CREATE MATERIALIZED VIEW sales_summary AS
SELECT product_id, SUM(quantity) AS total
FROM sales
GROUP BY product_id;

-- Update the stored data
REFRESH MATERIALIZED VIEW sales_summary;
```

### Comparison

| Feature             | View                     | Materialized View                     |
|---------------------|--------------------------|---------------------------------------|
| Stores data?        | No                       | **Yes**                               |
| Data freshness      | Always up to date        | Can be old (until refresh)            |
| Read speed          | Same as the query        | **Fast**                              |
| Uses disk space?    | No                       | Yes                                   |
| Can have indexes?   | No                       | **Yes** (in most databases)           |
| Best for            | Simplicity, security     | Heavy reports, dashboards             |

> Support for materialized views depends on the database. PostgreSQL and Oracle have them. SQL Server has *indexed views*. MySQL does not have them natively.

---

## 14. Concurrency

**Question:** What happens when two users try to change the same record at the same time?

### Short answer

The database uses **transactions**, **locks**, and **isolation levels** to keep data correct. Usually, one transaction **waits** for the other, or the database uses **MVCC** to avoid blocking.

### Key concepts

**Transaction:** A group of operations that run as one unit: all succeed or all fail. It follows **ACID**:

| Letter | Meaning         | Simple idea                              |
|--------|-----------------|------------------------------------------|
| **A**  | Atomicity       | All or nothing                           |
| **C**  | Consistency     | Data follows the rules                   |
| **I**  | Isolation       | Transactions do not disturb each other   |
| **D**  | Durability      | Saved data is not lost                   |

**Lock:** A "reserved" sign on data.

- **Shared lock (read):** Many readers allowed at the same time.
- **Exclusive lock (write):** Only one writer. Others must wait.

### Example: two updates at the same time

```
Time   Transaction A                    Transaction B
 1     BEGIN;                           BEGIN;
 2     UPDATE accounts                  
       SET balance = balance - 100
       WHERE id = 1;     -- gets lock
 3                                      UPDATE accounts
                                        SET balance = balance - 50
                                        WHERE id = 1;  -- WAITS
 4     COMMIT;           -- releases lock
 5                                      -- now it runs (balance - 50)
 6                                      COMMIT;
```

Result: both updates are applied correctly, one after the other. No update is lost.

### MVCC (Multi-Version Concurrency Control)

Used by PostgreSQL, Oracle, MySQL InnoDB. The database keeps **several versions** of a row.

- **Readers do not block writers**, and **writers do not block readers**.
- Each transaction sees a consistent **snapshot** of the data.
- Two **writers** on the same row still must wait for each other.

### Isolation levels

They control what a transaction can see from other transactions.

| Level                | Dirty read | Non-repeatable read | Phantom read |
|----------------------|:----------:|:-------------------:|:------------:|
| `READ UNCOMMITTED`   | Possible   | Possible            | Possible     |
| `READ COMMITTED`     | No         | Possible            | Possible     |
| `REPEATABLE READ`    | No         | No                  | Possible*    |
| `SERIALIZABLE`       | No         | No                  | No           |

\* Depends on the database. PostgreSQL's `REPEATABLE READ` also prevents phantoms.

- **Dirty read:** Reading data that another transaction has not committed yet.
- **Non-repeatable read:** Reading the same row twice and getting different values.
- **Phantom read:** Running the same query twice and getting different **rows**.

Higher isolation = safer, but slower and more conflicts.

### Common problems and solutions

| Problem                | Description                                         | Solution                                           |
|------------------------|-----------------------------------------------------|----------------------------------------------------|
| **Lost update**        | Two transactions read the same value and both write | Use locks, atomic updates, or versioning           |
| **Deadlock**           | A waits for B, and B waits for A                    | DB detects it and **cancels one** transaction; retry |
| **Long waits**         | A transaction holds locks for too long              | Keep transactions **short**; set lock timeouts     |

### Pessimistic locking

Lock the row **before** changing it.

```sql
BEGIN;
SELECT * FROM accounts WHERE id = 1 FOR UPDATE;  -- locks the row
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
COMMIT;
```

### Optimistic locking

Do not lock. Check **at update time** that nobody changed the row, using a `version` column.

```sql
UPDATE accounts
SET balance = 900,
    version = version + 1
WHERE id = 1
  AND version = 5;      -- the version I read earlier

-- If 0 rows were updated, someone else changed it. Reload and retry.
```

### Best practices

1. Keep transactions **short**.
2. Update rows in the **same order** in all code (helps avoid deadlocks).
3. Prefer **atomic updates**: `SET balance = balance - 100` instead of reading and writing in two steps.
4. Be ready to **retry** after a deadlock or serialization error.

---

## 15. CASE Statement

**Definition:** `CASE` is the SQL version of **if / else**. It checks conditions in order and returns a value for the first condition that is true.

It is an **expression**, so it returns a value. You can use it in `SELECT`, `WHERE`, `ORDER BY`, `GROUP BY`, and inside aggregate functions.

### Searched CASE (most common)

Each `WHEN` has its own condition.

```sql
CASE
    WHEN condition1 THEN result1
    WHEN condition2 THEN result2
    ELSE default_result
END
```

```sql
SELECT sale_id,
       quantity,
       CASE
           WHEN quantity >= 20 THEN 'High'
           WHEN quantity >= 10 THEN 'Medium'
           ELSE 'Low'
       END AS sales_level
FROM sales;
```

**Result with our sample data:**

| sale_id | quantity | sales_level |
|--------:|---------:|-------------|
| 1       | 10       | Medium      |
| 2       | 25       | High        |
| 3       | 5        | Low         |
| 4       | 8        | Low         |
| 5       | 12       | Medium      |

### Simple CASE

Compares **one column** against several values (equality only).

```sql
SELECT name,
       CASE category
           WHEN 'Electronics' THEN 'Tech'
           WHEN 'Furniture'   THEN 'Home'
           ELSE 'Other'
       END AS group_name
FROM products;
```

### Important rules

1. SQL checks the `WHEN` conditions **from top to bottom** and stops at the **first** true one. Order matters.
2. If no condition is true and there is **no `ELSE`**, the result is `NULL`.
3. All `THEN` / `ELSE` results must have **compatible data types** (do not mix numbers and text).
4. Always finish with `END`. Use an alias (`AS ...`) to name the new column.
5. In simple `CASE`, you cannot check `NULL` with `WHEN NULL`. Use searched `CASE` with `IS NULL`.

```sql
-- Correct way to check NULL
CASE
    WHEN phone IS NULL THEN 'No phone'
    ELSE phone
END
```

### Common uses

**1. Conditional aggregation (pivot-style report)**

Count or sum only some rows, in one query:

```sql
SELECT
    SUM(CASE WHEN quantity >= 10 THEN 1 ELSE 0 END) AS big_sales,
    SUM(CASE WHEN quantity <  10 THEN 1 ELSE 0 END) AS small_sales
FROM sales;
```

**2. Custom sorting**

```sql
SELECT name, category
FROM products
ORDER BY CASE category
             WHEN 'Furniture'   THEN 1
             WHEN 'Electronics' THEN 2
             ELSE 3
         END;
```

**3. Conditional update**

```sql
UPDATE sales
SET quantity = CASE
                   WHEN quantity < 5 THEN 5
                   ELSE quantity
               END;
```

**4. Avoid division by zero**

```sql
SELECT CASE
           WHEN total_orders = 0 THEN 0
           ELSE total_revenue / total_orders
       END AS average_order
FROM report;
```

### CASE vs. COALESCE

| Feature    | `COALESCE`                          | `CASE`                                |
|------------|-------------------------------------|---------------------------------------|
| Purpose    | Replace `NULL` with the first non-`NULL` value | Any condition logic        |
| Flexibility| Low (only checks `NULL`)            | High (any condition)                  |
| Example    | `COALESCE(phone, 'N/A')`            | `CASE WHEN phone IS NULL THEN 'N/A' ELSE phone END` |

> `COALESCE(a, b)` is a shorter way to write a `CASE` that checks `NULL`.

---

## 16. OVER Clause

**Definition:** `OVER` turns a function into a **window function**. It tells SQL: "do this calculation over a group of rows, but **keep every row** in the result."

```sql
function(...) OVER (
    PARTITION BY column   -- optional: split rows into groups
    ORDER BY column       -- optional: order rows inside each group
)
```

| Part              | Meaning                                              |
|-------------------|------------------------------------------------------|
| `OVER ()`         | The window is **all rows** of the result             |
| `PARTITION BY`    | Makes a separate window for each group               |
| `ORDER BY`        | Sets the row order inside the window                 |

**Short example:** show each sale next to the total of all sales.

```sql
SELECT sale_id,
       quantity,
       SUM(quantity) OVER () AS total_all
FROM sales;
```

**Returns:**

| sale_id | quantity | total_all |
|--------:|---------:|----------:|
| 1       | 10       | 60        |
| 2       | 25       | 60        |
| 3       | 5        | 60        |
| 4       | 8        | 60        |
| 5       | 12       | 60        |

Every row is kept, and each one gets the same total (60). With `GROUP BY`, you would get only **one** row.

> See [Window Functions](#10-window-functions) for more functions like `ROW_NUMBER`, `RANK`, and `LAG`.

---

## 17. Quick Vocabulary

| Word            | Simple meaning                                      |
|-----------------|-----------------------------------------------------|
| Row / Record    | One line of data in a table                         |
| Column / Field  | One attribute of the data (e.g., `name`)            |
| Primary key     | Unique ID of each row                               |
| Foreign key     | Column that points to a primary key in another table|
| Alias           | A temporary name (`AS total`)                       |
| Aggregate       | Function that summarizes rows (`SUM`, `COUNT`, `AVG`) |
| Subquery        | A query inside another query                        |
| Execution plan  | Steps the database uses to run your query           |
| Full table scan | Reading every row of a table                        |
| Selectivity     | How unique the values in a column are               |
| Snapshot        | A frozen view of the data at one moment             |
| Deadlock        | Two transactions waiting for each other forever     |
| Rollback        | Cancel a transaction and undo its changes           |
| Commit          | Save a transaction permanently                      |

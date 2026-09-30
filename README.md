# 04 · SQL E-commerce Report (SQL — Week 4)

38 queries over a 6-table e-commerce schema: top products, customer spend, NULL handling, JOINs, and DDL constraints.

## Files
| File | What it does |
|---|---|
| `01_schema.sql` | DDL: PK, FK, UNIQUE, NOT NULL, CHECK, DEFAULT, ON DELETE CASCADE, indexes |
| `02_seed.sql` | 24 products, 20 customers, 60 orders, items and payments (deterministic) |
| `03_queries.sql` | 38 queries, grouped into 5 sections |
| `04_constraint_tests.sql` | 8 statements that must be rejected, proving the constraints work |
| `run_report.py` | Builds `ecommerce.db`, runs everything, writes `report.md` |
| `report.md` | Generated output: every query, its result, and constraint test results |

## Run
```bash
python3 run_report.py            # builds DB + report.md
sqlite3 ecommerce.db < 03_queries.sql   # or run queries directly
```

## Query coverage
- **A. Basics (Q1–7):** WHERE, BETWEEN, ORDER BY, aggregates, GROUP BY, date bucketing
- **B. Top products (Q8–15):** top-N by units and revenue, revenue by category, best per category (RANK), never-ordered products, HAVING, CASE bands
- **C. Customer spend (Q16–24):** lifetime spend, AOV, anti-joins (LEFT JOIN vs NOT EXISTS), repeat buyers, tiers, running total, above-average subquery
- **D. NULL handling (Q25–32):** IS NULL, COALESCE, COUNT(*) vs COUNT(col), NULLIF, LEFT JOIN + NULL
- **E. Joins (Q33–38):** 5-table join, self joins (product pairs, same-city), CTE + LAG for MoM growth

## Portability
Written for SQLite. For MySQL/Postgres: replace `STRFTIME('%Y-%m', d)` with `DATE_FORMAT(d,'%Y-%m')` / `TO_CHAR(d,'YYYY-MM')`, `INTEGER PRIMARY KEY` with `SERIAL`/`AUTO_INCREMENT`, and `DATE('now')` with `CURRENT_DATE`. Window functions need MySQL 8+.

"""Builds ecommerce.db, runs all queries, writes report.md, and verifies constraints."""
import re, sqlite3, os
here = os.path.dirname(os.path.abspath(__file__))
db_path = os.path.join(here, "ecommerce.db")
if os.path.exists(db_path): os.remove(db_path)
con = sqlite3.connect(db_path)
for f in ("01_schema.sql", "02_seed.sql"):
    con.executescript(open(os.path.join(here, f)).read())
con.execute("PRAGMA foreign_keys = ON")

def blocks(path):
    txt = open(os.path.join(here, path)).read()
    parts = re.split(r"(?m)^-- (Q\d+|T\d+): ", txt)[1:]
    for i in range(0, len(parts), 2):
        label, body = parts[i], parts[i+1]
        title, _, sql = body.partition("\n")
        yield label, title.strip(), sql.split("\n-- =====")[0].strip()

def table(cur):
    cols = [d[0] for d in cur.description]; rows = cur.fetchall()
    out = ["| " + " | ".join(cols) + " |", "|" + "---|"*len(cols)]
    out += ["| " + " | ".join("NULL" if v is None else str(v) for v in r) + " |" for r in rows]
    return "\n".join(out), len(rows)

md = ["# SQL E-commerce Report\n"]
n = 0
for label, title, sql in blocks("03_queries.sql"):
    cur = con.execute(sql); t, cnt = table(cur); n += 1
    md.append(f"## {label}. {title}\n```sql\n{sql}\n```\n{t}\n")
md.insert(1, f"_{n} queries executed successfully._\n")

md.append("## Constraint tests (all must be rejected)\n")
ok = 0; total = 0
for label, title, sql in blocks("04_constraint_tests.sql"):
    total += 1
    try:
        con.execute(sql); res = "❌ NOT rejected"
    except sqlite3.Error as e:
        ok += 1; res = f"✅ rejected — {e}"
    con.rollback()
    md.append(f"- **{label}** {title}: {res}")
md.append(f"\n{ok}/{total} constraints enforced.")
open(os.path.join(here, "report.md"), "w").write("\n".join(md) + "\n")
print(f"{n} queries OK, {ok}/{total} constraint tests rejected")

---
source_url: https://www2.iuj.ac.jp/directory/student_search.cfm
namespace: Administration
category: student-services
last_crawled: 2026-05-18
language: en
# ── Permissions (RBAC) ─────────────────────────────────────────────────────
article_id: 04-Administration/student-services/campus-directory
owner_role: admin
edit_roles:
  - admin
suggest_roles:
  - student
  - faculty
status: published
version: 1
---

# Campus Directory (People Search)

## Overview

The **Campus Directory** lets you search for students, faculty, and staff at IUJ by name. It is accessible from within the MyIUJ! portal and returns each person's Student ID, school affiliation, full name, and IUJ email address.

---

## How to Search

### From MyIUJ! Portal
1. Log in to [https://www2.iuj.ac.jp/myiuj/login/](https://www2.iuj.ac.jp/myiuj/login/) and click **"Enter MyIUJ!"**
2. At the top of any MyIUJ! page, find the **People Search** bar
3. Type a name (partial names work), select **Student**, **Faculty**, or **Staff** from the dropdown, then click **Go**
4. Results open in a new tab showing: Student ID, School (IR/IM), Full Name, Email

### Direct URL
```
https://www2.iuj.ac.jp/directory/student_search.cfm?SearchType=Student&Name=QUERY&Format=Email&Criteria=FullNameE&Sort=FullNameE
```
Replace `QUERY` with any name fragment and `SearchType` with `Student`, `Faculty`, or `Staff`.

---

## Directory Information Shown

| Field | Description |
|---|---|
| Student ID | e.g. `2C5059` — first digit is cohort year, C = current, IM/IR code |
| School | `IR` = Graduate School of International Relations, `IM` = Graduate School of International Management |
| Full Name | English full name (Last, First format) |
| Email | IUJ email address (format: `username@iuj.ac.jp`) |

---

## Student ID Format

IUJ student IDs follow this pattern: `[cohort][C or D][4-digit number]`

- First character: cohort year (e.g. `2` = second year, `1` = first year)
- `C` = current student, `D` = doctoral or special student
- School prefix embedded in the range: GSIM IDs run from `2C5001` upward; GSIR from `1C4001` upward

---

## Notes

- The directory is login-gated — you must be authenticated via MyIUJ! to access it
- Results are sorted alphabetically by full name by default
- Searching "a" returns the full directory (~395 students as of May 2026)
- Email addresses follow the pattern `[username]@iuj.ac.jp`; usernames are assigned at enrollment

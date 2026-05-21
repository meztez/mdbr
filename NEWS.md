# mdbr 0.3.0

* **Bundled mdbtools**: The mdbtools C library is now compiled and shipped with
  the package (`src/mdbtools/`). No external `mdbtools` installation is required.
* **DBI interface**: A full read-only DBI backend is now available. Use
  `DBI::dbConnect(mdb(), dbname = "path/to/file.mdb")` to open connections and
  standard DBI verbs (`dbReadTable()`, `dbGetQuery()`, `dbListTables()`, etc.).
* **New helper functions** from the bundled library:
  - `mdb_sql()` — run SQL queries directly against an MDB/ACCDB file.
  - `mdb_queries()` — list saved Access queries and retrieve their SQL.
  - `mdb_count()` — count rows in a table, optionally with a `WHERE` clause.
  - `mdb_ddl()` — generate DDL (CREATE TABLE) schema in various SQL dialects.
  - `mdb_ver()` — return the file format or the mdbtools library version.
  - `mdb_array()` — export a table as a named list of column vectors.
  - `mdb_export()` — export a table to CSV or SQL INSERT statements.
  - `mdb_json()` — export a table to JSON.
  - `mdb_header()` — return a structural summary (version, tables, queries).
  - `mdb_hexdump()` — hexadecimal dump of MDB file bytes.
  - `mdb_import()` — stub (read-only; always errors with a clear message).
  - `mdb_parsecsv()` — convert CSV to a C array source string.
  - `mdb_prop()` — retrieve MDB object properties.
  - `print.mdblist` — pretty-printer for `mdblist` objects.
* **Backward-compatible**: `read_mdb()`, `export_mdb()`, `mdb_tables()`,
  `mdb_schema()`, and `mdb_example()` signatures are unchanged. Internally they
  now use the bundled library instead of system `mdb-*` binaries.
* `mdb_tables()` gains additional optional arguments (`system`, `type`,
  `show_type`, `as_text`, `single_column`, `delimiter`) matching the `mdb-tables`
  CLI surface.
* Bruno Tremblay (Boostao) added as co-author for the DBI interface and
  bundled mdbtools integration (originally developed in the `mdbtoolr` package).

# mdbr 0.2.1

* Update maintainer email, website URL, and GitHub URL.

# mdbr 0.2.0

* Functions now quote their input files with `shQuote()`. (#7)
* `export_mdb()` now mirrors `readr::format_csv()` with arguments, etc.
* Remove all formatting arguments for `read_mdb()` (with smart hidden defaults).
* Add more schema types with readr equivalents. 
* Write schema to a matrix in-memory rather than a temporary file.
* Always read data from a temporary file instead of `stdout` option.
* Add better checking if mdbtools is installed.

# mdbr 0.1.1

* `read_mdb()` now has `stdout()` which can take `TRUE` or a file path.
* Examples and tests don't run on CRAN.

# mdbr 0.1.0

* Added a `NEWS.md` file to track changes to the package.
* Cover the most basic functions from mdbtools:
    * List tables in database
    * Export table as delimited file
    * Read delimited file as dataframe
    * Convert simple schema to readr spec

#' List tables in a Microsoft Access database
#'
#' @param file Path to the Microsoft Access file.
#' @param system Logical; include system (`MSys*`) tables. Equivalent to `-S`.
#' @param type Object type to list: `"table"` (default), `"query"`,
#'   `"systable"`, `"any"`, or `"all"`. Equivalent to `-t`.
#' @param show_type Logical; prefix each entry with its type. Equivalent to `-T`.
#' @return A character vector of table names.
#' @export
mdb_tables <- function(
  file,
  system = FALSE,
  type = c(
    "table",
    "query",
    "systable",
    "any",
    "all",
    "form",
    "macro",
    "report",
    "linkedtable",
    "module",
    "relationship",
    "dbprop"
  ),
  show_type = FALSE
) {
  type <- match.arg(type)
  path <- .mdb_normalize_path(file)
  need_sys <- isTRUE(system) || type %in% c("systable", "all", "any")
  user_tables <- .native_list_tables(path, system = FALSE)
  sys_tables  <- if (need_sys) .native_list_tables(path, system = TRUE) else character(0)
  queries     <- .native_list_queries(path)

  out <- switch(
    type,
    table    = c(user_tables, sys_tables),
    query    = queries,
    systable = sys_tables,
    any      = c(user_tables, queries),
    all      = c(user_tables, sys_tables, queries),
    {
      warning(
        sprintf(
          "Type '%s' is not available in library-only mode; returning empty result.",
          type
        ),
        call. = FALSE
      )
      character(0)
    }
  )

  if (isTRUE(show_type)) {
    out <- ifelse(
      out %in% queries,
      paste("query", out),
      ifelse(
        out %in% sys_tables,
        paste("systable", out),
        paste("table", out)
      )
    )
  }


  out
}

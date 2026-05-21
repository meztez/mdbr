#' List tables in a Microsoft Access database
#'
#' @param file Path to the Microsoft Access file.
#' @param system Logical; include system (`MSys*`) tables.
#' @param single_column Logical; use newline delimiter (equivalent to `-1`).
#' @param delimiter Delimiter for `as_text` mode.
#' @param type Object type to list: `"table"` (default), `"query"`,
#'   `"systable"`, `"any"`, or `"all"`.
#' @param show_type Logical; prefix each entry with its type.
#' @param as_text Logical; return a single delimited string instead of a vector.
#' @return A character vector of table names, or a scalar string when
#'   `as_text = TRUE`.
#' @export
mdb_tables <- function(
  file,
  system = FALSE,
  single_column = FALSE,
  delimiter = NULL,
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
  show_type = FALSE,
  as_text = FALSE
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

  delim <- if (!is.null(delimiter)) {
    delimiter
  } else if (isTRUE(single_column)) {
    "\n"
  } else {
    "\t"
  }

  if (isTRUE(as_text)) {
    return(paste(out, collapse = delim))
  }
  out
}

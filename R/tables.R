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
  type = c("table", "query", "systable", "any", "all",
           "form", "macro", "report", "linkedtable",
           "module", "relationship", "dbprop"),
  show_type = FALSE,
  as_text = FALSE
) {
  type <- match.arg(type)
  con <- .mdb_connect(file)
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  tables     <- DBI::dbListTables(con)
  user_tables <- tables[!grepl("^MSys", tables)]
  sys_tables  <- tables[grepl("^MSys", tables)]
  queries     <- .native_list_queries(.mdb_normalize_path(file))

  out <- switch(
    type,
    table   = user_tables,
    query   = queries,
    systable = sys_tables,
    any     = c(user_tables, if (isTRUE(system)) sys_tables, queries),
    all     = c(user_tables, if (isTRUE(system)) sys_tables, queries),
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

  if (type %in% c("table", "any", "all") && isFALSE(system)) {
    out <- out[!grepl("^MSys", out)]
  }

  if (isTRUE(show_type)) {
    out <- ifelse(
      out %in% queries,
      paste("query", out),
      paste("table", out)
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

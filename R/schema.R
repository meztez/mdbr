#' Column type codes for a table
#'
#' Returns a named character vector mapping column names to type codes:
#' `"c"` = character, `"i"` = integer, `"d"` = double,
#' `"l"` = logical, `"T"` = datetime (POSIXct).
#'
#' @param file Path to the Microsoft Access file.
#' @param table Name of the table, list with [mdb_tables()].
#' @param condense When `TRUE`, return only the unique type codes present
#'   in the table rather than one entry per column.
#' @return A named character vector of type codes.
#' @examples
#' \dontrun{
#' mdb_schema(mdb_example(), "Flights")
#' }
#' @export
mdb_schema <- function(file, table, condense = FALSE) {
  if (missing(table)) {
    stop("Must define a table name, list with mdb_tables()", call. = FALSE)
  }
  x <- .native_print_schema(
    path = .mdb_normalize_path(file),
    table = as.character(table),
    backend = "access",
    namespace = NULL,
    export_options = .mdb_schema_options()
  )
  x <- strsplit(x[[1]], "\n")[[1]]
  x <- grep("^\t", x, value = TRUE)
  x <- gsub("\t{3}", "|", x)
  x <- gsub("^\t", "", x)
  x <- gsub(",\\s*$", "", x)
  x <- gsub("\\[|\\]", "", x)
  x <- gsub("\\s\\(\\d+\\).*", "", x)
  x <- gsub("\\sNOT NULL", "", x)
  y <- matrix(
    data = unlist(strsplit(x, "\\|")),
    ncol = 2,
    byrow = TRUE
  )
  z <- vapply(y[, 2], list_switch, character(1), mdb_col_types)
  names(z) <- y[, 1]
  if (isTRUE(condense)) unique(z) else z
}

# types from mdbtools/src/libmdb/backend.c
#   MDB Tools - A library for reading MS Access database files
#   Copyright (C) 2000-2011 Brian Bruns and others
mdb_col_types <- list(
  "Unknown 0x00" = "c",
  "Boolean" = "l",
  "Byte" = "i",
  "Integer" = "i",
  "Long Integer" = "i",
  "Currency" = "d",
  "Single" = "d",
  "Double" = "d",
  "DateTime" = "T",
  "Binary" = "c",
  "Text" = "c",
  "OLE" = "c",
  "Memo/Hyperlink" = "c",
  "Unknown 0x0d" = "c",
  "Unknown 0x0e" = "c",
  "Replication ID" = "c",
  "Numeric" = "d"
)

list_switch <- function(val, list) {
  do.call("switch", c(val, as.list(list)))
}

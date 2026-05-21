#' Read a table as data frame
#'
#' Reads a table directly from a Microsoft Access database using the bundled
#' mdbtools C library. Column types are inferred from the MDB schema:
#' integer, double, logical, [POSIXct][base::DateTimeClasses] for DateTime
#' columns, and character otherwise.
#'
#' @param file Path to the Microsoft Access file.
#' @param table Name of the table, list with [mdb_tables()].
#' @param col_names Logical; when `FALSE` columns are named `V1`, `V2`, etc.
#' @param col_types Ignored. Retained for backward compatibility; type coercion
#'   is handled automatically by the native reader.
#' @param ... Ignored. Retained for backward compatibility.
#' @return A `data.frame`.
#' @examples
#' \dontrun{
#' read_mdb(mdb_example(), "Airlines")
#' }
#' @export
read_mdb <- function(file, table, col_names = TRUE, col_types = NULL, ...) {
  if (missing(table)) {
    stop("Must define a table name, list with mdb_tables()", call. = FALSE)
  }
  path <- .mdb_normalize_path(file)
  raw  <- .native_read_table(path, as.character(table))
  df   <- .as_data_frame(raw)
  df   <- .coerce_mdb_data_frame(df, raw)
  if (!isTRUE(col_names)) {
    names(df) <- paste0("V", seq_along(df))
  }
  df
}

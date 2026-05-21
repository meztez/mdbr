# has_mdb_tools() checks for the bundled native library (always TRUE when the
# package is installed), with a fallback to the system mdbtools binary for
# users who have not yet upgraded to the compiled version.
has_mdb_tools <- function() {
  if (is.loaded("mdbr_version")) {
    ver <- tryCatch(.native_mdbtools_version(), error = function(e) NULL)
    if (!is.null(ver) && nzchar(ver)) {
      return(stats::setNames(TRUE, ver))
    }
  }
  # Fallback: try system binary (preserved for source-only installs)
  try <- suppressWarnings(tryCatch(
    expr = system2(
      command = Sys.which("mdb-ver"),
      args = "-M",
      stderr = TRUE,
      stdout = TRUE
    ),
    error = function(e) return(NULL)
  ))
  if (is.null(try) || !nzchar(try[1])) {
    return(FALSE)
  }
  stats::setNames(TRUE, try)
}

check_mdb_tools <- function() {
  if (isFALSE(has_mdb_tools())) {
    msg <- c(
      "MDB Tools are not installed",
      "See: https://github.com/mdbtools/mdbtools",
      "* Debian: apt install mdbtools",
      "* Homebrew: brew install mdbtools"
    )
    stop(paste(msg, collapse = "\n"), call. = FALSE)
  }
}

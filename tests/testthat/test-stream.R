library(mdbr)

stream_fixture <- function(path, table) {
  con <- DBI::dbConnect(mdb(), dbname = path)
  on.exit(DBI::dbDisconnect(con))
  expected <- DBI::dbReadTable(con, table)
  res <- mdb_stream_table(con, table)
  on.exit(DBI::dbClearResult(res), add = TRUE)
  expect_identical(DBI::dbIsValid(res), TRUE)
  expect_identical(nrow(res@data), 0L)
  expect_identical(DBI::dbFetch(res, 0L), expected[0, , drop = FALSE])
  expect_identical(res@state$position, 0L)
  parts <- list()
  repeat {
    part <- DBI::dbFetch(res, n = 7L)
    if (!nrow(part)) {
      break
    }
    parts[[length(parts) + 1L]] <- part
    expect_lte(nrow(part), 7L)
    expect_identical(names(part), names(expected))
    expect_identical(lapply(part, class), lapply(expected, class))
  }
  combined <- if (length(parts)) {
    do.call(rbind, parts)
  } else {
    expected[0, , drop = FALSE]
  }
  rownames(combined) <- NULL
  expect_identical(combined, expected)
  expect_identical(DBI::dbHasCompleted(res), TRUE)
  expect_identical(DBI::dbFetch(res, 2L), expected[0, , drop = FALSE])
  expect_identical(DBI::dbIsValid(res), TRUE)
  expect_identical(DBI::dbClearResult(res), TRUE)
  expect_identical(DBI::dbClearResult(res), TRUE)
  expect_identical(DBI::dbIsValid(res), FALSE)
}

test_that("MDB table cursor advances without materializing on open", {
  path <- testthat::test_path("mdbtestdata", "data", "nwind.mdb")
  skip_if_not(file.exists(path))
  stream_fixture(path, "Umsätze")
  con <- DBI::dbConnect(mdb(), dbname = path)
  on.exit(DBI::dbDisconnect(con))
  res <- mdb_stream_table(con, "Umsätze")
  expect_identical(res@state$position, 0L)
  expect_identical(nrow(res@data), 0L)
  expect_identical(nrow(DBI::dbFetch(res, 1L)), 1L)
  expect_identical(res@state$position, 1L)
  DBI::dbClearResult(res)
  expect_snapshot(error = TRUE, DBI::dbFetch(res, 1L))
  expect_identical(DBI::dbClearResult(res), TRUE)
})

test_that("MDB OLE fields retain populated raw bytes", {
  path <- testthat::test_path("mdbtestdata", "data", "nwind.mdb")
  skip_if_not(file.exists(path))
  stream_fixture(path, "Categories")
  con <- DBI::dbConnect(mdb(), dbname = path)
  on.exit(DBI::dbDisconnect(con))
  res <- mdb_stream_table(con, "Categories")
  on.exit(DBI::dbClearResult(res), add = TRUE)
  picture <- DBI::dbFetch(res, 1L)$Picture[[1L]]
  expect_type(picture, "raw")
  expect_gt(length(picture), 0L)
  expect_identical(picture[[4L]], as.raw(0))
})

test_that("native cursor distinguishes null and empty values", {
  path <- testthat::test_path("mdbtestdata", "data", "nwind.mdb")
  skip_if_not(file.exists(path))
  con <- DBI::dbConnect(mdb(), dbname = path)
  on.exit(DBI::dbDisconnect(con))
  res <- mdb_stream_table(con, "Umsätze")
  on.exit(DBI::dbClearResult(res), add = TRUE)
  first <- DBI::dbFetch(res, 2L)
  expect_identical(is.na(first$ShipRegion), c(FALSE, TRUE))
  expect_identical(first$ShipRegion[[1L]], "Lara")
})

test_that("ACCDB table cursor matches eager read", {
  path <- testthat::test_path("mdbtestdata", "data", "ASampleDatabase.accdb")
  skip_if_not(file.exists(path))
  stream_fixture(path, "Asset Items")
  con <- DBI::dbConnect(mdb(), dbname = path)
  on.exit(DBI::dbDisconnect(con))
  res <- mdb_stream_table(con, "Asset Items")
  on.exit(DBI::dbClearResult(res), add = TRUE)
  expect_identical(nrow(DBI::dbFetch(res, 1L)), 1L)
  expect_identical(DBI::dbClearResult(res), TRUE)
  expect_identical(DBI::dbIsValid(res), FALSE)
})

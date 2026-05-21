library(testthat)
library(mdbr)

test_that("schema returns a tibble with expected columns", {
  skip_on_cran()
  skip_if_not(is.loaded("mdbr_version"))
  dat <- mdb_schema(mdb_example(), "Flights")
  expect_s3_class(dat, "tbl_df")
  expect_named(dat, c("col_name", "access_type", "r_type"))
  expect_equal(nrow(dat), 19L)
  expect_type(dat$col_name, "character")
  expect_type(dat$access_type, "character")
  expect_type(dat$r_type, "character")
})

test_that("schema errors without table", {
  skip_on_cran()
  skip_if_not(is.loaded("mdbr_version"))
  expect_error(mdb_schema(mdb_example()))
})

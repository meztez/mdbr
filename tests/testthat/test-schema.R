library(testthat)
library(mdbr)

test_that("schema returns named character vector of type codes", {
  skip_on_cran()
  skip_if_not(is.loaded("mdbr_version"))
  dat <- mdb_schema(mdb_example(), "Flights")
  expect_type(dat, "character")
  expect_named(dat)
  expect_length(dat, 19L)
})

test_that("schema condense returns unique type codes", {
  skip_on_cran()
  skip_if_not(is.loaded("mdbr_version"))
  a <- mdb_schema(mdb_example(), "Flights")
  b <- mdb_schema(mdb_example(), "Flights", condense = TRUE)
  expect_gt(length(a), length(b))
})

test_that("schema errors without table", {
  skip_on_cran()
  skip_if_not(is.loaded("mdbr_version"))
  expect_error(mdb_schema(mdb_example()))
})

test_that("frozen compiled kernel is available", {
  expect_identical(
    landisR:::bs52_growth_kernel_version_cpp(),
    "v3.11-ward-interior-fastpath"
  )

  expect_true(
    isTRUE(
      landisR:::bs52_large_init_bulk52()
    )
  )
})

context("Test mask - main function")
testthat::skip_on_cran() # because using runtime GDAL
testthat::skip_on_travis() # because required SAFE do not exists

safe_dir <- file.path(dirname(attr(load_binpaths(), "path")), "safe")
dir.create(safe_dir, showWarnings = FALSE)

testthat::test_that(
  "Tests on base mask on BOA", {
    
    outdir_5 <- tempfile(pattern = "out_test5_")
    dir.create(dirname(outdir_5), showWarnings = FALSE)
    exp_outpath_5 <- file.path(outdir_5, "BOA", "S2A2A_20190723_022_Scalve_BOA_10.dat")
    unlink(exp_outpath_5)
    unlink(gsub("dat$", "hdr", exp_outpath_5))
    sen2r(
      gui = FALSE,
      online = TRUE,
      step_atmcorr = "l2a", # to avoid checks on Sen2Cor
      extent = system.file("extdata/vector/scalve.kml", package = "sen2r"),
      extent_name = "Scalve",
      extent_as_mask = TRUE,
      timewindow = as.Date("2019-07-23"),
      list_prods = c("BOA", "TOA"),
      mask_type = "cloud_high_proba",
      outformat = "ENVI",
      path_l1c = safe_dir,
      path_l2a = safe_dir,
      path_out = outdir_5,
      thumbnails = FALSE
    )
    expect_true(file.exists(exp_outpath_5))
    
    # test on raster metadata
    exp_meta_r <- raster_metadata(exp_outpath_5, format = "list")[[1]]
    testthat::expect_equal(exp_meta_r$size, c("x"=1911, "y"=1479))
    testthat::expect_equal(exp_meta_r$res, c("x"=10, "y"=10))
    testthat::expect_equal(exp_meta_r$nbands, 11)
    testthat::expect_equal(
      as.numeric(exp_meta_r$bbox), 
      c(578590, 5086740, 597700, 5101530)
    )
    expect_equal_crs(st_crs2(exp_meta_r$proj), 32632)
    testthat::expect_equal(exp_meta_r$type, "UInt16")
    testthat::expect_equal(exp_meta_r$outformat, "ENVI")
    
    # test on raster values
    exp_stars <- stars::read_stars(exp_outpath_5)
    testthat::expect_true(round(mean(exp_stars[[1]][,,1], na.rm=TRUE)) %in% c(939, 994))
    testthat::expect_equal(sum(is.na(exp_stars[[1]][,,1])), 1816353)
    rm(exp_stars)
    
  }
)


context("Test mask - s2_mask()")
testthat::skip_on_cran() # because using runtime GDAL
# testthat::skip_on_travis()
ref_dir <- system.file("extdata/out", package = "sen2r")

testthat::test_that(
  "Tests on custom mask on TOA with smoothing and buffering, with save binary mask", {
    
    outdir_6 <- tempfile(pattern = "out_test6_")
    dir.create(dirname(outdir_6), showWarnings = FALSE)
    exp_outpath_6 <- file.path(outdir_6, "TOA", "S2A1C_20190723_022_Barbellino_TOA_10.tif")
    exp_outpath_msk <- file.path(outdir_6, "MSK", "S2A1C_20190723_022_Barbellino_MSK_10.tif")
    unlink(exp_outpath_6)
    unlink(exp_outpath_msk)
    s2_mask(
      infiles = file.path(ref_dir, "S2A1C_20190723_022_Barbellino_TOA_10.tif"),
      maskfiles = file.path(ref_dir, "S2A2A_20190723_022_Barbellino_SCL_10.tif"),
      mask_type = "clear_sky",
      outdir = outdir_6,
      subdirs = TRUE, 
      smooth = 10,
      buffer = 10,
      save_binary_mask = TRUE
    )
    expect_true(file.exists(exp_outpath_6))
    expect_true(file.exists(exp_outpath_msk))
    
    # test on raster metadata
    exp_meta_r <- raster_metadata(exp_outpath_6, format = "list")[[1]]
    testthat::expect_equal(exp_meta_r$size, c("x"=24, "y"=42))
    testthat::expect_equal(exp_meta_r$res, c("x"=10, "y"=10))
    testthat::expect_equal(exp_meta_r$nbands, 12)
    testthat::expect_equal(
      as.numeric(exp_meta_r$bbox), 
      c(580560, 5101700, 580800, 5102120)
    )
    expect_equal_crs(st_crs2(exp_meta_r$proj), 32632)
    testthat::expect_equal(exp_meta_r$type, "UInt16")
    testthat::expect_equal(exp_meta_r$outformat, "GTiff")
    
    # test on raster values
    exp_stars <- stars::read_stars(exp_outpath_6)
    testthat::expect_true(round(mean(exp_stars[[1]][,,1], na.rm=TRUE)) %in% c(1398, 1400))
    testthat::expect_true(sum(is.na(exp_stars[[1]][,,1])) %in% c(126, 69))
    rm(exp_stars)
    
    
    exp_meta_msk <- raster_metadata(exp_outpath_msk, format = "list")[[1]]
    testthat::expect_equal(exp_meta_msk$size, c("x" = 24, "y" = 42))
    testthat::expect_equal(exp_meta_msk$type, "Byte")
    
    exp_stars <- stars::read_stars(exp_outpath_msk)
    testthat::expect_equal(max(exp_stars[[1]], na.rm=TRUE),1)
    testthat::expect_equal(min(exp_stars[[1]], na.rm=TRUE),0)
    rm(exp_stars)
    
  }
)


testthat::test_that(
  "Tests on clip BOA on extent - do not create if cloudiness > threshold", {
    
    outdir_7 <- tempfile(pattern = "out_test7_")
    dir.create(dirname(outdir_7), showWarnings = FALSE)
    exp_outpath_7 <- file.path(outdir_7, "BOA", "S2A2A_20190723_022_Barbellino_BOA_10.tif")
    unlink(exp_outpath_7)
    s2_mask(
      infiles = file.path(ref_dir, "S2A2A_20190723_022_Barbellino_BOA_10.tif"),
      maskfiles = file.path(ref_dir, "S2A2A_20190723_022_Barbellino_SCL_10.tif"),
      mask_type = "land",
      max_mask = 20,
      outdir = outdir_7,
      subdirs = TRUE
    )
    testthat::expect_false(file.exists(exp_outpath_7))
    
    # test on raster metadata
    exp_meta_r <- raster_metadata(exp_outpath_7, format = "list")
    testthat::expect_equal(names(exp_meta_r[[1]]), c("path", "valid"))
    testthat::expect_equal(exp_meta_r[[1]]$valid, FALSE)
    
  }
)

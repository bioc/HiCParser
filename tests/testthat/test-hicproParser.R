test_that("Parser for .hicpro data works as expected", {
    # Path to each matrix file
    matrixPaths <-
        system.file("extdata", "hicsample_21.matrix", package = "HiCParser")

    # Path to each bed file
    bedPaths <-
        system.file("extdata", "hicsample_21.bed", package = "HiCParser")

    # Replicate and condition of each file. Can be names instead of numbers.
    replicates <- 1
    conditions <- 1

    # Instantiation of data set
    expect_message(
        object <- parseHiCPro(
            matrixPaths,
            bedPaths,
            replicates = replicates,
            conditions = conditions
        ),
        "hicsample_21.matrix"
    )
    expect_equal(length(object), 44)

    # Interactions
    expect_true("matrix" %in% class(SummarizedExperiment::assay(object)))
    expect_s4_class(InteractionSet::regions(object), "GRanges")
    expect_s4_class(InteractionSet::interactions(object), "StrictGInteractions")
    expect_s4_class(S4Vectors::mcols(object), "DataFrame")
    expect_true(is.numeric(SummarizedExperiment::assay(object)))
})

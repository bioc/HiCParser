test_that("Parser for .cool data works as expected", {
    paths <-
        system.file("extdata", "hicsample_21.cool",
            package = "HiCParser"
        )

    # Replicate and condition of each file. Can be names instead of numbers.
    replicates <- "GG"
    conditions <- "AA"
    binSize <- 5000000

    # Instantiation of data set
    if(requireNamespace("rhdf5")) {
        expect_message(
            object <- parseCool(
                paths,
                replicates = replicates,
                conditions = conditions
            ),
            "hicsample_21.cool"
        )
        expect_equal(length(object), 44)

        # Interactions
        expect_true("matrix" %in% class(SummarizedExperiment::assay(object)))
        expect_s4_class(InteractionSet::regions(object), "GRanges")
        expect_s4_class(
            InteractionSet::interactions(object),
            "StrictGInteractions"
        )
        expect_s4_class(S4Vectors::mcols(object), "DataFrame")
        expect_true(is.numeric(SummarizedExperiment::assay(object)))
    } else {
        expect_error(
            object <- parseCool(
                paths,
                replicates = replicates,
                conditions = conditions
            ),
            "'rhdf5' package is required"
        )
    }

})

test_that("Parser for .cool data returns expected errors", {
    paths <-
        system.file("extdata", "hicsample_21.cool",
            package = "HiCParser"
        )
    if(requireNamespace("rhdf5")) {
        expect_error(
            parseCool(
                paths,
                replicates = c(1, 2),
                conditions = c(1, 2)
            ),
            "'conditions/replicates' and 'paths' must have the same length"
        )
    } else {
        expect_error(
            parseCool(
                paths,
                replicates = c(1, 2),
                conditions = c(1, 2)
            ),
            "'rhdf5' package is required"
        )
    }
})

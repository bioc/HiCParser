
<!-- README.md is generated from README.Rmd. Please edit that file -->

# HiCParser

<!-- badges: start -->

[![GitHub
issues](https://img.shields.io/github/issues/emaigne/HiCParser)](https://github.com/emaigne/HiCParser/issues)
[![GitHub
pulls](https://img.shields.io/github/issues-pr/emaigne/HiCParser)](https://github.com/emaigne/HiCParser/pulls)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![Bioc release
status](http://www.bioconductor.org/shields/build/release/bioc/HiCParser.svg)](https://bioconductor.org/checkResults/release/bioc-LATEST/HiCParser)
[![Bioc devel
status](http://www.bioconductor.org/shields/build/devel/bioc/HiCParser.svg)](https://bioconductor.org/checkResults/devel/bioc-LATEST/HiCParser)
[![Bioc downloads
rank](https://bioconductor.org/shields/downloads/release/HiCParser.svg)](http://bioconductor.org/packages/stats/bioc/HiCParser/)
[![Bioc
support](https://bioconductor.org/shields/posts/HiCParser.svg)](https://support.bioconductor.org/tag/HiCParser)
[![Bioc
history](https://bioconductor.org/shields/years-in-bioc/HiCParser.svg)](https://bioconductor.org/packages/release/bioc/html/HiCParser.html#since)
[![Bioc last
commit](https://bioconductor.org/shields/lastcommit/devel/bioc/HiCParser.svg)](http://bioconductor.org/checkResults/devel/bioc-LATEST/HiCParser/)
[![Bioc
dependencies](https://bioconductor.org/shields/dependencies/release/HiCParser.svg)](https://bioconductor.org/packages/release/bioc/html/HiCParser.html#since)
[![R-CMD-check-bioc](https://github.com/emaigne/HiCParser/actions/workflows/check-bioc.yml/badge.svg)](https://github.com/emaigne/HiCParser/actions/workflows/check-bioc.yml)
[![Codecov test
coverage](https://codecov.io/gh/emaigne/HiCParser/branch/devel/graph/badge.svg)](https://app.codecov.io/gh/emaigne/HiCParser?branch=devel)
<!-- badges: end -->

The goal of `HiCParser` is to parse Hi-C data (`HiCParser` supports
serveral formats), and import them in R, as an `InteractionSet` object.

## Installation instructions

Get the latest stable `R` release from
[CRAN](http://cran.r-project.org/). Then install `HiCParser` from
[Bioconductor](http://bioconductor.org/) using the following code:

``` r
if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
}

BiocManager::install("HiCParser")
```

And the development version from
[GitHub](https://github.com/emaigne/HiCParser) with:

``` r
BiocManager::install("emaigne/HiCParser")
```

Then load the package :

``` r
library("HiCParser")
```

## Supported formats

So far, `HiCParser` supports:

-   [cool and mcool](https://github.com/open2c/cooler) formats

-   [hic](https://github.com/aidenlab/hictools) format

-   [HiC-Pro](https://github.com/nservant/HiC-Pro) format

-   A tabular format, where

    -   the first column is named “chromosome”
    -   the second column is named “position 1” or “position.1”
    -   the third column is named “position 2” or “position.2”
    -   the fourth column is named “*x*.R*y*”, and *x* is the id of the
        condition (“1”, or “2”, usually), *y* is the id of the replicate
        (“1”, “2”, “3”, etc.); it should contain matrix counts
    -   the remaining columns are optional, and should be formatted like
        the fourth column

## Example

### hic format

We show here how to parse one hic format file.

``` r
hicFilePath <- system.file("extdata", "hicsample_21.hic", package = "HiCParser")
data <- parseHiC(
    paths = hicFilePath,
    binSize = 5000000,
    conditions = 1,
    replicates = 1
)
```

Note that a hic file can include several matrices, with different bin
sizes. This is why the bin size should be provided.

We show here how to parse several files (actually, the same file,
several times). We suppose here that we have 2 conditions, with 3
replicates for each condition.

``` r
data <- parseHiC(
    paths = rep(hicFilePath, 6),
    binSize = 5000000,
    conditions = rep(seq(2), each = 3),
    replicates = rep(seq(3), 2)
)
```

Currently, `HiCParser` supports the hic format up to the version 9.

### HiC-Pro format

A HiC-Pro file contains a matrix file, and a bed file. A different bed
file could be use for each matrix file, but the same can also be used.

``` r
matrixFilePath <- 
    system.file("extdata", "hicsample_21.matrix", package = "HiCParser")
bedFilePath <- 
    system.file("extdata", "hicsample_21.bed", package = "HiCParser")
data <- parseHiCPro(
    matrixPaths = rep(matrixFilePath, 6),
    bedPaths = bedFilePath,
    conditions = rep(seq(2), each = 3),
    replicates = rep(seq(3), 2)
)
```

### cool and mcool formats

Please note that the cool and mcool format store data in HDF5 format.
The [HDF5
package](https://bioconductor.org/packages/release/bioc/html/rhdf5.html)
is not included by default, because it requires a substantial time to be
compiled, and many users will not need the cool/mcool parser. So, in
order to use the cool/mcool parser, you should install the `rhdf5`
package.

The cool format include only one bin size.

``` r
if (!"rhdf5" %in% installed.packages()) {
    install.packages("rhdf5")
}
coolFilePath <- system.file("extdata",
    "hicsample_21.cool",
    package = "HiCParser"
)
data <- parseCool(
    paths = rep(coolFilePath, 6),
    conditions = rep(seq(2), each = 3),
    replicates = rep(seq(3), 2)
)
```

The mcool format may include several bin sizes. It is thus compulsory to
mention it. The same function is used for the cool/mcool formats.

``` r
mcoolFilePath <- system.file("extdata",
    "hicsample_21.mcool",
    package = "HiCParser"
)
data <- parseCool(
    paths = rep(mcoolFilePath, 6),
    binSize = 5000000,
    conditions = rep(seq(2), each = 3),
    replicates = rep(seq(3), 2)
)
```

## Tabular files

A tabular file is a tab-separated multi-replicate sparse matrix with a
header:

    chromosome    position 1    position 2    C1.R1    C1.R2    C1.R3    ...
    Y             1500000       7500000       145      184      72       ...

The number of interactions between `position 1` and `position 2` of
`chromosome` are reported in each `condition.replicate` column. There is
no limit to the number of conditions and replicates.

To load Hi-C data in this format:

``` r
hic.experiment <- parseTabular(
    system.file("extdata",
        "hicsample_21.tsv",
        package = "HiCParser"
    ),
    sep = "\t"
)
```

### Output

The output is a
[InteractionSet](https://bioconductor.org/packages/release/bioc/html/InteractionSet.html).
This object can store one or several samples. Please read the
[corresponding
vignette](https://bioconductor.org/packages/devel/bioc/vignettes/InteractionSet/inst/doc/interactions.html)
in order to known more about this format.

``` r
library("HiCParser")
hicFilePath <- system.file("extdata", "hicsample_21.hic", package = "HiCParser")
hic.experiment <- parseHiC(
    paths = rep(hicFilePath, 6),
    binSize = 5000000,
    conditions = rep(seq(2), each = 3),
    replicates = rep(seq(3), 2)
)
#> 
#> Parsing '/tmp/RtmpHFfOT6/temp_libpathc52a1c587e54/HiCParser/extdata/hicsample_21.hic'.
#> 
#> Parsing '/tmp/RtmpHFfOT6/temp_libpathc52a1c587e54/HiCParser/extdata/hicsample_21.hic'.
#> 
#> Parsing '/tmp/RtmpHFfOT6/temp_libpathc52a1c587e54/HiCParser/extdata/hicsample_21.hic'.
#> 
#> Parsing '/tmp/RtmpHFfOT6/temp_libpathc52a1c587e54/HiCParser/extdata/hicsample_21.hic'.
#> 
#> Parsing '/tmp/RtmpHFfOT6/temp_libpathc52a1c587e54/HiCParser/extdata/hicsample_21.hic'.
#> 
#> Parsing '/tmp/RtmpHFfOT6/temp_libpathc52a1c587e54/HiCParser/extdata/hicsample_21.hic'.
hic.experiment
#> class: InteractionSet 
#> dim: 44 6 
#> metadata(0):
#> assays(1): ''
#> rownames: NULL
#> rowData names(1): chromosome
#> colnames: NULL
#> colData names(2): condition replicate
#> type: StrictGInteractions
#> regions: 9
```

The conditions and replicates are reported in the `colData` slot :

``` r
SummarizedExperiment::colData(hic.experiment)
#> DataFrame with 6 rows and 2 columns
#>   condition replicate
#>   <integer> <integer>
#> 1         1         1
#> 2         1         2
#> 3         1         3
#> 4         2         1
#> 5         2         2
#> 6         2         3
```

They corresponds to columns of the `assays` matrix (containing
interactions values):

``` r
head(SummarizedExperiment::assay(hic.experiment))
#>      [,1] [,2] [,3] [,4] [,5] [,6]
#> [1,]   79   79   79   79   79   79
#> [2,]   22   22   22   22   22   22
#> [3,]    3    3    3    3    3    3
#> [4,]    1    1    1    1    1    1
#> [5,]    1    1    1    1    1    1
#> [6,]    2    2    2    2    2    2
```

The positions of interactions are in the `interactions` slot of the
object:

``` r
InteractionSet::interactions(hic.experiment)
#> StrictGInteractions object with 44 interactions and 1 metadata column:
#>        seqnames1           ranges1     seqnames2           ranges2 | chromosome
#>            <Rle>         <IRanges>         <Rle>         <IRanges> |      <Rle>
#>    [1]        21  5000001-10000000 ---        21  5000001-10000000 |         21
#>    [2]        21  5000001-10000000 ---        21 10000001-15000000 |         21
#>    [3]        21  5000001-10000000 ---        21 15000001-20000000 |         21
#>    [4]        21  5000001-10000000 ---        21 20000001-25000000 |         21
#>    [5]        21  5000001-10000000 ---        21 25000001-30000000 |         21
#>    ...       ...               ... ...       ...               ... .        ...
#>   [40]        21 35000001-40000000 ---        21 40000001-45000000 |         21
#>   [41]        21 35000001-40000000 ---        21 45000001-50000000 |         21
#>   [42]        21 40000001-45000000 ---        21 40000001-45000000 |         21
#>   [43]        21 40000001-45000000 ---        21 45000001-50000000 |         21
#>   [44]        21 45000001-50000000 ---        21 45000001-50000000 |         21
#>   -------
#>   regions: 9 ranges and 1 metadata column
#>   seqinfo: 1 sequence from an unspecified genome; no seqlengths
```

## Citation

Below is the citation output from using `citation('HiCParser')` in R.
Please run this yourself to check for any updates on how to cite
**HiCParser**.

To cite the ‘HiCParser’ HiCParser in a publication, use :

Maigné E, Zytnicki M (2024). *A multiple format Hi-C data parser*.
<doi:10.18129/B9.bioc.HiCParser>
<https://doi.org/10.18129/B9.bioc.HiCParser>,
<https://github.com/emaigne/HiCParser/HiCParser> - R package version
0.1.0, <http://www.bioconductor.org/packages/HiCParser>.

As a BibTeX entry :

    @Manual{hicparser,
      title = {A multiple format Hi-C data parser},
      author = {Elise Maigné and Matthias Zytnicki},
      year = {2024},
      url = {http://www.bioconductor.org/packages/HiCParser},
      note = {https://github.com/emaigne/HiCParser/HiCParser - R package version 0.1.0},
      doi = {10.18129/B9.bioc.HiCParser},
    }

Please note that the `HiCParser` was only made possible thanks to many
other R and bioinformatics software authors, which are cited either in
the vignettes and/or the paper(s) describing this package.

## Code of Conduct

Please note that the `HiCParser` project is released with a [Contributor
Code of Conduct](http://bioconductor.org/about/code-of-conduct/). By
contributing to this project, you agree to abide by its terms.

## Development tools

-   Continuous code testing is possible thanks to [GitHub
    actions](https://www.tidyverse.org/blog/2020/04/usethis-1-6-0/)
    through *[usethis](https://CRAN.R-project.org/package=usethis)*,
    *[remotes](https://CRAN.R-project.org/package=remotes)*, and
    *[rcmdcheck](https://CRAN.R-project.org/package=rcmdcheck)*
    customized to use [Bioconductor’s docker
    containers](https://www.bioconductor.org/help/docker/) and
    *[BiocCheck](https://bioconductor.org/packages/3.17/BiocCheck)*.
-   Code coverage assessment is possible thanks to
    [codecov](https://codecov.io/gh) and
    *[covr](https://CRAN.R-project.org/package=covr)*.
-   The [documentation website](http://emaigne.github.io/HiCParser) is
    automatically updated thanks to
    *[pkgdown](https://CRAN.R-project.org/package=pkgdown)*.
-   The code is styled automatically thanks to
    *[styler](https://CRAN.R-project.org/package=styler)*.
-   The documentation is formatted thanks to
    *[devtools](https://CRAN.R-project.org/package=devtools)* and
    *[roxygen2](https://CRAN.R-project.org/package=roxygen2)*.

For more details, check the `dev` directory.

This package was developed using
*[biocthis](https://bioconductor.org/packages/3.17/biocthis)*.

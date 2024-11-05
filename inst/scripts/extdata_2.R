##############################################################################
# R code to generate inst/extdata/hicsample_21.txt file

# Reading matrix and bed files
mat21 <- data.table::fread("inst/extdata/hicsample_21.matrix")
bed21 <- data.table::fread("inst/extdata/hicsample_21.bed", drop=3)

# Setting colnames
setnames(mat21, c("index1", "index2", "1.R1"))
setnames(bed21, c("chromosome", "start", "index"))

# Merging data
tsv21 <- merge(bed21[,-1], mat21, by.x="index", by.y="index2", all.y = TRUE)
setnames(tsv21, "start", "position 2")
tsv21[,index := NULL]

tsv21 <- merge(bed21, tsv21, by.x="index", by.y="index1", all.y = TRUE)
setnames(tsv21, "start", "position 1")
tsv21[,index := NULL]

data.table::fwrite(tsv21, file="inst/extdata/hicsample_21.tsv", sep="\t")

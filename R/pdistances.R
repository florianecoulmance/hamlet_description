#!/usr/bin/env Rscript
# by: Floriane Coulmance: 27/10/2021
# usage:
# Rscript 
# -------------------------------------------------------------------------------------------------------------------
#
# -------------------------------------------------------------------------------------------------------------------


# Clear the work space
rm(list = ls())

library(adegenet)
library(phangorn)



file <- "/Users/fco/Desktop/PhD/HAMLET_DESCRIPTION_PAPER/hamlet_description/coi_filterd.fas"



g <- fasta2DNAbin(file)
f <- as.phyDat(g)

# proportion (p) of nucleotide sites at which the two sequences compared are different.
x <- dist.p(f, cost = "polymorphism", ignore.indels = TRUE)
y <- as.matrix(x)
rn <- rownames(y)
b <- y[order(as.numeric(rn)), ]

dim <- ncol(y)
image(1:dim, 1:dim, y, axes = FALSE, xlab="", ylab="")
axis(1, 1:dim, colnames(y), cex.axis = 0.5, las=3)
axis(2, 1:dim, rownames(y), cex.axis = 0.5, las=1)
text(expand.grid(1:dim, 1:dim), sprintf("%0.1f", y), cex=0.6)



z <- y[ !(rownames(y) %in% "PL17_160floflo"), ]
z <- z[ , !(colnames(z) %in% "PL17_160floflo") ]

dim <- ncol(z)
image(1:dim, 1:dim, z, axes = FALSE, xlab="", ylab="")
axis(1, 1:dim, colnames(z), cex.axis = 0.5, las=3)
axis(2, 1:dim, rownames(z), cex.axis = 0.5, las=1)
text(expand.grid(1:dim, 1:dim), sprintf("%0.1f", z), cex=0.6)



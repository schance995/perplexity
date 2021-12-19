#!/usr/bin/env Rscript



args = commandArgs(trailingOnly=TRUE)


library(polyester)
library(Biostrings)



#error
if (length(args) < 3) {
  stop("program <transcript fasta file> <quant file> <outputdir>", call.=FALSE)
} 

txpFastaFile <- args[1]
salmonModelFile <- args[2]

txnames <- fasta.index(txpFastaFile)$desc
#print(txnames)
salmonModel <- read.table(salmonModelFile,header=TRUE)
df = salmonModel[match(txnames, salmonModel$Name),]
countMatSalmon <- matrix(df$NumReads, nrow=length(txnames))
#print(countMatSalmon)
countMatSalmon[is.na(countMatSalmon)] <- 0
#print(df)
#print(countMatSalmon)
# https://robpatro.com/blog/?p=235#efflen
# effective length considers both the length of the transcript and fragment
tx_lengths <- salmonModel$EffectiveLength
read_length <- 100
# 30x coverage
coverage <- 30
# replicates <- c(5)
# should be sufficient, each run gives ~14.7 million reads
# Long transcripts usually produce more reads in RNA-seq experiments than short ones, so you may want to specify reads_per_transcript as a function of transcript length
readspertx = round(coverage * tx_lengths / read_length)
#print(readspertx)

set.seed(2021)
# each run produces ~14.7M reads, run 7 times for 100M reads
# https://github.com/alyssafrazee/polyester/issues/9#issuecomment-77029729
# from ?simulate_experiment
# No return, but simulated reads and a simulation info file are
# written to ‘outdir’. Note that reads are written out transcript by
# transcript and so need to be shuffled if used as input to
# quantification algorithms such as eXpress or Salmon.
simul <- function(out) {
    print(paste('Simulating', out))
    simulate_experiment_countmat(txpFastaFile, 
                                 readmat=countMatSalmon, 
                                 outdir=out,
                                 readlen=read_length,
                                 #size=1e6,
                                 strand_specific=F, 
                                 paired=TRUE, 
                                 error_model='uniform',
#                                 gzip=TRUE,
                                 error_rate=0.001,
                                 reads_per_transcript=readspertx,
     # num_reps=replicates)
    )
}

# 14.7 * 7 = 102.9
for (i in 1:7) {
    out <- paste0(args[3], '/', i)
    simul(out)
}
print('DONE')


# Kmer-based analysis of sequencing data 

There are numerous kmer counters available that can be used to create kmer tables. A probably inclomplete list 
can found here:
 * [FastK](https://github.com/thegenemyers/FASTK)
 * [kat](https://github.com/TGAC/KAT)
 * [jellyfish](https://github.com/gmarcais/Jellyfish)
 * [meryl](https://github.com/marbl/meryl)

In principle they can be used quite interchangeably and only have marginal differences in runtime and memory footprint, 
as well as different default arguments. In order to derive useful estimates for `sequencing coverage and genome size`, `heterozygosity`, 
`repeat content`, and biases e.g. `contamination` the kmer database should be created wit the following options:
   1. include 1-copy kmers
   2. use a high maximum kmer count >= 1'000'000
   3. choose a good kmer size*

*) The selection of a good kmer size is not straight forward. 

* `k21` seems to be a good balance between repetetive elements vs sequencing error and heterozygosity [[mschatz](https://github.com/schatzlab/genomescope/issues/32)]. 
* the merqury git repo offers a small script `best_k.sh` to calculate a 'good' kmer size based on genome size and error rate [[merqury](https://github.com/marbl/merqury/blob/master/best_k.sh)]. For pacbio HiFi reads with average error rates within [0.1 - 0.5%] the estimated best kmer sizes are in a very narrow range [17,25] for haploid genomes from ranging from 90M to 90G. 
* `k40` is used by FastK by default
* rule of thumb: for smaller genomes <500M a smaller kmer size (<20) should be tested as well
      
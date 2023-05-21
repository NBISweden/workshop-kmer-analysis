
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
   4. minimum haploid coverage: ~20x

*) The selection of a good kmer size is not straight forward. 

* `k21` seems to be a good balance between repetetive elements vs sequencing error and heterozygosity [[mschatz](https://github.com/schatzlab/genomescope/issues/32)]. 
* the merqury git repo offers a small script `best_k.sh` to calculate a 'good' kmer size based on genome size and error rate [[merqury](https://github.com/marbl/merqury/blob/master/best_k.sh)]. For pacbio HiFi reads with average error rates within [0.1 - 0.5%] the estimated best kmer sizes are in a very narrow range [17,25] for haploid genomes ranging from 90M to 90G. 
* `k40` is used by FastK by default
* rule of thumb: for smaller genomes <500M a smaller kmer size (<20) should be tested as well

# Kmer-based analysis with FastK and Genomescope2.0

## Data set T2T PacBio HiFi

1. create kmer tables with FastK  

```bash 
cor=12
tim=12:00:00 
mem=50G
par=core
nam=FASTK_PB
acc="-A proj2022-5-333"
# reads SRR1129212[1234].fastq are linked to current working dir 
for k in 14 21 31 40 50 
do 
   mkdir -p t2t_pb_k${k}
   pushd t2t_pb_k${k}
   cmd1="${SG} FastK -v -T${cor} -NT2T_PB_k${k} -k${k} -t1 ../SRR1129212[1234].fastq"
   sbatch -c ${cor} ${acc} -n 1 -p ${par} --mem=${mem} --time=${tim} -J ${nam}_k${k} --wrap="echo \"${cmd1}\" && ${cmd1}"
   popd
done
```

Run statistics

input read set: ~55G

|  K  |  walltime  | CPUtime | MemPeak (Gb) | storage (Gb)  |
|----:|:----------:|:-----------:|------------:|--------------:|
|  14 |   00:11:30 | 02:18:00    |     11.9    |      0.5      |
|  21 |   00:13:03 | 02:36:36    |     12.2    |      20       |
|  31 |   00:14:25 | 02:53:00    |     12.2    |      37       |
|  40 |   00:14:08 | 02:49:00    |     12.2    |      **58**   |
|  50 |   00:16:01 | 03:12:00    |     12.2    |      **91**   |


2. run GeneScope.FK 

```bash 
cor=1
tim=02:00:00 
mem=10G
par=gpu
nam=GeneScope_PB
acc="" #-A proj2022-5-333"
for k in 14 21 31 40 50;  
do           
   pushd t2t_pb_k${k}
   cmd1="/projects/dazzler/pippel/prog/dazzlerGIT/FASTK/Histex -G T2T_PB_k${k} | /projects/dazzler/pippel/prog/dazzlerGIT/GENESCOPE.FK/GeneScopeFK.R -o GeneS_T2T_PB_k${k} -p 1 -k ${k}"
   sbatch -c ${cor} ${acc} -n 1 -p ${par} --mem=${mem} --time=${tim} -J ${nam}_k${k} --wrap="echo \"${cmd1}\" && ${cmd1}"
   popd
done 
```

Results:

<img src="../examples/humanT2T/pb/GeneS_T2T_PB_k14/linear_plot.png" alt="GeneScope PacBio K14" width="300"/> 

<img src="../examples/humanT2T/pb/GeneS_T2T_PB_k21/linear_plot.png" alt="GeneScope PacBio K21" width="300"/> <img src="../examples/humanT2T/pb/GeneS_T2T_PB_k31/linear_plot.png" alt="GeneScope PacBio K31" width="300"/> 
<img src="../examples/humanT2T/pb/GeneS_T2T_PB_k40/linear_plot.png" alt="GeneScope PacBio K40" width="300"/> <img src="../examples/humanT2T/pb/GeneS_T2T_PB_k50/linear_plot.png" alt="GeneScope PacBio K50" width="300"/>


# potato (tetraploid)

## Data set T2T PacBio Hifi reads

1. create kmer tables with FastK  

```bash 
    cor=12
    tim=12:00:00 
    mem=50G
    par=core
    nam=FASTK_PB
    acc="-A proj2022-5-333"
    # reads SRR1681122[6-8].fasta are linked to current working dir 
    for k in 21 31 40
    do 
    mkdir -p potato_pb_k${k}
    pushd potato_pb_k${k}
    cmd1="${SG} FastK -v -T${cor} -Npotato_pb_k${k} -P$(pwd) -k${k} -t1 ../SRR1681122[6-8].fasta"
    sbatch -c ${cor} ${acc} -n 1 -p ${par} --mem=${mem} --time=${tim} -J ${nam}_k${k} --wrap="echo \"${cmd1}\" && ${cmd1}"
    popd
    done
```

Run statistics

input read set: ~41G

|  K  |  walltime  | CPUtime | MemPeak (Gb) | storage (Gb)  |
|----:|:----------:|:-----------:|------------:|--------------:|
|  21 |   00:16:29 | 03:17:48    |     13.2    |      12       |
|  31 |   00:18:24 | 03:40:48    |     13.2    |      26       |

2. run GeneScope.FK 

```bash 
cor=1
tim=02:00:00 
mem=10G
par=gpu
nam=GeneScope_PB
acc="" #-A proj2022-5-333"
for k in 21 31;  
do           
   pushd potato_pb_k${k}
   cmd1="${SG} Histex -G potato_pb_k${k} | ${SG} GeneScopeFK.R -o GeneS_potato_pb_k${k} -p 4 -k ${k}"
   sbatch -c ${cor} ${acc} -n 1 -p ${par} --mem=${mem} --time=${tim} -J ${nam}_k${k} --wrap="echo \"${cmd1}\" && ${cmd1}"
   popd
done 
```

Results:

<img src="../examples/potato/pb/GeneS_potato_pb_k21/linear_plot.png" alt="GeneScope Potato PacBio K21" width="300"/>  <img src="../examples/potato/pb/GeneS_potato_pb_k31/linear_plot.png" alt="GeneScope Potato PacBio K31" width="300"/>

You should also have a look into the summary.txt file and check e.g. the Model Fit.

|K|property|min|max|
|:------|:-------|:----------|:-----------|
|21||||
||Homozygous (aaaa)         |    90.4604%        |  95.0882%        |  
||Heterozygous (not aaaa)   |    4.91184%        |  9.53961%        |  
||aaab                      |    3.98885%        |  4.31829%        |  
||aabb                      |    0.92299%        |  3.01475%        |  
||aabc                      |    0%              |  1.59935%        |  
||abcd                      |    0%              |  0.607219%       |  
||Genome Haploid Length     |    NA bp           |  726,211,287 bp  |  
||Genome Repeat Length      |    382,571,420 bp  |  389,767,832 bp  |  
||Genome Unique Length      |    336,935,728 bp  |  343,273,703 bp  |  
||Model Fit                 |    76.8903%        |  95.5521%        |  
||Read Error Rate           |    0.175859%       |  0.175859%       |  
|31||||
||Homozygous (aaaa)         |    92.3889%        |  96.2144%        |  
||Heterozygous (not aaaa)   |    3.78557%        |  7.61107%        |  
||aaab                      |    2.95001%        |  3.12044%        |  
||aabb                      |    0.835552%       |  2.55367%        |  
||aabc                      |    0%              |  1.27701%        |  
||abcd                      |    0%              |  0.659954%       |  
||Genome Haploid Length     |    NA bp           |  738,006,290 bp  |  
||Genome Repeat Length      |    308,638,365 bp  |  312,012,268 bp  |  
||Genome Unique Length      |    425,377,758 bp  |  430,027,807 bp  |  
||Model Fit                 |    83.4242%        |  96.5468%        |  
||Read Error Rate           |    0.186503%       |  0.186503%       |  


2. run PloidyPlot (smudgeplot)

* PloidyPlot fails 

<img src="../examples/potato/pb/PloidyP_potato_pb_k21.fi.pdf" alt="PloidyPlot Potato PacBio K21" width="600"/>

* fallback to original smudgeplot.py - still running: (> 4h, > 400Gb RAM)

back to [kmers.md](kmers.md)

back to [main kmer_workshop page](https://github.com/NBISweden/workshop-kmer-analysis)
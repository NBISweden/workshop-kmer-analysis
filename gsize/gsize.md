# Using kmer analysis to estimate genome size.  

## Background
To tune assembly parameters and to evaluate different versions of an assembly, knowing the true genome size is rather useful.  

There are several databases that compile experimental values of genomesize for many different species:
ADD LINKS HERE:

However, as more and more "obscure species" are being sequenced it is likely we will come across cases where the size is not known and where no one wants to put in the time, effort and money to estimate the size with traditional experiments.


### Kmers to the rescue, or?
In an ideal case, we can estimate the genome size (N) if we know the total number of k-mers (n) and the coverage (C).

N = n / C


However, in a real case it is of course not as straight-forward due to both technical and biological reasons.
Think sequencing biases, sequencing errors, contamination, repetetiveness, heterozygosity etc.  


Our first aim is to select a suitable k-mer size. 
The whole idea is based on being able to map k-mers uniquely without using a k-mer size that is too costly computationaly.  
So that probably means that we need to try some different values of k in order to find something useful.

### Step 1: count k-mers and generate a histogram of the k-mer occurence
There are many tools to kount kmers. We will use KAT today (which use Jellyfish internally).

Can be installed with conda.
```
conda env create -n KAT
conda activate KAT
conda install -c bioconda kat
```

Run it like this for our first test set ERR3712275.fasta.gz:
```
kat hist -o ERR3712275.hist -t 8 -m 21 -p png -v ERR3712275.fasta.gz
```

This will create  an output file "ERR3712275.hist" with the k-mer histogram and the corresponding plot "ERR3712275.hist.png"  
















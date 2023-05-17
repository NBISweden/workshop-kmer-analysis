# Using kmer analysis to estimate genome size.  

## Background
To tune assembly parameters and to evaluate different versions of an assembly, knowing the true genome size is rather useful.  

There are several databases that compile experimental values of genomesize for many different species. Often these are based on densitometry methods and give very good genome size estimates if done right.

However, as more and more "obscure species" are being sequenced it is likely we will come across cases where the size is not known and where no one wants to put in the time, effort and money to estimate the size with traditional experiments.


### Kmers to the rescue, or?
In an ideal case, we can estimate the genome size (N) if we know the total number of k-mers (n) and the coverage (C).

N = n / C

However, in a real-world case it is of course not as straight-forward due to both technical and biological reasons.
Think sequencing biases, sequencing errors, contamination, repetetiveness, heterozygosity etc. 


Our first aim is to select a suitable k-mer size for the data at hand. 
The whole idea is based on being able to map k-mers uniquely without using a k-mer size that is too costly computationaly.  
So that probably means that we need to try some different values of k before settling on something useful.

### Step 1: count k-mers and generate a histogram of the k-mer occurence
There are many tools to kount kmers. We will use KAT today (which use a modified version of Jellyfish internally).

Can be installed with conda.
```
conda env create -n KAT
conda activate KAT
conda install -c bioconda kat
```

Run it like this for our first test set TEST-1.fastq:
```
kat hist -o TEST-1.hist -t 8 -m 27 -p png TEST-1.fastq
```

This will create an output file "TEST-1.hist" with the k-mer histogram and the corresponding plot "TEST-1.hist.png"  

It will also produce som useful output like this:  
```
Analysing peaks  
---------------

Analysing distributions for: TEST-1.hist ... done.  Time taken:  3.0s

K-mer frequency spectra statistics
----------------------------------
K-value used: 27
Peaks in analysis: 3
Global minima @ Frequency=4x (1013233)
Global maxima @ Frequency=14x (7965507)
Overall mean k-mer frequency: 14x

  Index    Left    Mean    Right    StdDev      Max    Volume  Description
-------  ------  ------  -------  --------  -------  --------  -------------
      1    5.17   14.21    23.26      4.52  7841437  88846349  1X
      2    7.37   26       44.63      9.32   163865   3818190  2X
      3   13.66   70      126.34     28.17     5729    402083  5X

Calculating genome statistics
-----------------------------
Assuming that homozygous peak is the largest in the spectra with frequency of: 14x
Homozygous peak index: 1
CAUTION: the following estimates are based on having a clean spectra and having identified the correct homozygous peak!
Estimated genome size: 97.69 Mbp
```

Ha!  
Look it directly give you an estimate of the genome size! 
So basically that is the end of this tutorial. Thanks for your interest! :-)  

Or should we look into a bit more what is going on and see if we can arrive at the same estimate?

### Step 2: Inspect the histogram
The plot should look something like this:
[TEST-1 histogram](./img/TEST-1.hist.png)



First we need to disregard the kmers that are likely to be sequencing errors etc.
In this first example it is clear that what is the supposed to be erroneous kmers are everything below four or less on the x-axis.

Then we need to look at the region that corresponds to the single copy region.

Directly inspecting the plot we see that the peak is at 14.


### Step 3: Calculate the size
Based on this we can estimate the genome size:

```
sum(as.numeric(dataframe[2:9325,1]*dataframe[2:9325,2]))/12 # (12 in this case)
```


### How repetitive is the genome or rather how many single copy regions do we have?
Single copy regions
sum(as.numeric(dataframe19[2:28,1]*dataframe19[2:28,2]))/12


  

OK now we have an idea how this works.
What about using a few different kmer sizes, how does that affect the result?


What about different levels of heterozygosity?


What about amount of data used for estimation?

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
There are many tools to count kmers. We will use KAT today (which use a modified version of Jellyfish internally).

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

For the actual genome size estimation we need to filter a bit first.
First we need to disregard the kmers that are likely to be sequencing errors etc.  
In this first example it looks like what is supposed to be erroneous k-mers are everything below four or less on the x-axis.

Then we need to look at the region that corresponds to the single copy region.

Directly inspecting the plot we see that the peak is around 15. And the single copy region seem to be the region up to 25 or so.

The beginning of the underlying histogram file looks like this:
```
# Title:27-mer spectra for: TEST-1.fastq
# XLabel:27-mer frequency
# YLabel:# distinct 27-mers
# Kmer value:27
# Input 1:TEST-1.fastq
###
1 56383285
2 2766716
3 1417214
4 1088076
5 1013233
6 1169047
7 1555026
8 2164305
9 2988731
10 3984107
11 5084578
12 6160776
13 7063466
14 7692803
15 7965507
16 7820072
17 7306554
18 6522596
19 5577539
20 4561014
21 3584189
22 2716446
23 1983778
24 1403037
25 975588
26 667519
27 458548
28 320761
29 234493
```

### Step 3: Calculate the size
Let's see if we can do our own estimation.

```r
test1_kmers <- read.table("TEST-1.hist", skip = 6)
head(test1_kmers)
```

Plot the first 100 datapoints:
```r
plot(test1_kmers[1:100,], type="l")
```

OK, looks good but we are not interested in the junk so:
```r
plot(test1_kmers[5:100,], type="l")
points(test1_kmers[5:100,])
```

There is a total of 10001 datapoints in our histogram file.
So we can calculate the total number of k-mers like this:
```r
sum(as.numeric(test1_kmers[5:10001,1]*test1_kmers[5:10001,2]))
```
Total number: 1595108148


Since we know the peak position (14) we can calculate the genome size like this:

```r
sum(as.numeric(test1_kmers[5:10001,1]*test1_kmers[5:10001,2]))/14 
```
This would give us a genome size of: 113936296

### What is the single copy region of the genome?
Single copy regions by eyeballing, frestyling, "killgissning" based on the previous graph:

```r
sum(as.numeric(test1_kmers[5:25,1]*test1_kmers[5:25,2]))/14
```
Single copy part: 97038455 (close to what KAT reports)

So basically ≈ 85% are in the single copy fraction in this case.

OK, now we have an idea how this works.

### Step 4:

Let's do the same for an independent dataset:
```
kat hist -o TEST-2.hist -t 8 -m 27 -p png TEST-2.fastq
```

```r
test2_kmers <- read.table("TEST-2.hist", skip = 6)
head(test2_kmers)
```

Plot the first 100 datapoints:
```r
plot(test2_kmers[1:100,], type="l")
```

OK, looks good but we are not interested in the junk so:
```r
plot(test2_kmers[5:100,], type="l")
points(test2_kmers[5:100,])
```

There is a total of 10001 datapoints in this file as well.
So we calculate just as before:
```r
sum(as.numeric(test2_kmers[5:10001,1]*test2_kmers[5:10001,2]))
```
Total number: 1597773086

And calculate the genome size:

```r
sum(as.numeric(test2_kmers[5:10001,1]*test2_kmers[5:10001,2]))/14 
```
This would give us a genome size of: 114126649 

Looks like both datasets are giving us a similar estimate.

### Step 5
What about using a few different kmer sizes, how does that affect the result?

### Step 6
What about different levels of heterozygosity?

### Step 7
What about amount of data used for estimation?

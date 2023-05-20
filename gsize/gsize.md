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

The files:  
TEST-1_k17.hist  
TEST-1_k21.hist  
TEST-1_k25.hist  
TEST-1_k31.hist  
contain results from runs with different k-mer settings (in addition to our first example that was run with k = 27).  

Already from the output of KAT it is clear that the estimates differ a bit:
Also KAT does not estimate a heterozygosity rate for our set with all of our settings of k.

TEST-1_k17:
```
Analysing distributions for: TEST-1_k17.hist ... done.  Time taken:  3.7s

K-mer frequency spectra statistics
----------------------------------
K-value used: 17
Peaks in analysis: 4
Global minima @ Frequency=5x (696968)
Global maxima @ Frequency=16x (6245251)
Overall mean k-mer frequency: 18x

  Index    Left    Mean    Right    StdDev      Max    Volume  Description
-------  ------  ------  -------  --------  -------  --------  -------------
      1    6.4    15.73    25.07      4.67  6103909  71366081  1X
      2    7.75   30       52.25     11.13   307816   8559185  2X
      3   13.14   64      114.86     25.43    11573    733679  4X
      4   14.49   80      145.51     32.76     7458    608126  5X

Calculating genome statistics
-----------------------------
Assuming that homozygous peak is the largest in the spectra with frequency of: 15x
Homozygous peak index: 1
CAUTION: the following estimates are based on having a clean spectra and having identified the correct homozygous peak!
Estimated genome size: 93.12 Mbp
```

TEST-1_k21.hist
```
Analysing distributions for: TEST-1_k21.hist ... done.  Time taken:  5.5s

K-mer frequency spectra statistics
----------------------------------
K-value used: 21
Peaks in analysis: 4
Global minima @ Frequency=4x (877390)
Global maxima @ Frequency=15x (7524937)
Overall mean k-mer frequency: 16x

  Index    Left    Mean    Right    StdDev      Max    Volume  Description
-------  ------  ------  -------  --------  -------  --------  -------------
      1    1.57    7       12.43      2.72   101905    691636  1/2X
      2    5.91   15.14    24.37      4.61  7397294  85502423  1X
      3    7.48   28       48.52     10.26   173903   4459543  2X
      4   14.08   75      135.92     30.46     6071    460521  5X

Calculating genome statistics
-----------------------------
Assuming that homozygous peak is the largest in the spectra with frequency of: 15x
Homozygous peak index: 2
CAUTION: the following estimates are based on having a clean spectra and having identified the correct homozygous peak!
Estimated genome size: 96.15 Mbp
Estimated heterozygous rate: 0.03%
```

TEST-1_k25.hist
```
Analysing distributions for: TEST-1_k25.hist ... done.  Time taken:  51.0s

K-mer frequency spectra statistics
----------------------------------
K-value used: 25
Peaks in analysis: 5
Global minima @ Frequency=4x (966925)
Global maxima @ Frequency=14x (7805827)
Overall mean k-mer frequency: 15x

  Index    Left    Mean    Right    StdDev      Max    Volume  Description
-------  ------  ------  -------  --------  -------  --------  -------------
      1    2.15    7       11.85      2.43    50567    307339  1/2X
      2    5.42   14.51    23.6       4.54  7714544  87847602  1X
      3    7.64   26       44.37      9.18   173516   3986340  2X
      4   12.39   56       99.61     21.8       977     53151  4X
      5   13.66   70      126.34     28.17     5975    419326  5X

Calculating genome statistics
-----------------------------
Assuming that homozygous peak is the largest in the spectra with frequency of: 14x
Homozygous peak index: 2
CAUTION: the following estimates are based on having a clean spectra and having identified the correct homozygous peak!
Estimated genome size: 97.81 Mbp
Estimated heterozygous rate: 0.01%
```

TEST-1_k31.hist
```
Analysing distributions for: TEST-1_k31.hist ... done.  Time taken:  3.4s

K-mer frequency spectra statistics
----------------------------------
K-value used: 31
Peaks in analysis: 3
Global minima @ Frequency=4x (1120587)
Global maxima @ Frequency=14x (8159575)
Overall mean k-mer frequency: 14x

  Index    Left    Mean    Right    StdDev      Max    Volume  Description
-------  ------  ------  -------  --------  -------  --------  -------------
      1    4.78   13.64    22.51      4.43  8088929  89794636  1X
      2    7.21   26       44.79      9.39   157795   3706976  2X
      3   13.66   70      126.34     28.17     3673    257818  5X

Calculating genome statistics
-----------------------------
Assuming that homozygous peak is the largest in the spectra with frequency of: 13x
Homozygous peak index: 1
CAUTION: the following estimates are based on having a clean spectra and having identified the correct homozygous peak!
Estimated genome size: 97.98 Mbp
```

### Step 6
What about contamination?
I have artificially generated a contaminated dataset by adding about 10% reads from a different species.
But this could also be mitochondrial or chloroplast reads etc. 

Lets see what happens for two different values of k:

```
Analysing peaks
---------------

Analysing distributions for: Contaminated_set_k27.hist ... done.  Time taken:  138.3s

K-mer frequency spectra statistics
----------------------------------
K-value used: 27
Peaks in analysis: 5
Global minima @ Frequency=3x (2235591)
Global maxima @ Frequency=11x (9128739)
Overall mean k-mer frequency: 11x

  Index    Left    Mean    Right    StdDev      Max    Volume  Description
-------  ------  ------  -------  --------  -------  --------  -------------
      1    1.46    5        8.54      1.77   422316   1871092  1/2X
      2    3.2    11.06    18.92      3.93  8976869  88275984  1X
      3    6.88   20       33.12      6.56   296084   4864645  2X
      4   11.16   44       76.83     16.42     4027    165184  4X
      5   12.29   55       97.7      21.35     7160    381474  5X

Calculating genome statistics
-----------------------------
Assuming that homozygous peak is the largest in the spectra with frequency of: 11x
Homozygous peak index: 2
CAUTION: the following estimates are based on having a clean spectra and having identified the correct homozygous peak!
Estimated genome size: 100.96 Mbp
Estimated heterozygous rate: 0.07%
```

```
Analysing peaks
---------------

Analysing distributions for: Contaminated_set_k17.hist ... WARNING: problem optimising peaks. It is likely that the spectra is too complex to analyse properly.  Output for this spectra may not be valid.
Optimal parameters not found: The maximum number of function evaluations is exceeded.
done.  Time taken:  360.7s

K-mer frequency spectra statistics
----------------------------------
K-value used: 17
Peaks in analysis: 6
Global minima @ Frequency=4x (1607024)
Global maxima @ Frequency=12x (7157091)
Overall mean k-mer frequency: 15x

  Index    Left    Mean    Right    StdDev      Max    Volume  Description
-------  ------  ------  -------  --------  -------  --------  -------------
      1    2.1      7      11.9       2.45  2355857  14450059  1/2X
      2    3.48    12.3    21.11      4.41  7157088  78923176  1X
      3    1       23      45        11      563011  15270919  2X
      4    1       35      69        17      148451   6209700  3X
      5    1       47      93        23       53643   3032574  4X
      6    1       59     117        29       26531   1889916  5X

Calculating genome statistics
-----------------------------
Assuming that homozygous peak is the largest in the spectra with frequency of: 12x
Homozygous peak index: 2
CAUTION: the following estimates are based on having a clean spectra and having identified the correct homozygous peak!
Estimated genome size: 156.90 Mbp
Estimated heterozygous rate: 0.54%
```

### Step 7
What about amount of data used for estimation?
There  are two downsampled datsets "80_percent.hist and 70_percent.hist".
For the 70% set we are no longer able to get a reliable estimate:

```
Analysing peaks
---------------

Analysing distributions for: 70_percent.hist ... done.  Time taken:  0.0s

K-mer frequency spectra statistics
----------------------------------
K-value used: 27
Peaks in analysis: 0
Global minima @ Frequency=2x (1851944)
Global maxima @ Frequency=9x (9780359)
Overall mean k-mer frequency: 0x

No peaks detected

Calculating genome statistics
-----------------------------
No peaks detected, so no genome stats to report
```


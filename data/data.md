
# Sequencing data 

* The human [Telomer-to-telomer project](https://github.com/marbl/CHM13/tree/master#telomere-to-telomere-consortium-chm13-projectT2T): 

    * homozygous genome (haploid) - BUT due to a female sample the Y-Chromosome was seqeunced from another sample!
    * a complete overview of all available sequencing data can be found [here](https://github.com/marbl/CHM13/blob/master/Sequencing_data.md#sequencing-data)
    * for the kmer workshop we used
        1. PacBio HiFi data (20Kb library, 32x coverage)
            * [SRR11292120](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR11292120&display=metadata)
            * [SRR11292121](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR11292121&display=metadata)
            * [SRR11292122](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR11292122&display=metadata)
            * [SRR11292123](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR11292123&display=metadata)
        2. Illimina 10X Genomics linked-reads
            * [10x](https://github.com/marbl/CHM13/blob/master/Sequencing_data.md#10x-genomics-data)
        3. Illumina HiC reads 
            * [hic](https://github.com/marbl/CHM13/blob/master/Sequencing_data.md#hi-c-data) 
        4. Illumina reads (PCR-free) 
            * [SRR1997411](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR1997411&display=metadata)
            * [SRR3189741](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR3189741&display=metadata) 
            * [SRR3189742](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR3189742&display=metadata)
            * [SRR3189743](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR3189743&display=metadata)
 
 * autotetraploid potato  [Altus cultivar](https://www.biorxiv.org/content/10.1101/2022.05.10.491293v1)
    1. PacBio HiFi
        * [SRR16811226](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR16811226&display=metadata)
        * [SRR16811227](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR16811227&display=metadata)
        * [SRR16811228](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR16811228&display=metadata)
 
 * simulated PacBio HiFi reads based on the T2T PacBio sequencing data 

# Simulated read data

To simulate PacBio reads we used the tool [HI.sim](https://github.com/thegenemyers/HI.SIM). **BUT!**

Short HowTo (only works on Mac!)
    
1. create kmer database with `FastK`:  

    ```bash
    # kmer >=40
    FastK -v -T38 -NT2T_PB_k40 -k40 -p -t1 SRR1129212[1234].fastq
    # model error rate 
    ```

2. build error and length model, based on PacBio HiFi Kmer table 

    ```bash 
    # you need to choose a 'good' kmer range -g20,30 and error range -e4
    # FastK binaries need to be in $PATH: Symmex is need 
    HImodel -v -g20:30 -e4 -oT2T_PB_set3_k40 T2T_PB_set3_k40
    ```

3. simulate data with different ploidy 

    ```bash 
    # e.g. simulate diploid data set, 15X coverage of each haplotype and 0.1% mutation from reference genome 
    HIsim chm13v2.0_noY.id_chr22.fa T2T_PB_set3_k40 -h -e -f -p.1,.1 -osim_chm13v2.0_noY_chr22c_dip -c30 -v -w100 -m16854 -s2412 -x1000 

    # e.g. simulate triploid data set, 10X coverage of each haplotype, and ploidy tree: .2(.1,.2),.3 
    # hap1: 1% mutation of a genome X that is a .2% mutation of the source genome. 
    # hap2: The second is a .2% mutation of X
    # hap3: and the third is a .3% mutation of the source.
    #
    #                           chr22 (source)
    #                           /    \
    #                   X (.2%)     hap3(.3%)
    #                   /     \
    #             hap1(.1%)   hap2(.2%)
    HIsim chm13v2.0_noY.id_chr22.fa T2T_PB_set3_k40 -h -e -f -p.2(.1,.2),.3 -osim_chm13v2.0_noY_chr22c_dip -c30 -v -w100 -m16854 -s2412 -x1000 

    ``` 

# Genome assemblies 

* human T2T assembly ([XYv2.0](https://github.com/marbl/CHM13/blob/master/Previous_assembly_release_HG002.md))
* potato assembly ([C88](http://solomics.agis.org.cn/potato/ftp/tetraploid))

back to [main kmer_workshop page](https://github.com/NBISweden/workshop-kmer-analysis)
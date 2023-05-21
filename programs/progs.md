Most tools that are used in the kmer workshop can be installed with the following 3 options.
We recommend to use the available Docker/Singularity container.

A) Use a singularity or docker container (recommended)
Install Singularity from sylabs.io.
The singularity container `kmer-workshop_v0.1.sif` can be downloaded from the [here](https://cloud.mpi-cbg.de/index.php/s/y3MG0kHYNEu0EaU) and can be set up in the following way:

```bash
# 1. create a directory for the container (full path)
SING_CONT_DIR=/proj/snic2022-6-208/private/martin/prog
mkdir -p ${SING_CONT_DIR}
cd ${SING_CONT_DIR}

# 2. download container file
curl 'https://cloud.mpi-cbg.de/index.php/s/y3MG0kHYNEu0EaU/download?path=%2F&files=kmer-workshop_v0.1.sif'  -o kmer-workshop_v0.1.sif

# 3. test container 
singularity exec --no-home --cleanenv ${SING_CONT_DIR}/kmer-workshop_v0.1.sif FastK
singularity exec --no-home --cleanenv ${SING_CONT_DIR}/kmer-workshop_v0.1.sif kat

# 4. to access files on your host system, you need to bind the host path(s) into the container (for more info: https://sylabs.io/guides/3.0/user-guide/bind_paths_and_mounts.html) 
singularity exec --no-home --cleanenv -B /proj/snic2022-6-208 ${SING_CONT_DIR}/kmer-workshop_v0.1.sif ls ${SING_CONT_DIR}/kmer-workshop_v0.1.sif

# 5. if everything works you can create an environment variable which contains the full container command call 
export SG="singularity exec --no-home --cleanenv -B /proj/snic2022-6-208 ${SING_CONT_DIR}/kmer-workshop_v0.1.sif"
$SG FastK
```

The docker container is available via dockerhub [pippel/kmer-workshop](https://hub.docker.com/repository/docker/pippel/kmer-workshop/general) and can be used in the following way.

```bash 
docker pull pippel/kmer-workshop:v0.1
# start docker container in interactive mode
sudo docker run -i --mount type=bind,source="/proj/snic2022-6-208",target=/proj/snic2022-6-208  --rm -t kmer-workshop:v0.1
```

back to [main kmer_workshop page](https://github.com/NBISweden/workshop-kmer-analysis)

# B) Use Anaconda ( ... and from source)
Install Anaconda from [https://docs.anaconda.com](https://docs.anaconda.com/anaconda/install/index.html#), create a new conda environment, and install the the software packages from the file `kmer-workshop.yaml`.
```bash
# 1. create new environment from package file 
conda create --name kmer_workshop --file kmer-workshop.yaml
# 2. load conda environment 
conda activate kmer_workshop
# 3. most of the kmer tools can be used now from the command line, e.g.  
FastK -help
```

But the following 2 software packages must be installed from source.
* [MERQURY.FK](https://github.com/thegenemyers/MERQURY.FK)
* [GENESCOPE.FK](https://github.com/thegenemyers/GENESCOPE.FK)

back to [main kmer_workshop page](https://github.com/NBISweden/workshop-kmer-analysis)

# C) Build from source 

* [merqury](https://github.com/marbl/merqury)
* [merfin](https://github.com/arangrhie/merfin)
* [FastK](https://github.com/thegenemyers/FASTK)
* [MERQURY.FK](https://github.com/thegenemyers/MERQURY.FK)
* [GENESCOPE.FK](https://github.com/thegenemyers/GENESCOPE.FK)
* [kat](https://github.com/TGAC/KAT)
* [jellyfish](https://github.com/gmarcais/Jellyfish)
* [genomescope2.0](https://github.com/tbenavi1/genomescope2.0)
* [smudgeplot](https://github.com/KamilSJaron/smudgeplot)

back to [main kmer_workshop page](https://github.com/NBISweden/workshop-kmer-analysis)

## [D) build container from scratch]

Just for completeness (and documentation) here are all steps to recreate the containers (docker and singularity): 

1. The initial kmer tools were installed in a clean conda environment. 
```bash 
conda create -n kmer-workshop
conda activate kmer-workshop
conda config --add channels conda-forge
conda config --add channels bioconda 

mamba install kat fastk genomescope2 meryl merqury smudgeplot kmer-jellyfish
```

2. Export (and adapt) conda environment  
```bash 
conda env export --from-history > kmer-workshop.yaml
```
The versions of some tools needed to be specified. This was manually done and the python version need to be fixed to 3.9.


4. run the build.sh script to create docker and singularity containers. 
```bash 
bash build.sh
```

5. **Troubleshooting**

In case you are building the singularity container on a compute cluster (as we did) you might get the following error: 
```bash 
INFO:    Starting build...
FATAL:   While performing build: conveyor failed to get: Error writing blob: write /tmp/bundle-temp-817373221/oci-put-blob352501850: no space left on device
``` 
If this is the case you can prepend the envionment variable SINGULARITY_TMPDIR=/path/onHost/WithEnough/Storage/tmp to the singularity build call in the build.sh script. E.g.:
``` bash  
SINGULARITY_TMPDIR=/path/onHost/WithEnough/Storage/tmp SINGULARITY_DISABLE_CACHE=true singularity build "$SINGULARITY_IMAGE" "docker-daemon://$DOCKER_TAG"
```

back to [main kmer_workshop page](https://github.com/NBISweden/workshop-kmer-analysis)

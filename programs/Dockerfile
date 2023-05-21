# start from base
FROM condaforge/mambaforge:4.9.2-5

MAINTAINER Martin Pippel <martin.pippel@nbis.se>

ARG NCPUS=1
ARG PREFIX="/usr/local"
ENV BINDIR="$PREFIX/bin"
ENV PATH="$BINDIR:$PATH"

# Configure tzdata (timezone)
ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Fix error message about locales (at least sometimes)
ENV LANGUAGE=C \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Provide our convenient build script to reduce verbosity
COPY ./build-and-install.sh ./kmer-workshop.yaml /opt/
COPY ./conda_init.sh /usr/local/bin

# Override default shell and use bash
SHELL ["/bin/bash", "--login", "-c"]

RUN mamba env update -n base --file /opt/kmer-workshop.yaml && conda clean -afy

# GENESCOPE.FK
ENV REPO=https://github.com/thegenemyers/GENESCOPE.FK.git
ENV BRANCH=380815c420f50171f9234a0fd1ff426b39829b91
RUN BUILD_DEPS="build-essential git" && \
    source conda_init.sh && conda activate base && \
    apt-get update && apt-get install -y $BUILD_DEPS && \
    git clone "$REPO" /opt/GENESCOPE.FK && \ 
    cd /opt/GENESCOPE.FK && \
    git checkout $BRANCH && \
    echo "install.packages('minpack.lm', repos = \"http://cran.us.r-project.org\")" > my_install.R && \
    echo "install.packages('argparse', repos = \"http://cran.us.r-project.org\")" >> my_install.R && \
    echo "install.packages('.', repos=NULL, type=\"source\")" >> my_install.R && \
    Rscript my_install.R && cp GeneScopeFK.R "$BINDIR" && \ 
    apt-get remove -y $BUILD_DEPS && apt-get autoremove -y && apt-get clean && rm -rf /opt/GENESCOPE.FK 

# MERQURY.FK
RUN BUILD_DEPS="build-essential git zlib1g-dev" && \
    source conda_init.sh && conda activate base && \
    apt-get update && apt-get install -y $BUILD_DEPS && \
    REPO=https://github.com/thegenemyers/MERQURY.FK.git \
    BRANCH=932b50f542e3e7ed03a372ad6650d76dba508d41 \
    /opt/build-and-install.sh MERQURY.FK make && \
    apt-get remove -y $BUILD_DEPS && apt-get autoremove -y && apt-get clean


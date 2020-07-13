# use ubuntu as base image
FROM ubuntu:20.04
# dependencies
# last 2 in install are for telegram
RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive apt-get -qq install -y locales wget python3.5 gcc make g++ zlib1g-dev zlib1g libyaml-syck-perl git bzip2 libbz2-dev liblzma-dev ncurses-dev sqlite3 r-base python3-minimal ncbi-blast+ python2 python2-dev libgsl0-dev libssl-dev libcurl4-openssl-dev > /dev/null && rm -rf /var/lib/apt/lists/* && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
# possibly qdbus, kdialog package, xargs package, and ssh
ENV LANG en_US.utf8
# install samtools
ENV SAMTOOLS_INSTALL_DIR=/opt/samtools
WORKDIR /tmp
RUN wget -q https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 && tar --bzip2 -xf samtools-1.9.tar.bz2
WORKDIR /tmp/samtools-1.9
RUN ./configure --enable-plugins --prefix=$SAMTOOLS_INSTALL_DIR -q && \
  make all all-htslib -s && \
  make install install-htslib -s
WORKDIR /
RUN ln -s $SAMTOOLS_INSTALL_DIR/bin/samtools /usr/bin/samtools && \
  rm -rf /tmp/samtools-1.9
RUN cd var && mkdir building;cd building;wget -q https://github.com/OpenGene/fastp/archive/v0.20.0.tar.gz &&\
 tar -xzf v0.20.0.tar.gz && \
 cd fastp* && \
 make -sj2 && \
 make install -s
# install minimap2 (based on minimap2 dockerfile)
RUN cd /usr/local/ && wget -q https://github.com/lh3/minimap2/releases/download/v2.17/minimap2-2.17.tar.bz2 \
    && tar -xjf minimap2-2.17.tar.bz2 \
    && cd minimap2-2.17  \
    && make -s \
    && mv minimap2 /usr/local/bin \
    && cd .. \
    && rm -rf minimap2-2.17.tar.bz2 minimap2-2.17 \
    && mkdir /pasteur

RUN cd var/building/ && git clone --depth 1 https://github.com/rvosa/bio-phylo && \
 cd bio-phylo && perl Makefile.PL && \
 make -s && make install -s

# https://github.com/samtools/bcftools/releases/download/1.9/bcftools-1.9.tar.bz2
RUN cd /var/building && wget -q https://github.com/samtools/bcftools/releases/download/1.10.2/bcftools-1.10.2.tar.bz2 && \
 tar -xjf bcftools-*tar.bz2 && cd bcftools-* && ./configure -q && make -sj2 && make install -s
# install all admixture dependencies
RUN true download plink '(needed for conversion)' && \
 cd /var/building/ && \
 wget -O- https://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20200616.zip| funzip > $HOME/plink && \
 chmod a+x $HOME/plink && \
 true 'download (and build fastStructure)' && \
 git clone --depth 1 https://github.com/rajanil/fastStructure  && \
 cd fastStructure  && \
 export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib CFLAGS="-I/usr/local/include" LDFLAGS="-L/usr/local/lib" && \
 true 'install pip so pip can install Cython (and numpy and scipy)' && \
 true 'so Cython (and numpy) could help us build fastStructure' && \
 wget -O- https://bootstrap.pypa.io/get-pip.py | python2 - && \
 true 'install Cython (and numpy and scipy) so Cython (and numpy) could help us build fastStructure' && \
 true 'and scipy could help fastStructure actually work' && \
 pip2 install Cython numpy scipy && \
 true 'build fastStructure library extensions' && \
 cd vars && python2 setup.py build_ext --inplace && cd .. && \
 true 'build fastStructure itself' && \
 python2 setup.py build_ext --inplace && \
 ln -s $PWD/structure.py /var/data/structure.py && \
 true 'structure is build and symlinked inside script directory' && \
 true 'download the tar.bzip2 file, and stdout, now -eXtract a bziped(j) tar and only the file bin/admixture to directory (-C) /usr/bin without creating the first directory (bin)'
 wget -O- https://anaconda.org/bioconda/admixture/1.3.0/download/linux-64/admixture-1.3.0-0.tar.bz2 | tar -xj bin/admixture -C /usr/bin --strip-components=1
# install all gene ontology dependencies
RUN wget "https://netix.dl.sourceforge.net/project/snpeff/snpEff_latest_core.zip" && \
 unzip snpEff_latest_core.zip && rm -r snpEff_latest_core.zip clinEff && \
 mv snpEff $HOME/

# install R dependencies
RUN R -q -e 'install.packages(c("BiocManager", "RSQLite", "dbplyr", "telegram", "ggplot2", "MASS", "ggrepel", "patchwork"), quiet = TRUE);BiocManager::install("Biostrings", quiet = TRUE)'
# BiocManager::install(c("limma", "GO.db", "clusterProfiler"), quiet = TRUE) for the deprecated GO-terms
# install.packages(c("future.batchtools", "future.apply")) and BiocManager::install(c("biomaRt", "org.Rn.eg.db"), quiet = TRUE) for within deprecated scripts

COPY ./ /var/data/
WORKDIR /var/data/
# RUN /var/data/fastqTo100SNPs.sh

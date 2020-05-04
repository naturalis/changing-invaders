# use ubuntu as base image
FROM ubuntu:20.04
# dependencies
RUN apt-get update && apt-get install -y locales wget python3.5 gcc make g++ zlib1g-dev zlib1g libyaml-syck-perl git bzip2 libbz2-dev liblzma-dev ncurses-dev && rm -rf /var/lib/apt/lists/* && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
# install samtools
ENV SAMTOOLS_INSTALL_DIR=/opt/samtools
WORKDIR /tmp
RUN wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 && tar --bzip2 -xf samtools-1.9.tar.bz2
WORKDIR /tmp/samtools-1.9
RUN ./configure --enable-plugins --prefix=$SAMTOOLS_INSTALL_DIR && \
  make all all-htslib && \
  make install install-htslib
WORKDIR /
RUN ln -s $SAMTOOLS_INSTALL_DIR/bin/samtools /usr/bin/samtools && \
  rm -rf /tmp/samtools-1.9
RUN cd var && mkdir building;cd building;wget https://github.com/OpenGene/fastp/archive/v0.20.0.tar.gz &&\
 tar -xzf v0.20.0.tar.gz && \
 cd fastp* && \
 make -j2 && \
 make install
# install minimap2 (based on minimap2 dockerfile)
RUN cd /usr/local/ && wget https://github.com/lh3/minimap2/releases/download/v2.17/minimap2-2.17.tar.bz2 \
    && tar -xjf minimap2-2.17.tar.bz2 \
    && cd minimap2-2.17  \
    && make \
    && mv minimap2 /usr/local/bin \
    && cd .. \
    && rm -rf minimap2-2.17.tar.bz2 minimap2-2.17 \
    && mkdir /pasteur

RUN cd var/building/ && git clone --depth 1 https://github.com/rvosa/bio-phylo && \
 cd bio-phylo && perl Makefile.PL && \
 make && make install
#
COPY ./ /var/data/
WORKDIR /var/data/
# RUN /var/data/fastqTo100SNPs.sh

FROM ubuntu:18.04

# File Author / Maintainer
MAINTAINER Jon Bråte <jon.brate@fhi.no>

RUN apt-get update && apt-get -y upgrade && \
	apt-get install -y build-essential wget unzip \
		libncurses5-dev zlib1g-dev libbz2-dev liblzma-dev libcurl3-dev && \
	apt-get clean && apt-get purge && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /usr/src

# Install Samtools
RUN wget https://github.com/samtools/samtools/releases/download/1.15/samtools-1.15.tar.bz2 && \
	tar jxf samtools-1.15.tar.bz2 && \
	rm samtools-1.15.tar.bz2 && \
	cd samtools-1.15 && \
	./configure --prefix $(pwd) && \
	make

ENV PATH=${PATH}:/usr/src/samtools-1.15

# Install bcftools
RUN wget https://github.com/samtools/bcftools/releases/download/1.15.1/bcftools-1.15.1.tar.bz2 && \
	tar jxf bcftools-1.15.1.tar.bz2 && \
	rm bcftools-1.15.1.tar.bz2 && \
	cd bcftools-1.15.1 && \
	./configure --prefix $(pwd) && \
	make

ENV PATH=${PATH}:/usr/src/bcftools-1.15.1

# Install Tanoti mapper from https://github.com/vbsreenu/Tanoti
# Copy Tanoti
COPY Tanoti/bin/ /usr/bin/
RUN chmod +x /usr/bin/*

# Install Bowtie2
RUN wget https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.4.5/bowtie2-2.4.5-linux-x86_64.zip && \
	unzip bowtie2-2.4.5-linux-x86_64.zip && \
	rm bowtie2-2.4.5-linux-x86_64.zip && \
	cd bowtie2-2.4.5-linux-x86_64

ENV PATH=${PATH}:/usr/src/bowtie2-2.4.5-linux-x86_64

# Install Python3
RUN apt-get update \
  && apt-get install -y python3-pip python3-dev \
  && cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip

# Install bedtools
RUN wget https://github.com/arq5x/bedtools2/releases/download/v2.29.1/bedtools-2.29.1.tar.gz && \
	tar -zxvf bedtools-2.29.1.tar.gz && \
	cd bedtools2 && \
	make

ENV PATH=${PATH}:/usr/src/bedtools2/bin/

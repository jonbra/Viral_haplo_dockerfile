FROM ubuntu:22.04

# File Author / Maintainer
MAINTAINER Jon Bråte <jon.brate@fhi.no>

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y upgrade && \
	apt-get install -y build-essential wget unzip \
		autoconf python3-dev python3-pip libncurses5-dev zlib1g-dev libbz2-dev liblzma-dev libcurl3-dev git-all && \
	apt-get clean && apt-get purge && \
	pip3 install --upgrade pip && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /usr/src

# Install Python3
#RUN apt-get update \
#  && apt-get install -y python3-pip python3-dev \
#  && cd /usr/local/bin \
#  && ln -s /usr/bin/python3 python \
#  && pip3 install --upgrade pip

# Install HTSlib
RUN cd /usr/src/ && \
	wget https://github.com/samtools/htslib/releases/download/1.19.1/htslib-1.19.1.tar.bz2 && \
    	tar xvf htslib-1.19.1.tar.bz2 && \
   	 cd htslib-1.19.1/ && \
    	./configure && \
    	make && \
    	make install && \
    	cd ../ && \
    	rm htslib-1.19.1.tar.bz2

ENV PATH=${PATH}:/usr/src/htslib-1.19.1

# Install iVar
RUN cd /usr/src/ && \
	git clone https://github.com/andersen-lab/ivar.git && \
	cd ivar/ && \
	./autogen.sh && \
	./configure && \
	make && \
	make install

ENV PATH=${PATH}:/usr/src/ivar

# Install Samtools
RUN cd /usr/src/ && \
	wget https://github.com/samtools/samtools/releases/download/1.19.2/samtools-1.19.2.tar.bz2 && \
	tar jxf samtools-1.19.2.tar.bz2 && \
	rm samtools-1.19.2.tar.bz2 && \
	cd samtools-1.19.2 && \
	./configure --prefix $(pwd) && \
	make

ENV PATH=${PATH}:/usr/src/samtools-1.19.2

# Install bcftools
RUN cd /usr/src/ && \
	wget https://github.com/samtools/bcftools/releases/download/1.15.1/bcftools-1.15.1.tar.bz2 && \
	tar jxf bcftools-1.15.1.tar.bz2 && \
	rm bcftools-1.15.1.tar.bz2 && \
	cd bcftools-1.15.1 && \
	./configure --prefix $(pwd) && \
	make

ENV PATH=${PATH}:/usr/src/bcftools-1.15.1

# Install Tanoti mapper from https://github.com/vbsreenu/Tanoti
RUN cd /usr/src/ && \
	wget https://github.com/vbsreenu/Tanoti/archive/refs/heads/master.zip && \
	unzip master.zip && \
	rm master.zip && \
	cd Tanoti-master/src && \
	bash compile_tanoti.sh && \
	cp * /usr/src/

RUN chmod +x /usr/src/*
ENV PATH=${PATH}:/usr/src/

# Install Bowtie2
RUN cd /usr/src/ && \
	wget https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.4.5/bowtie2-2.4.5-linux-x86_64.zip && \
	unzip bowtie2-2.4.5-linux-x86_64.zip && \
	rm bowtie2-2.4.5-linux-x86_64.zip && \
	cd bowtie2-2.4.5-linux-x86_64

ENV PATH=${PATH}:/usr/src/bowtie2-2.4.5-linux-x86_64

# Install bedtools
RUN cd /usr/src/ && \
	wget https://github.com/arq5x/bedtools2/releases/download/v2.31.0/bedtools-2.31.0.tar.gz && \
	tar -zxvf bedtools-2.31.0.tar.gz && \
	cd bedtools2 && \
	make

ENV PATH=${PATH}:/usr/src/bedtools2/bin/

# Install OpenJDK-18 (see here https://stackoverflow.com/questions/31196567/installing-java-in-docker-image)
RUN apt-get update && \
    apt-get install -y openjdk-18-jdk && \
    apt-get clean;
    
# Fix certificate issues
RUN apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;

# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-18-openjdk-amd64/
RUN export JAVA_HOME


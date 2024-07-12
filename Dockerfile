FROM ubuntu:22.04

# install git
RUN apt-get update \
    && apt-get upgrade \
    && apt-get install -y --no-install-recommends wget sudo binutils git \
    lsb-release nano gdb build-essential gcc-9 g++-9 && \
    rm -rf /var/lib/apt/lists/*

RUN sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 10 \
    && sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 1 \
    && sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 10 \
    && sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 1

RUN wget --no-check-certificate https://www.python.org/ftp/python/2.7.9/Python-2.7.9.tgz \
    && sudo tar xzf Python-2.7.9.tgz \
    && cd Python-2.7.9 \
    && sudo ./configure --enable-optimizations \
    && sudo make altinstall \
    && sudo update-alternatives --install /usr/bin/python python /usr/local/bin/python2.7 10

RUN sudo apt update \
    && sudo apt install -y software-properties-common \
    && sudo apt-add-repository universe \
    && sudo apt-get update \
    && sudo apt-get install -y python-pip \
    && update-alternatives --install /usr/bin/pip pip /usr/bin/pip2 10 \
    && pip install ply

ENV PYTHONPATH=/usr/local/lib/python2.7/dist-packages:$PYTHONPATH

ENV GIT_SSL_NO_VERIFY=false

COPY connectal /root/connectal/
COPY fpgamake /root/fpgamake/

ADD https://github.com/B-Lang-org/bsc/releases/download/2023.01/bsc-2023.01-ubuntu-22.04.tar.gz /root/
RUN cd /root/ && tar -xf bsc-2023.01-ubuntu-22.04.tar.gz \
    && mkdir -p /opt/tools/bsc \
    && mv bsc-2023.01-ubuntu-22.04 /opt/tools/bsc/bsc-2023.01-ubuntu-22.04 \
    && cd /opt/tools/bsc && ln -s bsc-2023.01-ubuntu-22.04 latest
ENV PATH="/opt/tools/bsc/latest/bin:$PATH"
ENV BLUESPECDIR=/opt/tools/bsc/latest/lib

RUN cd /root/ && git clone https://github.com/B-Lang-org/bsc-contrib \
    && cd bsc-contrib && make
ENV BSC_CONTRIB_DIR=/root/bsc-contrib/inst/lib
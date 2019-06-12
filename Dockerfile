# install cuda, cudnn
FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04
MAINTAINER Yi Zhu

WORKDIR "/"

# Set the locale
# See https://stackoverflow.com/questions/28405902/how-to-set-the-locale-inside-a-ubuntu-docker-container
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

# install dependencies
RUN apt-get update --fix-missing && \
    apt-get install -y wget git vim sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    chmod -R 777 /opt/conda/ && \
    conda clean -tipsy

# create a new conda environment from yml
COPY main.yml /tmp/main.yml
RUN conda env create -f /tmp/main.yml && rm /tmp/main.yml
#RUN conda create -y --name main 

# Create user with appropriate GID
ARG UNAME=dk-yz568
ARG GNAME=dk-grp
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID $GNAME
RUN useradd -m -u $UID -g $GID -s /bin/bash $UNAME && echo "${UNAME}:${UNAME}" | chpasswd && adduser $UNAME sudo
USER $UNAME

# activate the environment
RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate main" >> ~/.bashrc

WORKDIR /home/$UNAME
CMD [ "/bin/bash" ]

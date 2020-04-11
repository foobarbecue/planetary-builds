FROM ubuntu:18.04
SHELL ["/bin/bash", "-c"]
RUN apt-get update -y
RUN apt-get install -y gcc-5 g++-5 gfortran tcsh libtool-bin binutils     \
   m4 autoconf automake libssl-dev wget curl git subversion zip    \
   xorg-dev libx11-dev libxext-dev libxmu6 libxmu-dev libxi-dev    \
   '^libxcb.*-dev' libx11-xcb-dev libgl1-mesa-dev libglu1-mesa-dev \
   freeglut3-dev libgtk2.0-dev texlive-latex-base graphviz texinfo \
   git

#Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN bash Miniconda3-latest-Linux-x86_64.sh -b
ENV PATH="/root/miniconda3/bin:$PATH"
RUN conda init bash # for some reason this isn't working. Calls to conda in lines below don't work.

#ISIS
COPY isis_environment.yml /
RUN conda env create -n isis3 -f /isis_environment.yml
RUN echo "source activate isis3" > ~/.bashrc
RUN git clone --recurse-submodules https://github.com/USGS-Astrogeology/ISIS3.git
RUN cd /ISIS3 && git checkout 989134b28fca90b78a457dd0b73470d996d92997
RUN cd ISIS3 && mkdir build install
ENV ISISROOT /ISIS3/build
RUN cd /ISIS3/build && source activate isis3 && cmake DJP2KFLAG=OFF -DCMAKE_BUILD_TYPE=RELEASE -GNinja ../isis
RUN cd /ISIS3/build && source activate isis3 && ninja install

#ASP
# set system gcc and g++ to version 5
RUN rm /usr/bin/gcc /usr/bin/g++ && ln -s /usr/bin/gcc-5 /usr/bin/gcc && ln -s /usr/bin/g++-5 /usr/bin/g++
RUN git clone https://github.com/NeoGeographyToolkit/StereoPipeline
RUN cd StereoPipeline && git checkout v2.6.2
RUN mkdir /projects && cd /projects && git clone https://github.com/NeoGeographyToolkit/BinaryBuilder.git
RUN cd /projects/BinaryBuilder && source activate isis3 && source ./auto_build/utils.sh && ./build.py


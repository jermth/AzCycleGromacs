#! /bin/bash

if [ ! -f /opt/intel/compilers_and_libraries_2017.2.174/linux/bin/compilervars.sh ] || [ ! -f /opt/intel/compilers_and_libraries_2017.2.174/linux/mpi/intel64/bin/mpivars.sh ]; then
    echo "Intel MPI library 2017 Release 2 not found. https://software.intel.com/en-us/intel-mpi-library"
    exit 1
fi

yum groupinstall -y "Development Tools" "Development Libraries"

yum install -y cmake zlib-devel libxml2 libxml2-dev

# install boost

BOOST_VERSION=1_60_0
BOOST_DOTTED_VERSION=$(echo $BOOST_VERSION | tr _ .)
wget -q -O - https://sourceforge.net/projects/boost/files/boost/${BOOST_DOTTED_VERSION}/boost_${BOOST_VERSION}.tar.gz/download | tar -xzf -
cd boost_${BOOST_VERSION}
./bootstrap.sh --prefix=/usr/local --with-libraries=filesystem,system,test 
./b2 -d0 -j"${NUM_CPUS}" install
/sbin/ldconfig /usr/local/lib /usr/lib/x86_64-linux-gnu /usr/lib
cd ..
rm -rf ./boost_${BOOST_VERSION}

# build GROMACS

GROMACS_VERSION="5.1.4"
GROMACS_SRC_DIR=/tmp/gromacs-${GROMACS_VERSION}
GROMACS_BUILD_DIR=/tmp/gromacs-${GROMACS_VERSION}-build
GROMACS_INSTALL_DIR=/opt/gromacs-${GROMACS_VERSION}

cd /tmp
wget ftp://ftp.gromacs.org/pub/gromacs/gromacs-${GROMACS_VERSION}.tar.gz

tar -xzvf gromacs-${GROMACS_VERSION}.tar.gz
mkdir ${GROMACS_BUILD_DIR}
cd ${GROMACS_BUILD_DIR}

# source Intel MPI env
source /opt/intel/compilers_and_libraries_2017.2.174/linux/bin/compilervars.sh
source /opt/intel/compilers_and_libraries_2017.2.174/linux/bin/compilervars.sh intel64
source /opt/intel/compilers_and_libraries_2017.2.174/linux/mpi/intel64/bin/mpivars.sh
source /opt/intel/compilers_and_libraries_2017.2.174/linux/mpi/intel64/bin/mpivars.sh 

CC=mpicc CXX=mpicxx cmake $GROMACS_SRC_DIR  -DGMX_OPENMP=ON -DGMX_MPI=ON -DGMX_BUILD_OWN_FFTW=ON -DGMX_PREFER_STATIC_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DGMX_BUILD_UNITTESTS=OFF -DCMAKE_INSTALL_PREFIX=$GROMACS_INSTALL_DIR
NUM_CPUS=$( cat /proc/cpuinfo | awk '/^processor/{print $3}' | tail -1 )

make -j"${NUM_CPUS}"
make install

cd /opt
tar cfz  gromacs-${GROMACS_VERSION}.tgz gromacs-${GROMACS_VERSION}




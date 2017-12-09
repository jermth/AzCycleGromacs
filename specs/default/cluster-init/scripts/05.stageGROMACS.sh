#! /bin/bash

tar xf $CYCLECLOUD_SPEC_PATH/files/gromacs-5.1.4.tgz -C /mnt/resource

# if this is the shared file, download the GROMACS benchmarks
if  /opt/cycle/jetpack/bin/jetpack config run_list | grep -q sge_master; then
    mkdir -p /shared/gromacs_example
    pushd $CYCLECLOUD_SPEC_PATH/files/
    wget http://ftp.gromacs.org/pub/benchmarks/water_GMX50_bare.tar.gz
    tar xf water_GMX50_bare.tar.gz -C /shared/gromacs_example
    popd

    cp $CYCLECLOUD_SPEC_PATH/files/run_gromacs.sh /shared/gromacs_example/
fi

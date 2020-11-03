#!/bin/bash
#SBATCH --time=00:10:00
#SBATCH --output=/home/vol01/scarf981/logs/%J.log
#SBATCH --job-name=build-mpi4py
#SBATCH --partition=scarf
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2

# Setup MPI
module load OpenMPI/4.0.0-GCC-8.2.0-2.31.1
export OMPI_MCA_btl="openib,tcp,vader,self"
export OMPI_MCA_btl_openib_allow_ib=1

# Configure logging prefix
PS4='+ $(date "+%Y-%m-%d %H:%M:%S")\011 '
set -x
set -e

# Display job host environment
pwd; hostname; date
which mpirun
which mpicc
singularity --version

# Get the Singularity container environment
mkdir -p "$HOME/images"
IMAGE="$HOME/images/opt-id-env-v3.sif"
set +e
singularity pull $IMAGE shub://JossWhittle/Opt-ID-Env:env-v3  
set -e

# Inject the host environments OpenMPI installation into the container environment
HOST_PATH=$(dirname $(which mpicc))
CONT_PATH=$(singularity exec --bind /apps $IMAGE bash -c 'echo $PATH')
export SINGULARITYENV_PATH="$HOST_PATH:$CONT_PATH"

# Use the Singularity container environment to build MPI4Py and store in the host environment
set +e
rm -rf build
set -e
DIR=$(pwd)
mkdir -p build && cd build
if [[ ! -f "$HOME/downloads/mpi4py-3.0.3.tar.gz" ]]; then
    wget https://bitbucket.org/mpi4py/mpi4py/downloads/mpi4py-3.0.3.tar.gz -P $HOME/downloads
fi
tar -zxf $HOME/downloads/mpi4py-3.0.3.tar.gz -C .
cd mpi4py-3.0.3
singularity exec --bind /apps $IMAGE python setup.py build --mpicc=$(which mpicc) --build-base=./
mkdir -p $HOME/bin
rm -rf $HOME/bin/mpi4py
mv lib.linux-x86_64-3.8/mpi4py $HOME/bin/mpi4py
cd $DIR
rm -rf build

# Inject the host environments MPI4Py installation into the container environment
HOST_PYTHONPATH=$HOME/bin
CONT_PYTHONPATH=$(singularity exec --bind /apps $IMAGE bash -c 'echo $PYTHONPATH')
export SINGULARITYENV_PYTHONPATH="$HOST_PYTHONPATH:$CONT_PYTHONPATH"

# Execute the MPI job using the Singulartiy container image
mpirun singularity exec --bind /apps $IMAGE python test.py  

echo 'HALTING'

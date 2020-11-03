#!/bin/bash
#SBATCH --time=00:10:00
#SBATCH --output=/home/vol01/scarf981/logs/%J.log
#SBATCH --job-name=test-opt-id-env
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

if [ ! -d "$HOME/bin/mpi4py" ]; then
    echo "MPI4Py not found in ~/bin/ directory! Submit 'sbatch job-build.sh'"
    exit 1
fi

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

# Inject the host environments MPI4Py installation into the container environment
HOST_PYTHONPATH=$HOME/bin
CONT_PYTHONPATH=$(singularity exec --bind /apps $IMAGE bash -c 'echo $PYTHONPATH')
export SINGULARITYENV_PYTHONPATH="$HOST_PYTHONPATH:$CONT_PYTHONPATH"

# Execute the MPI job using the Singulartiy container image
mpirun singularity exec --bind /apps $IMAGE python test.py  

echo 'HALTING'

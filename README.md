# Opt-ID-Env-SCARF-Test
Tests the use of the Singularity environment on the STFC SCARF cluster needed by the Opt-ID software developed by the Rosalind Franklin Institute and Diamond Light Source. https://github.com/DiamondLightSource/Opt-ID

Clone this repository into a `jobs` directory within the home directory on SCARF.

From `~/jobs/Opt-ID-Env-SCARF-Test/` submit `sbatch job-build.sh` to pull the Singularity environment image `shub://JossWhittle/Opt-ID-Env:env-v3` and use it to compile the MPI4Py python package using OpenMPI 4.0.0 hoisted from the SCARF host into the container, and then executes `test.py` using 4 processes (2 nodes with 2 processes per node). This configures the following environment.

```
~/
	jobs/
		Opt-ID-Env-SCARF-Test/
			job-build.sh
			job-test.sh
			test.py

	images/
		opt-id-env-v3.sif

	bin/
		mpi4py/*

	logs/
		*.log
```

From `~/jobs/Opt-ID-Env-SCARF-Test/` submit `sbatch job-test.sh` to execute `test.py` using 4 processes (2 nodes with 2 processes per node) using the Singularity container and the pre-compiled MPI4Py.

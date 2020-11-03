# Copyright 2017 Diamond Light Source
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
# either express or implied. See the License for the specific
# language governing permissions and limitations under the License.

import h5py
import pandas as pd
import numpy as np
import scipy 
import matplotlib.pyplot as plt
import jax.numpy as jnp
import radia as rad
import socket

from mpi4py import MPI
comm = MPI.COMM_WORLD

comm.Barrier()

if comm.rank == 0:
	print(f'{comm.rank:04d} of {comm.size:04d} : Test Radia on each process...')

comm.Barrier() 

print(f'{comm.rank:04d} of {comm.size:04d} : Radia version: {rad.UtiVer()}')

rad.UtiDelAll()
magnet   = rad.ObjRecMag([0,0,0], [1,1,1], [0,1,0])
observed = np.array(rad.Fld(magnet, 'b', [1,2,3]), dtype=np.float32)
expected = np.array([0.0006504201540729257, -0.00021819974895862903, 0.0019537852236147252], dtype=np.float32)

print(f'{comm.rank:04d} of {comm.size:04d} : Radia success: {np.allclose(observed, expected)}')

comm.Barrier()

if comm.rank == 0:
	print(f'{comm.rank:04d} of {comm.size:04d} : Test communication on each process...')

comm.Barrier() 

if comm.rank == 0:
    values = np.arange(16).astype(np.float32)
    print(f'{comm.rank:04d} of {comm.size:04d} : {socket.gethostname()} Broadcasting values {values} to rank 0')
    comm.Bcast(values, root=0) 

else:
    values = np.zeros((16,), dtype=np.float32)
    comm.Bcast(values, root=0)
    print(f'{comm.rank:04d} of {comm.size:04d} : {socket.gethostname()} has values {values}')

comm.Barrier()

#!/bin/bash -l
#SBATCH --job-name=job_name
#SBATCH --time=00:30:00
#SBATCH --nodes=32
#SBATCH --ntasks-per-core=2
#SBATCH --ntasks-per-node=12
#SBATCH --cpus-per-task=2
#SBATCH --partition=normal
#SBATCH --constraint=gpu
#SBATCH --account=d108

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export CRAY_CUDA_MPS=1
module load daint-gpu
conda activate legate
cd ~/legate/legate.numpy/
echo "attempting launch"
bash sweep.sh -j
echo "launch done"

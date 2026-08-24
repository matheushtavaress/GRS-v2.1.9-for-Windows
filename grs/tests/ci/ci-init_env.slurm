#!/bin/bash
#
#SBATCH --job-name=grs-init_env
#SBATCH --time=00:30:00
#SBATCH -N 1
#SBATCH -n 4
#SBATCH --mem-per-cpu=4G
#SBATCH --account=campus

#cnes_level2

cd ${MY_JOB_WORKDIR}/grs2
module load conda
conda-lock install -p /work/scratch/data/${USER}/.conda/envs/grs2_tests gitlab-ci/conda-lock.yml
conda activate /work/scratch/data/${USER}/.conda/envs/grs2_tests
pip install -U pip
pip install .[dev]
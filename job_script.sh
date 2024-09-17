#!/bin/bash
#PBS -N osu_bench_joao
#PBS -l nodes=2:ppn=48
#PBS -l walltime=00:10:00
#PBS -q parexp
#PBS -m abe
#PBS -o /home/lovelace/proj/proj1011/j263792/hpccm_osu_benchmark/output_file_parexp_10.txt
#PBS -e /home/lovelace/proj/proj1011/j263792/hpccm_osu_benchmark/error_file_parexp_10.txt

cd $PBS_O_WORKDIR

# Carregar os módulos necessários
module load openmpi/5.0.5-gcc-12.2.0
module load sage/container-singularity

mpirun -np 2 -map-by ppr:1:node -mca pml ucx --mca btl ^vader,tcp,openib,uct -x UCX_NET_DEVICES=mlx5_0:1 \
singularity exec osu-benchmark.sif /usr/local/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw
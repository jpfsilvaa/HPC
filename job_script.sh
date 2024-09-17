#!/bin/bash
#PBS -N osu_bench_joao
#PBS -l nodes=2:ppn=128
#PBS -l walltime=00:10:00
#PBS -q paralela
#PBS -m abe
#PBS -o /home/lovelace/proj/proj1011/j263792/hpccm_osu_benchmark/output_file_paralela_8.txt
#PBS -e /home/lovelace/proj/proj1011/j263792/hpccm_osu_benchmark/error_file_paralela_8.txt

cd $PBS_O_WORKDIR

# Carregar os módulos necessários
module load openmpi/5.0.5-gcc-12.2.0
module load sage/container-singularity

export OMPI_MCA_pml=ucx
export OMPI_MCA_btl_openib_allow_ib=1
export OMPI_MCA_btl=^vader,tcp,sm,self
export UCX_NET_DEVICES=mlx5_0:1
export UCX_TLS=rc,sm,self
export UCX_RC_RX_QUEUE_LEN=1024

mpirun -np 2 -map-by ppr:1:node -mca pml ucx --mca btl ^vader,tcp,openib,uct -x UCX_NET_DEVICES=mlx5_0:1 \
singularity exec osu-benchmark.sif /usr/local/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw
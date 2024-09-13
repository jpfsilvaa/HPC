#!/bin/bash
#PBS -N osu_bw_benchmark             # Nome do job
#PBS -l nodes=2:ppn=1                # Solicita 2 nós com 1 processador por nó
#PBS -l walltime=00:10:00            # Tempo máximo de execução
#PBS -q testes                       # Fila para testes
#PBS -o /home/lovelace/proj/proj1011/j263792/hpccm_osu_benchmark/output_file.txt  # Arquivo de saída
#PBS -e /home/lovelace/proj/proj1011/j263792/hpccm_osu_benchmark/error_file.txt   # Arquivo de erro

# Carregar os módulos necessários
module load openmpi/5.0.5-gcc-12.2.0
module load sage/container-singularity

# Ativar o InfiniBand via UCX
export OMPI_MCA_pml=ucx
export OMPI_MCA_btl_openib_allow_ib=1
export UCX_NET_DEVICES=mlx5_0:1

# Executar o benchmark usando a imagem Singularity
singularity exec /home/lovelace/proj/proj1011/j263792/hpccm_osu_benchmark/osu-benchmark.sif \
mpirun -np 2 -ppn 1 osu_bw
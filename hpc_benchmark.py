from hpccm import Stage
from hpccm.building_blocks import gnu, cmake, generic_autotools, openmpi, mlnx_ofed
from hpccm.primitives import baseimage, shell, environment
from hpccm.building_blocks import apt_get, ucx

# hpccm --recipe hpc_benchmark.py --format docker > Dockerfile
# sudo docker build -t osu-benchmark:latest -f Dockerfile .
# sudo singularity build osu-benchmark.sif docker-daemon://osu-benchmark:latest 

Stage0 += baseimage(image='ubuntu:22.04', _as='build')
Stage0 += apt_get(ospackages=['wget', 'make', 'tar', 'git', 
                              'ca-certificates', 'autoconf', 
                              'autotools-dev', 'libtool', 
                              'automake', 'python3', 'python3-pip'])

compiler = gnu(version='12')
Stage0 += compiler
Stage0 += cmake(eula=True)
Stage0 += mlnx_ofed(version='5.8-3.0.7.0')

Stage0 += shell(commands=[
    'wget https://github.com/openucx/ucx/releases/download/v1.14.0/ucx-1.14.0.tar.gz',
    'tar -xzf ucx-1.14.0.tar.gz',
    'cd ucx-1.14.0',
    './configure --prefix=/usr/local/ucx',
    'make',
    'make install',
])

Stage0 += openmpi(version='5.0.5', 
                  infiniband=True,
                  cuda=False,
                  prefix='/usr/local/openmpi',
                  ucx='/usr/local/ucx')

Stage0 += shell(commands=[
    'wget http://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-5.6.2.tar.gz',
    'tar zxvf ./osu-micro-benchmarks-5.6.2.tar.gz',
    'cd osu-micro-benchmarks-5.6.2/',
    './configure CC=/usr/local/openmpi/bin/mpicc CXX=/usr/local/openmpi/bin/mpicxx --prefix=/usr/local/osu',
    'make',
    'make install'
])

Stage0 += environment(variables={
    'PATH': '/usr/local/openmpi/bin:$PATH',
    'LD_LIBRARY_PATH': '/usr/local/openmpi/lib:$LD_LIBRARY_PATH'
})
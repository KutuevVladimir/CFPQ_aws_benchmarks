#!/bin/sh

if [ "$(id -u)" != 0 ] ; then
    sudo "$0" "$@"
    exit $?
fi

set -ex

download_dataset()
{
	URL="https://docs.google.com/uc?export=download&id=$1"
	wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate "${URL}" -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=$1" -O "$2" && rm -rf /tmp/cookies.txt
}

# shellcheck source=./BENCHMARKS.config
. ./BENCHMARKS.config

# Git, Python, Pip, CMake
echo "Installing wget, git, python3, pip3, cmake"
apt update
apt upgrade -y
DEBIAN_FRONTEND=noninteractive apt install -y \
	wget \
	git \
	python3 \
	python3-pip \
	cmake \
	make \
	libomp-dev

# SuiteSparse:GraphBLAS
echo "Installing SuiteSparse:GraphBLAS"
SS_BURBLE=0
SS_COMPACT=0

git clone --branch "${SS_RELEASE}" --single-branch --depth=1 https://github.com/DrTimothyAldenDavis/GraphBLAS.git
cd GraphBLAS/build
cmake .. -DGB_BURBLE="${SS_BURBLE}" -DGBCOMPACT="${SS_COMPACT}"
make "-j$(nproc)"
make install
export LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"
cd ../..

# pygraphblas
echo "Installing pygraphblas"

git clone --branch "${PYGRAPHBLAS_VERSION}" --single-branch https://github.com/Graphegon/pygraphblas.git
echo "Suppress problem with types.py"
cp -f types.py pygraphblas/pygraphblas
cd pygraphblas
pip3 install numpy==1.20
python3 setup.py install
cd ..

# CFPQ_PyAlgo
echo "Installing CFPQ_PyAlgo"

git clone --branch "${CFPQ_BRANCH}" --single-branch --recurse-submodules https://github.com/JetBrains-Research/CFPQ_PyAlgo.git
cd CFPQ_PyAlgo

echo "Installing deps/"
cd deps/CFPQ_Data
pip3 install -r requirements.txt
python3 setup.py install

cd ../../
pip3 install -r requirements.txt

echo "Test CFPQ_PyAlgo"
python3 -m pytest test -v -m "CI"

# Dataset
echo "Preparing benchmark dataset"

cd benchmark
download_dataset "${SMALL_DATASET_FILE_ID}" "${SMALL_DATASET_FILE_NAME}"
tar -xvf "${SMALL_DATASET_FILE_NAME}"
download_dataset "${LARGE_DATASET_FILE_ID}" "${LARGE_DATASET_FILE_NAME}"
tar -xvf "${LARGE_DATASET_FILE_NAME}"
cd large
download_dataset "${LARGE_DATASET_CHUNK_1_FILE_ID}" "${LARGE_DATASET_CHUNK_1_FILE_NAME}"
tar -xvf "${LARGE_DATASET_CHUNK_1_FILE_NAME}"


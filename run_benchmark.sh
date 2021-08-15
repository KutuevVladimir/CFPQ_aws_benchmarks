#!/bin/sh

# shellcheck source=./BENCHMARKS.config
. ./BENCHMARKS.config

cd CFPQ_PyAlgo || return 1
INSTANCE_CORES_THREADS="$(cat /proc/cpuinfo | grep "cores" |uniq|awk '{print $4}')_$(cat /proc/cpuinfo | grep -c "processor")"

export LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"

mkdir -p "results/small_${INSTANCE_CORES_THREADS}"
echo "Benchmarking SMALL_GRAPHS" && python3 -m benchmark.start_benchmark -ms_algo "${MS_ALGORITHM}" -data_dir "${SMALL_GRAPHS_DATASET_PATH}" -all_pairs_rounds "${SMALL_GRAPHS_ALL_PAIRS_ROUNDS}" -result_dir "results/small_${INSTANCE_CORES_THREADS}"

mkdir -p "results/large_${INSTANCE_CORES_THREADS}"
echo "Benchmarking LARGE_GRAPHS" && python3 -m benchmark.start_benchmark -ms_algo "${MS_ALGORITHM}" -data_dir "${LARGE_GRAPHS_DATASET_PATH}" -all_pairs_rounds "${LARGE_GRAPHS_ALL_PAIRS_ROUNDS}" -result_dir "results/large_${INSTANCE_CORES_THREADS}" -ms_chunks 1


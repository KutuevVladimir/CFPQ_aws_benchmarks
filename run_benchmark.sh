#!/bin/sh

# shellcheck source=./BENCHMARKS.config
. ./BENCHMARKS.config

cd CFPQ_PyAlgo || return 1
INSTANCE_CORES_THREADS="$(cat /proc/cpuinfo | grep "cores" |uniq|awk '{print $4}')_$(cat /proc/cpuinfo | grep -c "processor")"

mkdir -p "results/small_${INSTANCE_CORES_THREADS}"
echo "Benchmarking SMALL_GRAPHS" && python3 -m benchmark.start_benchmark -ms_algo "${MS_ALGORITHM}" -data_dir "${SMALL_GRAPHS_DATASET_PATH}" -all_pairs_rounds "${SMALL_GRAPHS_ALL_PAIRS_ROUNDS}" -ms_worst_rounds "${SMALL_GRAPHS_MS_WORST_ROUNDS}" -ms_min_reachable_vertices "${SMALL_GRAPHS_MS_MIN_REACHABLE_VERTICES}" -ms_worst_count "${SMALL_GRAPHS_MS_WORST_VERTICES_COUNT}" -result_dir "results/small_${INSTANCE_CORES_THREADS}"

mkdir -p "results/large_${INSTANCE_CORES_THREADS}"
echo "Benchmarking LARGE_GRAPHS" && python3 -m benchmark.start_benchmark -ms_algo "${MS_ALGORITHM}" -data_dir "${LARGE_GRAPHS_DATASET_PATH}" -all_pairs_rounds "${LARGE_GRAPHS_ALL_PAIRS_ROUNDS}" -ms_worst_rounds "${LARGE_GRAPHS_MS_WORST_ROUNDS}" -ms_min_reachable_vertices "${LARGE_GRAPHS_MS_MIN_REACHABLE_VERTICES}" -ms_worst_count "${LARGE_GRAPHS_MS_WORST_VERTICES_COUNT}" -result_dir "results/large_${INSTANCE_CORES_THREADS}"


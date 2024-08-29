#!/bin/bash

PWD=$(pwd)
SLOT_DIR=/app
VLLM_DIR=$SLOT_DIR/vllm
MODEL=/data/Qwen2-7B/


if [ $1 -eq 1 ];then

        for gen_len in 200;
        do
                for input_len in 2000;
                do
                echo "=======RUNNING $MODEL $input_len $gen_len ========="
                torchrun --standalone --nproc_per_node=$2 --nnodes=1 $VLLM_DIR/benchmarks/benchmark_latency.py --model $MODEL --input-len $input_len --output-len $gen_len --batch-size 1 --tensor-parallel-size 1 --num-iters 5 --profile --profile-result-dir $PWD
        #python benchmarks/benchmark_latency.py --model $MODEL --input-len $input_len --output-len $gen_len --batch-size 1  --tensor-parallel-size 1 --num-iters 5
                done
        done
else
        for gen_len in 1 200;
        do
                for input_len in 1024 4096 8192 32768;
                do
                echo "=======RUNNING $MODEL $input_len $gen_len ========="
                torchrun --standalone --nproc_per_node=$2 --nnodes=1 $VLLM_DIR/benchmarks/benchmark_latency.py --model $MODEL --input-len $input_len --output-len $gen_len --batch-size $3 --tensor-parallel-size $2 --num-iters 3    
                done
        done

fi

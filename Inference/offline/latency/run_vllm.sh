#!/bin/bash

PWD=$(pwd)
SLOT_DIR=/app
VLLM_DIR=$SLOT_DIR/vllm

if [ $1 -eq 1 ];then

        for gen_len in 200;
        do
                for input_len in 2000;
                do
                echo "=======RUNNING $2 $input_len $gen_len ========="
                torchrun --standalone --nproc_per_node=$4 --nnodes=1 $VLLM_DIR/benchmarks/benchmark_latency.py --model $2 --input-len $input_len --output-len $gen_len --batch-size $5 --tensor-parallel-size $4 --num-iters 5 --dtype $3 --profile --profile-result-dir $PWD
        #python benchmarks/benchmark_latency.py --model $MODEL --input-len $input_len --output-len $gen_len --batch-size 1  --tensor-parallel-size 1 --num-iters 5
                done
        done
else
        for gen_len in 1 200;
        do                
                if [ $2 = "/data/Mixtral-8x22B-v0.1/" ];then
                        for input_len in 1024 4096 8192 32512;
                        do
                        echo "=======RUNNING $2 $input_len $gen_len ========="
                        torchrun --standalone --nproc_per_node=$4 --nnodes=1 $VLLM_DIR/benchmarks/benchmark_latency.py --model $2 --input-len $input_len --output-len $gen_len --batch-size $5 --tensor-parallel-size $4 --dtype $3 --num-iters 3 
                        done
                elif [ $2 = "/data/Meta-Llama-3.1-70B/" ];then
                        for input_len in 1024 4096 8192 32512;
                        do
                        echo "=======RUNNING $2 $input_len $gen_len ========="
                        torchrun --standalone --nproc_per_node=$4 --nnodes=1 $VLLM_DIR/benchmarks/benchmark_latency.py --model $2 --input-len $input_len --output-len $gen_len --batch-size $5 --tensor-parallel-size $4 --dtype $3 --num-iters 3
                        done
                else
                        for input_len in 1024 2048 4096 7938;
                        do
                        echo "=======RUNNING $2 $input_len $gen_len ========="
                        torchrun --standalone --nproc_per_node=$4 --nnodes=1 $VLLM_DIR/benchmarks/benchmark_latency.py --model $2 --input-len $input_len --output-len $gen_len --batch-size $5 --tensor-parallel-size $4 --dtype $3 --num-iters 3
                        done
                fi
        done

fi

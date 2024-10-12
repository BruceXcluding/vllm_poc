#!/bin/bash

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --test1) TEST1="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
    case $1 in
        --test2) TEST2="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
    case $1 in
        --test3) TEST3="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
    case $1 in
        --prefill_test) PREFILL_TEST="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

MODEL_NAME="Mixtral-8x22B-v0.1"
IFS=', '
for model_name in $MODEL_NAME
do
LOG_DIR=log/$model_name
if [ ! -d "$LOG_DIR" ]; then
        mkdir -p "$LOG_DIR"
        echo "create log dir: $LOG_DIR"
else
        echo "dir is exit: $LOG_DIR"
fi

# TEST 1
if [ "$TEST1" == "True" ]; then
        LOG_PATH_TEST1=$LOG_DIR/${model_name}_test1.log
        LOG_PROCESS_PATH_TEST1=$LOG_DIR/${model_name}_test1_results.txt
        bash vllm_latency_bench.sh --if_profile False --model_name $model_name --input_len 8192 --output_len 100 --data_type half --tp 8 --batch_size 1,4,8,16,32,40,48,64,80,96,112,120,128,224,240 --num_scheduler_steps 20 --num_iters_warmup 1 --num_iters 3 |& tee $LOG_PATH_TEST1
        cat $LOG_PATH_TEST1 | grep "Metrics" >> $LOG_PROCESS_PATH_TEST1
fi

# TEST 2
if  [ "$TEST2" == "True" ]; then
        LOG_PATH_TEST2=$LOG_DIR/${model_name}_test2.log
        LOG_PROCESS_PATH_TEST2=$LOG_DIR/${model_name}_test2_results.txt
        bash vllm_latency_bench.sh --if_profile False --model_name $model_name --input_len 16384 --output_len 100 --data_type half --tp 2 --batch_size 1,4,8,9 --num_scheduler_steps 20 --num_iters_warmup 1 --num_iters 3 |& tee $LOG_PATH_TEST2
        cat $LOG_PATH_TEST2 | grep "Metrics" >> $LOG_PROCESS_PATH_TEST2
fi

# TEST 3
if  [ "$TEST2" == "True" ]; then 
        LOG_PATH_TEST3=$LOG_DIR/${model_name}_test3.log
        LOG_PROCESS_PATH_TEST3=$LOG_DIR/${model_name}_test3_results.txt
        bash vllm_latency_bench.sh --if_profile False --model_name $model_name --input_len 2048,4096,6144,8192,16384 --output_len 100 --data_type half --tp 8 --batch_size 32 --num_scheduler_steps 20 --num_iters_warmup 1 --num_iters 3 |& tee $LOG_PATH_TEST3
        cat $LOG_PATH_TEST3| grep "Metrics" >> $LOG_PROCESS_PATH_TEST3
fi

# TEST 4
if [ "$PREFILL_TEST" == "True" ]; then
        LOG_PATH_PREFILL=$LOG_DIR/${model_name}_prefill.log
        LOG_PROCESS_PATH_PREFILL=$LOG_DIR/${model_name}_prefill_results.txt
        bash vllm_latency_bench.sh --if_profile False --model_name $model_name --input_len 2048,4096,6144,8192,16384 --output_len 1 --data_type half --tp 8 --batch_size 1 --num_scheduler_steps 1 --num_iters_warmup 1 --num_iters 3 |& tee $LOG_PATH_PREFILL
        cat $LOG_PATH_PREFILL | grep "Metrics" >> $LOG_PROCESS_PATH_PREFILL
fi

done

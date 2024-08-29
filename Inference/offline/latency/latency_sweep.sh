#!/bin/bash

MODEL_NAME="Llama-2-70b-hf, Meta-Llama-3-70B, Mixtral-8x22B-v0.1" 
IFS=', '
for model_name in $MODEL_NAME
do
MODLE=/data/$model_name
LOG_DIR=log/$model_name
        for batch_size in 1 4 8 16;
        do 
                for tp in 8;
                do
                LOG_PATH=$LOG_DIR/${model_name}_tp${tp}_bs${batch_size}_latency.txt
                LOG_PROCESS_PATH=$LOG_DIR/${model_name}_tp${tp}_bs${batch_size}_latency_process.txt
                bash run_vllm.sh 0 $MODEL $tp $batch_size |& tee $LOG_PATH
                echo "latency(ms) prefill:" > $LOG_PROCESS_PATH
                cat $LOG_PATH| grep "Avg" |awk -F' ' '{print $(NF-1)*1000}' |awk -v tp="$tp" '(NR-1)%tp==0'|head -n 4 >>$LOG_PROCESS_PATH
                echo "latency(ms) total:" >>$LOG_PROCESS_PATH
                cat $LOG_PATH| grep "Avg" |awk -F' ' '{print $(NF-1)*1000}' |awk -v tp="$tp" '(NR-1)%tp==0'|tail -n 4 >>$LOG_PROCESS_PATH
                echo "calculate latency(ms)decode using (total latency-prefill latency)/199" >>$LOG_PROCESS_PATH
                done
        done
done

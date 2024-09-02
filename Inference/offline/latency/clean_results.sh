#!/bin/bash

PWD=$(pwd)
MODEL="Meta-Llama-3.1-70B"
DTYPE="bfloat16"

for tp in 8 4 2;
do
        for bs in 1 4 8 16;
        do
        LOG_PATH=tp${tp}
        LOG_PROCESS_PATH=$LOG_PATH/${MODEL}_tp${tp}_bs${bs}_${DTYPE}_latency_process.txt
        LOG_RESULTS_PATH=$LOG_PATH/bs${bs}.txt
        echo "latency(ms) prefill:" > $LOG_RESULTS_PATH
        cat $LOG_PROCESS_PATH| awk -F' ' '{print $(NF-1)*1000}' |awk -v tp="$tp" '(NR-1)%tp==0'|head -n 4 >>$LOG_RESULTS_PATH
        echo "latency(ms) total:" >>$LOG_RESULTS_PATH
        cat $LOG_PROCESS_PATH| awk -F' ' '{print $(NF-1)*1000}' |awk -v tp="$tp" '(NR-1)%tp==0'|tail -n 4 >>$LOG_RESULTS_PATH
        done
done

#!/bin/bash

#MODEL_NAME="Mixtral-8x22B-v0.1, Meta-Llama-3.1-70B, Meta-Llama-3-70B"
MODEL_NAME="Mixtral-8x22B-v0.1"
IFS=', '
for model_name in $MODEL_NAME
do
MODEL=/data/$model_name/
LOG_DIR=log/$model_name
if [ ! -d "$LOG_DIR" ]; then
        mkdir -p "$LOG_DIR"
        echo "create log dir: $LOG_DIR"
else
        echo "dir is exit: $LOG_DIR"
fi
DTYPE="half, bfloat16"
IFS=', '
        for dt in $DTYPE
        do
                for tp in 8 2;
                do 
                        if [ $tp -eq 8 ];then
                                for bs in 1 64 72 80 88 96 104 112 120 128;
                                do
                                LOG_PATH=$LOG_DIR/${model_name}_tp${tp}_bs${bs}_${dt}_latency.txt
                                LOG_PROCESS_PATH=$LOG_DIR/${model_name}_tp${tp}_bs${bs}_${dt}_latency_process.txt
                                bash run_vllm.sh 0 $MODEL $dt $tp $bs |& tee $LOG_PATH
                                echo "Avg results:" > $LOG_PROCESS_PATH
                                cat $LOG_PATH| grep "Avg" >>$LOG_PROCESS_PATH
                                echo "latency(ms) prefill:" > $LOG_PROCESS_PATH
                                cat $LOG_PATH| grep "Avg" |awk -F' ' '{print $(NF-1)*1000}'| head -n 2 >>$LOG_PROCESS_PATH
                                echo "latency(ms) total:" >>$LOG_PROCESS_PATH
                                cat $LOG_PATH| grep "Avg" |awk -F' ' '{print $(NF-1)*1000}'| tail -n 2 >>$LOG_PROCESS_PATH
                                done
                        elif [ $tp -eq 2 ];then
                                for bs in 1 4 6 8 10 12 14 16;
                                do
                                LOG_PATH=$LOG_DIR/${model_name}_tp${tp}_bs${bs}_${dt}_latency.txt
                                LOG_PROCESS_PATH=$LOG_DIR/${model_name}_tp${tp}_bs${bs}_${dt}_latency_process.txt
                                HIP_VISIBLE_DEVICES=0,1 bash run_vllm.sh 0 $MODEL $dt $tp $bs |& tee $LOG_PATH
                                echo "Avg results:" > $LOG_PROCESS_PATH
                                cat $LOG_PATH| grep "Avg" >>$LOG_PROCESS_PATH
                                echo "latency(ms) prefill:" > $LOG_PROCESS_PATH
                                cat $LOG_PATH| grep "Avg" |awk -F' ' '{print $(NF-1)*1000}'| head -n 2 >>$LOG_PROCESS_PATH
                                echo "latency(ms) total:" >>$LOG_PROCESS_PATH
                                cat $LOG_PATH| grep "Avg" |awk -F' ' '{print $(NF-1)*1000}'| tail -n 2 >>$LOG_PROCESS_PATH
                                done
                        else
                                for bs in 1 4 8 16;
                                do
                                LOG_PATH=$LOG_DIR/${model_name}_tp${tp}_bs${bs}_${dt}_latency.txt
                                LOG_PROCESS_PATH=$LOG_DIR/${model_name}_tp${tp}_bs${bs}_${dt}_latency_process.txt
                                HIP_VISIBLE_DEVICES=0,1,2,3 bash run_vllm.sh 0 $MODEL $dt $tp $bs |& tee $LOG_PATH
                                echo "Avg results:" > $LOG_PROCESS_PATH
                                cat $LOG_PATH| grep "Avg" >>$LOG_PROCESS_PATH
                                echo "latency(ms) prefill:" > $LOG_PROCESS_PATH
                                cat $LOG_PATH| grep "Avg" |awk -F' ' '{print $(NF-1)*1000}'| head -n 5 >>$LOG_PROCESS_PATH
                                echo "latency(ms) total:" >>$LOG_PROCESS_PATH
                                cat $LOG_PATH| grep "Avg" |awk -F' ' '{print $(NF-1)*1000}'| tail -n 5 >>$LOG_PROCESS_PATH
                                done

                        fi
                done
        done
done

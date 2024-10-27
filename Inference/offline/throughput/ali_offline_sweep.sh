
MODEL_NAME_GROUP1="Meta-Llama-3-8B, Qwen2-7B, Mixtral-8x7B-Instruct-v0.1"
IFS=', '
for model_name in $MODEL_NAME_GROUP1
do
MODEL=/data/$model_name/
LOG_DIR=log/$model_name
if [ ! -d "$LOG_DIR" ]; then
        mkdir -p "$LOG_DIR"
        echo "create log dir: $LOG_DIR"
else
        echo "dir is exit: $LOG_DIR"
fi

DTYPE="half"
IFS=', '
        for dt in $DTYPE
        do
                for tp in 1 2;
                do
                        for out in 128 256;
                        do
                                for int in 128 1024 4096;
                                do
                                LOG_PATH=$LOG_DIR/${model_name}_${dt}.txt
                                echo " " 2>&1 | tee $LOG_PATH
                                echo "[INFO] THROUGHPUT" 2>&1 | tee $LOG_PATH
                                echo $model_name $tp $inp $out $dt 2>&1 |
                                python  /opt/vllm/benchmarks/benchmark_throughput.py --model $MODEL --trust-remote-code --distributed-executor-backend mp --dtype $dt --num-prompts=1000 --input-len $int --output-len $out --tensor-parallel-size $tp --output-json $LOG_DIR/${model_name}_${int}_${out}_tp${tp}_${dt}.json 2>&1 | tee $LOG_PATH
                                done
                        done
                done
        done
done

for model_name in $MODEL_NAME_GROUP1
do
LOG_DIR=log/$model_name
if [ ! -d "$LOG_DIR" ]; then
        mkdir -p "$LOG_DIR"
        echo "create log dir: $LOG_DIR"
else
        echo "dir is exit: $LOG_DIR"
fi

DTYPE="half"
IFS=', '
        for dt in $DTYPE
        do
                for tp in 1 2;
                do
                        for out in 128 256;
                        do
                                for int in 128 1024 4096;
                                do
                                LOG_PATH=$LOG_DIR/${model_name}_${int}_${out}_tp${tp}_${dt}.json
                                RESULT=$LOG_DIR/${model_name}_${dt}_result.json
                                cat $LOG_PATH| grep "tokens_per_second" | awk -F' ' '{print $(NF)}' >> $RESULT
                                done
                        done
                done
        done
done

MODEL_NAME_GROUP2="Meta-Llama-3-70B, Qwen2-72B, Mixtral-8x22B-Instruct-v0.1"
IFS=', '
for model_name in $MODEL_NAME_GROUP2
do
MODEL=/data/$model_name/
LOG_DIR=log/$model_name
if [ ! -d "$LOG_DIR" ]; then
        mkdir -p "$LOG_DIR"
        echo "create log dir: $LOG_DIR"
else
        echo "dir is exit: $LOG_DIR"
fi

DTYPE="half"
IFS=', '
        for dt in $DTYPE
        do
                for tp in 2 4 8;
                do
                        for out in 128 256;
                        do
                                for int in 128 1024 4096;
                                do
                                LOG_PATH=$LOG_DIR/${model_name}_${dt}.txt
                                echo " " 2>&1 | tee $LOG_PATH
                                echo "[INFO] THROUGHPUT" 2>&1 | tee $LOG_PATH
                                echo $model_name $tp $inp $out $dt 2>&1 |
                                python  /opt/vllm/benchmarks/benchmark_throughput.py --model $MODEL --trust-remote-code --distributed-executor-backend mp --dtype $dt --num-prompts=1000 --input-len $int --output-len $out --tensor-parallel-size $tp --output-json $LOG_DIR/${model_name}_${int}_${out}_tp${tp}_${dt}.json 2>&1 | tee $LOG_PATH
                                done
                        done
                done
        done
done

for model_name in $MODEL_NAME_GROUP2
do
LOG_DIR=log/$model_name
if [ ! -d "$LOG_DIR" ]; then
        mkdir -p "$LOG_DIR"
        echo "create log dir: $LOG_DIR"
else
        echo "dir is exit: $LOG_DIR"
fi

DTYPE="half"
IFS=', '
        for dt in $DTYPE
        do
                for tp in 2 4 8;
                do
                        for out in 128 256;
                        do
                                for int in 128 1024 4096;
                                do
                                LOG_PATH=$LOG_DIR/${model_name}_${int}_${out}_tp${tp}_${dt}.json
                                RESULT=$LOG_DIR/${model_name}_${dt}_result.json
                                cat $LOG_PATH| grep "tokens_per_second" | awk -F' ' '{print $(NF)}' >> $RESULT
                                done
                        done
                done
        done
done

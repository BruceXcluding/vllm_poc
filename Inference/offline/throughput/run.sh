MODEL_NAME="Mixtral-8x22B-v0.1, Llama3.1-70B"
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

DTYPE="half"
IFS=', '
        for dt in $DTYPE
        do
                for tp in 8;
                do
                        for int in 1000 2000 20000;
                        do
                                for out in 500;
                                do
                                LOG_PATH=$LOG_DIR/${model_name}_tp${tp}_intput${int}_output${out}_${dt}.txt
                                echo " " 2>&1 | tee $LOG_PATH
                                echo "[INFO] THROUGHPUT" 2>&1 | tee $LOG_PATH
                                echo $model_name $tp $inp $out $dt 2>&1 |
                                python  /app/vllm/benchmarks/benchmark_throughput.py --model $MODEL --trust-remote-code --distributed-executor-backend mp --dtype $dt --num-prompts=1000 --input-len $int --output-len $out --tensor-parallel-size $tp --output-json ${model_name}_${int}_${out}_tp${tp}_${dt}.json 2>&1 | tee $LOG_PATH
                                done
                        done
                done
        done
done

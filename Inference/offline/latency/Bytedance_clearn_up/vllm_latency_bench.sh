
PWD=$(pwd)
MODEL_ROOT="/data/"
SLOT_DIR=/app
VLLM_DIR=$SLOT_DIR/rocm_vllm

# Parse named arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --if_profile) IF_PROFILE="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
    case $1 in
        --model_name) MODEL_NAME="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
    case $1 in
        --input_len) INPUT_LEN="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
    case $1 in
        --output_len) OUTPUT_LEN="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
    case $1 in
        --data_type) DATA_TYPE="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
    case $1 in 
        --tp) TP="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; usage ;; 
    esac 
    shift 
    case $1 in 
        --batch_size) BATCH_SIZE="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; usage ;; 
    esac 
    shift
        case $1 in 
        --gpu-memory-utilization) MEM="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; usage ;; 
    esac 
    shift 
    case $1 in 
        --num_scheduler_steps) NUM_SCHEDULER_STEPS="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; usage ;; 
    esac 
    shift
    case $1 in 
        --num_iters_warmup) NUM_ITERS_WARMUP="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; usage ;; 
    esac 
    shift
    case $1 in 
        --num_iters) NUM_ITERS="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; usage ;; 
    esac 
    shift 
done

INPUT_LEN_SP=""
for i in $(echo $INPUT_LEN | tr "," "\n")
do
  INPUT_LEN_SP="$INPUT_LEN_SP $i"
done

OUTPUT_LEN_SP=""
for i in $(echo $OUTPUT_LEN | tr "," "\n")
do
  OUTPUT_LEN_SP="$OUTPUT_LEN_SP $i"
done

DATA_TYPE_SP=""
for i in $(echo $DATA_TYPE | tr "," "\n")
do
  DATA_TYPE_SP="$DATA_TYPE_SP $i"
done

BATCH_SIZE_SP=""
for i in $(echo $BATCH_SIZE | tr "," "\n")
do 
    BATCH_SIZE_SP="$BATCH_SIZE_SP $i"
done 

if [ -z "$MODEL_NAME" ]; then
    echo "Error: Missing one or more required parameters."
    usage
fi

echo "====Hyper Params Start===="
echo $MODEL_NAME
echo $INPUT_LEN_SP
echo $OUTPUT_LEN_SP
echo $DATA_TYPE_SP

profile=$IF_PROFILE
model_path=$MODEL_ROOT/$MODEL_NAME 
tp=$TP
mem=$MEM
data_type=$DATA_TYPE_SP
isl=$INPUT_LEN_SP
osl=$OUTPUT_LEN_SP
batch_size=$BATCH_SIZE_SP
num_scheduler_steps=$NUM_SCHEDULER_STEPS
num_iters_warmup=$NUM_ITERS_WARMUP
num_iters=$NUM_ITERS 

if [ $profile == "True" ];then
    for dt in $data_type; do 
            for bs in $batch_size; do 
                    for input_len in $isl; do
                        for gen_len in $osl; do 
                            in_out_dims="${input_len},${gen_len}"
                            echo "=====TP: $tp, BS: $bs, ISL/OSL: $in_out_dims===="
                            python $VLLM_DIR/benchmarks/benchmark_latency_tps.py --model $model_path --distributed-executor-backend mp --num-scheduler-steps $num_scheduler_steps --input-len $input_len --output-len $gen_len --batch-size $bs --tensor-parallel-size $tp --dtype $dt --num-iters-warmup $num_iters_warmup --num-iters $num_iters --profile --profile-result-dir $PWD
                        done
                    done 
            done 
    done
else
    for dt in $data_type; do 
            for bs in $batch_size; do 
                    for input_len in $isl; do
                        for gen_len in $osl; do 
                            in_out_dims="${input_len},${gen_len}"
                            echo "TP: $tp, BS: $bs, ISL/OSL: $in_out_dims"
                            python $VLLM_DIR/benchmarks/benchmark_latency_tps.py --model $model_path --gpu-memory-utilization $mem --distributed-executor-backend mp --num-scheduler-steps $num_scheduler_steps --input-len $input_len --output-len $gen_len --batch-size $bs --tensor-parallel-size $tp --dtype $dt --num-iters-warmup $num_iters_warmup --num-iters $num_iters
                        done
                    done 
            done 
    done
fi

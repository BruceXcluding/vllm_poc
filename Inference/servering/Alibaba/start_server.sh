#!/bin/bash
export OPENBLAS_NUM_THREADS=1

if [ $1 -eq 1 ]; then
        HIP_VISIBLE_DEVICES=0,1 python -m vllm.entrypoints.sync_openai.api_server --host 0.0.0.0 --port 8011 --model /data/Mixtral-8/ --swap-space 16 --disable-log-requests --trust-remote-code --tensor-parallel-size 1 --dtype float16 --distributed-executor-backend mp
elif []; then
        HIP_VISIBLE_DEVICES=0,1 python -m vllm.entrypoints.sync_openai.api_server --host 0.0.0.0 --port 8011 --model /data/Qwen2-72B/ --swap-space 16 --disable-log-requests --trust-remote-code --tensor-parallel-size 2 --dtype float16 --distributed-executor-backend mp
else
        HIP_VISIBLE_DEVICES=0 python -m vllm.entrypoints.sync_openai.api_server --host 0.0.0.0 --port 8011 --model /data/Qwen2-7B/ --swap-space 16 --disable-log-requests --trust-remote-code --tensor-parallel-size 1 --dtype float16 --distributed-executor-backend mp
fi

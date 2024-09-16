#!/bin/bash
export OPENBLAS_NUM_THREADS=1

HIP_VISIBLE_DEVICES=0,1 python -m vllm.entrypoints.sync_openai.api_server --host 0.0.0.0 --port 8011 --model /data/Mixtral-8x22B-v0.1/ --swap-space 16 --disable-log-requests --trust-remote-code --tensor-parallel-size 2 --dtype float16 --distributed-executor-backend mp

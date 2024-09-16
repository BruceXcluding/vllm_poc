## Server Benchmark

#### Server Docker image: ```rocm/pytorch-private:vllm0.4.3_ROCm6.2_240902_02f2e``` or ```rocm/pytorch-private:20240819_exec_dashboard_unified_rc3_added_triton_fa_vllm_moe_final_Ali_mixtral_peng_v2```

```bash
sudo docker run -it --network=host --shm-size 16g -v /home/:/work -v /data/models:/data --env HF_HOME=/data --env TOKENIZERS_PARALLELISM=false --device=/dev/kfd --device=/dev/dri --group-add video --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --ipc=host -d --name vllm_server rocm/pytorch-private:20240819_exec_dashboard_unified_rc3_added_triton_fa_vllm_moe_final_Ali_mixtral_peng_v2
```

#### Client Docker image: rocm/pytorch-private:20240828_exec_dashboard_unified_v7_vllm0.5.5_rccl6.2.0_moe_final_v0.5.5

```bash
sudo docker run -it --network=host --shm-size 16g -v /home/:/work -v /data/models:/data --env HF_HOME=/data --env TOKENIZERS_PARALLELISM=false --device=/dev/kfd --device=/dev/dri --group-add video --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --ipc=host -d --name vllm_client rocm/pytorch-private:20240828_exec_dashboard_unified_v7_vllm0.5.5_rccl6.2.0_moe_final_v0.5.5
```


### vLLM Public Server

#### Start a server

```bash
sudo docker exec -it vllm_server bash
### git vllm_poc repo
cd Inference/servering/public
bash start_server.sh
```

#### Send requests from client

```bash
sudo docker exec -it vllm_client bash
python /app/rocm_vllm/benchmarks/benchmark_serving.py --port 8011 --model /data/Mixtral-8x22B-v0.1/ --tokenizer /data/Mixtral-8x22B-v0.1/ --dataset-name random --random-input-len 16000 --random-output-len 200 --trust-remote-code --request-rate inf --num-prompts 4
```

#### Modify params

Stable prompts type:

```bash
dataset-name: random
Input: random-input-len 16000
Output: random-output-len 200
request-rate: inf (send all the requests at time 0)
Num Prompts: 4
```


### Alibaba PoC Server

#### Start a server

```bash
sudo docker exec -it vllm_server bash
### git clone vllm_poc repo
cd Inference/servering/Alibaba
bash start_server.sh mixtral
```

#### Send requests from client

```bash
sudo docker exec -it vllm_client bash
### git clone vllm_poc repo
cp /vllm_poc/Inference/serving/Alibaba/mixtral_config.yaml /app/Alibaba_POC-main/ai_workload/inference_vllm/sever-mode-test/serving_benchmarks/configs/
cd /app/Alibaba_POC-main/ai_workload/inference_vllm/sever-mode-test/serving_benchmarks/
python benchmark.py --config configs/mixtral/mixtral_config.yaml
```

#### Modify params

Distribution prompts type:

```bash
Input: 0.8 * max_input_len - max_input_len ex. 1k input, 800-1000
Output: 0.6 * max_input_len - max_input_len ex. 0.5k input, 300-500
Concurrency
Num Prompts: 20 * concurrency
```

ex. marked

![serverparams diagram](./images/serverparams.png) 










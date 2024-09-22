# MI308X vllm_poc

## 1. Start an environment

#### Docker image:rocm/pytorch-private:20240828_exec_dashboard_unified_v7_vllm0.5.5_rccl6.2.0_moe_final_v0.5.5

```bash
sudo docker run -it --network=host --shm-size 16g -v /home/:/work -v /data/models:/data --env HF_HOME=/data --env TOKENIZERS_PARALLELISM=false --device=/dev/kfd --device=/dev/dri --group-add video --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --ipc=host -d --name vllm_poc rocm/pytorch-private:20240828_exec_dashboard_unified_v7_vllm0.5.5_rccl6.2.0_moe_final_v0.5.5

sudo docker exec -it vllm_poc bash
export PYTORCH_TUNABLEOP_ENABLED=0
```
or
#### Docker image:rocmshared/pytorch-private:ROCm6.2_hipblaslt0.10.0_pytorch2.5_vllm0.6.0_moe_final_v0.6.0

```bash
sudo docker run -it --network=host --shm-size 16g -v /home/:/work -v /data/models:/data --env HF_HOME=/data --env TOKENIZERS_PARALLELISM=false --device=/dev/kfd --device=/dev/dri --group-add video --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --ipc=host -d --name vllm_poc rocmshared/pytorch-private:ROCm6.2_hipblaslt0.10.0_pytorch2.5_vllm0.6.0_moe_final_v0.6.0

sudo docker exec -it vllm_poc bash
```
## 2. MoE Tuning (Optional)

If vllm could not read the moe tuning config file correctly on the machine, we need to re-tune the correct machine name. The defualt config file named "AMD_Radeon_Graphics.json".

### Steps to do tuning

```bash
cd /app/rocm_vllm/benchmarks/kernels
python benchmark_mixtral_moe_rocm.py --TP 2 --model 8x22B
Step-2 will dump a .json file. Copy it to /app/rocm_vllm/vllm/model_executor/layers/fused_moe/configs. name：
"…AMD_Instinct_MI300X_OAM.json"
```

## 3. Offline Latency Benchmark

### Command to start test

```bash
cd Inference/offline/latency
bash latency_sweep.sh
```
### Modify input_len
#### run_vllm.sh:

![input diagram](./images/input.png) 

#### latency_sweep.sh:

![results diagram](./images/results.png) 

### Modify params

#### latency_sweep.sh:

![params diagram](./images/params.png) 

### Profile

```bash
Profle:
bash run_vllm 1

non-Profile:
bash run_vllm 0
```

#### latency_sweep.sh:

![profile diagram](./images/profile.png) 


## 4. Offline Throughput Benchmark

```bash
cd Inference/offline/throughput
bash run.sh
```

## 4. Servering Throughput Benchmark
* [**Section - Workflow**](./Inference/servering/README.md)

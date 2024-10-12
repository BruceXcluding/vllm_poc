## Build Environment

```
sudo docker run -it --network=host --shm-size 16g -v /data/models/:/data --env HF_HOME=/data --env TOKENIZERS_PARALLELISM=false --device=/dev/kfd --device=/dev/dri --group-add video --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --ipc=host -d --name vllm_poc rocm/bytedance-private:vllm_poc_241012
```

## Benchmark

```
sudo docke exec -it vllm_poc bash
cd /app/vllm_poc
```

#### Test 1 - input 8K; output 100; bs=1,4,8,16,32,40,48,64,80,96,112,120,128,224,240
```
bash run.sh --test1 True --test2 False --test3 False --prefill_test False
```

#### Test 2 - input 16K; output 100; bs=1,4,8,9
```
bash run.sh --test1 False --test2 True --test3 False --prefill_test False
```

#### Test 3 - input 2K,4K,6K,8K,16K; output=100; bs=32,16,48
```
bash run.sh --test1 False --test2 False --test3 True --prefill_test False
```

#### Prefill test - input 2K,4K,6K,8K,16K; output 1; bs=1
```
bash run.sh --test1 False --test2 False --test3 False --prefill_test True
```

## Result

```
cd log/Mixtral-8x22B-v0.1
cat xxxx_results.txt
```

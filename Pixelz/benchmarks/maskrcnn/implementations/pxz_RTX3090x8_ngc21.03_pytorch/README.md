## Steps to launch training on a single node

For single-node training, we use docker to run our container.
Launch configuration and system-specific hyperparameters are in the `config_PXZ.sh` script.


0. Prepare the datasets, pretrained weighs:
```
cd path/to/dataset_scripts/
./download_dataset.sh
./verify_dataset.sh
DATASET_DIR='path/to/datasets' ./extract_dataset.sh
DATASET_DIR='path/to/datasets' ./download_weights.sh
```

Steps required to launch single node training (assume current folder is /path/to/pytorch/)

1. Build the docker image
```
sudo docker build --pull -t mlperf-pixelz:object_detection .
```

2. Set directories to appropriate values in `run_benchmark.sh`, for example:

```
WORKDIR=${WORKDIR:-"/mnt/data/workspace"}
DATADIR="${WORKDIR}/datasets"
LOGDIR="${WORKDIR}/benchmarks/maskrcnn/implementations/pytorch/logs"
```

3. Run the benchmark script:
```
sudo ./run_benchmark.sh
```
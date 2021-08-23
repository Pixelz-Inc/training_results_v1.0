#!/bin/bash

DATADIR=${DATADIR:-"/mnt/data/workspace/datasets"} # there should be ./coco2017 and ./torchvision dirs in here
LOGDIR=${LOGDIR:-"/mnt/data/workspace/benchmarks/maskrcnn/implementations/pytorch/logs"}
NEXP=${NEXP:-6} # Default number of times to run the benchmark

source config_PXZ.sh && LOGDIR=$LOGDIR DATADIR=$DATADIR CONT="mlperf-pixelz:object_detection_nccl" NEXP=$NEXP ./run_with_docker.sh

#!/bin/bash

WORKDIR=${WORKDIR:-"/mnt/data/workspace"}
DATADIR="${WORKDIR}/datasets"
LOGDIR="${WORKDIR}/benchmarks/maskrcnn/implementations/pytorch/logs"

source config_PXZ.sh && WORKDIR=$WORKDIR LOGDIR=$LOGDIR DATADIR=$DATADIR CONT="mlperf-pixelz:object_detection" ./run_with_docker.sh

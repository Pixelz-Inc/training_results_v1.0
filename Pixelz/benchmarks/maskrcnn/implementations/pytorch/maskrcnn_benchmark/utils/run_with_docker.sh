#!/bin/bash
set -euxo pipefail

# Vars without defaults
: "${PXZSYSTEM:?PXZSYSTEM not set}"
: "${CONT:?CONT not set}"
echo "foo"
echo $DATADIR
echo $LOGDIR

# Vars with defaults
: "${NEXP:=5}"
: "${DATESTAMP:=$(date +'%y%m%d%H%M%S%N')}"
: "${CLEAR_CACHES:=1}"
: "${DATADIR:=$(pwd)/datasets}"
: "${LOGDIR:=$(pwd)/logs}"

echo $DATADIR
echo $LOGDIR
echo "bar"

# Other vars
readonly _config_file="./config_${PXZSYSTEM}.sh"
readonly _logfile_base="${LOGDIR}/${DATESTAMP}"
readonly _cont_name="object_detection"
_cont_mounts=("--volume=${DATADIR}:/datasets" "--volume=${LOGDIR}:/logs")
_work_dir=("-w=/training_results_v1.0/NVIDIA/benchmarks/maskrcnn/implementations/pytorch")

# MLPerf vars
MLPERF_HOST_OS=$(
    source /etc/os-release
    echo "${PRETTY_NAME}"
)
export MLPERF_HOST_OS

# Setup directories
mkdir -p "${LOGDIR}"

# Get list of envvars to pass to docker
source "${_config_file}"
mapfile -t _config_env < <(env -i bash -c ". ${_config_file} && compgen -e" | grep -E -v '^(PWD|SHLVL)')
_config_env+=(MLPERF_HOST_OS)
mapfile -t _config_env < <(for v in "${_config_env[@]}"; do echo "--env=$v"; done)

# Cleanup container
cleanup_docker() {
    docker container rm -f "${_cont_name}" || true
}
cleanup_docker
trap 'set -eux; cleanup_docker' EXIT

# Setup container
nvidia-docker run --rm --init --detach \
    --net=host --uts=host --ipc=host --security-opt=seccomp=unconfined \
    --ulimit=stack=67108864 --ulimit=memlock=-1 \
    --name="${_cont_name}" "${_work_dir}" "${_cont_mounts[@]}" \
    "${CONT}" sleep infinity
docker exec -it "${_cont_name}" true

# Run experiments
for _experiment_index in $(seq 1 "${NEXP}"); do
    (
        echo "Beginning trial ${_experiment_index} of ${NEXP}"
        # Print system info
        docker exec -it "${_cont_name}" python -c "
import os
cwd = os.getcwd()
print('Current dir:', cwd)
from mlperf_logging.mllog import constants
print('ok lah')

from maskrcnn_benchmark.utils.mlperf_logger import log_event
log_event(constants.MASKRCNN)"

        # Clear caches
        if [ "${CLEAR_CACHES}" -eq 1 ]; then
            sync && sudo /sbin/sysctl vm.drop_caches=3
            docker exec -it "${_cont_name}" python -c "
from mlperf_logging.mllog import constants
from maskrcnn_benchmark.utils.mlperf_logger import log_event
log_event(key=constants.CACHE_CLEAR, value=True, stack_offset=0)"
        fi

        # Run experiment
        docker exec -it "${_config_env[@]}" "${_cont_name}" ./run_and_time1.sh
    ) |& tee "${_logfile_base}_${_experiment_index}.log"
done

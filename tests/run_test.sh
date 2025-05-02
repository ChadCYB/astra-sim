#!/bin/bash
set -e

# Path
SCRIPT_DIR=$(dirname "$(realpath $0)")
ASTRA_SIM_BUILD_DIR=${SCRIPT_DIR}/../extern/network_backend/ns-3/build/scratch/
ASTRA_SIM=./ns3.42-AstraSimNetwork-default

# Generate a timestamp for the folder name
TIMESTAMP=$(date +%Y%m%d%H%M%S)

# Create a new folder under outputs with the timestamp
OUTPUT_DIR=${SCRIPT_DIR}/outputs/${TIMESTAMP}
mkdir -p ${OUTPUT_DIR}

# Modify the ns3/config.txt with the new output folder paths
NS3_CONFIG=${SCRIPT_DIR}/inputs/ns3/config.txt
NEW_NS3_CONFIG=${SCRIPT_DIR}/inputs/ns3/config_${TIMESTAMP}.txt

# Update the paths in the config file
sed "s|../../../../../tests/outputs/mix.tr|${OUTPUT_DIR}/mix.tr|" \
    ${NS3_CONFIG} | sed "s|../../../../../tests/outputs/fct.txt|${OUTPUT_DIR}/fct.txt|" | \
    sed "s|../../../../../tests/outputs/pfc.txt|${OUTPUT_DIR}/pfc.txt|" | \
    sed "s|../../../../../tests/outputs/qlen.txt|${OUTPUT_DIR}/qlen.txt|" > ${NEW_NS3_CONFIG}

# Record start time (in milliseconds)
START_TIME=$(($(date +%s%N) / 1000000))

# Create the full command to run
COMMAND="${ASTRA_SIM} \
    --workload-configuration=${SCRIPT_DIR}/inputs/workloads/gpt2/distilgpt2_8gpus \
    --system-configuration=${SCRIPT_DIR}/inputs/systems/Ring_sys.json \
    --remote-memory-configuration=${SCRIPT_DIR}/inputs/systems/RemoteMemory.json \
    --logical-topology-configuration=${SCRIPT_DIR}/inputs/systems/logical_8nodes_1D.json \
    --network-configuration=${NEW_NS3_CONFIG}"

# Save the executing command to the beginning of the log file
echo "${COMMAND}" > ${OUTPUT_DIR}/log.txt
echo "=====" >> ${OUTPUT_DIR}/log.txt

# Run ASTRA-sim and capture both output and errors, append the output to log.txt
(
cd ${ASTRA_SIM_BUILD_DIR}
${COMMAND} >> ${OUTPUT_DIR}/log.txt 2>&1
)

# Record end time (in milliseconds)
END_TIME=$(($(date +%s%N) / 1000000))

# Calculate elapsed time in milliseconds
ELAPSED_TIME=$((END_TIME - START_TIME))

# Save the elapsed time in milliseconds to the log file
echo "=====" >> ${OUTPUT_DIR}/log.txt
echo "Elapsed Time: ${ELAPSED_TIME} ms" >> ${OUTPUT_DIR}/log.txt

# Move the new config file to the output folder
mv ${NEW_NS3_CONFIG} ${OUTPUT_DIR}




    # --workload-configuration=${SCRIPT_DIR}/inputs/workloads/gpt2/distilgpt2_8gpus \
    # --workload-configuration=${SCRIPT_DIR}/inputs/workloads/allreduce_1D/allreduce \

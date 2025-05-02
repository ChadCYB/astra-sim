#!/bin/bash
set -e

# Path
SCRIPT_DIR=$(dirname "$(realpath $0)")

# Clone ASTRA-sim
(
git clone https://github.com/ChadCYB/astra-sim.git
cd ${SCRIPT_DIR}/astra-sim/
git checkout ns3-test
git submodule update --init --recursive
)

# Create Chakra symlink for easy access
(
ln -s astra-sim/extern/graph_frontend/chakra .
)

# Clone Param (required for real system trace conversion)
(
git clone https://github.com/facebookresearch/param.git
)

# Clone Symbolic Tensor Graph (STG) Generator
(
git clone https://github.com/astra-sim/symbolic_tensor_graph
)

# Intall Chakra (Use Chakra fork in ASTRA-Sim repo).
(
cd ${SCRIPT_DIR}/chakra
pip3 install .
)

# Install PARAM (required for real system trace conversion)
(
git config --global --add safe.directory /app/param
cd ${SCRIPT_DIR}/param/et_replay
git checkout 7b19f586dd8b267333114992833a0d7e0d601630
pip install .
)

# Compile astra-sim with astra_analytical
(
cd ${SCRIPT_DIR}/astra-sim/build/astra_analytical
./build.sh
)

# Compile ASTRA-sim with ns3 backend model
(
cd ${SCRIPT_DIR}/astra-sim
bash ./build/astra_ns3/build.sh 
)


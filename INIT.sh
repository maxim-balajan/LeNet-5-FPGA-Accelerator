#!/bin/bash

# Set the name of the virtual environment
ENV_NAME=".venv"

# Set the python executable (explicitly Python 3.10)
PYTHON_VER="3.10.16"
PYTHON_BIN="$HOME/.pyenv/versions/$PYTHON_VER/bin/python"

# change your VUNIT simulator here (e.g. if you use questa)
export VUNIT_SIMULATOR=modelsim

export PRJ_ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PRJ_GENERATED_PATH="$PRJ_ROOT_PATH/_generated"
export PRJ_TRAIN_PATH="$PRJ_ROOT_PATH/reference/training"
export PRJ_SIM_PATH="$PRJ_ROOT_PATH/reference/simulation"
export PRJ_SCRIPTS="$PRJ_ROOT_PATH/scripts"
export PRJ_HW_SOURCES_PATH="$PRJ_ROOT_PATH/sources_1"
export PRJ_VUNIT_PATH="${PRJ_ROOT_PATH}/${ENV_NAME}/lib/python3.10/site-packages/vunit"

# Paths that are specific to this project
# The raw weights live in PRJ_DATA_PATH, the per BRAM tile files that are generated out
# of them in PRJ_BRAM_DATA_PATH. Both the VHDL and the Vivado scripts read those.
export PRJ_DATA_PATH="$PRJ_ROOT_PATH/data"
export PRJ_BRAM_DATA_PATH="$PRJ_DATA_PATH/output"
export PRJ_CONSTRAINTS_PATH="$PRJ_ROOT_PATH/constraints"
export PRJ_BUILD_PATH="$PRJ_ROOT_PATH/build"

# Various directory changes abstracted into new commands
alias cd_root="cd $PRJ_ROOT_PATH"
alias cd_train="cd $PRJ_TRAIN_PATH"
alias cd_sim="cd $PRJ_SIM_PATH"
alias cd_scripts="cd $PRJ_SCRIPTS"
alias cd_hw_sources="cd $PRJ_HW_SOURCES_PATH"
alias cd_data="cd $PRJ_DATA_PATH"

# Simulate functions
#
# These are functions rather than aliases so that VUnit arguments can be forwarded,
# for example 'prj_simulate_lenet_accel --list' or '... -v'.
prj_simulate_lenet_accel() {
    python -u "$PRJ_HW_SOURCES_PATH/lenet_accel/sim/run_vunit_tb.py" "$@" 2>&1 | tee "$PRJ_GENERATED_PATH/lenet_accel_tb.log"
}

prj_simulate_help() {
    echo "###########################################################################"
    echo "# prj_simulate_help..........: Print all possible simulation runs"
    echo "# prj_simulate_lenet_accel...: Run the VUnit TB of the whole accelerator"
    echo "#                              (arguments are forwarded to VUnit)"
    echo "###########################################################################"
}

# Script for slicing the raw weights into one file per BRAM tile
prj_generate_bram_data() {
    python -u "$PRJ_DATA_PATH/generate_bram_data.py" "$@" | tee "$PRJ_GENERATED_PATH/generate_bram_data.log"
}

# Style guide check / fix over all VHDL of the accelerator
prj_style_check() {
    vsg -c "$PRJ_ROOT_PATH/vsg.yml" \
        -f $(find "$PRJ_HW_SOURCES_PATH" -name "*.vhd" -not -path "*vunit_out*") "$@" | tee "$PRJ_GENERATED_PATH/style_check.log"
}

prj_style_fix() {
    prj_style_check --fix
}

# Create the Vivado project from scratch and start the runs
prj_vivado_project() {
    vivado -mode batch -source "$PRJ_SCRIPTS/create_project.tcl" "$@" | tee "$PRJ_GENERATED_PATH/vivado_project.log"
}

# Script for executing the Training of the Model
prj_train() {
    python -u "$PRJ_TRAIN_PATH/training.py" "$@" | tee "$PRJ_GENERATED_PATH/training_debug.log"
}

# Installs the machine learning stack, which is only needed for the training notebooks.
# It is not part of the default install because it pulls in a multi GB torch build.
prj_install_ml() {
    python -m pip install torch torchvision brevitas onnx onnxruntime
}

# Build and run functions for executing the C++ Simulation
prj_build_simulation() {
    local CWD="$PWD"

    rm -rf "$PRJ_SIM_PATH/build"
    if [ ! -d "$PRJ_SIM_PATH/build" ]; then
        echo "# Removed old building directory located at $PRJ_SIM_PATH/build" | tee "$PRJ_GENERATED_PATH/simulation_build_debug.log"
    else
        echo "# Error while removing old directory located at $PRJ_SIM_PATH/build ! Abort..." | tee "$PRJ_GENERATED_PATH/simulation_build_debug.log"
        cd "$CWD"
        return 1
    fi

    mkdir "$PRJ_SIM_PATH/build"
    if [ $? -ne 0 ] ; then
        echo "# Could not create new building directory located at $PRJ_SIM_PATH/build" | tee -a "$PRJ_GENERATED_PATH/simulation_build_debug.log"
        cd "$CWD"
        return 1
    else
        echo "# Created new building directory located at $PRJ_SIM_PATH/build" | tee -a "$PRJ_GENERATED_PATH/simulation_build_debug.log"
    fi
    cd "$PRJ_SIM_PATH/build"
    cmake .. | tee -a "$PRJ_GENERATED_PATH/simulation_build_debug.log" || {
        echo "# CMake failed while compiling the Simulation! Abort..." | tee -a "$PRJ_GENERATED_PATH/simulation_build_debug.log"
        cd "$CWD"
        return 1
    }
    make | tee -a "$PRJ_GENERATED_PATH/simulation_build_debug.log" || {
        echo "# Make failed while compiling the Simulation! Abort..." | tee -a "$PRJ_GENERATED_PATH/simulation_build_debug.log"
        cd "$CWD"
        return 1
    }
    cd "$CWD"
    echo "# Finished building process for simulation successfully!" | tee -a "$PRJ_GENERATED_PATH/simulation_build_debug.log"
}

prj_run_simulation() {
    local CWD="$PWD"

    cd $PRJ_SIM_PATH/build || {
        echo "$PRJ_SIM_PATH/build does not exist! Run prj_build_simulation first and try again..." | tee $PRJ_GENERATED_PATH/simulation_run_debug.log
        return 1
    }
    $PRJ_SIM_PATH/build/simulation "$@" | tee $PRJ_GENERATED_PATH/simulation_run_debug.log
    cd $CWD
}

# Prevent direct execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script must be sourced, not executed directly!"
    echo "Use: source ./INIT.sh"
    exit 1
fi

# Check if generated folder exist and creates it if necessary
if [ ! -d "$PRJ_GENERATED_PATH" ]; then
    mkdir "$PRJ_GENERATED_PATH"
    if [ $? -ne 0 ] ; then
        echo "# Could not create new logging directory located at $PRJ_GENERATED_PATH"
        return 1
    else
        echo "# Created new logging directory located at $PRJ_GENERATED_PATH" | tee "$PRJ_GENERATED_PATH/init_debug.log"
        echo "" | tee -a "$PRJ_GENERATED_PATH/init_debug.log"
    fi
else
    echo "# Logging Directory at $PRJ_GENERATED_PATH already exists!" | tee "$PRJ_GENERATED_PATH/init_debug.log"
    echo "" | tee -a "$PRJ_GENERATED_PATH/init_debug.log"
fi

# Start logging manually
exec 3>&1 4>&2
exec > >(tee -a "$PRJ_GENERATED_PATH/init_debug.log") 2>&1

RESULT="SUCCESS"

echo "####################################################################"
echo "# Start INIT Script...:"
echo "####################################################################"
echo ""; echo ""

if [ ! -f "$PYTHON_BIN" ]; then
    echo "$PYTHON_BIN does not exist!"
    echo "Install it via 'pyenv install $PYTHON_VER' first..."
    echo ""; echo ""
    RESULT="FAILURE"
else

    if [[ ! -d "$PRJ_ROOT_PATH/$ENV_NAME"  ||  -n "$1" ]]; then
        $PYTHON_BIN -m venv "$PRJ_ROOT_PATH/$ENV_NAME"
        source "$PRJ_ROOT_PATH/$ENV_NAME/bin/activate"

        echo "####################################################################"
        echo "# Upgrading pip...:"
        echo "####################################################################"
        python -m pip install --upgrade pip
        echo ""; echo ""

        echo "####################################################################"
        echo "# Installing required packages...:"
        echo "####################################################################"
        # HDL flow
        python -m pip install vunit_hdl
        python -m pip install vsg
        # data handling and the measurement notebooks
        python -m pip install numpy
        python -m pip install matplotlib
        python -m pip install pandas
        python -m pip install ipykernel
        python -m pip install pyyaml
        echo ""
        echo "# The training notebooks additionally need torch/brevitas/onnx."
        echo "# Run 'prj_install_ml' to install them."
        echo ""; echo ""
    else
        echo "####################################################################"
        echo "# All required packages installed!"
        echo "####################################################################"
        echo ""
        source "$PRJ_ROOT_PATH/$ENV_NAME/bin/activate"
    fi

    if [ -n "$1" ]; then
        echo "####################################################################"
        echo "# Version checks...:"
        echo "####################################################################"
        python -c "import vunit;             print('# VUnit version.......:', vunit.__version__)"
        python -c "import numpy as np;       print('# Numpy version.......:', np.__version__)"
        python -c "import matplotlib as mpl; print('# Matplotlib version..:', mpl.__version__)"
        python -c "import pandas as pd;      print('# Pandas version......:', pd.__version__)"
        python -c "import ipykernel;         print('# Ipykernel version...:', ipykernel.__version__)"
        python -c "import yaml;              print('# PyYaml version......:', yaml.__version__)"
        echo "####################################################################"
        echo ""; echo ""
    else
        echo "####################################################################"
        echo "# Version checks skipped!"
        echo "####################################################################"
        echo ""
    fi

    echo "####################################################################"
    echo "# Virtual environment '$ENV_NAME' is ready with Packages installed."
    echo "####################################################################"
    echo ""

fi

echo "####################################################################"
echo "# Environmental variables...:"
echo "####################################################################"
echo "# PRJ_ROOT_PATH.......: $PRJ_ROOT_PATH"
echo "# PRJ_GENERATED_PATH..: $PRJ_GENERATED_PATH"
echo "# PRJ_TRAIN_PATH......: $PRJ_TRAIN_PATH"
echo "# PRJ_SIM_PATH........: $PRJ_SIM_PATH"
echo "# PRJ_SCRIPTS.........: $PRJ_SCRIPTS"
echo "# PRJ_HW_SOURCES_PATH.: $PRJ_HW_SOURCES_PATH"
echo "# PRJ_DATA_PATH.......: $PRJ_DATA_PATH"
echo "# PRJ_BRAM_DATA_PATH..: $PRJ_BRAM_DATA_PATH"
echo "# PRJ_CONSTRAINTS_PATH: $PRJ_CONSTRAINTS_PATH"
echo "# PRJ_BUILD_PATH......: $PRJ_BUILD_PATH"
echo "# VUNIT_SIMULATOR.....: $VUNIT_SIMULATOR"
echo "####################################################################"
echo ""; echo ""

echo "###########################################################################"
echo "# Environmental aliases...:"
echo "###########################################################################"
echo "# prj_generate_bram_data: Slice the raw weights into one file per BRAM tile"
echo "# prj_style_check.......: Run the VHDL style guide over all sources"
echo "# prj_style_fix.........: Same, but fix the violations in place"
echo "# prj_vivado_project....: Create the Vivado project and start the runs"
echo "# prj_train.............: Run the Training Script of the LeNet-5 Model"
echo "# prj_install_ml........: Install torch/brevitas/onnx for the training"
echo "# prj_build_simulation..: Run the building process for the"
echo "#                         C++ reference implementation"
echo "# prj_run_simulation....: Run the C++ reference implementation"
echo "###########################################################################"
echo "# Simulation Tools...:"
prj_simulate_help
echo "# cd_root...............: Change CWD to project root:"
echo "#                         [$PRJ_ROOT_PATH]"
echo "# cd_train..............: Change CWD to path of training folder:"
echo "#                         [$PRJ_TRAIN_PATH]"
echo "# cd_sim................: Change CWD to path of simulation folder:"
echo "#                         [$PRJ_SIM_PATH]"
echo "# cd_scripts............: Change CWD to path of scripts folder:"
echo "#                         [$PRJ_SCRIPTS]"
echo "# cd_hw_sources.........: Change CWD to path containing VHDL sources:"
echo "#                         [$PRJ_HW_SOURCES_PATH]"
echo "# cd_data...............: Change CWD to path containing the weights:"
echo "#                         [$PRJ_DATA_PATH]"
echo "###########################################################################"
echo ""; echo ""

echo "####################################################################"
echo "# Initialization result...: $RESULT"
echo "####################################################################"
echo ""

# Restore output
exec 1>&3 2>&4

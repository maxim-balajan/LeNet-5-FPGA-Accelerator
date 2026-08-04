# Vivado project scripts

The Vivado project is no longer checked in. It is created from scratch by these scripts,
so the repository only holds sources.

## Usage

```sh
source ./INIT.sh        # exports PRJ_* and activates the virtual environment
prj_vivado_project      # or: vivado -mode batch -source $PRJ_SCRIPTS/create_project.tcl
```

The project is written to `$PRJ_BUILD_PATH/LeNet-Accelerator` (`build/` by default).

## Files

| File | Purpose |
| --- | --- |
| `create_project.tcl` | Creates the project, adds all sources and constraints, builds the block design wrapper and starts the runs. |
| `lenet_accel_main_bd.tcl` | Block design (Zynq PS, AXI interconnect, AXI DMA and the accelerator wrapper). *Expected to exist.* |
| `synth.tcl` | Synthesis and implementation runs plus bitstream generation. *Expected to exist.* |

`create_project.tcl` also expects the Ultra96-v2 board files in `$PRJ_ROOT_PATH/bdf`.

## Environment

All paths come from the variables `INIT.sh` exports, each with a fallback derived from
`PRJ_ROOT_PATH`, so only `PRJ_ROOT_PATH` is strictly required:

| Variable | Used for |
| --- | --- |
| `PRJ_ROOT_PATH` | required; also locates `bdf/` |
| `PRJ_SCRIPTS` | the block design and synthesis scripts |
| `PRJ_HW_SOURCES_PATH` | the VHDL sources |
| `PRJ_DATA_PATH` | the weights and the BRAM data generator |
| `PRJ_CONSTRAINTS_PATH` | the Ultra96-v2 XDC |
| `PRJ_BUILD_PATH` | where the generated project is written |

The generator is run with `$PRJ_ROOT_PATH/.venv/bin/python` when that exists, otherwise
with `python3`.

## Notes

- **The design is VHDL-93.** All sources are added with file type `VHDL`, *not*
  `VHDL 2008`. Adding them as 2008 is harmless for analysis but hides accidental
  reintroduction of 2008-only constructs.
- **BRAM initialisation data.** Every BRAM tile initialises itself from its own file in
  `data/output`. Those files are generated from the raw `data/layer_weight_*.data` by
  `data/generate_bram_data.py`, which `create_project.tcl` runs automatically. To do it
  by hand: `prj_generate_bram_data`.
- **Relative data paths.** The VHDL defaults open their data files as `../data/output/...`.
  The VUnit runner overrides those with absolute paths via generics, but Vivado uses the
  defaults, so `create_project.tcl` copies `data/` next to the synthesis and simulation
  run directories. If elaboration fails with a file-open error, that copy is the first
  thing to check.
- **The test bench is not added to the Vivado project.** It is a VUnit test bench and is
  run with `prj_simulate_lenet_accel`.

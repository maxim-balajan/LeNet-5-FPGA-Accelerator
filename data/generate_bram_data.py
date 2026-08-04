#!/usr/bin/env python3
"""Generate one initialisation file per BRAM tile of the LeNet-5 accelerator.

The raw weight files produced by the training script store the weights of a whole
layer in one stream. The accelerator however distributes those weights over many
individual BRAM tiles, and every tile needs exactly the lines that belong to it.
That slicing used to happen inside VHDL (the `libmemory` package). Doing it here
keeps `bram_single_port` a plain "read this file" memory and keeps the elaboration
of the design fast.

Input  (this directory):
    layer_weight_0.data   first convolution   6 output channels x 1 input channel x 5x5
    layer_weight_1.data   second convolution  16 output channels x 6 input channels x 5x5
    layer_weight_2.data   first dense layer   120 rows x 400
    layer_weight_3.data   second dense layer  84 rows x 120
    layer_weight_4.data   third dense layer   10 rows x 84

Output (./output):
    conv_1_weights_ch<NNN>.data    6 files,   25 lines each
    conv_2_weights_ch<NNN>.data    6 files,  400 lines each
    dense_weights_row<NNN>.data  120 files,  604 lines each

Run it from anywhere:  python3 data/generate_bram_data.py
"""

import argparse
import os
import sys

# --------------------------------------------------------------------------------------
# Configuration of the LeNet-5 network. These have to match the generics of lenet_accel.
# --------------------------------------------------------------------------------------

KERNEL_SIZE = 5
KERNEL_AREA = KERNEL_SIZE * KERNEL_SIZE

CONV_1_INPUT_CHANNELS = 1
CONV_1_OUTPUT_CHANNELS = 6

CONV_2_INPUT_CHANNELS = 6
CONV_2_OUTPUT_CHANNELS = 16

# (width, height) of every dense layer, width == amount of weights in one row
DENSE_LAYERS = [(400, 120), (120, 84), (84, 10)]

# One BRAM tile per MAC of the matrix vector unit
DENSE_MAC_AMOUNT = max(height for _, height in DENSE_LAYERS)

ZERO = "00"


def read_lines(path):
    """Read a weight file and return its non empty lines."""
    with open(path) as handle:
        lines = [line.strip() for line in handle]
    return [line for line in lines if line]


def write_lines(path, lines):
    with open(path, "w") as handle:
        handle.write("\n".join(lines))
        handle.write("\n")


def expect(condition, message):
    if not condition:
        sys.exit("ERROR: " + message)


def gen_conv_1(weights, out_dir):
    """First convolution: one tile per output channel.

    All input channels of one output channel lie next to each other in the file, so a
    tile is a single contiguous block.
    """
    block = KERNEL_AREA * CONV_1_INPUT_CHANNELS
    expect(
        len(weights) == block * CONV_1_OUTPUT_CHANNELS,
        "layer_weight_0.data has %d lines, expected %d"
        % (len(weights), block * CONV_1_OUTPUT_CHANNELS),
    )

    written = []
    for channel in range(CONV_1_OUTPUT_CHANNELS):
        start = channel * block
        name = "conv_1_weights_ch%03d.data" % channel
        write_lines(os.path.join(out_dir, name), weights[start:start + block])
        written.append((name, block))
    return written


def gen_conv_2(weights, out_dir):
    """Second convolution: one tile per input channel.

    The output channels are computed one after the other, so a tile has to hold its own
    input channel for every output channel. Those blocks are interleaved in the file:
    one stride covers all input channels of a single output channel.
    """
    stride = KERNEL_AREA * CONV_2_INPUT_CHANNELS
    expect(
        len(weights) == stride * CONV_2_OUTPUT_CHANNELS,
        "layer_weight_1.data has %d lines, expected %d"
        % (len(weights), stride * CONV_2_OUTPUT_CHANNELS),
    )

    written = []
    for channel in range(CONV_2_INPUT_CHANNELS):
        tile = []
        for out_channel in range(CONV_2_OUTPUT_CHANNELS):
            start = out_channel * stride + channel * KERNEL_AREA
            tile.extend(weights[start:start + KERNEL_AREA])
        name = "conv_2_weights_ch%03d.data" % channel
        write_lines(os.path.join(out_dir, name), tile)
        written.append((name, len(tile)))
    return written


def gen_dense(layers, out_dir):
    """Dense layers: one tile per MAC.

    The matrix vector unit is reused for all three dense layers, so MAC i holds row i of
    every layer, stored back to back at fixed offsets. Layers that have fewer rows than
    there are MACs leave their slot zeroed, which is what the unused MACs read.
    """
    for index, (weights, (width, height)) in enumerate(zip(layers, DENSE_LAYERS)):
        expect(
            len(weights) == width * height,
            "layer_weight_%d.data has %d lines, expected %d"
            % (index + 2, len(weights), width * height),
        )

    depth = sum(width for width, _ in DENSE_LAYERS)

    written = []
    for row in range(DENSE_MAC_AMOUNT):
        tile = []
        for weights, (width, height) in zip(layers, DENSE_LAYERS):
            if row < height:
                tile.extend(weights[row * width:(row + 1) * width])
            else:
                # this layer is not that tall, the slot stays empty
                tile.extend([ZERO] * width)
        expect(len(tile) == depth, "internal error while building dense row %d" % row)
        name = "dense_weights_row%03d.data" % row
        write_lines(os.path.join(out_dir, name), tile)
        written.append((name, depth))
    return written


def main():
    here = os.path.dirname(os.path.abspath(__file__))

    # INIT.sh exports these; fall back to this file's own location so that the script
    # also works in a plain checkout without sourcing anything.
    default_input = os.environ.get("PRJ_DATA_PATH", here)
    default_output = os.environ.get("PRJ_BRAM_DATA_PATH", os.path.join(default_input, "output"))

    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--input-dir", default=default_input,
                        help="directory holding the raw layer_weight_*.data files "
                             "(default: $PRJ_DATA_PATH)")
    parser.add_argument("--output-dir", default=default_output,
                        help="directory the BRAM initialisation files are written to "
                             "(default: $PRJ_BRAM_DATA_PATH)")
    args = parser.parse_args()

    for index in range(5):
        path = os.path.join(args.input_dir, "layer_weight_%d.data" % index)
        expect(os.path.isfile(path), "missing input file " + path)

    if not os.path.isdir(args.output_dir):
        os.makedirs(args.output_dir)

    def load(index):
        return read_lines(os.path.join(args.input_dir, "layer_weight_%d.data" % index))

    written = []
    written += gen_conv_1(load(0), args.output_dir)
    written += gen_conv_2(load(1), args.output_dir)
    written += gen_dense([load(2), load(3), load(4)], args.output_dir)

    total_lines = sum(lines for _, lines in written)
    print("wrote %d BRAM files (%d lines total) to %s"
          % (len(written), total_lines, args.output_dir))
    for name, lines in written[:3]:
        print("  %s (%d lines)" % (name, lines))
    print("  ...")


if __name__ == "__main__":
    main()

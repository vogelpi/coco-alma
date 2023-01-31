#!/usr/bin/env python3
# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
"""
The flip-flop-based bignum register file is defined as

  logic [311:0] rf [32];

and depending on involved tool versions, the synthesis flow may generate a single packed array
for this as follows

  reg [9983:0] rf;

In addition, the unpacked dimension "[32]" is understood as the big-endian notation, i.e., it
is equal to [0:31]. As a result, the following correspondence between bits in "rf" and the
actual bignum register may result:

  w0  - rf[9983:9672]
  w1  - rf[9671:9360]
  w2  - rf[9359:9048]
  .   .        .
  w31 - rf[ 311:   0]

The purpose of the script is to generate the correct "rf" inidices for labels placed on the
bignum registers w0 - w31.
"""
import argparse
import re


def main():
    parser = argparse.ArgumentParser(
        prog="generate_bignum_rf_labels",
        description="Script to generate Coco-Alma labels for variables in OTBN bignum RF",
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('--input-file',
                        '-i',
                        type=str,
                        required=True,
                        help='Input file')
    parser.add_argument('--output-file',
                        '-o',
                        type=str,
                        required=True,
                        help='Output file')
    parser.add_argument('--width',
                        '-w',
                        type=int,
                        help='Width of variables. Defaults to ExtWLEN. Specify smaller values\
                              to reduce execution time.')
    parser.add_argument('--offset',
                        '-s',
                        type=int,
                        help='Offset of variables in OTBN bignum RF. Defaults to 0.')
    args = parser.parse_args()

    with open(args.input_file, 'r') as f:
        input_lines = f.readlines()

    bignum_rf_path = "u_otbn_core.u_otbn_rf_bignum.gen_rf_bignum_ff.u_otbn_rf_bignum_inner.rf"
    nwdrs = 32
    extwlen = 8 * (32 + 7)

    # Checking width and offset.
    width = args.width if args.width else extwlen
    if (width > extwlen) or (width < 1):
        width = extwlen
        print("WARNING: Setting width to " + str(width) + ".")

    offset = args.offset if args.offset else 0
    if width + offset > extwlen:
        offset = 0
        print("WARNING: Setting offset to " + str(offset) + ".")

    output_lines = []
    for line in input_lines:

        # Extract bignum RF indices and labels.
        pattern = re.compile("w([0-9]+):\\s*([a-z_]+)\\s*([0-9]*)")
        wdr = pattern.match(line)
        if not wdr:
            print("Line " + str(input_lines.index(line)) + ": No WDR label found - " + line, end="")
            output_lines.append(line)
            continue

        wdr_index, qualifier, qualifier_index = wdr.groups()
        wdr_index = int(wdr_index)

        # Compute rf bit indices.
        rf_indices = " [" + str((nwdrs - wdr_index - 1) * extwlen + width + offset - 1)
        if width > 1:
            rf_indices += ":" + str((nwdrs - wdr_index - 1) * extwlen + offset)
        rf_indices += "]"

        # Compute secret indices.
        if not qualifier_index:
            qualifier_indices = ""
        else:
            qualifier_index = int(qualifier_index)
            qualifier_indices = " " + str((qualifier_index + 1) * width - 1)
            if width > 1:
                qualifier_indices += ":" + str(qualifier_index * width)

        output_line = bignum_rf_path + rf_indices + " = " + qualifier + qualifier_indices + "\n"

        print("Line " + str(input_lines.index(line)) + ": WDR label found - " + output_line, end="")
        output_lines.append(output_line)

    with open(args.output_file, 'w') as f:
        f.writelines(output_lines)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Design a 2nd-order Butterworth low-pass and print float32 IEEE-754 bit patterns
for filter_float_IIR_buttorworth.v, and audit the constants already in that file.

The module computes  y = X_K*x + X_1_K*x1 + X_2_K*x2 + Y_1_K*y1 - Y_2_K*y2,
so Y_1_K = -a1 and Y_2_K = a2 for scipy's (b, a) with a[0] = 1.

Usage:
  python tools/iir_coeffs.py --fc 1000 --fs 50000        # new constants
  python tools/iir_coeffs.py --audit                      # check the RTL constants
"""
import argparse
import re
import struct
from pathlib import Path

import numpy as np
from scipy import signal

RTL = Path(__file__).resolve().parents[1] / "filter_float_IIR_buttorworth.v"
NAMES = ("X_K", "X_1_K", "X_2_K", "Y_1_K", "Y_2_K")


def f32_bits(x):
    return format(struct.unpack(">I", struct.pack(">f", x))[0], "032b")


def bits_f32(b):
    return struct.unpack(">f", int(b, 2).to_bytes(4, "big"))[0]


def design(fc, fs):
    b, a = signal.butter(2, fc / (fs / 2))
    return dict(zip(NAMES, (b[0], b[1], b[2], -a[1], a[2])))


def read_rtl(path=RTL):
    text = path.read_text()
    out = {}
    for name in NAMES:
        m = re.search(rf"\b{name}\s*=\s*32'b([01]{{32}})", text)
        out[name] = bits_f32(m.group(1))
    return out


def dc_gain(c):
    return (c["X_K"] + c["X_1_K"] + c["X_2_K"]) / (1 - c["Y_1_K"] + c["Y_2_K"])


def fit_wn(c):
    """Normalised cutoff (fc / (fs/2)) of the Butterworth design closest to c."""
    grid = np.linspace(1e-4, 0.5, 50000)
    target = np.array([c[n] for n in NAMES])
    err = [np.abs(np.array(list(design(w, 2.0).values())) - target).sum() for w in grid]
    return float(grid[int(np.argmin(err))])


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--fc", type=float)
    ap.add_argument("--fs", type=float)
    ap.add_argument("--audit", action="store_true")
    args = ap.parse_args()
    if args.audit:
        c = read_rtl()
        for n in NAMES:
            print(f"{n:6s} = {c[n]:.9g}")
        print(f"DC gain      = {dc_gain(c):.6f}  (ideal 1.0)")
        print(f"fitted Wn    = {fit_wn(c):.5f}  -> fc = {fit_wn(c) / 2:.5f} * f_update")
        print(f"pole radius  = {max(abs(np.roots([1, -c['Y_1_K'], c['Y_2_K']]))):.5f}")
        return
    if args.fc is None or args.fs is None:
        ap.error("give --fc and --fs, or --audit")
    for n, v in design(args.fc, args.fs).items():
        print(f"reg [31:0] {n:6s} = 32'b{f32_bits(v)}; // {v:.9g}")


if __name__ == "__main__":
    main()

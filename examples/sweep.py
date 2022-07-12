from __future__ import print_function
import datetime
import math

from benchmark import run_benchmark
import cunumeric as np
from examples.stencil_27 import run_stencil

def benchmark_stencil(args):
    totals = []
    for arg in args:
        N,I = arg
        timing=True
        total = run_benchmark(
            run_stencil, benchmark, "Stencil", (N, I, timing)
        )
        totals.append((N,I,total))

N = 300
I = 100
totals = benchmark_stencil([])
for total in totals:
    print("N: ",N, " : ", total)

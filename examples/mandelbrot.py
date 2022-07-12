# -----------------------------------------------------------------------------
# From Numpy to Python
# Copyright (2017) Nicolas P. Rougier - BSD license
# More information at https://github.com/rougier/numpy-book
# -----------------------------------------------------------------------------

import cunumeric as np
import numpy as npy
import argparse
import datetime
import math 

def linspace(start, stop, num, dtype):
    X = np.empty((num, ), dtype=dtype)
    dist = (stop - start) / (num - 1)
    for i in range(num):
        X[i] = start + i * dist
    return X


def mandelbrot(xmin, xmax, ymin, ymax, xn, yn, maxiter, horizon=4.0, D=np.float32, timing=True):
    # Adapted from https://www.ibm.com/developerworks/community/blogs/jfp/...
    #              .../entry/How_To_Compute_Mandelbrodt_Set_Quickly?lang=en

    X = linspace(xmin, xmax, xn, dtype=D)
    Y = linspace(ymin, ymax, yn, dtype=D)
    Y1 = Y[:, None]
    N = np.zeros((xn, yn), dtype=np.int32)
    Zre = np.zeros((xn, xn), dtype=D)
    Zim = np.zeros((yn, yn), dtype=D)
    #tmp = np.zeros((yn, yn), dtype=D)
    start = datetime.datetime.now()
    for n in range(maxiter):
        I = np.less(Zre*Zre + Zim*Zim, horizon)
        N = (I)*n+(~I)*N

        tmp = (Zre)*Zre - (Zim)*Zim + X
        ZimTemp = 2.0 * Zre  * Zim + Y1

        Zre = tmp*(I) + Zre*(~I)
        Zim = ZimTemp*(I) + Zim*(~I)
        
    assert np.sum(N)>0
    stop = datetime.datetime.now()
    delta = stop - start
    total = delta.total_seconds() * 1000.0
    if timing:
        print("Elapsed Time: " + str(total) + " ms")
    NmaxIter = (N==maxiter -1)
    N = np.int32(~NmaxIter)*N
    return Zre, Zim, N, total

g=2000
xmin = -1.75
xmax = .25
xn = g
ymin = -1.0
ymax = 1.0
yn=g
maxiter=500

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-n",
        "--ndim",
        dest="ndim",
        type=int,
        default=1,
        help="save iteration data",
    )

    parser.add_argument(
        "-b",
        "--benchmark",
        dest="nbenchmark",
        type=int,
        default=3,
        help="save iteration data",
    )



    parser.add_argument(
        "-s",
        "--save_data",
        dest="save_data",
        action="store_true",
        default=False,
        help="save iteration data",
    )
 
    parser.add_argument(
        "-g",
        "--genimage",
        dest="make_image",
        action="store_true",
        default=False,
        help="generate image",
    )
 
    args = parser.parse_args()
    totals = []
    for i in range(args.nbenchmark):
        Zre, Zim, N, total = mandelbrot(xmin, xmax, ymin, ymax, args.ndim, args.ndim, maxiter, 4.0,np.float32, True)
        totals.append(total)
    print("parsetotal", float(sum(totals))/len(totals)) 

    if args.save_data:
       with open("data.npy", 'wb') as f:
           N=npy.array(N, dtype=np.int32)
           np.save(f,N)

    if args.make_image:
        from PIL import Image
        # creating a image object
        image  = Image.new(mode="1", size=(args.ndim, args.ndim)) 
        N=(N%2==0)  
        print(N.type)
        width, height = image.size
        data = Image.fromarray(N)
        data.save("data.png")

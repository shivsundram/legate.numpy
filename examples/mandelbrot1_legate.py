# -----------------------------------------------------------------------------
# From Numpy to Python
# Copyright (2017) Nicolas P. Rougier - BSD license
# More information at https://github.com/rougier/numpy-book
# -----------------------------------------------------------------------------

#import cunumeric as np
import numpy as np


def linspace(start, stop, num, dtype):
    X = np.empty((num, ), dtype=dtype)
    dist = (stop - start) / (num - 1)
    for i in range(num):
        X[i] = start + i * dist
    return X

def mandelbrotR(xmin, xmax, ymin, ymax, xn, yn, maxiter, horizon=2.0):
    # Adapted from https://www.ibm.com/developerworks/community/blogs/jfp/...
    #              .../entry/How_To_Compute_Mandelbrodt_Set_Quickly?lang=en
    X = linspace(xmin, xmax, xn, dtype=np.float32)
    Y = linspace(ymin, ymax, yn, dtype=np.float32)
    # C = X + Y[:,None]*1j
    N = np.zeros((xn, yn), dtype=np.int64)
    Zre = np.zeros((xn, yn), dtype=np.float32)
    Zim = np.zeros((xn, yn), dtype=np.float32)
    for n in range(maxiter):
        I = np.less(np.sqrt(Zre**2 + Zim**2), horizon)
        N[:] = np.int64(I) * n + np.int64(~I) * N
        Zre[:] = np.int64(I) * (Zre**2 - Zim**2 + X[:, None]) + np.int64(~I)*Zre
        Zim[:] = np.int64(I) * (2 * Zre * Zim + Y[None, :]) + np.int64(~I)*Zim
    I = np.not_equal(N, maxiter - 1)
    N[:] = np.int64(I) * N
    #for n in range(maxiter):
    #    I = np.less(np.sqrt(Zre**2 + Zim**2), horizon)
    #    print(I.shape)
    #    N[I] = n
    #    # Z[I] = Z[I]**2 + C[I]
    #    tmp = Zre[I]**2 - Zim[I]**2 + X[I, None]
    #    Zim[I] = 2 * Zre[I] * Zim[I] + Y[None, I]
    #    Zre[I] = tmp
    #N[N == maxiter - 1] = 0
    return Zre, Zim, N

    #for n in range(maxiter):
    #    I = np.less(np.sqrt(Zre**2 + Zim**2), horizon)
    #    N[:] = np.int64(I) * n + np.int64(~I) * N
    #    Zre[:] = np.int64(I) * (Zre**2 - Zim**2 + X[:, None]) + np.int64(~I)*Zre
    #    Zim[:] = np.int64(I) * (2 * Zre * Zim + Y[None, :]) + np.int64(~I)*Zim
    #I = np.not_equal(N, maxiter - 1)
    #N[:] = np.int64(I) * N

def mandelbrotN(xmin, xmax, ymin, ymax, xn, yn, maxiter, horizon=2.0):
    # Adapted from https://www.ibm.com/developerworks/community/blogs/jfp/...
    #              .../entry/How_To_Compute_Mandelbrodt_Set_Quickly?lang=en
    X = np.linspace(xmin, xmax, xn, dtype=np.float64)
    Y = np.linspace(ymin, ymax, yn, dtype=np.float64)
    C = X + Y[:, None] * 1j
    N = np.zeros(C.shape, dtype=np.int64)
    Z = np.zeros(C.shape, dtype=np.complex128)
    for n in range(maxiter):
        I = np.less(np.absolute(Z), horizon)
        #print(np.absolute(Z))
        N[I] = n
        Z[I] = Z[I]**2 + C[I]
    N[N == maxiter - 1] = 0
    return Z, N



def mandelbrot(xmin, xmax, ymin, ymax, xn, yn, maxiter, horizon=4.0):
    # Adapted from https://www.ibm.com/developerworks/community/blogs/jfp/...
    #              .../entry/How_To_Compute_Mandelbrodt_Set_Quickly?lang=en
    X = linspace(xmin, xmax, xn, dtype=np.float64)
    Y = linspace(ymin, ymax, yn, dtype=np.float64)
    N = np.zeros((xn, yn), dtype=np.int64)
    Zre = np.zeros((xn, xn), dtype=np.float64)
    Zim = np.zeros((yn, yn), dtype=np.float64)
    for n in range(maxiter):
        I = np.less(Zre*Zre + Zim*Zim, horizon)
        N = np.int64(I)*n+np.int64(~I)*N

        tmp = (Zre)*Zre - (Zim)*Zim + X
        ZimTemp = 2 * Zre  * Zim + Y[:, None]

        Zre = tmp*np.int64(I) + Zre*np.int64(~I)
        Zim = ZimTemp*np.int64(I) + Zim*np.int64(~I)
        
    NmaxIter = (N==maxiter -1)
    N = np.int64(~NmaxIter)*N
    return Zre, Zim, N

g=2000
xmin = -1.75
xmax = .25
xn = g
ymin = -1.0
ymax = 1.0
yn=g
maxiter=100

for i in range(1):
    total=run_benchmark(
        mandelbrot, 3, "mandelbrot", (xmin, xmax, ymin, ymax, xn, yn, maxiter, horizone=4.0)
    )
    Zre, Zim, N = mandelbrot(xmin, xmax, ymin, ymax, xn, yn, maxiter, horizon=4.0)
    #Z1, N1 = mandelbrotN(xmin, xmax, ymin, ymax, xn, yn, maxiter, horizon=2.0)
from PIL import Image
      
# creating a image object
image  = Image.new(mode="1", size=(xn, yn)) 
N=(N%2==0)  
N=np.array(N, dtype=bool)
width, height = image.size
data = Image.fromarray(N)
data.save("data.png")

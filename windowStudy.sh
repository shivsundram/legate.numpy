#!/bin/bash

#for getting fusability info
CGPUSPERNODE=1
RUNNER="srun"
hostName=$(hostname)
echo "current host" $hostName 
if [[ $hostName == *"lassen"* ]]; then
  CGPUSPERNODE=4
  RUNNER="jsrun"
fi
if [[ $hostName == *"sapling"* ]]; then
  CGPUSPERNODE=4
  RUNNER="mpirun"
fi
if [[ $hostName == *"daint"* ]]; then
  CGPUSPERNODE=1
fi


while getopts ":wmbsuljtv" option; do
   case $option in
      w) # Enter a name
         echo "requesting weighted stencil"
         WS=1
         ;;
      m) # Enter a name
         echo "requesting mandelbrot"
         M=1;;
      b) # Enter a name
         echo "requesting black scholes"
         B=1;;
      u) # Enter a name
         echo "requesting unweighted 3d stencil"
         S=1;;
      l) # Enter a name
         echo "requesting logreg"
         L=1;;
      j) # Enter a name
         echo "requesting jacobi"
         J=1;;
      t) # Enter a name
         echo "requesting 2d weighted stencil"
         T=1;;
      v) # Enter a name
         echo "requesting black scholes with various workloads on 4 nodes"
         V=1;;
     \?) echo "invalid option";;
   esac
done


echo "Identified" $CGPUSPERNODE "gpus per node"
echo "Current allocation:" $SLURM_JOB_NUM_NODES 
echo "Using Runner" $RUNNER

#regular 3d stencil
for i in "4 300"
do
    if [ -z "$S" ]; then
       break;
    fi
    set -- $i # convert the "tuple" into the param args $1 $2...
    ZNODES=$(($1 / $CGPUSPERNODE))
    NODES=$(( $ZNODES > 1 ? $ZNODES : 1 ))
    GPUSPERNODE=$(( $ZNODES > 1 ? $CGPUSPERNODE : $1 ))

    WSIZE=50
    if [[ "$SLURM_JOB_NUM_NODES" -lt "$NODES" ]]; then
        break
    fi

    echo running stencil with ngpus $1, $NODES nodes, size $2 , window size $WSIZE, gpuspernode $GPUSPERNODE
    LEGATE_WINDOW_SIZE=$WSIZE ../legate.core/install/bin/legate examples/stencil_27.py -n $2 -i 2 -t -b 1 --gpus $GPUSPERNODE -ll:fsize 12000 --launcher $RUNNER --nodes $NODES 
    echo running stencil with ngpus $1, $NODES nodes, size $2 , window size 1
    #LEGATE_WINDOW_SIZE=1 ../legate.core/install/bin/legate examples/stencil_27.py -n $2 -i 2 -t -b 1 --gpus $GPUSPERNODE -ll:fsize 12000 --launcher $RUNNER --nodes $NODES 
done

#weighted 3d stencil
#for i in  "32 600"
#for i in "1 188" "2 238" "4 300" "8 378" "16 476" 
for i in "4 300"
do
    if [ -z "${WS}" ]; then
       break;
    fi
    set -- $i # convert the "tuple" into the param args $1 $2...
    ZNODES=$(($1 / $CGPUSPERNODE))
    NODES=$(( $ZNODES > 1 ? $ZNODES : 1 ))
    GPUSPERNODE=$(( $ZNODES > 1 ? $CGPUSPERNODE : $1 ))

    WSIZE=50
    if [[ "$SLURM_JOB_NUM_NODES" -lt "$NODES" ]]; then
        break
    fi
    cp cOn.py cunumeric/array.py
    echo running stencil C with ngpus $1, $NODES nodes, size $2 , window size $WSIZE, gpuspernode $GPUSPERNODE
    LEGATE_WINDOW_SIZE=$WSIZE ../legate.core/install/bin/legate examples/stencil_27C.py -n $2 -i 10 -t -b 1 --gpus $GPUSPERNODE -ll:fsize 12000 --launcher $RUNNER --nodes $NODES 
    #cp cOff.py cunumeric/array.py
    #echo running stencil C  with ngpus $1, $NODES nodes, size $2 , window size 1
    #LEGATE_WINDOW_SIZE=1 ../legate.core/install/bin/legate examples/stencil_27C.py -n $2 -i 2 -t -b 1 --gpus $GPUSPERNODE -ll:fsize 12000 --launcher $RUNNER --nodes $NODES 
    #cp cOn.py cunumeric/array.py
done


#logreg
echo "do logreg"
for i in "4 6400" 
do
    if [ -z "$L" ]; then
       break;
    fi
    set -- $i # convert the "tuple" into the param args $1 $2...
    ZNODES=$(($1 / $CGPUSPERNODE))
    NODES=$(( $ZNODES > 1 ? $ZNODES : 1 ))
    GPUSPERNODE=$(( $ZNODES > 1 ? $CGPUSPERNODE : $1 ))


    WSIZE=50
    if [[ "$SLURM_JOB_NUM_NODES" -lt "$NODES" ]]; then
        break
    fi
    cp cOn.py cunumeric/array.py
    echo running logreg with ngpus $1, $NODES nodes, size $2 , window size $WSIZE
    LEGATE_WINDOW_SIZE=50 ../legate.core/install/bin/legate examples/logreg.py -i 5 --gpus $GPUSPERNODE -n $2 -s 500  -ll:fsize 12000 --benchmark 1 --launcher $RUNNER --nodes $NODES 2>&1  
    #cp cOff.py cunumeric/array.py
    #echo running logreg with ngpus $1, $NODES nodes, size $2 , window size 1
    #LEGATE_WINDOW_SIZE=1 ../legate.core/install/bin/legate examples/logreg.py -i 5 --gpus $GPUSPERNODE -n $2 -s 500  -ll:fsize 12000 --benchmark 1 --launcher $RUNNER --nodes $NODES 2>&1 
    #cp cOn.py cunumeric/array.py
done


#jacobi
echo "do jacobi"
#for i in  "8 18101"
for i in "4 12800" 
do
    if [ -z "$J" ]; then
       break;
    fi
    set -- $i # convert the "tuple" into the param args $1 $2...
    ZNODES=$(($1 / $CGPUSPERNODE))
    NODES=$(( $ZNODES > 1 ? $ZNODES : 1 ))
    GPUSPERNODE=$(( $ZNODES > 1 ? $CGPUSPERNODE : $1 ))


    WSIZE=50
    if [[ "$SLURM_JOB_NUM_NODES" -lt "$NODES" ]]; then
        break
    fi
    cp cOn.py cunumeric/array.py
    echo running jacobi with ngpus $1, $NODES nodes, size $2 , $GPUSPERNODE gpu per node, window size $WSIZE
    #LEGATE_WINDOW_SIZE=50 ../legate.core/install/bin/legate examples/jacobi.py -i 5000 --gpus $GPUSPERNODE -n $2  -ll:fsize 12000 --benchmark 3 --launcher $RUNNER --nodes $NODES
    LEGATE_TEST=1 LEGATE_WINDOW_SIZE=50 ../legate.core/install/bin/legate examples/jacobi.py -i 10 --gpus $GPUSPERNODE -n $2  -ll:fsize 12000 --benchmark 1 --launcher $RUNNER --nodes $NODES 2>&1   
    cp cOff.py cunumeric/array.py
    echo running jacobi with ngpus $1, $NODES nodes, size $2 , window size 1
    LEGATE_TEST=1 LEGATE_WINDOW_SIZE=1 ../legate.core/install/bin/legate examples/jacobi.py -i 10 --gpus $GPUSPERNODE -n $2  -ll:fsize 12000 --benchmark 1 --launcher $RUNNER --nodes $NODES 2>&1  
    cp cOn.py cunumeric/array.py
done




#mandelbrot
echo "do mandelbrot"
for i in  "4 2000" 
do
    if [ -z "$M" ]; then
       break;
    fi
    set -- $i # convert the "tuple" into the param args $1 $2...
    ZNODES=$(($1 / $CGPUSPERNODE))
    NODES=$(( $ZNODES > 1 ? $ZNODES : 1 ))
    GPUSPERNODE=$(( $ZNODES > 1 ? $CGPUSPERNODE : $1 ))


    WSIZE=50
    if [[ "$SLURM_JOB_NUM_NODES" -lt "$NODES" ]]; then
        break
    fi
    echo gpus per node $GPUSPERNODE
    #cp cOn.py cunumeric/array.py
    cp cOn.py cunumeric/array.py
    echo running mandel with ngpus $1, $NODES nodes, size $2 , window size $WSIZE
    echo LEGATE_WINDOW_SIZE=50 ../legate.core/install/bin/legate examples/mandelbrot.py --gpus $GPUSPERNODE --nodes $NODES --launcher $RUNNER -n $2 
    LEGATE_WINDOW_SIZE=50 ../legate.core/install/bin/legate examples/mandelbrot2.py --gpus $GPUSPERNODE --nodes $NODES --launcher $RUNNER -n $2 

    #cp cOff.py cunumeric/array.py
    #echo running mandel with ngpus $1, $NODES nodes, size $2 , window size 1, no copt
    #LEGATE_WINDOW_SIZE=1 ../legate.core/install/bin/legate examples/mandelbrot.py --gpus $GPUSPERNODE --nodes $NODES --launcher $RUNNER -n $2  

    #cp cOn.py cunumeric/array.py
    #echo running mandel with ngpus $1, $NODES nodes, size $2 , window size 1, copt
    #LEGATE_WINDOW_SIZE=1 ../legate.core/install/bin/legate examples/mandelbrot.py --gpus $GPUSPERNODE --nodes $NODES --launcher $RUNNER -n $2  
done

#black scholes
echo "do black scholes"
#for i  in "4 51200" "4 25600" "4 6400" "4 3200" "4 1600"
for i in "4 12800" 
do
    if [ -z "$B" ]; then
       break;
    fi
    set -- $i # convert the "tuple" into the param args $1 $2...
    ZNODES=$(($1 / $CGPUSPERNODE))
    NODES=$(( $ZNODES > 1 ? $ZNODES : 1 ))
    GPUSPERNODE=$(( $ZNODES > 1 ? $CGPUSPERNODE : $1 ))


    WSIZE=50
    if [[ "$SLURM_JOB_NUM_NODES" -lt "$NODES" ]]; then
        break
    fi
    echo running BS with ngpus $1, $NODES nodes, size $2 , window size $WSIZE
    cp cOn.py cunumeric/array.py
    LEGATE_TEST=1 LEGATE_WINDOW_SIZE=50 ../legate.core/install/bin/legate examples/black_scholes2.py  -ll:fsize 12000 --gpus $GPUSPERNODE -b 1 --nodes $NODES --launcher $RUNNER -n $2 2>&1   
    #

    #echo running BS with ngpus $1, $NODES nodes, size $2 , window size 1
    #cp cOff.py cunumeric/array.py
    #LEGATE_TEST=1 LEGATE_WINDOW_SIZE=1 ../legate.core/install/bin/legate examples/black_scholes.py -ll:fsize 12000 --gpus $GPUSPERNODE -b 1 --nodes $NODES --launcher $RUNNER -n $2 2>&1 

    #echo running BS with ngpus $1, $NODES nodes, size $2 , window size 1, copt on
    #cp cOn.py cunumeric/array.py
    #LEGATE_WINDOW_SIZE=1 ../legate.core/install/bin/legate examples/black_scholes.py -ll:fsize 12000 --gpus $GPUSPERNODE -b 3 --nodes $NODES --launcher $RUNNER -n $2 2>&1 
done

#black scholes with var workloads
echo "do black scholes with various workloads"
for i  in "4 51200" "4 25600" "4 6400" "4 3200" "4 1600"
do
    if [ -z "$V" ]; then
       break;
    fi
    set -- $i # convert the "tuple" into the param args $1 $2...
    ZNODES=$(($1 / $CGPUSPERNODE))
    NODES=$(( $ZNODES > 1 ? $ZNODES : 1 ))
    GPUSPERNODE=$(( $ZNODES > 1 ? $CGPUSPERNODE : $1 ))


    WSIZE=50
    if [[ "$SLURM_JOB_NUM_NODES" -lt "$NODES" ]]; then
        break
    fi
    echo running BS with ngpus $1, $NODES nodes, size $2 , window size $WSIZE
    cp cOn.py cunumeric/array.py
    LEGATE_TEST=1 LEGATE_WINDOW_SIZE=50 ../legate.core/install/bin/legate examples/black_scholes.py  -ll:fsize 12000 --gpus $GPUSPERNODE -b 3 --nodes $NODES --launcher $RUNNER -n $2 2>&1   
    #

    echo running BS with ngpus $1, $NODES nodes, size $2 , window size 1
    cp cOff.py cunumeric/array.py
    LEGATE_TEST=1 LEGATE_WINDOW_SIZE=1 ../legate.core/install/bin/legate examples/black_scholes.py -ll:fsize 12000 --gpus $GPUSPERNODE -b 3 --nodes $NODES --launcher $RUNNER -n $2 2>&1 

    #echo running BS with ngpus $1, $NODES nodes, size $2 , window size 1, copt on
    #cp cOn.py cunumeric/array.py
    #LEGATE_WINDOW_SIZE=1 ../legate.core/install/bin/legate examples/black_scholes.py -ll:fsize 12000 --gpus $GPUSPERNODE -b 3 --nodes $NODES --launcher $RUNNER -n $2 2>&1 
done



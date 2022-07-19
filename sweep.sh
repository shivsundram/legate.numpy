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

echo "Identified" $CGPUSPERNODE "gpus per node"
echo "Current allocation:" $SLURM_JOB_NUM_NODES 
echo "Using Runner" $RUNNER

for i in "1 188" "2 238" "4 300 8 378 16 400" 
do
    break
    set -- $i # convert the "tuple" into the param args $1 $2...
    ZNODES=$(($1 / $CGPUSPERNODE))
    NODES=$(( $ZNODES > 1 ? $ZNODES : 1 ))
    GPUSPERNODE=$(( $ZNODES > 1 ? $CGPUSPERNODE : $1 ))

    WSIZE=50
    if [[ "$SLURM_JOB_NUM_NODES" -lt "$NODES" ]]; then
        break
    fi

    echo running stencil with ngpus $1, $NODES nodes, size $2 , window size $WSIZE, gpuspernode $GPUSPERNODE
    LEGATE_WINDOW_SIZE=$WSIZE ../legate.core/install/bin/legate examples/stencil_27.py -n $2 -i 500 -t -b 3 --gpus $GPUSPERNODE -ll:fsize 12000 --launcher $RUNNER --nodes $NODES | grep "parsetotal"
    echo running stencil with ngpus $1, $NODES nodes, size $2 , window size 1
    LEGATE_WINDOW_SIZE=1 ../legate.core/install/bin/legate examples/stencil_27.py -n $2 -i 500 -t -b 3 --gpus $GPUSPERNODE -ll:fsize 12000 --launcher $RUNNER --nodes $NODES | grep "parsetotal"
done


for i in "1 188" "2 238" "4 300" "8 378" "16 400" 
#for i in  "8 378" "16 400" 
do
    break;
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
    LEGATE_WINDOW_SIZE=$WSIZE ../legate.core/install/bin/legate examples/stencil_27C.py -n $2 -i 500 -t -b 3 --gpus $GPUSPERNODE -ll:fsize 12000 --launcher $RUNNER --nodes $NODES | grep "parsetotal"
    cp cOff.py cunumeric/array.py
    echo running stencil C  with ngpus $1, $NODES nodes, size $2 , window size 1
    LEGATE_WINDOW_SIZE=1 ../legate.core/install/bin/legate examples/stencil_27C.py -n $2 -i 500 -t -b 3 --gpus $GPUSPERNODE -ll:fsize 12000 --launcher $RUNNER --nodes $NODES | grep "parsetotal"
    cp cOn.py cunumeric/array.py
done



echo "do logreg"
for i in "1 1600" "4 6400" "8 12800"
do
    break
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
    LEGATE_WINDOW_SIZE=50 ../legate.core/install/bin/legate examples/logreg.py -i 1000 --gpus $GPUSPERNODE -n $2 -s 500  -ll:fsize 12000 --benchmark 3 --launcher $RUNNER --nodes $NODES 2>&1 | grep "parsetotal"
    cp cOff.py cunumeric/array.py
    echo running logreg with ngpus $1, $NODES nodes, size $2 , window size 1
    LEGATE_WINDOW_SIZE=1 ../legate.core/install/bin/legate examples/logreg.py -i 1000 --gpus $GPUSPERNODE -n $2 -s 500  -ll:fsize 12000 --benchmark 3 --launcher $RUNNER --nodes $NODES 2>&1 | grep "parsetotal"
    cp cOn.py cunumeric/array.py
done


echo "do mandelbrot"
for i in "1 1000" "4 2000" "8 2828" "16 4000" "32 5656"
do
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
    LEGATE_WINDOW_SIZE=50 ../legate.core/install/bin/legate examples/mandelbrot.py --gpus $GPUSPERNODE --nodes $NODES --launcher $RUNNER -n $2 |  grep "parsetotal"

    cp cOff.py cunumeric/array.py
    echo running mandel with ngpus $1, $NODES nodes, size $2 , window size 1, no copt
    LEGATE_WINDOW_SIZE=1 ../legate.core/install/bin/legate examples/mandelbrot.py --gpus $GPUSPERNODE --nodes $NODES --launcher $RUNNER -n $2  | grep "parsetotal"

    cp cOn.py cunumeric/array.py
    echo running mandel with ngpus $1, $NODES nodes, size $2 , window size 1, copt
    LEGATE_WINDOW_SIZE=1 ../legate.core/install/bin/legate examples/mandelbrot.py --gpus $GPUSPERNODE --nodes $NODES --launcher $RUNNER -n $2  | grep "parsetotal"
done

echo "do black scholes"
for i in "1 3200" "4 12800" "8 25600" "16 51200" "32 102400"
do
    break
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
    LEGATE_WINDOW_SIZE=50 ../legate.core/install/bin/legate examples/black_scholes.py --gpus $GPUSPERNODE -b 3 --nodes $NODES --launcher $RUNNER -n $2 2>&1 | grep "parsetotal"  
    #| grep "parsetotal"

    echo running BS with ngpus $1, $NODES nodes, size $2 , window size 1
    cp cOff.py cunumeric/array.py
    LEGATE_WINDOW_SIZE=1 ../legate.core/install/bin/legate examples/black_scholes.py --gpus $GPUSPERNODE -b 3 --nodes $NODES --launcher $RUNNER -n $2 2>&1 | grep "parsetotal"

    echo running BS with ngpus $1, $NODES nodes, size $2 , window size 1, copt on
    cp cOn.py cunumeric/array.py
    LEGATE_WINDOW_SIZE=1 ../legate.core/install/bin/legate examples/black_scholes.py --gpus $GPUSPERNODE -b 3 --nodes $NODES --launcher $RUNNER -n $2 2>&1 | grep "parsetotal"
done


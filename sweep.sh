

CGPUSPERNODE=4
RUNNER="srun"
hostName=$(hostname)
echo "current host" $hostName 
if [[ $hostName == *"lassen"* ]]; then
  CGPUSPERNODE=4
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


echo "do mandelbrot"
for i in "1 1000" "4 2000" "8 2828"
do
    set -- $i # convert the "tuple" into the param args $1 $2...
    ZNODES=$(($1 / $CGPUSPERNODE))
    NODES=$(( $ZNODES > 1 ? $ZNODES : 1 ))
    GPUSPERNODE=$(( $ZNODES > 1 ? $ZNODES : $1 ))

    WSIZE=50
    if [[ "$SLURM_JOB_NUM_NODES" -lt "$NODES" ]]; then
        break
    fi
    echo running mandel with ngpus $1, $NODES nodes, size $2 , window size $WSIZE
    LEGATE_WINDOW_SIZE=50 ../legate.core/install/bin/legate examples/mandelbrot.py --gpus $GPUSPERNODE --nodes $NODES --launcher mpirun -n $2 2>&1 | grep "parsetotal"
    echo running mandel with ngpus $1, $NODES nodes, size $2 , window size 1
    LEGATE_WINDOW_SIZE=1 ../legate.core/install/bin/legate examples/mandelbrot.py --gpus $GPUSPERNODE --nodes $NODES --launcher mpirun -n $2 2>&1 | grep "parsetotal"
done

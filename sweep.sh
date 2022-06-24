GPUSPERNODE=4
for i in "1 188" "2 238" "4 300 8 378 16 400" 
do
    set -- $i # convert the "tuple" into the param args $1 $2...
    NODES=$(($1 / $GPUSPERNODE))
    NODES=$(( $NODES > 1 ? $NODES : 1 ))
    WSIZE=50
    if [[ "$SLURM_JOB_NUM_NODES" -lt "$NODES" ]]; then
        break
    fi

    echo running stencil with ngpus $1, $NODES nodes, size $2 , window size $WSIZE
    LEGATE_WINDOW_SIZE=$WSIZE ../legate.core/install/bin/legate examples/stencil_27.py -n $2 -i 500 -t -b 3 --gpus $GPUSPERNODE -ll:fsize 12000 --launcher mpirun --nodes $NODES | grep "parsetotal"
    echo running stencil with ngpus $1, $NODES nodes, size $2 , window size 1
    LEGATE_WINDOW_SIZE=1 ../legate.core/install/bin/legate examples/stencil_27.py -n $2 -i 500 -t -b 3 --gpus $GPUSPERNODE -ll:fsize 12000 --launcher mpirun --nodes $NODES | grep "parsetotal"
done

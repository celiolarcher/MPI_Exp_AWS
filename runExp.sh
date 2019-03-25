inst=$(head -n 1 $1)

ssh -i "teste1.pem" -o StrictHostKeyChecking=no ubuntu@$inst "cd NPB3.3.1/NPB3.3-MPI/bin/; mkdir -p output"

ID_MAC=$(($(cat $1 | wc -l)+1))

HOSTS="node1"

for inst2 in $(seq 2 $ID_MAC)
do
    echo nodes$inst2

    if (($inst2 > 3 && $inst2 < 5))
    then
        ssh -n -i "teste1.pem" ubuntu@$inst "cd NPB3.3.1/NPB3.3-MPI/bin; rm output/LU'$HOSTS';"

        for i in $(seq 1 5)
        do
            ssh -n -i "teste1.pem" ubuntu@$inst "export LD_LIBRARY_PATH=/usr/local/lib; cd NPB3.3.1/NPB3.3-MPI/bin; mpirun -np 8 -hosts '$HOSTS' ./lu.B.8  >> output/LU'$HOSTS';"
        done
    fi
    HOSTS=$HOSTS",node"$inst2
done


rm -r $1output
scp -r -i "teste1.pem" ubuntu@$inst:~/NPB3.3.1/NPB3.3-MPI/bin/output $1output


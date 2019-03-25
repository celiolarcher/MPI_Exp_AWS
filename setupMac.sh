ID_MAC=0

rm hostIP$1

while read inst 
do
    ID_MAC=$((ID_MAC+1))
    ssh -n -i "teste1.pem" -o StrictHostKeyChecking=no ubuntu@$inst "sudo apt-get -y install make gcc g++ libblas-dev liblapack-dev gfortran"

    scp -i "teste1.pem" mpich-3.2.1.tar.gz ubuntu@$inst:/home/ubuntu
    ssh -n -i "teste1.pem" ubuntu@$inst "tar -xvzf mpich-3.2.1.tar.gz; cd mpich-3.2.1; ./configure; make; sudo make install"
    ssh -n -i "teste1.pem" ubuntu@$inst "echo 'export LD_LIBRARY_PATH=/usr/local/lib' >> .bashrc; source .bashrc"

    scp -i "teste1.pem" -r .ssh ubuntu@$inst:/home/ubuntu
    ssh -n -i "teste1.pem" ubuntu@$inst  "sudo chmod 600 .ssh/id_rsa; sudo chmod 644 .ssh/id_rsa.pub"

           
    IP_INST=$(ssh -n -i "teste1.pem" ubuntu@$inst  "ifconfig eth0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*'")

    echo $IP_INST    node$ID_MAC >> hostIP$1

    scp -i "teste1.pem" NPB3.3.1.tar.gz  ubuntu@$inst:/home/ubuntu
    scp -i "teste1.pem" make.def  ubuntu@$inst:/home/ubuntu
    ssh -n -i "teste1.pem" ubuntu@$inst "tar -xvzf NPB3.3.1.tar.gz; cp make.def NPB3.3.1/NPB3.3-MPI/config/make.def; cd NPB3.3.1/NPB3.3-MPI;make LU CLASS=B NPROCS=8; make LU CLASS=C NPROCS=8"
done < "$1"

while read inst 
do
    scp -i "teste1.pem" hostIP$1  ubuntu@$inst:/home/ubuntu

    ssh -n -i "teste1.pem" ubuntu@$inst  "sudo bash -c 'cat hostIP$1 >> /etc/hosts'"

    for inst2 in $(seq 1 $ID_MAC)
    do
        ssh -n -tt -i "teste1.pem" ubuntu@$inst "ssh -o StrictHostKeyChecking=no node$inst2 'exit'"
    done
done < "$1"

rm hostIP$1

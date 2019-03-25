from os import listdir
from os.path import isfile, join
import pandas as pd
import matplotlib.pyplot as plt

paths=["t2.microoutput","t2.mediumoutput", "m4.largeoutput", "m4.xlargeoutput", "t2.2xlargeoutput"]


size=(11,8)

clusterTimeAllNodes=[]
for path in paths:
    clusterTimes=[]
    clusterSpeedUp=[]
    for proc, filename in enumerate(listdir(path)):
        filepath=join(path,filename)
        times=[]
        with open(filepath) as f:
            for line in f:
                if "Time in seconds" in line:
                    time=float(line.split("=")[1])
                    times.append(time)
    
        clusterTimes.append(sum(times)/len(times))
        print(filepath,times)
        clusterSpeedUp.append(clusterTimes[0]/((proc+1)*clusterTimes[-1]))
    fig,axis1=plt.subplots(figsize=size)
    axis1.bar([i for i in range(1,len(clusterTimes)+1)],clusterTimes)
    plt.title(path[0:-6]+" Instances")
    plt.xticks([int(i) for i in range(1,len(clusterTimes)+1)])
    plt.xlabel("# Nodes")
    axis1.set_ylabel("Tempo (s)",color="blue")
    axis1.tick_params(axis='y', colors="blue")
    axis2=axis1.twinx()
    axis2.set_ylabel('Speedup',color="red")
    axis2.plot([i for i in range(1,len(clusterTimes)+1)],clusterSpeedUp, color="red", linewidth=4.0)   
    axis2.tick_params(axis='y', colors="red")
    axis2.set_yticks([0,0.25,0.5,0.75,1,1.25])

    plt.savefig("Relatorio Experimentação/figs/"+path[0:-6]+"Time.png")
    
    clusterTimeAllNodes.append(clusterTimes[-1])    

plt.figure(figsize=size)
plt.bar([i for i in range(1,len(clusterTimeAllNodes)+1)],clusterTimeAllNodes)
plt.title("Tempo de execuçao/cluster")
plt.xticks([i for i in range(1,len(clusterTimeAllNodes)+1)], [path[0:-6] for path in paths])
plt.xlabel("Clusters")
plt.ylabel("Tempo (s)")
plt.savefig("Relatorio Experimentação/figs/AllNodesTime.png")

instancias=pd.read_excel("instancias.xls")

instancias["Tempo"]=clusterTimeAllNodes

instancias["Total"]=(instancias["Preço ($) / hora"]*(8/instancias["vCPU"]))*instancias["Tempo"]/60
instancias["Nodes"]=8/instancias["vCPU"]

plt.figure(figsize=size)
plt.bar([i for i in range(1,len(clusterTimeAllNodes)+1)],instancias["Total"])
plt.title("Gasto computacional/cluster")
plt.xticks([i for i in range(1,len(clusterTimeAllNodes)+1)], [path[0:-6] for path in paths])
plt.xlabel("Clusters")
plt.ylabel("Preço ($)")
plt.savefig("Relatorio Experimentação/figs/AllNodesPreco.png")



plt.figure(figsize=size)
plt.bar([i for i in range(1,len(clusterTimeAllNodes)+1)],(instancias["Preço ($) / hora"]*(8/instancias["vCPU"])))
plt.title("Gasto computacional/cluster")
plt.xticks([i for i in range(1,len(clusterTimeAllNodes)+1)], [path[0:-6] for path in paths])
plt.xlabel("Clusters")
plt.ylabel("Preço ($) /  hora")
plt.savefig("Relatorio Experimentação/figs/AllNodesPrecoHora.png")


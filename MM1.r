source("Rposim.r")

initialize(2)

#initialize shared time
TotalUp <- filebacked.big.matrix(1,1, type='float',init = 0, backingpath = "./", backingfile = "TotalUp.bin", descriptorfile = "TotalUp.desc", binarydescriptor = TRUE)

#initialize machines
for (i in 1:2){
	M <- process(i,"MachRun1.r")
	activate(M)
}

#run simulation
simulate(10000)

print("Uptime percentage:")
print(TotalUp[1,1]/20000)

#remove extra files for TotalUp
system("rm TotalUp.*")

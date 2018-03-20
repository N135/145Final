source("Rposim.r")

initialize(2,1)

#initialize shared data
#column 1 is uptime, col 2 is immediate repairs, col 3 is total repairs
Shared <- filebacked.big.matrix(1,3, type='float',init = 0, backingpath = "./", backingfile = "Shared.bin", descriptorfile = "Shared.desc", binarydescriptor = TRUE)

#initialize the resource
RepPerson <- resource(1,1)

#start both processes
for (i in 1:2){
	M <- process(i,"MachRun2.r")
	activate(M)
}

simulate(10000)

print("Uptime percentage:")
print(Shared[1,1]/20000)

print("Proportion of times repair was immediate:")
print(Shared[1,2]/Shared[1,3])
#remove extra files for TotalUp
system("rm Shared.*")

source("Rposim.r")

initialize(2)

RepairPerson <- resource(1,1)

for (i in 1:2){
	M <- process(i,"MachRep.r")
	activate(M)
}

simulate(1000)

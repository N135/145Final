source("Rposim.r")

loadList()
loadSelf()
loadResources()

#load in total up time
Shared <- attach.big.matrix("Shared.desc")

UpRate = 1/1.0
RepRate = 1/0.5


while(isActive()){

	startTime <- now()

	UpTime <- rexp(1, rate = UpRate)

	hold(self,UpTime)

	#update total up time
	Shared[1,1] <- Shared[1,1] + now() - startTime

	#update total number of repairs
	Shared[1,3] <- Shared[1,3] + 1

	#check if repair is immediate
	if(checkAvail(1)){
		Shared[1,2] <- Shared[1,2] + 1
	}

	#1 is the id of the repairperson
	request(self,1)

	RepTime <- rexp(1, rate = RepRate)

	hold(self, RepTime)
	
	release(self,1)
}

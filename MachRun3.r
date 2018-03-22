source("Rposim.r")

loadList()
loadSelf()
loadResources()

#load in total up time
Shared <- attach.big.matrix("Shared.desc")

UpRate = 1/1.0
RepRate = 1/0.5

#Number of machines up
Shared[1,2] <- Shared[1,2] + 1

while(isActive()){

	startTime <- now()

	#Machine up until hold ends
	UpTime <- rexp(1, rate = UpRate)
	hold(self,UpTime)

	Shared[1,1] <- Shared[1,1] + now() - startTime

	#Decrease number of machines up
	Shared[1,2] <- Shared[1,2] - 1

	#If one is still active, passivate this machine and wait for the other to go down
	if (Shared[1,2] == 1){
		print(paste("Passivating",self[1], Shared[1,2]))
		passivate(self)
	}
	#if both are down, reactivate the other machine so both can call for repairs
	else{
		if(checkAvail(1)){
			print(paste("Reactivating:", self[1] %% 2 + 1))
			#get other machine id
			reactivate(self[1] %% 2 + 1)
		}
	}

	#1 is the id of the repairperson
	request(self,1)

	RepTime <- rexp(1, rate = RepRate)

	hold(self, RepTime)

	Shared[1,2] <- Shared[1,2] + 1


	release(self,1)
}

source("Rposim.r")

loadList()
loadSelf()

#load in total up time
TotalUp <- attach.big.matrix("TotalUp.desc")

UpRate = 1/1.0
RepRate = 1/0.5

#run until time is up.
while(isActive()){
	#start time
	startTime <- now()

	#up time
	UpTime <- rexp(1, rate = UpRate)

	#wait for break
	hold(self,UpTime)

	#update total up time
	TotalUp[1,1] <- TotalUp[1,1] + now() - startTime

	#reparir time
	RepTime <- rexp(1, rate = RepRate)

	#wait for repairs
	hold(self, RepTime)
}

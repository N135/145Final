source("Rposim.r")

loadList()
loadSelf()

#load in total up time
TotalUp <- attach.big.matrix("TotalUp.desc")

UpRate = 1/1.0
RepRate = 1/0.5

while(isActive()){
	startTime <- now()

	UpTime <- rexp(1, rate = UpRate)

	hold(self,UpTime)

	TotalUp[1,1] <- TotalUp[1,1] + now() - startTime

	RepTime <- rexp(1, rate = RepRate)

	hold(self, RepTime)
}

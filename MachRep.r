library(bigmemory) #redundant
source("Rposim.r")

loadList()
loadSelf()

upRate <- 1/1.0
repRate <- 1/0.5

while(isActive()){
	start_time <- now()

	upTime <- runIf(1,0,upRate)

	hold(self,upTime)

	TotalUp <<- TotalUp += now() - start_Time

	repTime <- runIf(1,0,repRate)

	hold(self,repTime)
}

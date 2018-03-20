library(bigmemory)

#turn off annoying warning from bigmem package typcasting
options(bigmemory.typecast.warning=FALSE)
#load event_list
event_list <- attach.big.matrix("event_list.desc")

#Take in and set up max time arg
args <- commandArgs(trailingOnly = TRUE)
maxTime <- as.numeric(args[1])

#set sim time to 0, and run as long as time is not exceeded
simTime <- 0

while (simTime < maxTime){

	#get list of times and filter out 0's
	times <- event_list[-1,5]
	times <- times[times != 0]

	#If any non-zero times exist, replace min with 0 and update sim time
	if (length(times) != 0){
		#get min
		minTime <- min(times)

		#replace min in event_list with 0
		index <- match(minTime,event_list[-1,5])

		index <- index + 1

		event_list[index,5] <- 0
		event_list[index,1] <- 1

		#update sim time
		simTime <- minTime
		event_list[1,5] <- simTime
	}
}

#End the simulation, killing other threads
event_list[1,1] <- 1

library(bigmemory)

options(bigmemory.typecast.warning=FALSE)

#process class. Has an integer id (should be strictly increasing by 1; can we enforce that?) and a name
process <- function(id,runFile,args = NULL){
	attr(id,"class") <- "process"
	attr(id,"run") <- runFile
	attr(id,"args") <- args

	id
}

activate <- function(process){	
	val <- paste("Rscript",toString(process$run), sep = " ")

	for (i in process$args){
		val <- paste(val,toString(i), sep = " ")
	}

	system(val,wait=FALSE)
}

#lock the process up for the duration
hold <- function(process,duration){
	#get current sim time
	now <- event_list[1,4]

	pIndex = process[1] + 1

	#update event list, locking process thread (row 1) and setting the time to be awakened.
	event_list[pIndex,1] <- 0
        event_list[pIndex,4] <- duration + now

	while (event_list[pIndex,1] == 0){
		Sys.sleep(0.1)
	}
}

#passivates the thread until it's id is called for reactivation
passivate <- function(process){
	pIndex <- process[1] + 1

	event_list[pIndex,1] <- 0

	#sets time to 0 to ensure that the O.S. doesn't do anything.
        event_list[pIndex,4] <- 0

	while (event_list[pIndex,1] == 0){
		Sys.sleep(0.1)
	}	
}

#Reactivates a passivated thread
reactivate <- function(process){
	pIndex <- process[1] + 1

	event_list[pIndex,1] <- 1
}

#request use of a process
request <- function(process,resource){
	#get current sim time
	now <- event_list[1,4]

	pIndex <- process[1] + 1

	event_list[pIndex,2] <- resource[1]

	#wait to return until the resource is free
	while (event_list[pIndex,2] != 0){
		Sys.sleep(0.1)
	}

}

#release the resource from the process using it
release <- function(process,resource){
	pIndex <- process[1] + 1

	#check if a resource has been used.
	if (event_list[pIndex,3] != resource[1]){
		stop("No resource of that type used by this process, or resource has already been released.")
	}

	#tell the resource it is allowed to return
	event_list[pIndex,2] <- resource[1]

	#wait to return until the resource has been released
	while (event_list[pIndex,2] != 0){
		Sys.sleep(0.1)
	}
}


#Starts the resource thread running
#Passed number of resources as arguement
resource <- function(resourceId, resourceNum){
	val <- paste("Rscript Resource.r",toString(resourceId), toString(resourceNum), sep = " ")

	system(val,wait=FALSE)
	       #ignore.stdout = TRUE)

	attr(resourceId,"class") <- "resource"
	resourceId
}

#Sets up the big-memory array with number of processes + number of resource types + 1 as it's row number
initialize <- function(processNum){
	event_list <<- filebacked.big.matrix(1+processNum,4, type='integer',init = 0, backingpath = "./", backingfile = "event_list.bin", 
					     descriptorfile = "event_list.desc", binarydescriptor = TRUE)
}

#Starts the O.S. thread, which begins the simulation. Doesn't return until the sim is done.
#Takes the length of time the sim should run for as an arguement
simulate <- function(maxTime=10000){
	val <- paste("Rscript OS.r",toString(maxTime), sep = " ")

	system(val,wait=TRUE)
	       #ignore.stdout = TRUE)

	system("rm ./event_list.*")
}

#returns current time
now <- function(){
	event_list[1,4]
}

#returns true if the sim is running, false otherwise
isActive <- function(){
	if(event_list[1,1] == 0){
		TRUE
	}
	else{
		FALSE
	}
}

#loads the event_list for the user in the run function
loadList <- function(){
	#turn off annoying warning from bigmem package typcasting
	options(bigmemory.typecast.warning=FALSE)
	#load event_list
	event_list <<- attach.big.matrix("event_list.desc")
}

#creates a process object that has the passed process id.
loadSelf <- function(){
	
}

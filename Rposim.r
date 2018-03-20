library(bigmemory)

options(bigmemory.typecast.warning=FALSE)

#process class. Has an integer id (should be strictly increasing by 1; can we enforce that?) and a name
process <- function(id,runFile,args = NULL){
	attr(id,"class") <- "process"
	attr(id,"run") <- runFile
	attr(id,"args") <- args

	id
}

#begins running the thread for the object
activate <- function(process){

	Pid <- process[1]
	Pscript <- attr(process,"run")
	Pargs <- attr(process,"args")

	val <- paste("Rscript",toString(Pscript),toString(Pid), sep = " ")

	for (i in Pargs){
		val <- paste(val,toString(i), sep = " ")
	}

	system(val,wait=FALSE)
}

#lock the process up for the duration
hold <- function(process,duration){

	pIndex <- process[1] + 1

	#update event list, locking process thread (row 1) and setting the time to be awakened.
	event_list[pIndex,1] <- 0.0
        event_list[pIndex,5] <- duration + now()

	while (event_list[pIndex,1] == 0){
		Sys.sleep(0.01)
	}
}

#passivates the thread until it's id is called for reactivation
passivate <- function(process){
	pIndex <- process[1] + 1

	event_list[pIndex,1] <- 0.0

	#sets time to 0 to ensure that the O.S. doesn't do anything.
        event_list[pIndex,5] <- 0.0

	while (event_list[pIndex,1] == 0.0){
		Sys.sleep(0.01)
	}	
}

#Reactivates a passivated thread
reactivate <- function(process){
	pIndex <- process[1] + 1

	event_list[pIndex,1] <- 1.0
}

#request use of a process
request <- function(process,resourceId){
	#get current sim time
	now <- event_list[1,5]

	pIndex <- process[1] + 1

	event_list[pIndex,2] <- resourceId
	event_list[pIndex,4] <- resourceId

	#wait to return until the resource is free
	while (event_list[pIndex,4] != 0.0){
		Sys.sleep(0.1)
	}

}

#release the resource from the process using it
release <- function(process,resourceId){
	pIndex <- process[1] + 1

	#check if a resource has been used.
	if (event_list[pIndex,3] != resourceId){
		stop("No resource of that type used by this process, or resource has already been released.")
	}

	#tell the resource it is allowed to return
	event_list[pIndex,2] <- resourceId

	#wait to return until the resource has been released
	while (event_list[pIndex,3] == resourceId){
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
initialize <- function(processNum,resourceNum = 0){
	event_list <<- filebacked.big.matrix(1+processNum,5, type='float',init = 0, backingpath = "./", backingfile = "event_list.bin", 
					     descriptorfile = "event_list.desc", binarydescriptor = TRUE)

	if (resourceNum != 0){
		resFlag <<- TRUE
		resAvail <<- filebacked.big.matrix(1,resourceNum, type='float',init = 0, backingpath = "./", backingfile = "resAvail.bin", 
					     descriptorfile = "resAvail.desc", binarydescriptor = TRUE)
	}
	else{
		resFlag <<- FALSE
	}	
}

#Starts the O.S. thread, which begins the simulation. Doesn't return until the sim is done.
#Takes the length of time the sim should run for as an arguement
simulate <- function(maxTime=10000){
	val <- paste("Rscript OS.r",toString(maxTime), sep = " ")

	system(val,wait=TRUE)
	       #ignore.stdout = TRUE)

	system("rm ./event_list.*")

	if (resFlag == TRUE){
		system("rm ./resAvail.*")
	}
}

#returns current time
now <- function(){
	event_list[1,5]
}

#returns true if the sim is running, false otherwise
isActive <- function(){
	if(event_list[1,1] == 0){
		X <- TRUE
	}
	else{
		X <- FALSE
	}

	X
}

checkAvail <- function(resId){
	if(resAvail[1,resId] == 0){
		x <- FALSE
	}
	else{
		x <- TRUE
	}

	x
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
	#Take in and set up max time arg
	args <- commandArgs(trailingOnly = TRUE)
	id <- as.numeric(args[1])
	script <- NULL

	self <<- process(id, script)
}

#loads the resource_list for the user in the run function
loadResources <- function(){
	#turn off annoying warning from bigmem package typcasting
	options(bigmemory.typecast.warning=FALSE)
	#load event_list
	resAvail <<- attach.big.matrix("resAvail.desc")
}

library(bigmemory)

#turn off annoying warning from bigmem package typcasting
options(bigmemory.typecast.warning=FALSE)
#load event_list
event_list <- attach.big.matrix("event_list.desc")

#load resource availibility
resourceAvail <- attach.big.matrix("res_avail.desc")

#get input from command line
args <- commandArgs(trailingOnly = TRUE)
id <- as.numeric(args[1])
num <- as.numeric(args[2])

#show number of resources availible
resourceAvail[1,id] <- num

queue = c()

while(event_list[1,1] == 0){
	
	index <- match(id, event_list[,2])

	#check if any requests or releases have been made
	if (!is.na(index)){

		#check if this is a request or release
		if (event_list[index,3] != id){
	
			#check if any resources are availible
			if (num > 0){

				#if so, allocate a resource to the process
				event_list[index,2] <- 0
				event_list[index,3] <- id
				event_list[index,4] <- 0

				num <- num - 1

				resourceAvail[1,id] <- num
			}

			#if not, add to queue
			else{
				queue <- c(index,queue)

				event_list[index,2] <- 0
				event_list[index,3] <- 0
				event_list[index,4] <- id
			}	
		}

		#It's a release
		else{
			num <- num + 1

			#If non-empty queue, pop element and run resource allocation
			if (length(queue) != 0){
				Qindex <- queue[1]
				queue <- queue[-1]

				event_list[Qindex,2] <- 0
				event_list[Qindex,3] <- id
				event_list[Qindex,4] <- 0

				num <- num - 1

			}

			#End resource occupation of element with resource
			event_list[index,2] <- 0
			event_list[index,3] <- 0
			event_list[index,4] <- 0

			resourceAvail[1,id] <- num
		}
	}
	else{
		#Nothing to do, wait.
		Sys.sleep(0.1)
	}
}

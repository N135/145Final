library(bigmemory)

#turn off annoying warning from bigmem package typcasting
options(bigmemory.typecast.warning=FALSE)
#load event_list
event_list <- attach.big.matrix("event_list.desc")

#get input from command line
args <- commandArgs(trailingOnly = TRUE)
id <- as.numeric(args[1])
num <- as.numeric(args[2])

queue = list()

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

				num <- num - 1
			}

			#if not, add to queue
			else{
				queue.append(index)
			}	
		}

		#It's a release
		else{
			event_list[index,2] <- 0
			event_list[index,3] <- 0

			num <- num + 1
			
			#If non-empty queue, pop element and run resource allocation
			if (length(queue) != 0){
				index <- queue[1]
				queue <- queue[-1]

				event_list[index,2] <- 0
				event_list[index,3] <- id

				num <- num - 1
			}
		}
	}
	else{
		Sys.sleep(0.1)
	}
}

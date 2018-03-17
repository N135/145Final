library(bigmemory)

#turn off annoying warning from bigmem package typcasting
options(bigmemory.typecast.warning=FALSE)
#load event_list
event_list <- attach.big.matrix("event_list.desc")

#get input from command line
args <- commandArgs(trailingOnly = TRUE)
id <- as.numeric(args[1])
num <- as.numeric(args[2])

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
				print(num)
			}

			#if not, add to queue
			else{
				##add queue##
			}	
		}

		#It's a release
		else{
			event_list[index,2] <- 0
			event_list[index,3] <- 0

			num <- num + 1
		}
	}
	else{
		print(event_list[1,1])
		Sys.sleep(0.1)
	}
}

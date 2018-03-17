source("Rposim.r")

initialize(1)

print("Starting process")
Z <- process(1)

print("Starting Resource")
R <- resource(1,2)

print("Setting event_list")
event_list[2,4] <- 12

print("Starting sim")
simulate(10)

print("Request Made")
request(Z,R)

print(event_list[,])
#print("Holding for 5")
#hold(Z,5)

print(event_list[,])

event_list[1,1] <- 1

print(event_list[,])

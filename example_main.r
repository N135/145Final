source("Rposim.r")

initialize(1)

print("Starting process")
Machine <- process(1,"MachRun.r")

activate(Machine)

print("Starting Resource")
R <- resource(1,2)

print("Starting sim")
simulate(100)



# --------------------------------------------------------------------------------------------------
# ModalAnalysis.tcl --  modal analysis for the bridge model
# units: kip, in

file mkdir modes

# ======================================================================
# NUMBER OF EIGEN VALUES 
# ======================================================================
set numModes 5            

# ======================================================================
# MODES RECORDING 
# ======================================================================
# Top of Columms
for { set k 1 } { $k <= $numModes } { incr k } {
    recorder Node -file [format "modes/Colmode%i.out" $k] -node 3 -dof 1 2 3 4 5 6 "eigen $k"
} 
# ABUT 1
for { set k 1 } { $k <= $numModes } { incr k } {
    recorder Node -file [format "modes/ABUT1%i.out" $k] -node 1 -dof 1 2 3 4 5 6 "eigen $k"
} 

# ABUT 2
for { set k 1 } { $k <= $numModes } { incr k } {
    recorder Node -file [format "modes/ABUT2%i.out" $k] -node 2 -dof 1 2 3 4 5 6 "eigen $k"
} 

# ABUT 1 rigid beam
for { set k 1 } { $k <= $numModes } { incr k } {
    recorder Node -file [format "modes/ABUT1r%i.out" $k] -node 11 12 -dof 1 2 3 4 5 6 "eigen $k"
} 

# ABUT 2 rigid beam
for { set k 1 } { $k <= $numModes } { incr k } {
    recorder Node -file [format "modes/ABUT2r%i.out" $k] -node 21 22 -dof 1 2 3 4 5 6 "eigen $k"
} 

# DECK
for { set k 1 } { $k <= $numModes } { incr k } {
    recorder Node -file [format "modes/DECK%i.out" $k] -node 1 131 132 133 3 231 232 233 2 -dof 1 2 3 "eigen $k"
} 

# ======================================================================
# DO EIGEN ANALYSIS
# ======================================================================
set lambda [eigen "-fullGenLapack" $numModes] 

 
# The periods and frequencies of the structure are calculated here
set omega {}
set f {}
set T {}

foreach lam $lambda {
    lappend omega [expr sqrt($lam)]
    lappend f [expr sqrt($lam)/(2*$PI)]
    lappend T [expr (2*$PI)/sqrt($lam)]
}

# ======================================================================
# EXPORT AND PRINT RESULTS
# ======================================================================
#The periods are stored in a Periods.txt file inside of directory "modes".
set Omega "modes/Omegas.txt"
set Omegas [open $Omega "w"]
foreach om $omega {
    puts $Omegas " $om"
}
close $Omegas

set period "modes/Periods.txt"
set Periods [open $period "w"]
foreach t $T {
    puts $Periods " $t"
    puts "Period = $t"
}
close $Periods

record 
 
# --------------------------------------------------------------------------------------------------
# ModalAnalysis.tcl --  modal analysis for the bridge model
# units: kip, in


file mkdir modes; 

# ======================================================================
# NUMBER OF EIGEN VALUES 
# ======================================================================
set numModes 8 

# ======================================================================
# MODES RECORDING 
# ======================================================================
# Top of Columms
for { set k 1 } { $k <= $numModes } { incr k } {
    recorder Node -file [format "modes/Colmode%i.out" $k] -node 102 103 104 -dof 1 2 3 4 5 6 "eigen $k"
} 
# ABUT 1
for { set k 1 } { $k <= $numModes } { incr k } {
    recorder Node -file [format "modes/ABUT1%i.out" $k] -node 101 -dof 1 2 3 4 5 6 "eigen $k"
} 

# ABUT 2
for { set k 1 } { $k <= $numModes } { incr k } {
    recorder Node -file [format "modes/ABUT2%i.out" $k] -node 105 -dof 1 2 3 4 5 6 "eigen $k"
} 

# ABUT 1 rigid beam
for { set k 1 } { $k <= $numModes } { incr k } {
    recorder Node -file [format "modes/ABUT1r%i.out" $k] -node 211 212 -dof 1 2 3 4 5 6 "eigen $k"
} 

# ABUT 2 rigid beam
for { set k 1 } { $k <= $numModes } { incr k } {
    recorder Node -file [format "modes/ABUT2r%i.out" $k] -node 221 222 -dof 1 2 3 4 5 6 "eigen $k"
} 

# DECK
for { set k 1 } { $k <= $numModes } { incr k } {
    recorder Node -file [format "modes/DECK%i.out" $k] -node 101 131 132 133 102 231 232 233 103 331 332 333 104 431 432 433 105 -dof 1 2 3 "eigen $k"
} 


# ======================================================================
# DO EIGEN ANALYSIS
# ======================================================================
set lambda [eigen "-fullGenLapack" $numModes];

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

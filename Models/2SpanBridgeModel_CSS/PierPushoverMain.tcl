# --------------------------------------------------------------------------------------------------
# LibUnits.tcl -- define system of units
#-----------------------------------------------
# University of California, Berkeley
# updated (2022-12-10)
# updated (2024-08-26)

# ======================================================================
# DEFINE UNITS
# ====================================================================== 

puts " "
puts "Start..."
puts " "
puts " "

# ======================================================================
# DATA DIRECTION
# ======================================================================
# comment out the next 3 lines if you are using IDA file
wipe;                         # clear opensees model
set dataDir Data_Push;        # set up name of data directory -- remove
file mkdir $dataDir;          # create data directory

# ======================================================================
# SETUP MODELING
# ======================================================================
model basic -ndm 3 -ndf 6
source LibUnits.tcl

# ======================================================================
# GRID LINE
# ======================================================================
set Lpier      [expr 24.5*$ft];       # length of pier

# ======================================================================
# NODE DEFINITION AND RESTRAINT
# ======================================================================
node 1 0.0 $Lpier 0.0   # PIER TOP
node 2 0.0 0.0    0.0   # PIER BASE 

# restraints (check)
fix 1   0 0 1 1 1 0    
fix 2   1 1 1 1 1 1  

puts "01 --------------------------------------------------------------------------- NODE"
puts "Pier Base Nodes 2 Fixed."
puts "Nodes Assigned"
puts " "

# ======================================================================
# ELEMENT DEFINITION
# ======================================================================
set col1 1
set PierTransfTag   1

# --------------------- #
# Concrete bridge pier  #
# --------------------- #
puts "02 --------------------------------------------------------------------------- ELEMENT: PIER"
# geomTransf for pier
geomTransf PDelta $PierTransfTag -1.0 0.0 0.0;    # associate a tag to transformation

# Materials for concrete section 
source LibMaterialsRC.tcl

# Pier details 
set Ap  [expr 23.758*$ft*$ft];
set Ipy [expr 44.918*pow($ft,4)];  
set Ipz [expr 44.918*pow($ft,4)];

# set SectionType Elastic        # option: Elastic or FiberSection
set SectionType FiberSection;    # option: Elastic or FiberSection

if {$SectionType == "Elastic"} {
   element elasticBeamColumn $col1 2 1 $Ap $Ec $Gc $J $Ipy $Ipz $PierTransfTag
   puts "Elastic Beam Column $col1 from 2 to 1"

} elseif {$SectionType == "FiberSection"} {
   #MATERIAL parameters
   source build.RCSection.Circ3D.tcl;    # or source build.HollowSection3D.tcl

   #Geometry assignments
   set BotColTag 10
   set BotDsec [expr 5.5*$ft]
   set BotSecTagTorsion 99
   set BotSecTag3D 11

   set MidColTag 15
   set MidDsec [expr 8.75*$ft]
   set MidSecTagTorsion 98
   set MidSecTag3D 12

   set TopColTag 20
   set TopDsec [expr 14.0*$ft]
   set TopSecTagTorsion 97
   set TopSecTag3D 13

   # ### set different geometric variables for top and bottom column sections!!!!!!!
   BuildRCcircSection $BotColTag $IDconcCore $IDconcCover $IDSteel $BotDsec $BotSecTagTorsion $BotSecTag3D
   BuildRCcircSection $MidColTag $IDconcCore $IDconcCover $IDSteel $MidDsec $MidSecTagTorsion $MidSecTag3D
   BuildRCcircSection $TopColTag $IDconcCore $IDconcCover $IDSteel $TopDsec $TopSecTagTorsion $TopSecTag3D

   set Lpj 0.0;                # or set Lpj [expr 5.0*$in];
   set Lpi [expr 35.0*$in];    # (Priestly & Park, 1987) or set Lpj [expr $Lpi];
   set ACol $Ap
   set IzCol $Ipz

   # nonlinear piers (why 0.7)
   # element beamWithHinges $eleTag $iNode $jNode $secTagI $Lpi $secTagJ $Lpj $E $A $Iz $Iy $G $J $transfTag <-mass $massDens> <-iter $maxIters $tol>
   element beamWithHinges $col1 2 1 $BotColTag $Lpi $TopColTag $Lpj $Ec $ACol [expr 0.7*$Ipz] [expr 0.7*$Ipy] $Gc $J $PierTransfTag
   
   puts "NL Beam with Hinges $col1 from 2 to 1"

} else {
   puts "No section has been defined"
   return -1
}

puts " "

# recorder
recorder Node -file $dataDir/DTop.out       -time -node 1   -dof  1  disp;      # displacements of support nodes
recorder Node -file $dataDir/RBase.out      -time -node 2   -dof  1  reaction;  # support reaction
recorder Element -file $dataDir/FPier.out   -time -ele  1   force               # Pier element forces 
recorder Element -file $dataDir/DPier.out   -time -ele  1   basicDeformation    # Pier element forces 

recorder Element -file $dataDir/SteelFiber.out -time -ele 1 section fiber 0.0 33.0  3 stressStrain
recorder Element -file $dataDir/CCFiber.out -time -ele 1 section fiber 0.0 -31.0 1 stressStrain
recorder Element -file $dataDir/UCFiber.out -time -ele 1 section fiber 0.0 -33.0 2 stressStrain

# ======================================================================
# DEFINE GRAVITY LOADING AND MASS
# ======================================================================
# nodal forces           
set F1 [expr 1410.0*$kip];      #PIER TOP

# Masses 
mass 1 [expr $F1/$g] 0. [expr $F1/$g] 0. 0. 0.;    #PIER TOP

puts "03 --------------------------------------------------------------------------- GRIVITY LOAD AND MASS"
puts "Gravity Loads and Masses Assigned"
puts " "

# assign gravity loading 
set PatternTag 1;
set Tol 1.0e-5;                             # convergence tolerance for test 1.0e-8
pattern Plain $PatternTag Linear {
   load 1 0. -$F1 0. 0. 0. 0.;              # for the reactions
}

puts "04 --------------------------------------------------------------------------- GRAVITY ANALYSIS"
constraints Plain;          # how it handles boundary conditions
numberer RCM;               # renumber dofs to minimize band-width (optimization), if you want to
test EnergyIncr $Tol 6 ;    # determine if convergence has been achieved at the end of an iteration step
system BandGeneral;         # how to store and solve the system of equations in the analysis

algorithm Newton;                 # use Newton's solution algorithm: updates tangent stiffness at every iteration
set Nstep 10;                     # apply gravity in 10 steps
set LFinc [expr 1./$Nstep];       # first load increment;
integrator LoadControl $LFinc;    # determine the next time step for an analysis, # apply gravity in 10 steps
analysis Static;                  # define type of analysis static or transient
analyze $Nstep;                   # perform gravity analysis
loadConst -time 0.0;              # hold gravity constant and restart time
record

puts "Gravity analysis Complete"
puts " "

# ======================================================================
# PUSHOVER ANALYSIS
# ======================================================================

puts "05 --------------------------------------------------------------------------- PUSHOVER ANALYSIS"

# characteristics of pushover analysis
set Dmax  [expr 0.10*$Lpier];    # maximum displacement of pushover. push to 10% drift.
set Dincr [expr 0.0005*$Lpier];   # displacement increment for pushover.

# create load pattern for lateral pushover load
set Hload [expr $F1];           # define the lateral load as a proportion of the weight so that the pseudo time equals the lateral-load coefficient when using linear load pattern
pattern Plain 200 Linear {;     # define load pattern -- generalized
    load 1 $Hload 0.0 0.0 0.0 0.0 0.0
}

constraints Plain
numberer RCM
system UmfPack
test NormDispIncr 1e-6 100 
algorithm Newton
integrator DisplacementControl  1  1 $Dincr
analysis Static

#  ---------------------------------    perform Static Pushover Analysis
set Nsteps [expr int($Dmax/$Dincr)];     # number of pushover analysis steps
set ok [analyze $Nsteps];                # this will return zero if no convergence problems were encountered

set IDctrlNode 1
set IDctrlDOF  1

if {$ok != 0} {      
    # if analysis fails, we try some other stuff, performance is slower inside this loop
    set ok 0;
    set controlDisp 0.0;
    set D0 0.0;              # analysis starts from zero
    set Dstep [expr ($controlDisp-$D0)/($Dmax-$D0)]
    
    while {$Dstep < 1.0 && $ok == 0} {  
        set controlDisp [nodeDisp $IDctrlNode $IDctrlDOF ]
        set Dstep [expr ($controlDisp-$D0)/($Dmax-$D0)]
        set ok [analyze 1 ]
        if {$ok != 0} {
            puts "Trying Newton with Initial Tangent .."
            test NormDispIncr   1e-6 2000  0
            algorithm Newton -initial
            set ok [analyze 1 ]
            test NormDispIncr 1e-6 100
            algorithm Newton
        }
        if {$ok != 0} {
            puts "Trying Broyden .."
            algorithm Broyden 8
            set ok [analyze 1 ]
            algorithm Newton
        }
        if {$ok != 0} {
            puts "Trying NewtonWithLineSearch .."
            algorithm NewtonLineSearch .8
            set ok [analyze 1 ]
            algorithm Newton
        }
                };  # end while loop
};      # end if ok !0

puts "Pushover Done. Control Disp=[nodeDisp 1 1]"

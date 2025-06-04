# --------------------------------------------------------------------------------------------------
# PierMCurveMain.tcl -- moment-curvature analysis of a circular reinforced concrete section 
# units: kip, in

puts "# ==================================================================================================== #"
puts "This is an OpenSees model for the 4-span Orange County bridge model (55-0909G):"
puts "  1. Moment curvature analysis for the bridge pier section"
puts "  2. Unit: kips, inch, second"
puts "  3. Create (2024-08-29); Update (2024-09-04)"
puts " "
puts "          Maria Camila Lopez Ruiz and Ya-Heng Yang, University of California, Berkeley"
puts "# ==================================================================================================== #"
puts " "

# ======================================================================
# DEFINE MOMENT CURVATURE ANALYSIS MODULUS
# ====================================================================== 
proc MomentCurvature {secTag axialLoad maxK {numIncr 100} } {
    # Define two nodes at (0,0)
    node 1 0.0 0.0
    node 2 0.0 0.0

    # Fix all degrees of freedom except axial and bending
    fix 1 1 1 1
    fix 2 0 1 0

    # Define element
    element zeroLengthSection  1   1   2  $secTag

    # Create recorder
    recorder Node -file section$secTag.out -time -node 2 -dof 3 disp
    recorder Element -file SteelFiber.out -time -ele 1 section fiber  -40 0.0  3 stressStrain
    #recorder Element -file CFiber.out -time -ele 1 section fiber -31 0.0  stressStrain

    # Define constant axial load
    pattern Plain 1 "Constant" {
        load 2 $axialLoad 0.0 0.0
    }

    # Define analysis parameters
    integrator LoadControl 0.001
    system SparseGeneral -piv;      # Overkill, but may need the pivoting!
    test NormUnbalance 1.0e-9 100
    numberer Plain
    constraints Plain
    algorithm Newton
    analysis Static

    # Do one analysis for constant axial load
    analyze 1

    # Define reference moment
    pattern Plain 2 "Linear" {
        load 2 0.0 0.0 1.0
    }

    # Compute curvature increment
    set dK [expr $maxK/$numIncr]

    # Use displacement control at node 2 for section analysis
    integrator DisplacementControl 2 3 $dK 1 $dK $dK

    # Do the section analysis
    analyze $numIncr
}

puts " "
puts "Start..."
puts " "

# ======================================================================
# START MOMENT CURVATURE ANALYSIS
# ====================================================================== 

# Remove existing model
wipe

# Create ModelBuilder (with two-dimensions and 3 DOF/node)
model BasicBuilder -ndm 2 -ndf 3

# Unit
source LibUnits.tcl
    
# ======================================================================
# SECTION GEOMETRY AND MATERIAL PROPERTIES
# ======================================================================
# Column Diameter
set DSec     [expr 6.89*$ft] 
       
# Column cover to reinforcing steel NA.
set coverSec [expr 2.0*$in]  
     
# number of uniformly-distributed longitudinal-reinforcement bars
set numBarsSec 32    

# area of longitudinal-reinforcement bars
set barAreaSec [expr 2.33*$in*$in]

# inner radius of the section, only for hollow sections
set ri 0.0    
     
# overall (outer) radius of the section
set ro [expr $DSec/2] 
 
# number of radial divisions in the core (number of "rings")
set nfCoreR 8    
  
# number of theta divisions in the core (number of "wedges")
set nfCoreT 8   
  
# number of radial divisions in the cover
set nfCoverR 2  
   
# number of theta divisions in the cover
set nfCoverT 8     

set SecTag 10
set IDconcCore  1
set IDconcCover 2
set IDSteel     3
 
source LibMaterialsRC.tcl

# ======================================================================
# DEFINE THE FIBER SECTION
# ======================================================================
section fiberSec $SecTag -GJ $Ubig {
    set rc [expr $ro-$coverSec];                                    # Core radius
    patch circ $IDconcCore $nfCoreT $nfCoreR 0 0 $ri $rc 0 360;     # Define the core patch
    patch circ $IDconcCover $nfCoverT $nfCoverR 0 0 $rc $ro 0 360;  # Define the cover patch
     
    set theta [expr 360.0/$numBarsSec];                             # Determine angle increment between bars
    layer circ $IDSteel $numBarsSec $barAreaSec 0 0 $rc $theta 360; # Define the reinforcing layer
}

puts " "
puts "Section Created"
puts " "

# ======================================================================
# SET AXIAL LOAD  
# ======================================================================
set P [expr -2199*$kip];    # + Tension, - Compression  2199

puts " "
puts "Axial Load Applied"
puts " "

# ======================================================================
# SET MAXIMUM CURVATURE
# ======================================================================
set Ku [expr 0.0015/$in]
set numIncr 2000;    # Number of analysis increments to maximum curvature (default=100)

# ======================================================================
# CALL THE SECTION ANALYSIS PROCEDURE
# ======================================================================
MomentCurvature $SecTag $P $Ku $numIncr

puts " "
puts "Moment-Curvature Analysis Complete"

wipe

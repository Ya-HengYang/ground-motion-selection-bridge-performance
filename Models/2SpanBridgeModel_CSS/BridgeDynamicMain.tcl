#-----------------------------------------------
# University of California, Berkeley
# updated (2022-12-10)
# updated (2024-08-26)

#puts "# ==================================================================================================== #"
#puts "This is an OpenSees model for the 2-span San Jose bridge model (37-0536F):"
#puts "  1. Four elements for each span"
#puts "  2. Nodal and uniform loading are included"
#puts "  3. Including concrete pier, abutment spring, abutment rigid beam, pin connector, and concrete deck"
#puts "  4. Unit: kips, inch, second"
#puts "  5. updated (2022-12-10); updated (2024-08-29)"
#puts " "
#puts "          Maria Camila Lopez Ruiz and Ya-Heng Yang, University of California, Berkeley"
#puts "====================================================================================================== #"
# 
#puts " "
#puts "Start..."
#puts " "
#puts " "

# ======================================================================
# DATA DIRECTION
# ======================================================================
# comment out the next 3 lines if you are using IDA file
wipe
set dataDir Data_Dynamic         
file mkdir $dataDir           

# ======================================================================
# SETUP MODELING
# ======================================================================
model basic -ndm 3 -ndf 6
source LibUnits.tcl

# ======================================================================
# GRID LINE
# ======================================================================
set NPiers     1;                     # number of piers
set n_ab       1;
set Lpier      [expr 24.5*$ft];       # length of pier
set X_Pier1    [expr 126.667*$ft];    # location of pier
set X_ABUT2    [expr 262.0*$ft];      # location of abutment 2
set ZrigidLink [expr 12.417*$ft];     # half width of deck

set coliNode 4
set coljNode 3

# ======================================================================
# NODE DEFINITION AND RESTRAINT
# ======================================================================
node 1 0.0      $Lpier 0.0            # ABUTMENT 1
node 2 $X_ABUT2 $Lpier 0.0            # ABUTMENT 2
node 3 $X_Pier1 $Lpier 0.0            # PIER TOP
node 4 $X_Pier1 0.0    0.0            # PIER BASE 

# nodes for rigid beams of abutments
node 11  0.0       $Lpier  $ZrigidLink  
node 12  0.0       $Lpier -$ZrigidLink 
node 111 0.0       $Lpier  $ZrigidLink     
node 112 0.0       $Lpier -$ZrigidLink  

node 21  $X_ABUT2  $Lpier  $ZrigidLink  
node 22  $X_ABUT2  $Lpier -$ZrigidLink
node 121 $X_ABUT2  $Lpier  $ZrigidLink   
node 122 $X_ABUT2  $Lpier -$ZrigidLink 

# nodes for pin connector on the top of pier
#node 31 $X_Pier1 $Lpier 0.0;
#node 32 $X_Pier1 $Lpier 0.0;

# nodes for spans (element# + nodes# + nodeID)
node  131 [expr $X_Pier1 * 1/4]                         $Lpier 0.0
node  132 [expr $X_Pier1 * 2/4]                         $Lpier 0.0
node  133 [expr $X_Pier1 * 3/4]                         $Lpier 0.0
node  231 [expr $X_Pier1 + ($X_ABUT2 - $X_Pier1) * 1/4] $Lpier 0.0
node  232 [expr $X_Pier1 + ($X_ABUT2 - $X_Pier1) * 2/4] $Lpier 0.0
node  233 [expr $X_Pier1 + ($X_ABUT2 - $X_Pier1) * 3/4] $Lpier 0.0

# restraints
fix 4   1 1 1 1 1 1    
fix 111 1 1 1 1 1 1
fix 112 1 1 1 1 1 1
fix 121 1 1 1 1 1 1
fix 122 1 1 1 1 1 1

#puts "01 --------------------------------------------------------------------------- NODE"
#puts "Pier Base Nodes 4 Fixed."
#puts "Abutment Nodes 111, 112, 121, 122 Fixed."
#puts "Nodes Assigned"
#puts " "

# ======================================================================
# ELEMENT DEFINITION
# ======================================================================
# Element tags 
set col1          1;
set gird2         2;
set gird3         3;
set gird21        241;
set gird22        242;
set gird23        243;
set gird24        244;
set gird31        341;
set gird32        342;
set gird33        343;
set gird34        344;
set gird2_pin     31;    # pin connector on the top of pier  
set gird3_pin     32;
set Elem_Abt11    11;    # rigid beams for abutments  
set Elem_Abt12    12;
set Elem_Abt21    21;
set Elem_Abt22    22;
set Elem_Abt1_sp1 111;   # zeroLength element for abutments  
set Elem_Abt1_sp2 112;
set Elem_Abt2_sp1 121;
set Elem_Abt2_sp2 122;

# Geometric transformation tags 
set GirderTransfTag 2
set PierTransfTag   1
set AbtTransfTag    3

# --------------------- #
# Concrete bridge pier  #
# --------------------- #
#puts "02 --------------------------------------------------------------------------- ELEMENT: PIER"

# geomTransf for pier
geomTransf PDelta $PierTransfTag -1.0 0.0 0.0

# Materials for concrete section 
source LibMaterialsRC.tcl

# Pier details 
set Ap  [expr 23.758*$ft*$ft]
set Ipy [expr 44.918*pow($ft,4)]  
set Ipz [expr 44.918*pow($ft,4)]

# option: Elastic or FiberSection  
set SectionType FiberSection 
set Jpier [expr 0.2 * 1862840*$kip*$in*$in*$in]

if {$SectionType == "Elastic"} {
   
   element elasticBeamColumn $col1 4 3 $Ap $Ec $Gc $Jpier [expr 0.7*$Ipz] [expr 0.7*$Ipy] $PierTransfTag;
   puts "Elastic Beam Column $col1 from 4 to 3"

} elseif {$SectionType == "FiberSection"} {

   source build.RCSection.Circ3D.tcl;  # or source build.HollowSection3D.tcl

   #Geometry assignments
   set BotColTag        10
   set BotDsec          [expr 5.5*$ft]
   set BotSecTagTorsion 99
   set BotSecTag3D      11

   set MidColTag        15
   set MidDsec          [expr 8.75*$ft]
   set MidSecTagTorsion 98
   set MidSecTag3D      12

   set TopColTag        20
   set TopDsec          [expr 14.0*$ft]
   set TopSecTagTorsion 97
   set TopSecTag3D      13

   # set different geometric variables for top and bottom column sections!
   BuildRCcircSection $BotColTag $IDconcCore $IDconcCover $IDSteel $BotDsec $BotSecTagTorsion $BotSecTag3D
   BuildRCcircSection $MidColTag $IDconcCore $IDconcCover $IDSteel $MidDsec $MidSecTagTorsion $MidSecTag3D
   BuildRCcircSection $TopColTag $IDconcCore $IDconcCover $IDSteel $TopDsec $TopSecTagTorsion $TopSecTag3D

   set Lpj   0.0;                # or set Lpj [expr 5.0*$in];
   set Lpi   [expr 37.902*$in];  # SDC Eq. 5.3.4-1 (Priestly & Park, 1987) or set Lpj [expr $Lpi]; original: 35
   set ACol  $Ap
   set IzCol $Ipz

   # nonlinear piers
   set PierMod 0.56
   element beamWithHinges $col1 4 3 $BotColTag $Lpi $TopColTag $Lpj $Ec $ACol [expr $PierMod*$Ipz] [expr $PierMod*$Ipy]  $Gc $Jpier $PierTransfTag
   #puts "NL Beam with Hinges $col1 from 4 to 3"

} else {
   puts "No section has been defined"
   return -1
}

puts " "

# ---------------------
# Abutment Model 
# ---------------------
set KabL     [expr 1.681*(10**5)*$kip/$in/$n_ab]
set PabL     [expr -4.996*(10**5)*$kip/$n_ab]
set gapL     [expr -0.5*$in]
set etaL     [expr 10**(-3)]
set KabL_brg [expr 48.4*$kip/$in]

set KabT [expr 4.98*(10**4)*$kip/$in/$n_ab]
set PabT [expr 1.48*(10**5)*$kip/$n_ab]

set KabV_brg   [expr 121*$kip/$in/$n_ab]
set KabV_rigid [expr $Ubig/$n_ab]

# material tag
set IDAbL       31
set IDAbLgap    32
set IDAbL_brg   33
set IDAbT       34
set IDAbV_brg   35
set IDAbV_rigid 36
set IDAbrot     37

# Longitudinal material
uniaxialMaterial ElasticPPGap $IDAbLgap  $KabL      $PabL      $gapL   $etaL  
uniaxialMaterial Elastic      $IDAbL_brg $KabL_brg 
uniaxialMaterial Parallel     $IDAbL     $IDAbLgap  $IDAbL_brg

# Transverse material
uniaxialMaterial ElasticPP $IDAbT $KabT [expr $PabT/$KabT]

# Vertical material
uniaxialMaterial ENT $IDAbV_brg   $KabV_brg
uniaxialMaterial ENT $IDAbV_rigid $KabV_rigid

# rotation material
uniaxialMaterial Elastic $IDAbrot [expr 0.0*$kip/$in]

# Abutment spring model
element zeroLength $Elem_Abt1_sp1 11 111 -mat $IDAbL $IDAbV_rigid $IDAbT $IDAbrot $IDAbrot $IDAbrot -dir 1 2 3 4 5 6 -orient  -1 0 0 0 -1 0  
element zeroLength $Elem_Abt1_sp2 12 112 -mat $IDAbL $IDAbV_rigid $IDAbT $IDAbrot $IDAbrot $IDAbrot -dir 1 2 3 4 5 6 -orient  -1 0 0 0 -1 0  
element zeroLength $Elem_Abt2_sp1 21 121 -mat $IDAbL $IDAbV_rigid $IDAbT $IDAbrot $IDAbrot $IDAbrot -dir 1 2 3 4 5 6 -orient  1 0 0 0 -1 0 
element zeroLength $Elem_Abt2_sp2 22 122 -mat $IDAbL $IDAbV_rigid $IDAbT $IDAbrot $IDAbrot $IDAbrot -dir 1 2 3 4 5 6 -orient  1 0 0 0 -1 0 

#puts "03 --------------------------------------------------------------------------- ELEMENT: ABUTMENT SPRING"
#puts "Abutment Spring $Elem_Abt1_sp1 from 11 to 111"
#puts "Abutment Spring $Elem_Abt1_sp2 from 12 to 112"
#puts "Abutment Spring $Elem_Abt2_sp1 from 21 to 121"
#puts "Abutment Spring $Elem_Abt2_sp2 from 22 to 122"
#puts "Abutment Spring Assigned"
#puts " "
#
# --------------------------
# Rigid Beam for Abutments
# --------------------------
geomTransf Linear  $AbtTransfTag 0.0 1.0 0.0

element elasticBeamColumn $Elem_Abt11 1 11 $Ubig $Ec $Gc $Ubig $Ubig $Ubig $AbtTransfTag;
element elasticBeamColumn $Elem_Abt12 12 1 $Ubig $Ec $Gc $Ubig $Ubig $Ubig $AbtTransfTag;
element elasticBeamColumn $Elem_Abt21 2 21 $Ubig $Ec $Gc $Ubig $Ubig $Ubig $AbtTransfTag;
element elasticBeamColumn $Elem_Abt22 22 2 $Ubig $Ec $Gc $Ubig $Ubig $Ubig $AbtTransfTag;
#
#puts "03 --------------------------------------------------------------------------- ELEMENT: ABUTMENT RIGID BEAM"
#puts "Abutment Beam $Elem_Abt11 from 1 to 11"
#puts "Abutment Beam $Elem_Abt12 from 12 to 1"
#puts "Abutment Beam $Elem_Abt21 from 2 to 21"
#puts "Abutment Beam $Elem_Abt22 from 22 to 2"
#puts "Abutment Rigid Beam Assigned"
#puts " "

# -----------------------------------------------
# Pin (Zerolength) Elements on the top on pier 
# -----------------------------------------------
#puts "04 --------------------------------------------------------------------------- ELEMENT: PIN CONNECTOR"

proc ZeroLenthPins {iStart jStart eleTag NumPiers matTag} {
   
   # funtion assigns pin connectors in line along span of bridge
   for {set index 0} {$index< [expr $NumPiers]} {incr index} {
      set iNode [expr $iStart+$index]
      set jNode [expr $jStart+$index]

      puts "Pin Connector Element $eleTag from $iNode to $jNode"
      equalDOF $iNode $jNode 1 2 3 4 5;
      element zeroLength $eleTag $iNode $jNode -mat $matTag -dir 6  #-orient 1 0 0 0 0 1 

      set eleTag [expr $eleTag + 1]
   }
}

#uniaxialMaterial Elastic $IDRelease 0.10
#uniaxialMaterial Elastic $IDRelease $Usmall
#uniaxialMaterial Elastic $IDRelease $Ubig
#
#ZeroLenthPins 31 3 31 $NPiers $IDRelease
#ZeroLenthPins 3 32 32 $NPiers $IDRelease

#puts "Pin Connectors Assigned"
#puts " "

# ----------------
# Bridge deck
# ----------------
# geomTransf for deck
geomTransf Linear $GirderTransfTag 0.0 1.0 0.0

# Deck details 
set effectiveMod 0.7
set Ad  [expr 65.118*$ft*$ft];          
set Idy [expr 295.93*$effectiveMod*pow($ft,4)];   
set Idz [expr 5.53*(10**3)*$effectiveMod*pow($ft,4)]
 
set eleMass [expr 0.814*$kip/$in/$g]
element elasticBeamColumn $gird21 1   131 $Ad $Ec $Gc $J [expr $Idy] [expr $Idz] $GirderTransfTag -mass $eleMass
element elasticBeamColumn $gird22 131 132 $Ad $Ec $Gc $J [expr $Idy] [expr $Idz] $GirderTransfTag -mass $eleMass
element elasticBeamColumn $gird23 132 133 $Ad $Ec $Gc $J [expr $Idy] [expr $Idz] $GirderTransfTag -mass $eleMass
element elasticBeamColumn $gird24 133 3   $Ad $Ec $Gc $J [expr $Idy] [expr $Idz] $GirderTransfTag -mass $eleMass
element elasticBeamColumn $gird31 3   231 $Ad $Ec $Gc $J [expr $Idy] [expr $Idz] $GirderTransfTag -mass $eleMass
element elasticBeamColumn $gird32 231 232 $Ad $Ec $Gc $J [expr $Idy] [expr $Idz] $GirderTransfTag -mass $eleMass
element elasticBeamColumn $gird33 232 233 $Ad $Ec $Gc $J [expr $Idy] [expr $Idz] $GirderTransfTag -mass $eleMass
element elasticBeamColumn $gird34 233 2   $Ad $Ec $Gc $J [expr $Idy] [expr $Idz] $GirderTransfTag -mass $eleMass

#puts "05 --------------------------------------------------------------------------- ELEMENT: ELASITIC DECK BEAM"
#puts "Elastic Beam Element for deck $gird2 from 1 to 31"
#puts "Elastic Beam Element for deck $gird3 from 32 to 2"
#puts "Beam Elements Assigned"
#puts " "

# -----------------------------------------------
# Recorder 
# -----------------------------------------------
#recorder Node -file $dataDir/DBase.out   -time -node 1 2 4 -dof 1 2 3 disp;         # displacements of support nodes
#recorder Node -file $dataDir/RotBase.out -time -node 1 2 4 -dof 4 5 6 disp;         # displacements of support nodes
recorder Node -file $dataDir/RBase.out   -time -node 4 -dof 2 reaction;              # support reaction
#recorder Node -file $dataDir/MBase.out   -time -node 1 2 4 -dof 4 5 6 reaction;     # support reaction
#
#recorder Node -file $dataDir/RAbutmentx.out -time -node 111 112 121 122 -dof 1 reaction;  # support reaction
recorder Node -file $dataDir/RAbutmenty.out -time -node 111 112 121 122 -dof 2 reaction;   # support reaction
#recorder Node -file $dataDir/RAbutmentz.out -time -node 111 112 121 122 -dof 3 reaction;  # support reaction
#
#recorder Node -file $dataDir/DTop.out   -time -node 3 -dof 1 2 3 disp;              # displacements/ rot at bottom of bearings
#recorder Node -file $dataDir/RotTop.out -time -node 3 -dof 4 5 6 disp;              # displacements/ rot at Top of bearings
#
#recorder Element -file $dataDir/FPier.out   -time -ele      1       globalForce;    # Pier element forces 
#recorder Element -file $dataDir/FGirder.out -time -eleRange 244 341 globalForce;    # Girder element forces 

recorder Element -file $dataDir/abutSpringf1.out  -time -ele  111  force;               # Abutment springs   
recorder Element -file $dataDir/abutSpringd1.out  -time -ele  111  deformation; 
recorder Element -file $dataDir/abutSpringf3.out  -time -ele  112  force;                
recorder Element -file $dataDir/abutSpringd3.out  -time -ele  112  deformation;     
recorder Element -file $dataDir/abutSpringf2.out  -time -ele  121  force;            
recorder Element -file $dataDir/abutSpringd2.out  -time -ele  121  deformation;    
recorder Element -file $dataDir/abutSpringf4.out  -time -ele  122  force;            
recorder Element -file $dataDir/abutSpringd4.out  -time -ele  122  deformation;  

recorder Node -file $dataDir/PierD.out -time -node 3 -dof 1 3 disp;    

recorder Element -file $dataDir/SteelFiber.out -time -ele 1 section fiber 0.0  33.0  3 stressStrain
recorder Element -file $dataDir/CCFiber.out    -time -ele 1 section fiber 0.0  31.0  1 stressStrain
recorder Element -file $dataDir/UCFiber.out    -time -ele 1 section fiber 0.0 -33.0  2 stressStrain

# ======================================================================
# DEFINE GRAVITY LOADING AND MASS
# ======================================================================
# nodal forces
#set F1 [expr 675.622*$kip];     #ABUT 1 
#set F2 [expr 721.848*$kip];     #ABUT 2             
#set F3 [expr 1410.0*$kip];      #PIER TOP
set F3 [expr 58.97*$kip];        #PIER TOP
 

# Masses 
#mass 1 [expr $F1/$g] 0. [expr $F1/$g] 0. 0. 0.;     #ABUT1         # put massses in x, y, z
#mass 2 [expr $F2/$g] 0. [expr $F2/$g] 0. 0. 0.;     #ABUT2         # no masses in rotational degrees of freedom
mass 3 [expr $F3/$g] [expr $F3/$g] [expr $F3/$g] 0. 0. 0.;          # PIER TOP

# assign gravity loading 
set PatternTag 1
set Tol 1.0e-5 

pattern Plain $PatternTag Linear {           
   load 3 0. [expr -$F3] 0. 0. 0. 0.                
   eleLoad -ele 241 242 243 244 341 342 343 344 -type -beamUniform 0.0 -0.814  
}
#
#puts "06 --------------------------------------------------------------------------- GRIVITY LOAD AND MASS"
#puts "Gravity Loads and Masses Assigned"
#puts " "

#puts "07 --------------------------------------------------------------------------- GRAVITY ANALYSIS"
constraints Plain    
numberer    RCM 
test        EnergyIncr $Tol 6 
system      BandGeneral 
algorithm   Newton 

set Nstep 10;                     # apply gravity in 10 steps
set LFinc [expr 1./$Nstep];       # first load increment;

integrator LoadControl $LFinc;    # determine the next time step for an analysis, # apply gravity in 10 steps
analysis   Static;                # define type of analysis static or transient
analyze    $Nstep;                # perform gravity analysis
loadConst  -time 0.0;             # hold gravity constant and restart time
record

#puts "Gravity analysis Complete"
#puts " "

# ======================================================================
# Period of Bridge
# ====================================================================== 
#puts "08 --------------------------------------------------------------------------- MODAL ANALYSIS"
#puts " "
source ModalAnalysis.tcl
#puts " "
#puts "Modal Analysis Complete"
#puts " "

# ======================================================================
# PUSHOVER ANALYSIS 
# ======================================================================
# source PushoverAnalysis.tcl
# puts "Pushover Analysis Complete"

# ======================================================================
# EARTHQUAKE ANALYSIS 
# ======================================================================
#puts "09 --------------------------------------------------------------------------- EQ ANALYSIS"
source EQ2DAnalysis.tcl
#puts " "
#puts "Earthquake Analysis Complete"
#puts " "


#puts " "
#puts "Done!"

wipe
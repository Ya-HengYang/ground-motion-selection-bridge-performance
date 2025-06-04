#-----------------------------------------------
# University of California, Berkeley
# updated (2022-12-10)
# updated (2024-09-05)

#puts "# ==================================================================================================== #"
#puts "This is an OpenSees model for the 4-span Orange County bridge model (55-0909G):"
#puts "  1. Four elements for each span"
#puts "  2. Nodal and uniform loading are included"
#puts "  3. Including concrete pier, abutment spring, abutment rigid beam, pin connector, and concrete deck"
#puts "  4. Unit: kips, inch, second"
#puts "  5. updated (2022-12-10); updated (2024-09-05)"
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
set NPiers 3;                       # number of piers
set Lpier2  [expr 25.810*$ft];      # length of pier 2
set Lpier3  [expr 24.636*$ft];      # length of pier 3  [expr 24.636*$ft] 
set Lpier4  [expr 22.165*$ft];      # length of pier 4  [expr 22.165*$ft]

set X_PIER2 [expr 127.953*$ft];     # location of pier 2 
set X_PIER3 [expr 301.837*$ft];     # location of pier 3 
set X_PIER4 [expr 505.249*$ft];     # location of pier 4 
set X_ABUT2 [expr 623.360*$ft];     # location fo abutment 2

set ZrigidLink [expr 10.942*$ft];   # half width of deck

# ======================================================================
# NODE DEFINITION AND RESTRAINT
# ======================================================================
## Abutments 
#node 101 0.0      0.0 0.0;  # ABUTMENT 1 0.0      $Lpier2 0.0
#node 105 $X_ABUT2 0.0 0.0;  # ABUTMENT 2
#
## Piers base 
#node 2 $X_PIER2 -$Lpier2  0.0;       # PIER BASE  $X_PIER2 0.0  0.0
#node 3 $X_PIER3 -$Lpier3  0.0;       # PIER BASE 
#node 4 $X_PIER4 -$Lpier4  0.0;       # PIER BASE 
#
## Piers top 
#node 102 $X_PIER2 0.0 0.0;  # PIER TOP $X_PIER2 $Lpier2 0.0
#node 103 $X_PIER3 0.0 0.0;  # PIER TOP
#node 104 $X_PIER4 0.0 0.0;  # PIER TOP
#
## Rigid Beam nodes
#node 211 0.0 0.0  $ZrigidLink;  # 0.0 $Lpier2  $ZrigidLink   
#node 212 0.0 0.0 -$ZrigidLink 
#node 411 0.0 0.0  $ZrigidLink     
#node 412 0.0 0.0 -$ZrigidLink  
#
#node 221 $X_ABUT2  0.0  $ZrigidLink;  #$X_ABUT2  $Lpier4  $ZrigidLink     
#node 222 $X_ABUT2  0.0 -$ZrigidLink
#node 421 $X_ABUT2  0.0  $ZrigidLink   
#node 422 $X_ABUT2  0.0 -$ZrigidLink 

# Abutments 
node 101 0.0      $Lpier2 0.0;  # ABUTMENT 1 0.0      $Lpier2 0.0
node 105 $X_ABUT2 $Lpier4 0.0;  # ABUTMENT 2

# Piers base 
node 2 $X_PIER2 0.0  0.0;       # PIER BASE  $X_PIER2 0.0  0.0
node 3 $X_PIER3 0.0  0.0;       # PIER BASE 
node 4 $X_PIER4 0.0  0.0;       # PIER BASE 

# Piers top 
node 102 $X_PIER2 $Lpier2 0.0;  # PIER TOP $X_PIER2 $Lpier2 0.0
node 103 $X_PIER3 $Lpier3 0.0;  # PIER TOP
node 104 $X_PIER4 $Lpier4 0.0;  # PIER TOP

# Rigid Beam nodes
node 211 0.0 $Lpier2  $ZrigidLink;  # 0.0 $Lpier2  $ZrigidLink   
node 212 0.0 $Lpier2 -$ZrigidLink 
node 411 0.0 $Lpier2  $ZrigidLink     
node 412 0.0 $Lpier2 -$ZrigidLink  

node 221 $X_ABUT2  $Lpier4  $ZrigidLink;  #$X_ABUT2  $Lpier4  $ZrigidLink     
node 222 $X_ABUT2  $Lpier4 -$ZrigidLink
node 421 $X_ABUT2  $Lpier4  $ZrigidLink   
node 422 $X_ABUT2  $Lpier4 -$ZrigidLink 

# nodes for pin connector on the top of pier
#node 301 $X_PIER2 $Lpier2 0.0
#node 302 $X_PIER2 $Lpier2 0.0
#
#node 303 $X_PIER3 $Lpier3 0.0
#node 304 $X_PIER3 $Lpier3 0.0
#
#node 305 $X_PIER4 $Lpier4 0.0
#node 306 $X_PIER4 $Lpier4 0.0

# nodes for spans (element# + nodes# + nodeID)
node  131 [expr $X_PIER2 * 1/4]                         $Lpier2                                    0.0
node  132 [expr $X_PIER2 * 2/4]                         $Lpier2                                    0.0
node  133 [expr $X_PIER2 * 3/4]                         $Lpier2                                    0.0
node  231 [expr $X_PIER2 + ($X_PIER3 - $X_PIER2) * 1/4] [expr $Lpier2 + ($Lpier3 - $Lpier2) * 1/4] 0.0
node  232 [expr $X_PIER2 + ($X_PIER3 - $X_PIER2) * 2/4] [expr $Lpier2 + ($Lpier3 - $Lpier2) * 2/4] 0.0
node  233 [expr $X_PIER2 + ($X_PIER3 - $X_PIER2) * 3/4] [expr $Lpier2 + ($Lpier3 - $Lpier2) * 3/4] 0.0
node  331 [expr $X_PIER3 + ($X_PIER4 - $X_PIER3) * 1/4] [expr $Lpier3 + ($Lpier4 - $Lpier3) * 1/4] 0.0
node  332 [expr $X_PIER3 + ($X_PIER4 - $X_PIER3) * 2/4] [expr $Lpier3 + ($Lpier4 - $Lpier3) * 2/4] 0.0
node  333 [expr $X_PIER3 + ($X_PIER4 - $X_PIER3) * 3/4] [expr $Lpier3 + ($Lpier4 - $Lpier3) * 3/4] 0.0
node  431 [expr $X_PIER4 + ($X_ABUT2 - $X_PIER4) * 1/4] $Lpier4                                    0.0
node  432 [expr $X_PIER4 + ($X_ABUT2 - $X_PIER4) * 2/4] $Lpier4                                    0.0
node  433 [expr $X_PIER4 + ($X_ABUT2 - $X_PIER4) * 3/4] $Lpier4                                    0.0

#node  131 [expr $X_PIER2 * 1/4]                         0.0 0.0
#node  132 [expr $X_PIER2 * 2/4]                         0.0 0.0
#node  133 [expr $X_PIER2 * 3/4]                         0.0 0.0
#node  231 [expr $X_PIER2 + ($X_PIER3 - $X_PIER2) * 1/4] 0.0 0.0
#node  232 [expr $X_PIER2 + ($X_PIER3 - $X_PIER2) * 2/4] 0.0 0.0
#node  233 [expr $X_PIER2 + ($X_PIER3 - $X_PIER2) * 3/4] 0.0 0.0
#node  331 [expr $X_PIER3 + ($X_PIER4 - $X_PIER3) * 1/4] 0.0 0.0
#node  332 [expr $X_PIER3 + ($X_PIER4 - $X_PIER3) * 2/4] 0.0 0.0
#node  333 [expr $X_PIER3 + ($X_PIER4 - $X_PIER3) * 3/4] 0.0 0.0
#node  431 [expr $X_PIER4 + ($X_ABUT2 - $X_PIER4) * 1/4] 0.0 0.0
#node  432 [expr $X_PIER4 + ($X_ABUT2 - $X_PIER4) * 2/4] 0.0 0.0
#node  433 [expr $X_PIER4 + ($X_ABUT2 - $X_PIER4) * 3/4] 0.0 0.0

# restraints
fix 2 1 1 1 1 1 1  
fix 3 1 1 1 1 1 1   
fix 4 1 1 1 1 1 1  

fix 411 1 1 1 1 1 1
fix 412 1 1 1 1 1 1
fix 421 1 1 1 1 1 1
fix 422 1 1 1 1 1 1        

#puts "01 --------------------------------------------------------------------------- NODE"
#puts "Pier Base Nodes 2, 3, 4 Fixed."
#puts "Abutment Nodes 411, 412, 421, 422 Fixed"
#puts "Nodes Assigned"
#puts " "

# ======================================================================
# ELEMENT DEFINITION
# ======================================================================
# Element tags 
set col2          2
set col3          3
set col4          4
set gird1         101
set gird2         102
set gird3         103
set gird4         104
set gird11        141
set gird12        142
set gird13        143
set gird14        144
set gird21        241
set gird22        242
set gird23        243
set gird24        244
set gird31        341
set gird32        342
set gird33        343
set gird34        344
set gird41        441
set gird42        442
set gird43        443
set gird44        444

set Elem_Abt11    211;     # rigid beams for abutments
set Elem_Abt12    212
set Elem_Abt21    221
set Elem_Abt22    222
set Elem_Abt1_sp1 411;     # zeroLength element for abutments  
set Elem_Abt1_sp2 412
set Elem_Abt2_sp1 421
set Elem_Abt2_sp2 422

# Geometric transformation tags 
set GirderTransfTag 101
set PierTransfTag   1
set AbtTransfTag    201

# --------------------- #
# Concrete bridge pier  #
# --------------------- #
#puts "02 --------------------------------------------------------------------------- ELEMENT: PIER"

# geomTransf for pier
geomTransf PDelta $PierTransfTag -1.0 0.0 0.0

# Materials for concrete section 
source LibMaterialsRC.tcl

# Pier details 
set Ap  [expr 37.28*$ft*$ft]
set Ipy [expr 110.608*pow($ft,4)]
set Ipz $Ipy

# option: Elastic or FiberSection 
set SectionType FiberSection 
set Jpier [expr 0.2 * 4587800*$kip*$in*$in*$in]

if {$SectionType == "Elastic"} {
   element elasticBeamColumn $col2 2 102 $Ap $Ec $Gc $Jpier [expr 0.56*$Ipy] [expr 0.56*$Ipz] $PierTransfTag;
   element elasticBeamColumn $col3 3 103 $Ap $Ec $Gc $Jpier [expr 0.56*$Ipy] [expr 0.56*$Ipz] $PierTransfTag;
   element elasticBeamColumn $col4 4 104 $Ap $Ec $Gc $Jpier [expr 0.56*$Ipy] [expr 0.56*$Ipz] $PierTransfTag;
   #puts "Elastic Beam Column $col2 from 4 to 3"

} elseif {$SectionType == "FiberSection"} {
   
source build.RCSection.Circ3D.tcl; # or source build.HollowSection3D.tcl;

   #Geometry assignments
   set P2_ColTag         102
   set PierSecTagTorsion2 99
   set P2SecTag3D        112
   set P2_Dsec           [expr 6.89*$ft]
   set P2_cover          [expr 2.0*$in]
   set P2_barNum         32 
   set P2_barArea        [expr 2.33*$in*$in]

   set P3_ColTag         103
   set PierSecTagTorsion3 98
   set P3SecTag3D        113
   set P3_Dsec           $P2_Dsec
   set P3_cover          $P2_cover
   set P3_barNum         34 
   set P3_barArea        $P2_barArea

   set P4_ColTag         104
   set PierSecTagTorsion4 97
   set P4SecTag3D        114
   set P4_Dsec           $P2_Dsec
   set P4_cover          $P2_cover
   set P4_barNum         28            
   set P4_barArea        [expr 2*2.33*$in*$in] 

   #uniaxialMaterial Elastic $PierSecTagTorsion $Ubig;
   # 8 8 4 8   8 8 2 4    HingeMidpoint
   # 8 8 4 8   8 16 2 16  HingeMidpoint
   # 8 8 2 4   8 8 2 4   HingeRadau, HingeMidpoint
   # 8 8 2 8   8 16 8 16  HingeMidpoint
   BuildRCcircSection $P2_ColTag $IDconcCore $IDconcCover $IDSteel $P2_Dsec $P2_cover $P2_barNum $P2_barArea $PierSecTagTorsion2 $P2SecTag3D 8 8 2 8   
   BuildRCcircSection $P3_ColTag $IDconcCore $IDconcCover $IDSteel $P3_Dsec $P3_cover $P3_barNum $P3_barArea $PierSecTagTorsion3 $P3SecTag3D 8 8 2 8   
   BuildRCcircSection $P4_ColTag $IDconcCore $IDconcCover $IDSteel $P4_Dsec $P4_cover $P4_barNum $P4_barArea $PierSecTagTorsion4 $P4SecTag3D 8 8 2 8 

   set Lpj 0.0;                # or  set Lpj [expr 5.0*$in];
   set Lpi [expr 42.33*$in];   # (Priestly & Park, 1987) *Used max for all 3 piers or set Lpj [expr $Lpi];   
   
   
   # nonlinear piers
   #element beamWithHinges $col2 2 102 $P2_ColTag $Lpi $P2_ColTag $Lpj $Ec $Ap [expr 0.56*$Ipz] [expr 0.56*$Ipy] $Gc $Jpier $PierTransfTag
   #element beamWithHinges $col3 3 103 $P3_ColTag $Lpi $P3_ColTag $Lpj $Ec $Ap [expr 0.56*$Ipz] [expr 0.56*$Ipy] $Gc $Jpier $PierTransfTag
   #element beamWithHinges $col4 4 104 $P4_ColTag $Lpi $P4_ColTag $Lpj $Ec $Ap [expr 0.56*$Ipz] [expr 0.56*$Ipy] $Gc $Jpier $PierTransfTag
   #puts "NL Beam with Hinges $col2 from 2 to 102"
   #puts "NL Beam with Hinges $col2 from 3 to 103"
   #puts "NL Beam with Hinges $col2 from 4 to 104"
   
   
   #HingeRadau HingeMidpoint HingeRadauTwo 
   set secTagInterior 105
   section Elastic $secTagInterior $Ec $Ap [expr 0.56*$Ipz] [expr 0.56*$Ipy] $Gc $Jpier 
   element forceBeamColumn $col2 2 102 $PierTransfTag "HingeRadau $P2_ColTag $Lpi $P2_ColTag $Lpj $secTagInterior"
   element forceBeamColumn $col3 3 103 $PierTransfTag "HingeRadau $P3_ColTag $Lpi $P3_ColTag $Lpj $secTagInterior"
   element forceBeamColumn $col4 4 104 $PierTransfTag "HingeRadau $P4_ColTag $Lpi $P4_ColTag $Lpj $secTagInterior"
#
} else {
   puts "No section has been defined"
   return -1
}

# ---------------------
# Abutment Model 
# ---------------------
set n_ab 1.0
set KabL     [expr 1.847*(10**5)*$kip/$in/$n_ab]
set PabL     [expr -6.752*(10**5)*$kip/$n_ab]
set gapL     [expr -0.5*$in]
set etaL     [expr 10**(-3)]
set KabL_brg [expr 9.5*$kip/$in]

set KabT     [expr 5.47*(10**4)*$kip/$in/$n_ab]
set PabT     [expr 2.0*(10**5)*$kip/$n_ab]

set KabV_brg    [expr 31.49*$kip/$in/$n_ab]
set KabV_rigid  [expr $Ubig/$n_ab]

#materials 
set IDAbL       31
set IDAbLgap    32
set IDAbL_brg   33
set IDAbT       34
set IDAbV_brg   35
set IDAbV_rigid 36
set IDAbrot     37

# Longitudinal material
uniaxialMaterial ElasticPPGap $IDAbLgap  $KabL     $PabL $gapL $etaL damage
uniaxialMaterial Elastic      $IDAbL_brg $KabL_brg 
uniaxialMaterial Parallel     $IDAbL     $IDAbLgap $IDAbL_brg

# Transverse material
uniaxialMaterial ElasticPP $IDAbT $KabT [expr $PabT/$KabT]

# Vertical material
uniaxialMaterial ENT $IDAbV_brg $KabV_brg
uniaxialMaterial ENT $IDAbV_rigid $KabV_rigid

# rotation material
uniaxialMaterial Elastic $IDAbrot [expr 0.0*$kip/$in]; 

# Abutment spring model
element zeroLength $Elem_Abt1_sp1 211 411 -mat $IDAbL $IDAbV_rigid $IDAbT $IDAbrot $IDAbrot $IDAbrot -dir 1 2 3 4 5 6 -orient -1 0 0 0 -1 0  
element zeroLength $Elem_Abt1_sp2 212 412 -mat $IDAbL $IDAbV_rigid $IDAbT $IDAbrot $IDAbrot $IDAbrot -dir 1 2 3 4 5 6 -orient -1 0 0 0 -1 0  
element zeroLength $Elem_Abt2_sp1 221 421 -mat $IDAbL $IDAbV_rigid $IDAbT $IDAbrot $IDAbrot $IDAbrot -dir 1 2 3 4 5 6 -orient 1 0 0 0 -1 0 
element zeroLength $Elem_Abt2_sp2 222 422 -mat $IDAbL $IDAbV_rigid $IDAbT $IDAbrot $IDAbrot $IDAbrot -dir 1 2 3 4 5 6 -orient 1 0 0 0 -1 0 

#puts "03 --------------------------------------------------------------------------- ELEMENT: ABUTMENT SPRING"
#puts "Abutment Spring $Elem_Abt1_sp1 from 211 to 411"
#puts "Abutment Spring $Elem_Abt1_sp2 from 212 to 412"
#puts "Abutment Spring $Elem_Abt2_sp1 from 221 to 421"
#puts "Abutment Spring $Elem_Abt2_sp2 from 222 to 422"
#puts "Abutment Spring Assigned"
#puts " "

# --------------------------
# Rigid Beam for Abutments
# --------------------------
geomTransf Linear $AbtTransfTag 0.0 1.0 0.0

element elasticBeamColumn $Elem_Abt11 101 211 $Ubig $Ec $Gc $Ubig $Ubig $Ubig $AbtTransfTag;
element elasticBeamColumn $Elem_Abt12 212 101 $Ubig $Ec $Gc $Ubig $Ubig $Ubig $AbtTransfTag;
element elasticBeamColumn $Elem_Abt21 105 221 $Ubig $Ec $Gc $Ubig $Ubig $Ubig $AbtTransfTag;
element elasticBeamColumn $Elem_Abt22 222 105 $Ubig $Ec $Gc $Ubig $Ubig $Ubig $AbtTransfTag;

#puts "03 --------------------------------------------------------------------------- ELEMENT: ABUTMENT RIGID BEAM"
#puts "Abutment Beam $Elem_Abt11 from 101 to 211"
#puts "Abutment Beam $Elem_Abt12 from 212 to 101"
#puts "Abutment Beam $Elem_Abt21 from 105 to 221"
#puts "Abutment Beam $Elem_Abt22 from 222 to 105"
#puts "Abutment Rigid Beam Assigned"
#puts " "

# -----------------------------------------------
# Pin (Zerolength) Elements on the top on pier 
# -----------------------------------------------
#puts "04 --------------------------------------------------------------------------- ELEMENT: PIN CONNECTOR"

proc ZeroLenthPins {iStart jStart eleTag NumPiers matTag} {
   
   # funtion assigns pin connectors in line along span of bridge
   for {set index 0} {$index< [expr 1]} {incr index} {
      set iNode [expr $iStart+$index]
      set jNode [expr $jStart+$index]

      puts "Pin Connector Element $eleTag from $iNode to $jNode"
      equalDOF $iNode $jNode 1 2 3 4 5;
      element zeroLength $eleTag $iNode $jNode -mat $matTag -dir 6; # -orient 0 1 0

       set eleTag [expr $eleTag + 1]
   }
}

#uniaxialMaterial Elastic $IDRelease 0.10
# uniaxialMaterial Elastic $IDRelease $Usmall;
#uniaxialMaterial Elastic $IDRelease $Ubig;

#ZeroLenthPins 301 102 301 $NPiers $IDRelease
#ZeroLenthPins 102 302 302 $NPiers $IDRelease
#
#ZeroLenthPins 303 103 303 $NPiers $IDRelease
#ZeroLenthPins 103 304 304 $NPiers $IDRelease
#
#ZeroLenthPins 305 104 305 $NPiers $IDRelease
#ZeroLenthPins 104 306 306 $NPiers $IDRelease

#puts "Pin Connectors Assigned"
#puts " "

# ----------------
# Bridge deck
# ----------------
# geomTransf for deck
geomTransf Linear $GirderTransfTag 0.0 1.0 0.0;       # associate a tag to transformation

# Deck details 
set effectiveMod 0.7

set Ad  [expr 73.961*$ft*$ft];          
set Idy [expr $effectiveMod*847.648*pow($ft,4)];   
set Idz [expr $effectiveMod*7.165*(10**3)*pow($ft,4)]

set eleMass [expr 0.925*$kip/$in/$g]
element elasticBeamColumn $gird11 101 131 $Ad $Ec $Gc $J [expr $Idy] [expr $Idz] $GirderTransfTag -mass $eleMass
element elasticBeamColumn $gird12 131 132 $Ad $Ec $Gc $J [expr $Idy] [expr $Idz] $GirderTransfTag -mass $eleMass
element elasticBeamColumn $gird13 132 133 $Ad $Ec $Gc $J [expr $Idy] [expr $Idz] $GirderTransfTag -mass $eleMass
element elasticBeamColumn $gird14 133 102 $Ad $Ec $Gc $J [expr $Idy] [expr $Idz] $GirderTransfTag -mass $eleMass

element elasticBeamColumn $gird21 102 231 $Ad $Ec $Gc $J [expr $Idy] [expr $Idz] $GirderTransfTag -mass $eleMass
element elasticBeamColumn $gird22 231 232 $Ad $Ec $Gc $J [expr $Idy] [expr $Idz] $GirderTransfTag -mass $eleMass
element elasticBeamColumn $gird23 232 233 $Ad $Ec $Gc $J [expr $Idy] [expr $Idz] $GirderTransfTag -mass $eleMass
element elasticBeamColumn $gird24 233 103 $Ad $Ec $Gc $J [expr $Idy] [expr $Idz] $GirderTransfTag -mass $eleMass

element elasticBeamColumn $gird31 103 331 $Ad $Ec $Gc $J [expr $Idy] [expr $Idz] $GirderTransfTag -mass $eleMass
element elasticBeamColumn $gird32 331 332 $Ad $Ec $Gc $J [expr $Idy] [expr $Idz] $GirderTransfTag -mass $eleMass
element elasticBeamColumn $gird33 332 333 $Ad $Ec $Gc $J [expr $Idy] [expr $Idz] $GirderTransfTag -mass $eleMass
element elasticBeamColumn $gird34 333 104 $Ad $Ec $Gc $J [expr $Idy] [expr $Idz] $GirderTransfTag -mass $eleMass

element elasticBeamColumn $gird41 104 431 $Ad $Ec $Gc $J [expr $Idy] [expr $Idz] $GirderTransfTag -mass $eleMass
element elasticBeamColumn $gird42 431 432 $Ad $Ec $Gc $J [expr $Idy] [expr $Idz] $GirderTransfTag -mass $eleMass
element elasticBeamColumn $gird43 432 433 $Ad $Ec $Gc $J [expr $Idy] [expr $Idz] $GirderTransfTag -mass $eleMass
element elasticBeamColumn $gird44 433 105 $Ad $Ec $Gc $J [expr $Idy] [expr $Idz] $GirderTransfTag -mass $eleMass

#puts "05 --------------------------------------------------------------------------- ELEMENT: ELASITIC DECK BEAM"
#puts "Elastic Beam Element $gird1 from 101 to 301"
#puts "Elastic Beam Element $gird2 from 302 to 303"
#puts "Elastic Beam Element $gird2 from 304 to 305"
#puts "Elastic Beam Element $gird2 from 306 to 105"
#puts "Beam Elements Assigned"
#puts " "

# -----------------------------------------------
# Recorder 
# -----------------------------------------------

#recorder Node -file $dataDir/RAbutmentx.out -time -node 411 412 421 422 -dof 1 reaction;     # support reaction
#recorder Node -file $dataDir/RAbutmenty.out -time -node 411 412 421 422 -dof 2 reaction;     # support reaction
#recorder Node -file $dataDir/RAbutmentz.out -time -node 411 412 421 422 -dof 3 reaction;     # support reaction

#recorder Node -file $dataDir/DBase.out -time   -node 2 3 4 -dof 1 2 3 disp;         # displacements of support nodes
#recorder Node -file $dataDir/RotBase.out -time -node 2 3 4 -dof 4 5 6 disp;         # displacements of support nodes
#recorder Node -file $dataDir/RBase.out -time   -node 2 3 4 -dof 1 2 3 reaction;     # support reaction
#recorder Node -file $dataDir/MBase.out -time   -node 2 3 4 -dof 4 5 6 reaction;     # support reaction

#recorder Node -file $dataDir/DTop.out   -time -node 101 102 103 104 105 -dof 1 2 3 disp;     # displacements/ rot at bottom of bearings
#recorder Node -file $dataDir/RotTop.out -time -node 101 102 102 104 105 -dof 4 5 6 disp;     # displacements/ rot at Top of bearings

#recorder Element -file $dataDir/FPier.out   -time -ele      2   3   4       globalForce;     # Pier element forces 
recorder Node -file $dataDir/Pier2D.out -time -node 102 -dof 1 3 disp;  
recorder Node -file $dataDir/Pier3D.out -time -node 103 -dof 1 3 disp;  
recorder Node -file $dataDir/Pier4D.out -time -node 104 -dof 1 3 disp;  
#recorder Element -file $dataDir/FGirder.out -time -eleRange 101 102 103 104 globalForce;     # Girder element forces 
 
recorder Element -file $dataDir/SteelFiber.out -time -ele 3 section fiber 0.0 40.0  3 stressStrain
recorder Element -file $dataDir/CCFiber.out -time -ele 3 section fiber 0.0 -36.0 1 stressStrain
recorder Element -file $dataDir/UCFiber.out -time -ele 3 section fiber 0.0 -40.0 2 stressStrain

 
# ======================================================================
# DEFINE GRAVITY LOADING AND MASS
# ======================================================================
# nodal forces: 
#set F1 [expr 709.765*$kip];     #ABUT 1 
#set F5 [expr 964.553*$kip];     #ABUT 2             
#set F2 [expr 1784.0*$kip];      #PIER2 TOP
#set F3 [expr 2199.0*$kip];      #PIER3 TOP
#set F4 [expr 1883.0*$kip];      #PIER4 TOP
set F2 [expr 109.383*$kip];      # PIER2 TOP
set F3 [expr 106.099*$kip];      # PIER3 TOP
set F4 [expr 99.191*$kip];       # PIER4 TOP


# Masses OK
#mass 101 [expr $F1/$g] 0. [expr $F1/$g] 0. 0. 0.;       #ABUT1         # put massses in x, y, z
#mass 105 [expr $F5/$g] 0. [expr $F5/$g] 0. 0. 0.;       #ABUT2         # no masses in rotational degrees of freedom
mass 102 [expr $F2/$g] [expr $F2/$g] [expr $F2/$g] 0. 0. 0.;       # PIER TOP
mass 103 [expr $F3/$g] [expr $F3/$g] [expr $F3/$g] 0. 0. 0.;       # PIER TOP
mass 104 [expr $F4/$g] [expr $F4/$g] [expr $F4/$g] 0. 0. 0.;       # PIER TOP

# assign gravity loading 
set PatternTag 1 
set Tol 1.0e-8 
pattern Plain $PatternTag Linear {
   #load 101 0. -$F1 0. 0. 0. 0.;               # for the reactions
   load 102 0. -$F2 0. 0. 0. 0.;                # for the reactions
   load 103 0. -$F3 0. 0. 0. 0.;                # for the reactions
   load 104 0. -$F4 0. 0. 0. 0.;                # for the reactions
   #load 105 0. -$F5 0. 0. 0. 0.;               # for the reactions
   eleLoad -ele 141 142 143 144 -type -beamUniform 0.0 -0.925
   eleLoad -ele 241 242 243 244 -type -beamUniform 0.0 -0.925
   eleLoad -ele 341 342 343 344 -type -beamUniform 0.0 -0.925
   eleLoad -ele 441 442 443 444 -type -beamUniform 0.0 -0.925
}

#puts "06 --------------------------------------------------------------------------- GRIVITY LOAD AND MASS"
#puts "Gravity Loads and Masses Assigned"
#puts " "
#
#puts "07 --------------------------------------------------------------------------- GRAVITY ANALYSIS"
constraints Plain   
numberer    RCM; 
test        EnergyIncr $Tol 6 
system      BandGeneral 
algorithm Newton 

set Nstep 10;                 # apply gravity in 10 steps
set LFinc [expr 1./$Nstep];   # first load increment

integrator LoadControl $LFinc;   # determine the next time step for an analysis, # apply gravity in 10 steps
analysis   Static;               # define type of analysis static or transient
analyze    $Nstep;               # perform gravity analysis
loadConst -time 0.0;             # hold gravity constant and restart time
record
#
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
#
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
#
wipe
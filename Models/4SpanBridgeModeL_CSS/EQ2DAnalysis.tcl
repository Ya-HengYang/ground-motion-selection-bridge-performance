# --------------------------------------------------------------------------------------------------
# Coronado Bridge Model
# Maria Camila Lopez Ruiz
# University of California, Berkeley
# Bidirectional Uniform Earthquake Excitation
# execute this file after you have built the model, and after you apply gravity

# source in procedures
# set GMdir "Alamo_975";            # ground-motion file directory
# source ReadSMDfile.tcl;       # procedure for reading GM file and converting it to proper format
#source ReadRecord.tcl;      # procedure for reading GM file and converting it to proper format

# --------------------------------------------------------------------------------------------------
# set Scale 1.00

# --------------------------------------------------------------------------------------------------
# Uniform Earthquake ground motion (uniform acceleration input at all support nodes)

# --------------------------------------------------------------------------------------------------
#Duration Correlated GMs 

# Uniform Earthquake ground motion (uniform acceleration input at all support nodes)
# set iGMfile "RSN728_SUPERB_B-WSM090 RSN728_SUPERB_B-WSM180" ;     # ground-motion filenames, should be different files
# set iGMfact "1.0 1.0";            # ground-motion scaling factor

# set iGMfile "RSN1116_KOBE_SHI000 RSN1116_KOBE_SHI090" ;       # ground-motion filenames, should be different files
# set iGMfact "1.0 1.0";            # ground-motion scaling factor

# set iGMfile "RSN1120_KOBE_TAK000 RSN1120_KOBE_TAK090" ;       # ground-motion filenames, should be different files
# set iGMfact "1.0 1.0";            # ground-motion scaling factor

# set iGMfile "RSN1158_KOCAELI_DZC180 RSN1158_KOCAELI_DZC270" ;     # ground-motion filenames, should be different files
# set iGMfact "1.0 1.0";            # ground-motion scaling factor

# set iGMfile "RSN1176_KOCAELI_YPT060 RSN1176_KOCAELI_YPT150" ;     # ground-motion filenames, should be different files
# set iGMfact "1.0 1.0";            # ground-motion scaling factor

# set iGMfile "RSN1492_CHICHI_TCU052-E RSN1492_CHICHI_TCU052-N" ;       # ground-motion filenames, should be different files
# set iGMfact "1.0 1.0";    

# set iGMfile "RSN1505_CHICHI_TCU068-E RSN1505_CHICHI_TCU068-N" ;       # ground-motion filenames, should be different files
# set iGMfact "1.0 1.0";            # ground-motion scaling factor

# set iGMfile "RSN3748_CAPEMEND_FFS270 RSN3748_CAPEMEND_FFS360" ;       # ground-motion filenames, should be different files
# set iGMfact "1.0 1.0";            # ground-motion scaling factor

# set iGMfile "RSN4894_CHUETSU_1-G1EW RSN4894_CHUETSU_1-G1NS" ;     # ground-motion filenames, should be different files
# set iGMfact "1.0 1.0";            # ground-motion scaling factor

# set iGMfile "RSN6962_DARFIELD_ROLCS29E RSN6962_DARFIELD_ROLCS61W" ;       # ground-motion filenames, should be different files
# set iGMfact "1.0 1.0";            # ground-motion scaling factor

# set iGMfile "RSN8063_CCHURCH_CBGSN89W RSN8063_CCHURCH_CBGSS01W" ;     # ground-motion filenames, should be different files
# set iGMfact "1.0 1.0";            # ground-motion scaling factor

## Define DISPLAY -------------------------------------------------------------
#set  xPixels 1200;  # height of graphical window in pixels
#set  yPixels 800;   # height of graphical window in pixels
#set  xLoc1 10;  # horizontal location of graphical window (0=upper left-most corner)
#set  yLoc1 10;  # vertical location of graphical window (0=upper left-most corner)
#set ViewScale 10;   # scaling factor for viewing deformed shape, it depends on the dimensions of the model
## DisplayModel3D DeformedShape $ViewScale $xLoc1 $yLoc1  $xPixels $yPixels
#recorder plot $dataDir/DFree.out DisplDOF[lindex $iGMdirection 0] 1200 10 400 400 -columns 1 [expr 1+[lindex $iGMdirection 0]]; # a window to plot the nodal displacements versus time
#recorder plot $dataDir/DFree.out DisplDOF[lindex $iGMdirection 1] 1200 410 400 400 -columns 1 [expr 1+[lindex $iGMdirection 1]]; # a window to plot the nodal displacements versus time

# ----------- set up analysis parameters
source LibAnalysisDynamicParameters.tcl;    # constraintsHandler,DOFnumberer,system-ofequations,convergenceTest,solutionAlgorithm,integrator

# ------------ define & apply damping
# RAYLEIGH damping parameters, Where to put M/K-prop damping, switches (http://opensees.berkeley.edu/OpenSees/manuals/usermanual/1099.htm)
#          D=$alphaM*M + $betaKcurr*Kcurrent + $betaKcomm*KlastCommit + $beatKinit*$Kinitial
set xDamp 0.03;                                     # damping ratio
set MpropSwitch 1.0;
set KcurrSwitch 0.0;
set KcommSwitch 1.0;
set KinitSwitch 0.0;
set nEigenI 3;      # mode 3
set nEigenJ 4;      # mode 4
set lambdaN [eigen [expr $nEigenJ]];                # eigenvalue analysis for nEigenJ modes
set lambdaI [lindex $lambdaN [expr $nEigenI-1]];    # eigenvalue mode i
set lambdaJ [lindex $lambdaN [expr $nEigenJ-1]];    # eigenvalue mode j
set omegaI [expr pow($lambdaI,0.5)];
set omegaJ [expr pow($lambdaJ,0.5)];
set alphaM [expr $MpropSwitch*$xDamp*(2*$omegaI*$omegaJ)/($omegaI+$omegaJ)];    # M-prop. damping; D = alphaM*M
set betaKcurr [expr $KcurrSwitch*2.*$xDamp/($omegaI+$omegaJ)];                  # current-K;      +beatKcurr*KCurrent
set betaKcomm [expr $KcommSwitch*2.*$xDamp/($omegaI+$omegaJ)];                  # last-committed K;   +betaKcomm*KlastCommitt
set betaKinit [expr $KinitSwitch*2.*$xDamp/($omegaI+$omegaJ)];                  # initial-K;     +beatKinit*Kini
rayleigh $alphaM $betaKcurr $betaKinit $betaKcomm
#  # RAYLEIGH damping
#region 1 -node 101 131 132 133 102 232 232 233 103 331 332 333 104 431 432 433 105 -rayleigh $alphaM 0.0 0.0 0.0
#region 2 -ele  141 142 143 144 241 242 243 244 341 342 343 344 441 442 443 444 411 412 421 422 -rayleigh 0.0 $betaKcurr $betaKinit $betaKcomm
 

#  ---------------------------------    perform Dynamic Ground-Motion Analysis
# the following commands are unique to the Uniform Earthquake excitation
#set IDloadTag 400;  # for uniformSupport excitation
# Uniform EXCITATION: acceleration input
#foreach GMdirection $iGMdirection GMfile $iGMfile GMfact $iGMfact {
#    incr IDloadTag;
#    # set inFile $GMdir/$GMfile.AT2
#    set inFile $GMdir/$GMfile.acc
#    set outFile $GMdir/$GMfile.g3;          # set variable holding new filename (PEER files have .at2/dt2 extension)
#    ReadRecord $inFile $outFile dt nPts;        # call procedure to convert the ground-motion file
#    # ReadSMDFile $inFile $outFile dt;          # call procedure to convert the ground-motion file
#    set GMfatt [expr $g*$GMfact*$Scale];            # data in input file is in g Unifts -- ACCELERATION TH
#    set AccelSeries "Series -dt $dt -filePath $outFile -factor  $GMfatt";       # time series information
#    pattern UniformExcitation  $IDloadTag  $GMdirection -accel  $AccelSeries  ; # create Unifform excitation
#}

set iGMdirection "1 3";                          # ground-motion directions
#set IDloadTag 400;                              # for uniformSupport excitation
#set GMfatt [expr $g*$GMfact*$Scale];            # data in input file is in g Unifts -- ACCELERATION TH
#set AccelSeries "Series -dt $dt -filePath $outFile -factor  $GMfatt";       # time series information
timeSeries Path 1 -time $time -values $gm1 
timeSeries Path 2 -time $time -values $gm2 

#set AccelSeries1 "Series -time $time -values $gm1";   
#set AccelSeries2 "Series -time $time -values $gm2";  
pattern UniformExcitation  400  1  -accel 1;  # create Unifform excitation
pattern UniformExcitation  401  3  -accel 2;  # create Unifform excitation

# set up ground-motion-analysis parameters
set DtAnalysis  [expr $dt*$sec];        # time-step Dt for lateral analysis
set nPts [llength $time] 
set TmaxAnalysis    [expr $nPts*$dt];   # maximum duration of ground-motion analysis -- groundmotion durations plus 5*period
set Nsteps [expr int($TmaxAnalysis/$DtAnalysis)];


#____________________________________________________________________________#
set dtForAnalysis $DtAnalysis;
source Dynamic_Analysis_Script.tcl
#____________________________________________________________________________#

puts "Ground Motion Done. End Time: [getTime]"

set constraintsTypeDynamic Transformation;
constraints $constraintsTypeDynamic; 

set numbererTypeDynamic RCM;
numberer $numbererTypeDynamic; 

set systemTypeDynamic BandGeneral;  # try UmfPack for large problems
system $systemTypeDynamic;

set algorithmType Newton;

set analysisTypeDynamic Transient;
analysis $analysisTypeDynamic; 
set Tol 1.0e-8;
set maxNumIter 1000;
set printFlag 0;
set NewmarkGamma 0.5;
set NewmarkBeta 0.25;
set TestType EnergyIncr;  #EnergyIncr

# set Nsteps 5372;      #NPTS

for {set ik 1} {$ik <= $Nsteps} {incr ik 1} {
puts "Step #: $ik"
    # puts "$ik"
      set ok      [analyze 1 $dtForAnalysis]
    # Convergence
    if {$ok != 0} {
        puts "Trying Bisection ...";
        algorithm NewtonLineSearch <-type Bisection>;
        set ok [analyze 1 $dtForAnalysis]
        algorithm $algorithmType;
    };
    if {$ok != 0} {
        puts "Trying Secant ...";
        algorithm NewtonLineSearch <-type Secant>;
        set ok [analyze 1 $dtForAnalysis]
        algorithm $algorithmType;
    };
    if {$ok != 0} {
        puts "Trying RegulaFalsi ...";
        algorithm NewtonLineSearch <-type RegulaFalsi>;
        set ok [analyze 1 $dtForAnalysis]
        algorithm $algorithmType;
    };
    if {$ok != 0} {
        puts "Trying KrylovNewton ...";
        algorithm KrylovNewton;
        set ok [analyze 1 $dtForAnalysis]
        algorithm $algorithmType;
    };
    if {$ok != 0} {
        puts "Trying Newton ...";
        algorithm Newton;
        set ok [analyze 1 $dtForAnalysis]
        algorithm $algorithmType;
    };
    if {$ok != 0} {
        puts "Trying BFGS ...";
        algorithm BFGS;
        set ok [analyze 1 $dtForAnalysis]
        algorithm $algorithmType;
    };
    if {$ok != 0} {
        puts "Trying Broyden ...";
        algorithm Broyden;
        set ok [analyze 1 $dtForAnalysis]
        algorithm $algorithmType;
    };
    if {$ok != 0} {
        puts "Trying HHT 0.9 ...";
        integrator HHT 0.9;
        set ok [analyze 1 $dtForAnalysis]
        # integrator TRBDF2;
        integrator Newmark $NewmarkGamma $NewmarkBeta;
    };
    if {$ok != 0} {
        puts "Trying OS ...";
        integrator AlphaOS 1.00;
        algorithm Linear;
        set ok [analyze 1 $dtForAnalysis]
        # integrator TRBDF2;
        integrator Newmark $NewmarkGamma $NewmarkBeta;
        algorithm $algorithmType;
    };
    if {$ok != 0} {
        puts "Trying OSG ...";
        integrator AlphaOSGeneralized 1.00;
        algorithm Linear;
        set ok [analyze 1 $dtForAnalysis]
        # integrator TRBDF2;
        integrator Newmark $NewmarkGamma $NewmarkBeta;
        algorithm $algorithmType;
    };
        if {$ok != 0} {
        puts "Trying OSG ...";
        integrator GeneralizedAlpha 1.0 0.8;
        algorithm Newton;
        set ok [analyze 1 $dtForAnalysis]
        # integrator TRBDF2;
        integrator Newmark $NewmarkGamma $NewmarkBeta;
        algorithm $algorithmType;
    };
    if {$ok != 0} {
        puts "Trying more iterations...";
        test $TestType $Tol 1000 $printFlag;
        set ok [analyze 1 $dtForAnalysis]
        test $TestType $Tol $maxNumIter $printFlag;
    };
    if {$ok != 0} {
        puts "Trying tolerance 1.0e-7 ...";
        test $TestType 1.0e-7 $maxNumIter 50;
        set ok [analyze 1 $dtForAnalysis]
        test $TestType $Tol $maxNumIter $printFlag;
    };
    if {$ok != 0} {
        puts "Trying tolerance 1.0e-6 ...";
        test $TestType 1.0e-6 $maxNumIter 50;
        set ok [analyze 1 $dtForAnalysis]
        test $TestType $Tol $maxNumIter $printFlag;
    };
    if {$ok != 0} {
        puts "Trying tolerance 1.0e-5 ...";
        test $TestType 1.0e-5 $maxNumIter 50;
        set ok [analyze 1 $dtForAnalysis]
        test $TestType $Tol $maxNumIter $printFlag;
    };
    if {$ok != 0} {
        puts "Trying tolerance 1.0e-3 ...";
        test $TestType 1.0e-3 $maxNumIter 50;
        set ok [analyze 1 $dtForAnalysis]
        test $TestType $Tol $maxNumIter $printFlag;
    };
    if {$ok != 0} {
        puts "Trying tolerance 1.0e-3 ...";
        test $TestType 1.0e-3 $maxNumIter 50;
        set ok [analyze 1 [expr $dtForAnalysis/2.0]]
        test $TestType $Tol $maxNumIter $printFlag;
    };
    if {$ok != 0} {
        puts "Trying tolerance 1.0e-3 ...";
        test $TestType 1.0e-3 $maxNumIter 50;
        set ok [analyze 1 [expr $dtForAnalysis/4.0]]
        test $TestType $Tol $maxNumIter $printFlag;
    };
    if {$ok != 0} {
        puts "Trying tolerance 1.0e-3 ...";
        test $TestType 1.0e-3 $maxNumIter 50;
        set ok [analyze 1 [expr $dtForAnalysis/8.0]]
        test $TestType $Tol $maxNumIter $printFlag;
    };
    if {$ok != 0} {
        puts "Trying tolerance 1.0e-3 ...";
        test $TestType 1.0e-3 $maxNumIter 50;
        set ok [analyze 1 [expr $dtForAnalysis/16.0]]
        test $TestType $Tol $maxNumIter $printFlag;
    };
    if {$ok != 0} {
        puts "Trying tolerance 1.0e-3 ...";
        test $TestType 1.0e-3 $maxNumIter 50;
        set ok [analyze 1 [expr $dtForAnalysis/32.0]]
        test $TestType $Tol $maxNumIter $printFlag;
    };
    if {$ok != 0} {
        puts "Trying tolerance 1.0e-3 ...";
        test $TestType 1.0e-3 $maxNumIter 50;
        set ok [analyze 1 [expr $dtForAnalysis/64.0]]
        test $TestType $Tol $maxNumIter $printFlag;
    };


    
    
    
    if {$ok != 0} {
        set Nstepsmax [expr $ik-1]
        break;
    }
      
       }

if {[expr $ik-1] == $Nsteps} {

set AnalysisA [expr 1] } else {

set AnalysisA [expr 0] };

puts "Analysis completion=$AnalysisA"

set fileid10 [open "$dataDir/ConvergenceIndicator.txt" a+];
puts $fileid10 "$AnalysisA" 
close $fileid10


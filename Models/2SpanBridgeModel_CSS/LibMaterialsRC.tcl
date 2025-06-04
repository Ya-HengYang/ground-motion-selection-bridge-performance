##########################################################
# LibMaterialsRC.tcl:  define a library of Reinforced-Concrete materials
#           Silvia Mazzoni & Frank McKenna, 2006
##########################################################
source LibUnits.tcl;

#Material ID tags
set IDconcCore  1
set IDconcCover 2
set IDSteel     3
set IDRelease   20

# ======================================================================
# CONFINED AND UNCONFINED CONCRETE
# ======================================================================
# concrete compressive strength
set fc   [expr -5.0*$ksi];               # CONCRETE Compressive Strength, ksi   (+Tension, -Compression)
set Ec   [expr 57*$ksi*sqrt(-$fc/$psi)]; # Concrete Elastic Modulus
set GCol [expr 0.4*$Ec];                 # Shear Modulus - Moehle 6.11.1 (ACI R6.6.3.1)* other refs use n=0.2; Ec/(2*(1+nu))

set nu    0.2;
set Gc    [expr $Ec/2./[expr 1+$nu]];    # Torsional stiffness Modulus
set J     $Ubig;                         # set large torsional stiffness
set epsC -0.002;

# confined concrete
set Kfc 1.3;                             # ratio of confined to unconfined concrete strength, SDC Eq. 3.3.6-4
set Kres 0.6;                            # *ratio of residual/ultimate to maximum stress, original: 0.2
set fc1C  [expr $Kfc*$fc];               # CONFINED concrete (mander model), maximum stress
set eps1C [expr $epsC*(1+5*($Kfc-1))];   # strain at maximum stress (Mander model, 1988)
set fc2C  [expr $Kres*$fc1C];            # ultimate stress
set eps2C [expr -0.035];                 # *strain at ultimate stress (Moehle textbook or Mander, 1988 Equation (64) solved numerically)  
set lambda 0.1;                          # ratio between unloading slope at $eps2 and initial slope $Ec

# unconfined concrete
set fc1U   $fc;                # UNCONFINED concrete (todeschini parabolic model), maximum stress
set eps1U -0.002;              # strain at maximum strength of unconfined concrete
set fc2U  [expr $Kres*$fc1U];  # ultimate stress
set eps2U -0.005;              # strain at ultimate stress

# tensile-strength properties
set ftC [expr -0.14*$fc1C];    # tensile strength +tension
set ftU [expr -0.14*$fc1U];    # tensile strength +tension
set Ets [expr $ftU/0.002];     # tension softening stiffness
 
uniaxialMaterial Concrete02 $IDconcCore $fc1C $eps1C $fc2C $eps2C $lambda $ftC $Ets;    # Core concrete (confined)
uniaxialMaterial Concrete02 $IDconcCover $fc1U $eps1U $fc2U $eps2U $lambda $ftU $Ets;   # Cover concrete (unconfined)

# ======================================================================
# REINFORCING STEEL parameters
# ======================================================================
set Fy [expr 68*$ksi];       # STEEL yield stress
set Es [expr 29000.*$ksi];   # modulus of steel
set Bs 0.01;                 # strain-hardening ratio 
set R0 10;                   # *control the transition from elastic to plastic branches
set cR1 0.925;               # control the transition from elastic to plastic branches
set cR2 0.15;                # control the transition from elastic to plastic branches

uniaxialMaterial Steel02 $IDSteel  $Fy $Es $Bs $R0 $cR1 $cR2


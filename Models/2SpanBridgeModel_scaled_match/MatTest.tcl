# matTest.tcl: SDOF truss to test uniaxial material models

# Units: kip, in

# MHS, Sept 1999

# email: mhscott@ce.berkeley.edu

model BasicBuilder -ndm 1 -ndf 1

# Define nodes

node 1 0.0

node 2 1.0

# Fix node 1

fix 1 1

# Define uniaxialMaterial

# tag f'c epsc f'cu epscu

uniaxialMaterial Concrete01 1 -5.0 -0.002 -1.0 -0.004

# Define truss element with unit area

# tag ndI ndJ A matTag

element truss 1 1 2 1.0 1

set dt 1.0 ;# Increment between data points

set filename pattern1.txt ;# Filename containing data points

set factor 0.006 ;# Factor applied to data values

# Read displacement pattern from file

# Note, any pattern type can be used here: Linear, Path, Sine, etc.

pattern Plain 1 "Series -dt $dt -filePath $filename -factor $factor" {

# Set reference displacement value

# node dof value

sp 2 1 1.0

}

# Impose monotonic displacements

#pattern Plain 2 "Linear -factor $factor" {

# sp 2 1 1.0

#}

# Record nodal displacements (same as strains since truss length is 1.0)

recorder Node truss.out disp -load -node 2 -dof 1

# Record truss force (same as stress since truss area is 1.0)

recorder Element 1 -time -file force.out force

system UmfPack

constraints Penalty 1.0e12 1.0e12

# Set increment in load factor used for integration

# Does not have to be the same as dt used to read in displacement pattern

set dl $dt

integrator LoadControl $dl 1 $dl $dl

test NormDispIncr 1.0e-6 10

algorithm Newton

numberer RCM

analysis Static

analyze 10000
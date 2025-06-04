proc BuildRCcircSection {SecTag IDconcCore IDconcCover IDreinf DSec coverSec numBarsSec barAreaSec SecTagTorsion SecTag3D nfCoreR nfCoreT nfCoverR nfCoverT} { 


    # ======================================================================
    # build a section
    # ======================================================================
    source LibUnits.tcl;    

    # ======================================================================
    # Generate a circular reinforced concrete section
    # ======================================================================
    # with one layer of steel evenly distributed around the perimeter and a confined core.
    #
    # Notes
    #    The center of the reinforcing bars are placed at the inner radius
    #    The core concrete ends at the inner radius (same as reinforcing bars)
    #    The reinforcing bars are all the same size
    #    The center of the section is at (0,0) in the local axis system
    #    Zero degrees is along section y-axis
    # ----------------------------------------------------------------------
    
    # ======================================================================
    # section GEOMETRY 
    # ======================================================================
    # inner radius of the section, only for hollow sections
    set ri 0.0     
    
    # overall (outer) radius of the section
    set ro [expr $DSec/2]
    
    # number of radial divisions in the core (number of "rings")
    #set nfCoreR 8
    
    # number of theta divisions in the core (number of "wedges")
    #set nfCoreT 8
    
    # number of radial divisions in the cover (2, 4)
    #set nfCoverR 2
    
    # number of theta divisions in the cover   (4, 8)
    #set nfCoverT 8
    

    # Define the fiber section
    section fiberSec $SecTag -GJ $Ubig {
        set rc [expr $ro-$coverSec];                                    # Core radius
        patch circ $IDconcCore $nfCoreT   $nfCoreR  0 0 $ri $rc 0 360;  # Define the core patch
        patch circ $IDconcCover $nfCoverT $nfCoverR 0 0 $rc $ro 0 360;  # Define the cover patch
        set theta [expr 360.0/$numBarsSec];                             # Determine angle increment between bars
        layer circ $IDreinf $numBarsSec $barAreaSec 0 0 $rc $theta 360; # Define the reinforcing layer
    }

    # define elastic torsional stiffness
    #uniaxialMaterial Elastic $SecTagTorsion $Ubig;   
    
    # combine section properties
    #section Aggregator $SecTag3D $SecTagTorsion T -section $SecTag
    
}
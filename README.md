
  
Script name
================
`plot_condition_dependent_networks_and_barplots_gene_level.pl`


Description
================
Obtains complement sets of condition-dependent genetic interactions from:  
a) an -infile_table_between with gene-pairs with condition-dependent genetic interactions for conditions-pairs and . 
b) an -infile_table_within  with gene-pairs with genetic interactions for each condition . 
to plot sign changes like:
 
    neutral  (condition 1) to [positive|negative] (condition 2)
    positive (condition 1) to negative (condition 2)
    negative (condition 1) to positive (condition 2)

 To draw each condition network and condition-dependent networks and histograms (see Example Outfile):
 
Example Outfile
================
https://github.com/jdime/BFG_GI_ConditionDependent/blob/master/examples/OUTPUTS/example_outfile.BarplotsAndNetworks.diagonal_up.pdf
 
 
General workflow
================
This code is a wrapper library written in Perl, and needs Cytoscape to draw the networks and R to draw the barplots and create the matrix formatted final plot.

The general workflow of this script is as follows:
  1. Reads tables with intra-condition genetic interactions (shown as the diagonal of the example output)
  2. Reads tables with sign changes using specified False Discovery Rate cutoffs (shown off-diagonal as both networks and barplots in the example output)
  3. Gets specific gene-pairs changing interaction signs for off-diagonal networks, and frequencies for barplots
  4. Draws networks using a template nodes' position file using Cytoscape
  5. Draws barplots and integrated the networks into the 'matrix' layout using R
  6. Reports output
  7. Ends


Example commands
================
This example works with files provided in folder ~/examples/INPUTS<br />

`plot_condition_dependent_networks_and_barplots_gene_level.pl -cutoff_fdr_between 0.05 -cutoff_fdr_within 0.05 -diagonal_up_or_down up -infile_edge_types_order ~/examples/INPUTS/example_edge_types_order.txt -infile_gene_alias ~/examples/INPUTS/example_gene_alias.txt -infile_gml ~/examples/INPUTS/example_network.gml -infile_order_conditions ~/examples/INPUTS/example_order_conditions.txt -path_outfiles ~/examples/OUTPUTS -prefix_for_outfile example_outfile -represent_nodes none -string_separating_pairs \<tab\> -width_network_edges 10 -infile_table_between ~/examples/INPUTS/example_table_between.txt -infile_table_within ~/examples/INPUTS/example_table_within.txt`

Inputs Description
================

**1) an -infile_table_between in format like:**

    ID1    ID2    Condition1  Condition2  Class_Condition1  Class_Condition2  DeltaZ_FDR
    MMS1   MUS81  NoDrug      MMS         NEUTRAL           AGGRAVATING       0.00111
    RAD59  RAD61  NoDrug      MMS         NEUTRAL           AGGRAVATING       3.50e-06
    RAD52  SGS1   NoDrug      MMS         NEUTRAL           ALLEVIATING       3.97e-88
    CLA4   CSM2   NoDrug      4NQO        NEUTRAL           AGGRAVATING       2.79e-38
 Note: more columns can exist, but the ones shown are mandatory

**2) an -infile_table_within in format like:**

    ID1    ID2    FDR.Internal_xy.NoDrug  FDR.Internal_xy.MMS  FDR.Internal_xy.4NQO  Z_GIS_xy.NoDrug_Class  Z_GIS_xy.MMS_Class  Z_GIS_xy.4NQO_Class   
    MMS1   MUS81  3.238e-27               1.9310e-20           2.92310e-5            NEUTRAL                AGGRAVATING         AGGRAVATING
    RAD59  RAD61  0.224664                0.6263857            4.6286337             NEUTRAL                AGGRAVATING         AGGRAVATING
    RAD52  SGS1   8.465e-22               5.0232e-22           5.0232e-12            NEUTRAL                ALLEVIATING         ALLEVIATING
    CLA4   CSM2   0.799920                0.9493681            1.9368149             NEUTRAL                AGGRAVATING         AGGRAVATING
Note: more columns can exist, but Z_GIS_xy.*_Class and FDR.Internal_xy.* are mandatory

**3) an -infile_gene_alias in format like:**
 
    Abbreviated  Full_ID
    RTT101       RTT101__YJL047C__S000003583
    SRS2         SRS2__YJL092W__S000003628
    RAD52        RAD52__YML032C__S000004494
    SGS1         SGS1__YMR190C__S000004802
 Notes: this is useful in case -infile_table_* have Abbreviated_ID's and -infile_gml has Full_ID's
        the Abbreviated_ID also can be used with '-represent_nodes abbreviated_id' (see below)

**4) an -infile_order_conditions in format like:**
 
    #Condition   Plot(Y/N)
    NoDrug  N
    DMSO    Y
    MMS     Y
    4NQO    Y
Notes: outfile *BarplotsAndNetworks.diagonal_*.pdf will have conditions in the order of this file
        column 2 indicates if the condition should be plotted (Y) or not (N)

**5) an -infile_edge_types_order in format like:**

    negative---neutral
    neutral---negative
    positive---negative
    negative---positive
    positive---neutral
    neutral---positive
    positive
    negative

 Notes: will indicate the order in which edges will be drawn in the network (in Cytoscape)
        Still work in progress

**6) an -infile_gml to use as template for node positions for Cytoscape in gml format like:**
 
    Creator	"Cytoscape"
    Version	1.0
    graph	[
 	    node	[
 		    root_index	-57
 		    id	-57
 		    graphics	[
 			    x	124.55083084106445
 			    y	281.7039794921875
 			    w	39.99999237060547
 			    h	40.0
 		    ]
 		    label	"RAD18__YCR066W__S000000662"
 	    ]
 	    ...
 	    edge	[
 		    root_index	-15048
 		    target	-55
 		    source	-49
 		    graphics	[
 			    width	1.5
 			    fill	"#ffcc66"
 			    type	"line"
 			    Line	[
 			    ]
 			    source_arrow	0
 			    target_arrow	0
 		    ]
 		    label	"PPI"
 	    ]


Outputs Description
================

1) *BarplotsAndNetworks.diagonal_*.pdf  <br />
 Plotted networks and barplots merged into a single file

2) *BarplotsAndNetworks.legend.pdf <br />
 Colour legend for outfile 1
  
3) *Complement.Parameters <br />
 Parameters used for the run and date/time

4) ~/.../NETWORKS/InstructionsForCytoscape.ins <br />
 Commands for cytoscape.sh to draw the nerworks
 

Commands Description
================

     -path_outfiles             (path/name to the directory where outfiles will be saved)
     -infile_table_between      (path/name to the table with condition-dependent genetic interactions)
     -infile_table_within       (path/name to the table with genetic interactions for each condition)
     -infile_order_conditions   (path/name to a list of column headers from -infile_table_between that will be used for the *BarplotsAndNetworks.pdf outfile. Or type 'NA' to sort alphanumerically)
     -infile_gml                (path/name to the *gml file with node positions to be used as template for gene-gene level complement networks)
     -infile_edge_types_order   (path/name to a list of edge types in order to appear in the *gml file. Or type 'NA' to skip)
     -infile_gene_alias         (path/name to a paired tab of gene ID's to map from -infile_table_between to -infile_gml)

     -width_network_edges       (indicates the width for edges in the outfiles for networks, e.g. '1.0' or '2.0', or type 'NA' to skip)
     -diagonal_up_or_down       (indicates if the networks in the diagonal (each condition network) should be drawn from
                               the bottom-left to the top-right corners [type 'up'] or from the top-left to the bottom-right corners [type 'down'])
     -represent_nodes           (indicates if nodes in the networks should be represented by:
                               'abbreviated_id' to show the Abbreviated_ID from -infile_gene_alias
                               'node_as_a_dot'  to show the node as a dot
                               'both'           to show both Abbreviated_ID and node as a dot
                               'none'           to show none

     -cutoff_fdr_between        (cutoff to consider FDR scores in -infile_table_between as significant for outfiles)
     -cutoff_fdr_within         (cutoff to consider FDR scores in -infile_table_within as significant for outfiles)

     -prefix_for_outfile        (a string to be used for outfiles name)


Dependencies
================

**1) cytoscape.sh** <br />
(http://www.cytoscape.org/download.php)
  Tested with versions 2.8.1 and 3.6.0. <br />
  Modify file ~/perl_modules/PathsDefinition/PathsToPrograms.pm <br />
  to specify the path to cytoscape.sh file in 'cytoscape_executable' key <br />
  OR in $CytoscapeSh variable in plot_condition_dependent_networks_and_barplots_gene_level.pl
  
  Troubleshooting 'cytoscape.sh' <br />
  
  If your cytoscape.sh executable doesn't seem to be working, chances are that either you don;t have the correct version of Java or you need to need to tell cytoscape.sh how to find it. In a Console/Terminal do the following: <br />
`cd /Applications/Cytoscape_v3.6.0  ## or wherever your cytoscape.sh file is located`
`./cytoscape.sh ### this may tell you "Unable to find any JVMs matching version "1.7"`

If these commands open the cytoscape.sh GUI, then we are all good (despite the JVM message above) <br />
But if your 'cytoscape.sh' can't find the JVM, first make sure you have the correct Java version (see you Cytoscape version requiriments). Then type: <br />
`java -version ### to know the Java you have set up is the correct one`
    
Add your Java Home location to your ~/.bash_profile

    export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_161.jdk/Contents/Home" ### or whichever version of JDK you have installed.
    
Then open a new Console/Terminal for changes to take effect.
                  
 **2) convert** <br />
 (http://www.imagemagick.org/script/convert.php) <br />
 Needed to trim white background of network images

 **3) R and R packages (gplots and png)** <br />
 (https://www.r-project.org/) <br />
`install.packages("gplots","png")`
 
 **4) Perl modules** (can be obtained from https://github.com/jdime/BFG_GI_ConditionDependent) <br />
 (All provided in the 'perl_modules' folder) <br />
 LoadParameters::Parameters <br />
 LoadParameters::Evaluate_Definitions <br />
 ReformatPerlEntities::ObtainOutfileWOpath <br />
 PathsDefinition::PathsToInputs <br />
 PathsDefinition::PathsToPrograms <br />
 Rcommands::Rcommands <br />
    
 **5) Perl script** (can be obtained from https://github.com/jdime/BFG_GI_ConditionDependent) <br />

 merge_network_SIF_to_GML_template.pl

Script name:
obtain_Complement_BetweenPairsOfColumns_FromTableOfGenePairs_UsingCutoffs_FromAlbiTablesOfGenePairs_UsingLabels.pl

Description:
 Will obtain complement sets of condition-dependent genetic interactions from
 an -infile_table_between with gene-pairs with condition-dependent genetic interactions for conditions-pairs and
 an -infile_table_within  with gene-pairs with genetic interactions for each condition
 to form sign changes like:
 neutral  (condition 1) to [positive|negative] (condition 2)
 positive (condition 1) to negative (condition 2)
 negative (condition 1) to positive (condition 2)

 To draw condition-dependent networks and histograms

 -------------------------------------------INPUTS----------------------------------------------

 [1]
 a -infile_table_between in format like:
 ID1    ID2    Condition1  Condition2  Class_Condition1  Class_Condition2  DeltaZ_FDR
 MMS1   MUS81  NoDrug      MMS         NEUTRAL           AGGRAVATING       0.00111
 RAD59  RAD61  NoDrug      MMS         NEUTRAL           AGGRAVATING       3.50e-06
 RAD52  SGS1   NoDrug      MMS         NEUTRAL           ALLEVIATING       3.97e-88
 CLA4   CSM2   NoDrug      4NQO        NEUTRAL           AGGRAVATING       2.79e-38
 Note: more columns can exist, but the last four are mandatory

 [2]
 a -infile_table_within in format like:
 ID1    ID2    FDR.Internal_ij.NoDrug  FDR.Internal_ij.MMS  FDR.Internal_ij.4NQO  Z_GIS_ij.NoDrug_Class  Z_GIS_ij.MMS_Class  Z_GIS_ij.4NQO_Class   
 MMS1   MUS81  3.238e-27               1.9310e-20           2.92310e-5            NEUTRAL                AGGRAVATING         AGGRAVATING
 RAD59  RAD61  0.224664                0.6263857            4.6286337             NEUTRAL                AGGRAVATING         AGGRAVATING
 RAD52  SGS1   8.465e-22               5.0232e-22           5.0232e-12            NEUTRAL                ALLEVIATING         ALLEVIATING
 CLA4   CSM2   0.799920                0.9493681            1.9368149             NEUTRAL                AGGRAVATING         AGGRAVATING
 Note: more columns can exist, but Z_GIS_ij.*_Class and FDR.Internal_ij.* are mandatory

 [3]
 a -infile_gene_alias in format like:
 Abbreviated  Full_ID
 RTT101       RTT101__YJL047C__S000003583
 SRS2         SRS2__YJL092W__S000003628
 RAD52        RAD52__YML032C__S000004494
 SGS1         SGS1__YMR190C__S000004802
 Notes: this is useful in case -infile_table_* have Abbreviated_ID's and -infile_gml has Full_ID's
        the Abbreviated_ID also can be used with '-represent_nodes abbreviated_id' (see below)

 [3]
 a -infile_gml to use as template for node positions for Cytoscape in *gml format like:
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

 ----------------------------------------MAIN OUTPUTS-------------------------------------------

 [1]
 *AllUnderlyingScores.tab with all average, stdevp and underlying pairs, regardless of -infile_restrict_pairs_per_condition option

 [2]
 *RestrictedUnderlyingScores.tab with all average, stdevp and underlying pairs for each condition-pair, consideting -infile_restrict_pairs_per_condition

 [3]
 *tab with complements for each pair of columns

 [4]
 *BarplotsAndNetworks.pdf showing complements for each pair of columns as a 'matrix'

 [5]
 *sif file with complements at gene-gene level for each pair of columns

 [6] (optional)
 *gml file from *sif and a template gml file with node positions

 ------------------------------------------COMMANDS---------------------------------------------

 obtain_Complement_BetweenPairsOfColumns_FromTableOfGenePairs_UsingCutoffs_FromAlbiTablesOfGenePairs_UsingLabels.pl [options]
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


 ------------------------------------------DEPENDENCIES---------------------------------------------

This code is a wrapper library written in Perl, and needs Cytoscape to draw the networks and R to draw the barplots and create the matrix formatted final plot.

Dependencies:
1) cytoscape.sh (http://www.cytoscape.org/download.php)
                 Tested with versions 2.8.1 and 3.6.0
                 Modify file ~/perl_modules/PathsDefinition/PathsToPrograms.pm
                  to specify the path to cytoscape.sh file in 'cytoscape_executable' key
                  OR in $CytoscapeSh variable below

 2) convert      (http://www.imagemagick.org/script/convert.php)
                  to trim white background of network images

 3) R and R libraries (gplots and png)
  

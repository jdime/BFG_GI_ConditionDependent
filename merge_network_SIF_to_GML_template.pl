#!/usr/bin/perl

##########################
### Script that uses node positions of a network_1 '-infile_template_gml' in format *.gml (e.g. from Cytoscape)
### to map a second network_2 '-infile_network_sif' and returns the nodes and edges forming the
### UNION or INTERSECTION or INTERSECTION+Net1_COMPLEMENT or INTERSECTION+Net2_COMPLEMENT
### retaning the layout of the template
##########################
### Node IDs must match between the two networks
### Nodes from network_2 not existing in network_1 will appear in the center of the new network layout (*.gml outfile)
##########################

##########################
### Elaborated: Javier Diaz - Jul 2009
### Modified:   Javier Diaz - Apr 14, 2010
###                           to include a function that allows to print out the INTERSECTION+Net1_COMPLEMENT
### Modified:   Javier Diaz - Apr 18, 2011
###                           to include module LoadParameters::Parameters
### Modified:   Javier Diaz - Feb 21, 2017 to add -sif_contains_edge_colours and -sif_contains_edge_widths options
### Modified:   Javier Diaz - Feb 24, 2017 to add -infile_edge_types_order option
### Modified:   Javier Diaz - Jan 23, 2018 to get $outfileWOpath from -prefix_outfiles
##########################

use LoadParameters::Parameters;

$ThisProgramName = $0;
$ThisProgramName =~ s/\S+\///;

$defaultWidthEdge = "1.0";

$CommentsForHelp = "
#####################################################################################
################### START INSTRUCTIONS TO RUN THIS PROGRAM ##########################
###
### Script that uses node positions of a network_1 '-infile_template_gml' in format *.gml (e.g. from Cytoscape) to map a second network_2 '-infile_network_sif'
### Returns the second network mapped -prefix_for_outfile_name (prefix for outfile, or type 'default')
###
### -------------------------------------------INPUTS----------------------------------------------
###
### [1]
### a -infile_template_gml in format like:
### Creator	\"Cytoscape\"
### Version	1.0
### graph	[
### 	node	[
### 		root_index	-57
### 		id	-57
### 		graphics	[
### 			x	124.55083084106445
### 			y	281.7039794921875
### 			w	39.99999237060547
### 			h	40.0
### 		]
### 		label	\"RAD18__YCR066W__S000000662\"
### 	]
### 	...
### 	edge	[
### 		root_index	-15048
### 		target	-55
### 		source	-49
### 		graphics	[
### 			width	1.5
### 			fill	\"#ffcc66\"
### 			type	\"line\"
### 			Line	[
### 			]
### 			source_arrow	0
### 			target_arrow	0
### 		]
### 		label	\"PPI\"
### 	]
###
###
### [2]
### a -infile_network_sif in format like:
### CSM2__YIL132C__S000001394  GI  MMS1__YPR164W__S000006368
### CSM2__YIL132C__S000001394  GI  MMS1__YPR164W__S000006368
### CSM2__YIL132C__S000001394  GI  RAD52__YML032C__S000004494
### CSM2__YIL132C__S000001394  GI  SGS1__YMR190C__S000004802
###
### Optionally this file may contain a 4th column with colors for Edges in RGB Hex format, like: #ffcc66; and/or a 5th column with widths for Edges 
###
### [3] (optional)
### a -infile_edge_types_order indicating the order edges will be printed in the *gml file by their type, like:
### PPI
### Coexpression
### Conservation
### ...etc
###
### This may be useful when loading a file for edges of a certain type to appear on top of other type edges
###
### ----------------------------------------MAIN OUTPUTS-------------------------------------------
###
### [1]
### a new *gml file
###
### ------------------------------------------COMMANDS---------------------------------------------
###
### $ThisProgramName [options]
###   -infile_template_gml        (path/name to network_1 in *.gml format to use as template)
###   -infile_network_sif         (path/name to network_2 in *.sif format to be mapped onto network_1)
###   -infile_edge_types_order    (path/name to a list of edge types in order to appear in the *gml file. Or type 'NA' to skip)
###   -sif_contains_edge_colours  (indicates if the -infile_network_sif contains colours for edges, type [y/Y] or [n/N])
###   -sif_contains_edge_widths   (indicates if the -infile_network_sif contains edge weights, otherwise '$defaultWidthEdge' will be used, type [y/Y] or [n/N])
###   -nodes_union_intersec       (specifies if the outfile should contain:
###                                the UNION of nodes in network_1 and network_2, type [u/U]
###                                the INTERSECTION of nodes in network_1 and network_2, type [i/I]
###                                all nodes from network_1, type [n1]
###                                all nodes from network_2, type [n2]
###   -edges_union_intersec       (specifies if the outfile should contain:
###                                the UNION of edges in network_1 and network_2, type [u/U]
###                                the INTERSECTION of edges in network_1 and network_2, type [i/I]
###                                all edges from network_1, type [n1]
###                                all edges from network_2, type [n2]
###                                note that in any case edges will be printed out only if they pass the -nodes_union_intersec criteria)
###   -directed                   (indicates if edges G1->G2::databaseA vs. G2->G1::databaseA should be considered either directed [y/Y] or not [n/N])
###                                If [n/N] is selected then only one 'representative' edge will be printed out, whereas if [y/Y] is selected the two edges/directions will be printed out)
###   -prefix_outfiles            (indicates a prefix for the name of the outfile, or type [default] to obtain the preffix from infile names and parameters.
###                                Note that [default] can produce too large names
###
##################### END INSTRUCTIONS TO RUN THIS PROGRAM ##########################
#####################################################################################";
$CommentsForHelp =~ s/(\n####)|(\n###)|(\n##)|(\n#)/\n/g;

&Readme;
&Parameters;

#######################################
### PATHS to default infiles and parameters

### Default node attributes
$defaultXpositionNode = -1;
$defaultYpositionNode = 1;
$defaultWidthNode     = "10.0";
$defaultHeightNode    = "10.0";
$defaultFillNode      = "#E5E5E5"; ## RGB Hex Triplet Color ## Red
$defaultTypeNode      = "ellipse";
$defaultOutlineNode   = "#E5E5E5"; ## RGB Hex Triplet Color ## Red
$defaultOutlineWNode  = 0.1;

### Default edge attributes
$defaultFillEdge      = "#FF0000"; ## RGB Hex Triplet Color
$defaultTypeEdge      = "line";
$defaultLabelEdge     = "NO_LABEL";   ### For unknown reasons sometimes Cytoscape doesn't save the 'label' property of edges

#######################################

#####################################################################################################################
############################################### Begin of program ####################################################

### Necessary to index GML first and SIF last to avoid overhashing issues
&LoadNetwork1TemplateGML;
&LoadNetwork2;
&LoadNodetypesOrder($hashParameters{infile_edge_types_order});

## preparing name for outfile
if ($hashParameters{nodes_union_intersec} =~ /u/i) {
$forOutfileFromNodes = "Union";
}elsif ($hashParameters{nodes_union_intersec} =~ /i/i) {
$forOutfileFromNodes = "Intrsct";
}elsif ($hashParameters{nodes_union_intersec} =~ /n1/i) {
$forOutfileFromNodes = "MappedNet1";
}elsif ($hashParameters{nodes_union_intersec} =~ /n2/i) {
$forOutfileFromNodes = "MappedNet2";
}

if ($hashParameters{edges_union_intersec} =~ /u/i) {
$forOutfileFromedges = "Union";
}elsif ($hashParameters{edges_union_intersec} =~ /i/i) {
$forOutfileFromedges = "Intrsct";
}elsif ($hashParameters{edges_union_intersec} =~ /n1/i) {
$forOutfileFromedges = "MappedNet1";
}elsif ($hashParameters{edges_union_intersec} =~ /n2/i) {
$forOutfileFromedges = "MappedNet2";
}

if ($hashParameters{directed} =~ /y/i) {
$forOutfileFromDirection = "Directed";
}else{
$forOutfileFromDirection = "Undirected";
}

$outfileGML        = "$outfileWOpath.gml";
$outfileParameters = "$outfileWOpath.Parameters";

open OUTFILE, ">$hashParameters{path_outfiles}/$outfileGML" or die "Can't open '$hashParameters{path_outfiles}/$outfileGML' (outfile.gml)\n";

######################################
############## NODES #################
######################################

##########
### Determining set of nodes to print out
if ($hashParameters{nodes_union_intersec} =~ /u/i) {
	foreach $key2 (sort keys %hashAllNodesInNetwork2) {
	$hashAllNodesToPrint{$key2} = 1;
	}
	foreach $label (sort keys %hashNodeLabelIndex) {
	$hashAllNodesToPrint{$label} = 1;
	}
}elsif ($hashParameters{nodes_union_intersec} =~ /i/i) {
	foreach $key2 (sort keys %hashAllNodesInNetwork2) {
		if ($hashNodeLabelIndex{$key2}) {
		$hashAllNodesToPrint{$key2} = 1;
		}
	}
}elsif ($hashParameters{nodes_union_intersec} =~ /n1/i) {
	foreach $label (sort keys %hashNodeLabelIndex) {
	$hashAllNodesToPrint{$label} = 1;
	}
}elsif ($hashParameters{nodes_union_intersec} =~ /n2/i) {
	foreach $key2 (sort keys %hashAllNodesInNetwork2) {
	$hashAllNodesToPrint{$key2} = 1;
	}
}

##########
### Printing out nodes
$NodesNotInGml = 0;
print OUTFILE "Creator\t\"Cytoscape\"\nVersion\t1.0\ngraph\t[\n";
$NotInIndex = 0;
foreach $key1 (sort keys %hashAllNodesToPrint) {
	if ($hashLabelData{$key1}) {
	## Nodes in template will inherit node attributes from template
	$data = $hashLabelData{$key1};
	}else{
	## Nodes not in template will be added with default node attributes
	$NotInIndex++;
	$NodesNotInGml++;
	$forId = ($NotInIndex + $maximumRootIndexInTemplate) * -1;
	$hashNodeLabelIndex{$key1} = $forId;
	$data = "\tnode\t[\n\t\troot_index\t$forId\n\t\tid\t$forId\n\t\tgraphics\t[\n\t\t\tx\t$defaultXpositionNode\n\t\t\ty\t$defaultYpositionNode\n\t\t\tw\t$defaultWidthNode\n\t\t\th\t$defaultHeightNode\n\t\t\tfill\t\"$defaultFillNode\"\n\t\t\ttype\t\"$defaultTypeNode\"\n\t\t\toutline\t\"$defaultOutlineNode\"\n\t\t\toutline_width\t$defaultOutlineWNode\n\t\t]\n\t\tlabel\t\"$key1\"\n\t]\n";
	}
print OUTFILE "$data";
}

######################################
############## EDGES #################
######################################

##########
### Determining set of trios (node1->node2::database)  to print out
if ($hashParameters{edges_union_intersec} =~ /u/i) {
	foreach $trio (sort keys %hashAllTriosALL) {
	$hashAllEdgesToPrint{$trio} = 1;
	}
}elsif ($hashParameters{edges_union_intersec} =~ /i/i) {
	foreach $trio (sort keys %hashAllTriosALL) {
	($key1,$key2,$db) = split ("\t", $trio);
	$trioInv = "$key2\t$key1\t$db";
		if (($hashAllTriosGML{$trio} or $hashAllTriosGML{$trioInv}) && ($hashAllTriosSIF{$trio} or $hashAllTriosSIF{$trioInv})) {
		## here allowing that trios are in any sense for intersection N1->N2::db or N2->N1::db
		## later will take care of directionality for print out
		$hashAllEdgesToPrint{$trio} = 1;
		}
	}
}elsif ($hashParameters{edges_union_intersec} =~ /n/i) {
	foreach $trio (sort keys %hashAllTriosSIF) {
	$hashAllEdgesToPrint{$trio} = 1;
	}
}

##########
### Determining order of trios to print out
if ($hashParameters{infile_edge_types_order} =~ /^NA$/i) {
$NumberOfTriosToPrintout = 0;
	foreach $trio (sort keys %hashAllEdgesToPrint) {
	$NumberOfTriosToPrintout++;
	$hashTriosToPrintoutNumberToData{$NumberOfTriosToPrintout} = $trio;
	}
}else{

	foreach $trio (sort keys %hashAllEdgesToPrint) {
	$NumberOfTriosToPrintout++;
	($key1,$key2,$db) = split ("\t", $trio);
	
		if ($hashTypesOfEdgesLabelToOrder{$db}) {
		$orderOfEdge = $hashTypesOfEdgesLabelToOrder{$db};
		}else{
		$orderOfEdge = 0;
		}
	$hashSetsOfEdgeTypesNumberToTrios{$orderOfEdge}{$trio} = 1;
	}
	
	$NumberOfTriosToPrintout = 0;
	foreach $et (0..$TypesOfEdgesOrder) {
		foreach $trio (sort keys %{$hashSetsOfEdgeTypesNumberToTrios{$et}}) {
		$NumberOfTriosToPrintout++;
		$hashTriosToPrintoutNumberToData{$NumberOfTriosToPrintout} = $trio;
		}
	}
}


##########
### Printing out edges

$EdgesNotInGml = 0;

foreach $numberOfTrioToPrintout (1..$NumberOfTriosToPrintout) {
$trio = $hashTriosToPrintoutNumberToData{$numberOfTrioToPrintout};
($key1,$key2,$db) = split ("\t", $trio);
$trioInv = "$key2\t$key1\t$db";
$EdgesWithProperties = "";
$data = "";

	### Note that only edges whose two nodes were printed out will be printed as well
	if ($hashAllNodesToPrint{$key1} && $hashAllNodesToPrint{$key2}) {
	
		### here take care of directionality
		if ($hashParameters{directed} =~ /^n$/i) {
		## here duplicated edges (g1->g2::dbA vs. g2->g1::dbA) are merged
		
			unless ($hashYaPrintedEdges{$trio} or $hashYaPrintedEdges{$trioInv}) {
			$hashYaPrintedEdges{$trio} = 1;
			$hashYaPrintedEdges{$trioInv} = 1;
	
				### GML pairs already have edge properties so if they are requested inherit properties from template
				if ($hashAllPairsGML{$trio}) {
				$data = $hashAllPairsGML{$trio};
				}elsif ($hashAllPairsGML{$trioInv}) {
				$data = $hashAllPairsGML{$trioInv};
				}else{
					
				### Get edge colour
					if ($hashNetwork2{$key1}{$key2}{$db}) {
					($c,$w) = split ("\t", $hashNetwork2{$key1}{$key2}{$db});
					$EdgeColour = "$c";
					$EdgeWidth  = "$w";
					}elsif ($hashNetwork2{$key2}{$key1}{$db}) {
					($c,$w) = split ("\t", $hashNetwork2{$key2}{$key1}{$db});
					$EdgeColour = "$c";
					$EdgeWidth  = "$w";
					}else{
					$EdgeColour = $defaultFillEdge;
					$EdgeWidth  = $defaultWidthEdge;
					}
				$EdgeColour =~ tr/[A-Z]/[a-z]/;

				### Construct new edges
				$NotInIndex++;
				$EdgesNotInGml++;
				$forId = ($NotInIndex + $maximumRootIndexInTemplate) * -1;
					if ($hashNodeLabelIndex{$key1} && $hashNodeLabelIndex{$key2}) {
					$root_index1 = $hashNodeLabelIndex{$key1};
					$root_index2 = $hashNodeLabelIndex{$key2};
					$data = "\tedge\t[\n\t\troot_index\t$forId\n\t\ttarget\t$root_index2\n\t\tsource\t$root_index1\n\t\tgraphics\t[\n\t\t\twidth\t$EdgeWidth\n\t\t\tfill\t\"$EdgeColour\"\n\t\t\ttype\t\"$defaultTypeEdge\"\n\t\t\tLine\t[\n\t\t\t]\n\t\t\tsource_arrow\t0\n\t\t\ttarget_arrow\t0\n\t\t]\n\t\tlabel\t\"$db\"\n\t]\n";
					}
				}

				if ($data =~ /\S/) {
				print OUTFILE "$data";
				}else{
				die "Can't get EDGE data for key1='$key1', key2='$key2', db= '$db'\n";
				}
			}
		}else{
			## here duplicated edges (g1->g2::dbA vs. g2->g1::dbA) are mantained separate
			if ($hashAllPairsGML{$trio}) {
			$data = $hashAllPairsGML{$trio};
			}else{

			### Get edge colour
				if ($hashNetwork2{$key1}{$key2}{$db}) {
				($c,$w) = split ("\t", $hashNetwork2{$key1}{$key2}{$db});
				$EdgeColour = "$c";
				$EdgeWidth  = "$w";
				}else{
				$EdgeColour = $defaultFillEdge;
				$EdgeWidth  = $defaultWidthEdge;
				}
			$EdgeColour =~ tr/[A-Z]/[a-z]/;

			### Construct new edges
			$NotInIndex++;
			$EdgesNotInGml++;
			$forId = ($NotInIndex + $maximumRootIndexInTemplate) * -1;
				if ($hashNodeLabelIndex{$key1} && $hashNodeLabelIndex{$key2}) {
				$root_index1 = $hashNodeLabelIndex{$key1};
				$root_index2 = $hashNodeLabelIndex{$key2};
				$data = "\tedge\t[\n\t\troot_index\t$forId\n\t\ttarget\t$root_index2\n\t\tsource\t$root_index1\n\t\tgraphics\t[\n\t\t\twidth\t$EdgeWidth\n\t\t\tfill\t\"$EdgeColour\"\n\t\t\ttype\t\"$defaultTypeEdge\"\n\t\t\tLine\t[\n\t\t\t]\n\t\t\tsource_arrow\t0\n\t\t\ttarget_arrow\t0\n\t\t]\n\t\tlabel\t\"$db\"\n\t]\n";
				}
			}
			
			if ($data =~ /\S/) {
			print OUTFILE "$data";
			}else{
			die "Can't get EDGE data for key1='$key1', key2='$key2', db= '$db'\n";
			}
		}
	}
}

print OUTFILE "]\n";
close OUTFILE;

&PrintParameters;

print "\nDone.......!!!\n\n  Check outfile:\n'$hashParameters{path_outfiles}/$outfileGML'\n\n
$NodesNotInGml NODES from '$outfileWOpath' not existing in -infile_template_gml will appear in $outfileGML
$EdgesNotInGml EDGES from '$outfileWOpath' not existing in -infile_template_gml will appear in $outfileGML\n\n";

### Check here that Union|Intersection|Net1 works out for both nodes and edges

############################################### End of program ######################################################
#####################################################################################################################



#######################################
########### SUBRUTINES ################

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Parameters {

########## Print "Usage" for user

print "$CommentsForHelp\n\n";

##########################
######## Options and Infiles

use Cwd 'abs_path';
$ScriptName = abs_path($0);
$Parameters .= "$ScriptName\n";

chomp @ARGV;
@arrayInputtedOneLineCommands = @ARGV;

%hashParametersTolookFor = (
'path_outfiles' => 1,
'infile_template_gml' => 1,
'infile_network_sif' => 1,
'infile_edge_types_order' => 1,
'sif_contains_edge_colours' => 1,
'sif_contains_edge_widths' => 1,
'nodes_union_intersec' => 1,
'edges_union_intersec' => 1,
'directed' => 1,
'prefix_outfiles' => 1,
);

#######################
#### Starts -- Evaluate parameters

&LoadParameters::Parameters::MainSubParameters(\%hashParametersTolookFor,\@arrayInputtedOneLineCommands);
$Parameters .= "$MoreParameters";

## Defining prefix string for OUTFILE
$outfileWOpath = $hashParameters{prefix_outfiles};

#### Ends -- Evaluate parameters
#######################

}

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub LoadNetwork1TemplateGML {

### Necessary to index GML first and SIF last to avoid overhashing issues

print "Loading network_1 *.gml to be used as template\n";
open (TEMPLATE, "<$hashParameters{infile_template_gml}") or die "Can't open hashParameters{infile_template_gml} '$hashParameters{infile_template_gml}'\n";
$maximumRootIndexInTemplate = 0;

$ReadingEdges = 0;
$maximum_root_index_to_replace = 10000000;

while ($line = <TEMPLATE>) {
chomp $line;

	if ($line =~ /^\tedge\t\[/) {
	$ReadingEdges = 1;
	}

	if ($line =~ /^(\t\t)(root_index)(\t)(\S+)/) {
	$root_index = $4;
		
		if ($hashRootindices{$root_index}) {
			if ($ReadingEdges == 1) {
			$root_index = abs($root_index) + $maximum_root_index_to_replace;
				if ($hashRootindices{$root_index}) {
				die "ERROR!!! root_index '$root_index' appears more than once in edges of *.gml\n";
				}else{
				$hashRootindices{$root_index} = 1;
				}
			}else{
			die "ERROR!!! root_index '$root_index' appears more than once in nodes of *.gml\n";
			}
		}else{
		$hashRootindices{$root_index} = 1;
		}

		if (abs($root_index) > $maximumRootIndexInTemplate) {
		$maximumRootIndexInTemplate = abs($root_index);
		}

	}

	if ($ReadingEdges == 1) {
		if ($line =~ /^\s+edge\t\[/) {
		$is_an_edge = 1;
		$EdgeData .= "$line\n";
		}elsif ($line =~ /^\t\]/) {
			if ($is_an_edge == 1) {
			$EdgeData .= "$line\n";
				if ($hashEdgeIndexData{$root_index}) {
				die "ERROR root_index EDGES '$root_index' appear more than once in *.gml file. Please check sub(LoadNetwork1Template)\n";
				}else{
					if ($target =~ /\S/ &&  $source =~ /\S/) {
						if ($hashNodeIndexLabel{$source} && $hashNodeIndexLabel{$target}) {
						$key1 = $hashNodeIndexLabel{$source};
						$key2 = $hashNodeIndexLabel{$target};
							unless ($label =~ /\S/) {
							$label = $defaultLabelEdge;
							}
						
							if ($key1 =~ /\S/ && $key2 =~ /\S/ && $label =~ /\S/) {
							$pair = "$key1\t$key2";
							$trio = "$key1\t$key2\t$label";
							$hashAllTriosGML{$trio} = "$EdgeData";
							$hashAllTriosALL{$trio} = 1;
							}else{
							die "Some key1='$key1' or key2='$key2' or db_label='$label' were not found\n";
							}
						}else{
						die "ERROR EDGE hashNodeIndexLabel{$source} or hashNodeIndexLabel{$target} were not found\n";
						}
					}else{
					die "ERROR EDGE target='$target' or source='$source' are empty\n";
					}
				$hashEdgeIndexData{$root_index} = $EdgeData;
				}
			}
		# restarting		
		$is_an_edge = 0;
		$EdgeData = "";
		$source = "";
		$target = "";
		$key1 = "";
		$key2 = "";
		$label = "";
		}elsif ($line =~ /^(\t\t)(root_index)(\t)(\S+)/) {
		$root_index = $4;
			if ($is_an_edge == 1) {
			$EdgeData .= "$line\n";
			}
		}elsif ($line =~ /^(\t\t)(label)(\t)(\")(\S.+)(\")/) {
		$label = $5;
			if ($is_an_edge == 1) {
			$EdgeData .= "$line\n";
			}
		}elsif ($line =~ /^(\t\t)(target)(\t)(\S+)/) {
		$target = $4;
			if ($is_an_edge == 1) {
			$EdgeData .= "$line\n";
			}
		}elsif ($line =~ /^(\t\t)(source)(\t)(\S+)/) {
		$source = $4;
			if ($is_an_edge == 1) {
			$EdgeData .= "$line\n";
			}
		}elsif ($is_an_edge == 1) {
		$EdgeData .= "$line\n";
		}
	}else{
	## Always will read nodes
		if ($line =~ /^\s+node\t\[/) {
		$is_a_node = 1;
		$NodeData .= "$line\n";
		}elsif ($line =~ /^\t\]/) {
			if ($is_a_node == 1) {
			$NodeData .= "$line\n";
				if ($hashNodeIndexData{$root_index} or $hashLabelData{$label}) {
				die "ERROR root_index NODES '$root_index' and/or label '$label' appear more than once in *.gml file. Please check sub(LoadNetwork1Template)\n";
				}else{
				$hashNodeIndexData{$root_index} = $NodeData;
				$hashLabelData{$label} = $NodeData;
				}
			}
		# restarting		
		$is_a_node = 0;
		$NodeData = "";
		}elsif ($line =~ /^(\t\t)(root_index)(\t)(\S+)/) {
		$root_index = $4;
			if ($is_a_node == 1) {
			$NodeData .= "$line\n";
			}
		}elsif ($line =~ /^(\t\t)(label)(\t)(\")(\S.+)(\")/) {
		$label = $5;
			if ($is_a_node == 1) {
			$NodeData .= "$line\n";
			$hashNodeLabelIndex{$label} = $root_index;
			$hashNodeIndexLabel{$root_index} = $label;
			}
		}elsif ($is_a_node == 1) {
		$NodeData .= "$line\n";
		}
	}
}
close TEMPLATE;
}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub LoadNetwork2 {

### Necessary to index GML first and SIF last to avoid take the already used 'root_index' numbers

print "Loading network_2 *.sif to be mapped onto network_1\n";
open (SIF, "<$hashParameters{infile_network_sif}") or die "Can't open -infile_network_sif $hashParameters{infile_network_sif}'\n";
while ($line = <SIF>) {
chomp $line;
@arr = split ("\t", $line);
$key1 = @arr[0];
$db = @arr[1];
$key2 = @arr[2];

	if ($hashParameters{sif_contains_edge_colours} =~ /^y$/i) {
	$colour = @arr[3];
	}else{
	$colour = $defaultFillEdge;
	}
	if ($hashParameters{sif_contains_edge_widths} =~ /^y$/i) {
	$width = @arr[4];
	}else{
	$width = $defaultWidthEdge;
	}

$pair = "$key1\t$key2";
$trio = "$key1\t$key2\t$db";
$hashNetwork2{$key1}{$key2}{$db} = "$colour\t$width";
$hashAllNodesInNetwork2{$key1} = 1;
$hashAllNodesInNetwork2{$key2} = 1;
$hashAllDbsInNetwork2{$db} = 1;
$hashAllTriosSIF{$trio} = 1;
$hashAllTriosALL{$trio} = 1;
}
close SIF;
}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub PrintParameters {

### Printing out parameters. Need to be concatenated at sub(Parameters)
open PARAMETERS, ">$hashParameters{path_outfiles}/$outfileParameters" or die "Can't open '$hashParameters{path_outfiles}/$outfileParameters'\n";
print PARAMETERS "$Parameters";
close PARAMETERS;
}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Readme {

my ($date) = `date`;
chomp $date;

$Parameters .= "
#################################################################
# Javier Diaz -- $date
# javier.diazmejia\@gmail.com
#################################################################\n
$Extras
#################################################################
######################### PARAMETERS ############################
#################################################################\n\n";

}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub LoadNodetypesOrder {

unless ($hashParameters{infile_edge_types_order} =~ /^NA$/i) {

	open (EDGETYPESORDER, "<$hashParameters{infile_edge_types_order}") or die "Can't open -infile_edge_types_order $hashParameters{infile_edge_types_order}'\n";
	$TypesOfEdgesOrder = 0;
	while ($line = <EDGETYPESORDER>) {
	chomp $line;
		unless ($line =~ /^#/) {
		$TypesOfEdgesOrder++;
		$hashTypesOfEdgesOrderToLabel{$TypesOfEdgesOrder} = $line;
		$hashTypesOfEdgesLabelToOrder{$line} = $TypesOfEdgesOrder;
		}
	}
	close EDGETYPESORDER;
}

}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

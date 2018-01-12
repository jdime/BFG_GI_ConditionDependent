#!/usr/bin/perl

##########################
### Elaborated: Javier Diaz - 09Jan2018
##########################

##########################
### Dependencies:
### 1) cytoscape.sh (http://www.cytoscape.org/download.php)
###                  Tested with versions 2.8.1 and 3.6.0
###                  Modify file ~/perl_modules/PathsDefinition/PathsToPrograms.pm
###                  to specify the path to cytoscape.sh file in 'cytoscape_executable' key
###                  OR in $CytoscapeSh variable below
###
### 2) convert      (http://www.imagemagick.org/script/convert.php)
###                  to trim white background of network images
###
### 3) R and R libraries (gplots and png)
###
##########################

use LoadParameters::Parameters;
use ReformatPerlEntities::ObtainOutfileWOpath;
use PathsDefinition::PathsToInputs;
use PathsDefinition::PathsToPrograms;
use Rcommands::Rcommands;

$ThisProgramName = $0;
$ThisProgramName =~ s/\S+\///;

$CommentsForHelp = "
#####################################################################################
################### START INSTRUCTIONS TO RUN THIS PROGRAM ##########################
###
### Will obtain complement sets of condition-dependent genetic interactions from
### an -infile_table_between with gene-pairs with condition-dependent genetic interactions for conditions-pairs and
### an -infile_table_within  with gene-pairs with genetic interactions for each condition
### to form sign changes like:
### neutral  (condition 1) to [positive|negative] (condition 2)
### positive (condition 1) to negative (condition 2)
### negative (condition 1) to positive (condition 2)
###
### To draw condition-dependent networks and histograms
###
### -------------------------------------------INPUTS----------------------------------------------
###
### [1]
### a -infile_table_between in format like:
### ID1    ID2    Condition1  Condition2  Class_Condition1  Class_Condition2  DeltaZ_FDR
### MMS1   MUS81  NoDrug      MMS         NEUTRAL           AGGRAVATING       0.00111
### RAD59  RAD61  NoDrug      MMS         NEUTRAL           AGGRAVATING       3.50e-06
### RAD52  SGS1   NoDrug      MMS         NEUTRAL           ALLEVIATING       3.97e-88
### CLA4   CSM2   NoDrug      4NQO        NEUTRAL           AGGRAVATING       2.79e-38
### Note: more columns can exist, but the last four are mandatory
###
### [2]
### a -infile_table_within in format like:
### ID1    ID2    FDR.Internal_ij.NoDrug  FDR.Internal_ij.MMS  FDR.Internal_ij.4NQO  Z_GIS_ij.NoDrug_Class  Z_GIS_ij.MMS_Class  Z_GIS_ij.4NQO_Class   
### MMS1   MUS81  3.238e-27               1.9310e-20           2.92310e-5            NEUTRAL                AGGRAVATING         AGGRAVATING
### RAD59  RAD61  0.224664                0.6263857            4.6286337             NEUTRAL                AGGRAVATING         AGGRAVATING
### RAD52  SGS1   8.465e-22               5.0232e-22           5.0232e-12            NEUTRAL                ALLEVIATING         ALLEVIATING
### CLA4   CSM2   0.799920                0.9493681            1.9368149             NEUTRAL                AGGRAVATING         AGGRAVATING
### Note: more columns can exist, but Z_GIS_ij.*_Class and FDR.Internal_ij.* are mandatory
###
### [3]
### a -infile_gene_alias in format like:
### Abbreviated  Full_ID
### RTT101       RTT101__YJL047C__S000003583
### SRS2         SRS2__YJL092W__S000003628
### RAD52        RAD52__YML032C__S000004494
### SGS1         SGS1__YMR190C__S000004802
### Notes: this is useful in case -infile_table_* have Abbreviated_ID's and -infile_gml has Full_ID's
###        the Abbreviated_ID also can be used with '-represent_nodes abbreviated_id' (see below)
###
### [4]
### a -infile_order_conditions in format like:
### #Condition   Plot(Y/N)
### NoDrug  N
### DMSO    Y
### MMS     Y
### 4NQO    Y
### BLMC    Y
### ZEOC    Y
### HYDX    Y
### DXRB    Y
### CMPT    Y
### CSPL    Y
### Notes: outfile *BarplotsAndNetworks.diagonal_*.pdf will have conditions in the order of this file
###        column 2 indicates if the condition should be plotted (Y) or not (N)
###
### [5]
### a -infile_edge_types_order in format like:
### negative---neutral
### neutral---negative
### positive---negative
### negative---positive
### positive---neutral
### neutral---positive
### positive
### negative
###
### Notes: will indicate the order in which edges will be drawn in the network (in Cytoscape)
###        Still work in progress
###
### [6]
### a -infile_gml to use as template for node positions for Cytoscape in *gml format like:
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
### ----------------------------------------MAIN OUTPUTS-------------------------------------------
###
### [1]
### *BarplotsAndNetworks.diagonal_*.pdf
### Plotted networks and barplots merged into a single file
### 
### [2]
### *BarplotsAndNetworks.legend.pdf
### Colour legent for outfile [1]
###   
### [3]
### *Complement.Parameters
### Parameters used for the run and date/time
### 
### [4]
### *BarplotsAndNetworks.insFor.R
### Script used for R to generate barplots and merge them with the networks
###   
### [5]
### *full.tab
### Table of condition-dependent counts (used to make the barplots)
###  
### [6]
### NETWORKS/InstructionsForCytoscape.ins
### Commands for cytoscape.sh to draw the nerworks
###
### ------------------------------------------COMMANDS---------------------------------------------
###
### $ThisProgramName [options]
###   -path_outfiles             (path/name to the directory where outfiles will be saved)
###   -infile_table_between      (path/name to the table with condition-dependent genetic interactions)
###   -infile_table_within       (path/name to the table with genetic interactions for each condition)
###   -infile_order_conditions   (path/name to a list of column headers from -infile_table_between that will be used for the *BarplotsAndNetworks.pdf outfile. Or type 'NA' to sort alphanumerically)
###   -infile_gml                (path/name to the *gml file with node positions to be used as template for gene-gene level complement networks)
###   -infile_edge_types_order   (path/name to a list of edge types in order to appear in the *gml file. Or type 'NA' to skip)
###   -infile_gene_alias         (path/name to a paired tab of gene ID's to map from -infile_table_between to -infile_gml)
###
###   -width_network_edges       (indicates the width for edges in the outfiles for networks, e.g. '1.0' or '2.0', or type 'NA' to skip)
###   -diagonal_up_or_down       (indicates if the networks in the diagonal (each condition network) should be drawn from
###                               the bottom-left to the top-right corners [type 'up'] or from the top-left to the bottom-right corners [type 'down'])
###   -represent_nodes           (indicates if nodes in the networks should be represented by:
###                               'abbreviated_id' to show the Abbreviated_ID from -infile_gene_alias
###                               'node_as_a_dot'  to show the node as a dot
###                               'both'           to show both Abbreviated_ID and node as a dot
###                               'none'           to show none
###
###   -cutoff_fdr_between        (cutoff to consider FDR scores in -infile_table_between as significant for outfiles)
###   -cutoff_fdr_within         (cutoff to consider FDR scores in -infile_table_within as significant for outfiles)
###
###   -prefix_for_outfile        (a string to be used for outfiles name)
###
##################### END INSTRUCTIONS TO RUN THIS PROGRAM ##########################
#####################################################################################";
$CommentsForHelp =~ s/(\n####)|(\n###)|(\n##)|(\n#)/\n/g;

&Readme;
&Parameters;

$CytoscapeSh = $PathsToPrograms_Files{cytoscape_executable};

if (-f $CytoscapeSh) {
print "Will use '$CytoscapeSh'\n";
}else{
die "\n\nERROR!!! couldn't find '$CytoscapeSh'\n";
}


###########################
### Default parameters ####
###########################

$FactorSizeForBarPlot    = 2;
$FactorSizeOveralHeaders = 0.2; ## Considering plot size is '1' this fraction tells what the size of the space for row/column headers should be

$ColourNameforBarPlotsAxes   = "gray70";
$ColourNameforNetworkNodes   = "gray70";

%hashColourNumberToNameForComplements = (
'1' => 'goldenrod1',
'2' => 'pink',
'3' => 'tan',
'4' => 'darkolivegreen3',
'5' => 'red3',
'6' => 'blue4',
);

%hashColourNumberToNameForEachcolumn = (
'1' => 'skyblue2',
'2' => 'chocolate1',
);

%hashColourNamesToHex = (
'goldenrod1'	  => '#FFC125',
'pink'		  => '#FFC0CB',
'tan'	          => '#D2B48C',
'darkolivegreen3' => '#A2CD5A',
'red3'		  => '#CD0000',
'blue4' 	  => '#00008B',
'skyblue2'	  => '#7EC0EE',
'chocolate1'	  => '#FF7F24',
);

@PairsOfSignsToPlot = ("neutral---positive", "positive---neutral", "neutral---negative", "negative---neutral", "negative---positive", "positive---negative");
@SingleSignsToPlot  = ("positive", "negative");

$countPairsOfSigns = 0;
foreach $i (@PairsOfSignsToPlot) {
$countPairsOfSigns++;
$j = $i;
$j =~ s/---/.vs./;
$LabelsForLegend .= ",\"$j\"";
	if ($hashColourNumberToNameForComplements{$countPairsOfSigns}) {
	$ColorsHexadecimal .= ",\"$hashColourNamesToHex{$hashColourNumberToNameForComplements{$countPairsOfSigns}}\"";
	}else{
	die "\nERROR!!! couldn't find hashColourNamesToHex{hashColourNumberToNameForComplements{$countPairsOfSigns}}\n\n";
	}
}
$LabelsForLegend =~ s/^,//;
$ColorsHexadecimal =~ s/^,//;

$countSingleSigns = 0;
foreach $i (@SingleSignsToPlot) {
$countSingleSigns++;
$j = $i;
$j =~ s/---/.vs./;
$LabelsForLegend .= ",\"$j\"";
	if ($hashColourNumberToNameForEachcolumn{$countSingleSigns}) {
	$ColorsHexadecimal .= ",\"$hashColourNamesToHex{$hashColourNumberToNameForEachcolumn{$countSingleSigns}}\"";
	}else{
	die "\nERROR!!! couldn't find hashColourNamesToHex{hashColourNumberToNameForEachcolumn{$countSingleSigns}}\n\n";
	}
}
$LabelsForLegend =~ s/^,//;
$ColorsHexadecimal =~ s/^,//;


%hashMandatoryColumnHeadersFromInfileBetween = (
'Condition1'       => 1,
'Condition2'       => 1,
'Class_Condition1' => 1,
'Class_Condition2' => 1,
'DeltaZ_FDR'       => 1,
);

%hashMandatoryColumnHeaderBaseFromInfileWithin = (
'Z_GIS_ij.*_Class'  => 1,
'FDR.Internal_ij.*' => 1,
);


###########################
######## Load data ########
###########################


## Condition IDs and order for plots

$NumberOfConditionsToPlot = 0;
open ORDERPOOLS, "<$hashParameters{infile_order_conditions}" or die "Cant't open -infile_order_conditions '$hashParameters{infile_order_conditions}'\n";
while ($line = <ORDERPOOLS>) {
chomp $line;
	unless ($line =~ /^#/) {
	($Condition,$ToPlot) = split ("\t", $line);
		if ($ToPlot =~ /^Y$/i) {
		$NumberOfConditionsToPlot++;
		$hashOrderNumberOfConditionToName{$NumberOfConditionsToPlot} = $Condition; ### This hash will be used for the order of plots
		$hashAllExpectedConditionNames{$Condition} = $ToPlot; ### This hash will be used to look for condition  headers in -infile_table_within and -infile_table_within data, and indicates if condition should be plotted
		}
	}
}
close ORDERPOOLS;

&GetMatrixFieldsForPlot($NumberOfConditionsToPlot);

### Index gene aliases
open INFILEGENEALIAS, "<$hashParameters{infile_gene_alias}" or die "Cant't open -infile_gene_alias '$hashParameters{infile_gene_alias}'\n";
	while ($line = <INFILEGENEALIAS>) {
	chomp $line;
	@arr = split ("\t", $line);
	$hashNodeAliasShortToLong{@arr[0]} = @arr[1];
	}
close INFILEGENEALIAS;


### Get commands for node representation
### Working only for -represent_nodes node_as_a_dot and -represent_nodes none

$CommandsToSetNodes = "";

if ($hashParameters{represent_nodes} =~ /^none$/i) {
$CommandsToSetNodes = "
node set properties propertyList=\"Label\" valueList=\".\"
node set properties propertyList=\"Label Transparency\" valueList=0";

}elsif ($hashParameters{represent_nodes} =~ /^node_as_a_dot$/i) {
$CommandsToSetNodes = "
node set properties propertyList=\"Label\" valueList=\".\"
node set properties propertyList=\"Label Transparency\" valueList=255";
}else{
die "Working only for -represent_nodes node_as_a_dot and -represent_nodes none\n\n";
}




### Index INFILE_BETWEEN

open INFILE_BETWEEN, "<$hashParameters{infile_table_between}" or die "Cant't open -infile_table_between '$hashParameters{infile_table_between}'\n";

$van = 0;
while ($line = <INFILE_BETWEEN>) {
$line =~ s/(\r\n|\r|\n)$/\n/g; ### to transform Windows or Mac line breaks into Linux
chomp $line;
$van++;
@arr = split ("\t", $line);
	
	if ($van == 1) {
	print OUTFILE "Barcode_i---Barcode_j";
		if ($line =~ /^(\S+)(\t)(\S+)(\t)(\S.+)/) {
		@ColumnHeaders = split ("\t", $5);
		}else{
		die "\n\nERROR!!! unexpected format in '$line'\n\n";
		}

		$c = -1;
		foreach $columnheader (@ColumnHeaders) {
		$c++;
			
			if ($hashMandatoryColumnHeadersFromInfileBetween{$columnheader}) {
			$hashDataBetweenColumnNumberMinusOne{$columnheader} = "_$c";
			}
		}

		foreach $columnheader (sort keys %hashMandatoryColumnHeadersFromInfileBetween) {
			unless ($hashDataBetweenColumnNumberMinusOne{$columnheader}) {
			die "\n\nERROR!!! missing column header '$columnheader'\n\n";
			}
		}

	}else{
		if ($line =~ /^(\S+)(\t)(\S+)(\t)(\S.+)/) {
		$id1 =      "$1";
		$id2 =      "$3";
		@Data = split ("\t", $5);
		
		
			#############
			### Skips same ID pairs
			unless ($id1 eq $id2) {
		
				#############
				### This indexes scores in -infile_table_between for each pair of genes, for each pair of conditions
				### Restrict to pairs whose genes are contained in -infile_gene_alias

				if ($hashNodeAliasShortToLong{$id1} && $hashNodeAliasShortToLong{$id2}) {
				$key1 = $hashNodeAliasShortToLong{$id1};
				$key2 = $hashNodeAliasShortToLong{$id2};
				
				$columnNumberCondition1 = $hashDataBetweenColumnNumberMinusOne{Condition1};
				$columnNumberCondition2 = $hashDataBetweenColumnNumberMinusOne{Condition2};
				$columnNumberSign1      = $hashDataBetweenColumnNumberMinusOne{Class_Condition1};
				$columnNumberSign2      = $hashDataBetweenColumnNumberMinusOne{Class_Condition2};
				$columnNumberDeltaZ_FDR = $hashDataBetweenColumnNumberMinusOne{DeltaZ_FDR};
				$columnNumberCondition1 =~ s/^_//;
				$columnNumberCondition2 =~ s/^_//;
				$columnNumberSign1      =~ s/^_//;
				$columnNumberSign2      =~ s/^_//;
				$columnNumberDeltaZ_FDR =~ s/^_//;
				
				$Condition1  = @Data[$columnNumberCondition1];
				$Condition2  = @Data[$columnNumberCondition2];
				$Sign1       = @Data[$columnNumberSign1];
				$Sign2       = @Data[$columnNumberSign2];
				$DeltaZ_FDR  = @Data[$columnNumberDeltaZ_FDR];
		
				$Sign1 =~ s/AGGRAVATING/negative/;
				$Sign1 =~ s/ALLEVIATING/positive/;
				$Sign2 =~ s/AGGRAVATING/negative/;
				$Sign2 =~ s/ALLEVIATING/positive/;
				$Sign1 =~ tr/[A-Z]/[a-z]/;
				$Sign2 =~ tr/[A-Z]/[a-z]/;
				
				### Here just avoiding pairs to be counted more than once
				### e.g. if the input has conditions-pairs and/or gene-pairs in reciprocal order
					
					if ($hashAlreadyIndexed{$id1}{$id2}{$Condition1}{$Condition2} or $hashAlreadyIndexed{$id1}{$id2}{$Condition2}{$Condition1} or $hashAlreadyIndexed{$id2}{$id1}{$Condition1}{$Condition2} or $hashAlreadyIndexed{$id2}{$id1}{$Condition2}{$Condition1}) {
					die "\n\nERROR!!! pair of genes '$id1\t$id2' with pair of conditions '$Condition1\t$Condition2' appears more than once in -infile_table_between, look also for reciprocal pairs\n\n";
					}else{
					$hashAlreadyIndexed{$id1}{$id2}{$Condition1}{$Condition2} = 1;
					}
		
				### Here restricting input to only conditions in -infile_order_conditions
					if ($hashAllExpectedConditionNames{$Condition1} && $hashAllExpectedConditionNames{$Condition2}) {
					
					### Here filtering by DeltaZ_FDR
						if ($DeltaZ_FDR < $hashParameters{cutoff_fdr_between}) {
						### Pairs as provided by -infile_table_between
						$hashBetweenPairs{$Sign1}{$Sign2}{$Condition1}{$Condition2}{counts} += 1;
						$hashBetweenPairs{$Sign1}{$Sign2}{$Condition1}{$Condition2}{concatenateddata} .= "$key1\t$key2\n";
					
						### Pairs in reciprocal order provided by -infile_table_between
						$hashBetweenPairs{$Sign2}{$Sign1}{$Condition2}{$Condition1}{counts} += 1;
						$hashBetweenPairs{$Sign2}{$Sign1}{$Condition2}{$Condition1}{concatenateddata} .= "$key1\t$key2\n";
						
						}
					}
				}
			}
		}
	}
}
close INFILE_BETWEEN;

### Index INFILE_WITHIN

open INFILE_WITHIN, "<$hashParameters{infile_table_within}" or die "Cant't open -infile_table_within '$hashParameters{infile_table_within}'\n";

$van = 0;
while ($line = <INFILE_WITHIN>) {
$line =~ s/(\r\n|\r|\n)$/\n/g; ### to transform Windows or Mac line breaks into Linux
chomp $line;
$van++;
@arr = split ("\t", $line);
	
	if ($van == 1) {
		if ($line =~ /^(\S+\t\S+)(\t)(\S.+)/) {
		@ColumnHeaders = split ("\t", $3);
		}
		
		$c = -1;
		foreach $columnheader (@ColumnHeaders) {
		$c++;
		
			foreach $Condition (keys %hashAllExpectedConditionNames) {
				foreach $columnheadertosearch (keys %hashMandatoryColumnHeaderBaseFromInfileWithin) {
				$columnheadertosearch =~ s/\*/$Condition/;
					if ($columnheader eq $columnheadertosearch) {
					$hashDataWithinColumnNumberMinusOne{$columnheadertosearch} = "_$c";
					$hashAllConditionHeadersInWithin{$Condition} = 1;
					}
				}
			}
		}
			
	}elsif ($line =~ /^(\S+\t\S+)(\t)(\S.+)/) {
	($id1,$id2) = split ("\t", $1);
	@Data = split ("\t", $3);

		#############
		### Skips same ID pairs
		unless ($id1 eq $id2) {
	
			#############
			### This indexes scores in -infile_table_within for each pair of genes, for each condition
			### Restrict to pairs whose genes are contained in -infile_gene_alias
		
			if ($hashNodeAliasShortToLong{$id1} && $hashNodeAliasShortToLong{$id2}) {
			$key1 = $hashNodeAliasShortToLong{$id1};
			$key2 = $hashNodeAliasShortToLong{$id2};
				foreach $Condition (keys %hashAllConditionHeadersInWithin) {
					if ($hashAllExpectedConditionNames{$Condition}) {
					$searchFDRheader    = "FDR.Internal_ij.$Condition";
					$searchZclassheader = "Z_GIS_ij.$Condition" . "_Class";
					$columnNumberFDRminusOne    = $hashDataWithinColumnNumberMinusOne{$searchFDRheader};
					$columnNumberZclassminusOne = $hashDataWithinColumnNumberMinusOne{$searchZclassheader};
					$columnNumberFDRminusOne    =~ s/^_//;
					$columnNumberZclassminusOne =~ s/^_//;
			
					$FDR  = @Data[$columnNumberFDRminusOne];
					$Sign = @Data[$columnNumberZclassminusOne];
					$Sign =~ s/AGGRAVATING/negative/;
					$Sign =~ s/ALLEVIATING/positive/;
					$Sign =~ tr/[A-Z]/[a-z]/;
	
					### Here filtering by FDR
						if ($FDR < $hashParameters{cutoff_fdr_within}) {
						### Pairs as provided by -infile_table_between
						$hashWithinPairs{$Sign}{$Condition}{counts} += 1;
						$hashWithinPairs{$Sign}{$Condition}{concatenateddata} .= "$key1\t$key2\n";
						}
					}
				}
			}
		}
	}
}
close INFILE_WITHIN;

#####################################
#### Print table with complements BETWEEN conditions for barplots
#####################################

open TABLECOMPLEMENTSFULL, ">$hashParameters{path_outfiles}/$outfileWOpath.complements.full.tab" or die "Cant't open '$hashParameters{path_outfiles}/$outfileWOpath.complements.full.tab'\n";

print TABLECOMPLEMENTSFULL "ID1---ID2";

foreach $SignPair (@PairsOfSignsToPlot) {
$SignPairToPrint = $SignPair;
$SignPairToPrint =~ s/---/\.vs\./; ## necessary for R
print TABLECOMPLEMENTSFULL "\t$SignPairToPrint";
}
print TABLECOMPLEMENTSFULL "\n";

$maxYValueAll = 0;
foreach $Condition1 (sort keys %hashAllExpectedConditionNames) {
	foreach $Condition2 (sort keys %hashAllExpectedConditionNames) {
		if ($hashAllExpectedConditionNames{$Condition1} =~ /^Y$/i && $hashAllExpectedConditionNames{$Condition2} =~ /^Y$/i) {
		print TABLECOMPLEMENTSFULL "$Condition1.vs.$Condition2";
	
			foreach $SignPair (@PairsOfSignsToPlot) {
			($Sign1,$Sign2) = split ("---", $SignPair);

				### Get complements regardless of -infile_restrict_pairs_per_condition
				if ($hashBetweenPairs{$Sign1}{$Sign2}{$Condition1}{$Condition2}{counts}) {
				$valueAll = $hashBetweenPairs{$Sign1}{$Sign2}{$Condition1}{$Condition2}{counts};
					if ($valueAll > $maxYValueAll) {
					$maxYValueAll = $valueAll;
					}
				}else{
				$valueAll = 0;
				}

			print TABLECOMPLEMENTSFULL "\t$valueAll";
			}
		print TABLECOMPLEMENTSFULL "\n";
		}
	}
}
close TABLECOMPLEMENTSFULL;

#####################################
#### Commands to get edge width for networks
#####################################

if ($hashParameters{width_network_edges} =~ /^na$/i) {
$opt_width_network_edges = "-sif_contains_edge_widths N";
$width_network_edges = "";
}else{
$opt_width_network_edges = "-sif_contains_edge_widths Y";
$width_network_edges = "\t$hashParameters{width_network_edges}";
}

$OutDirNetworks = "$hashParameters{path_outfiles}/NETWORKS";

`mkdir -p $OutDirNetworks`;

$CommandsForCytoscape = "";

#####################################
#### Commands to generate 'BETWEEN' networks
#####################################

$countNetworks = 0;
foreach $Condition1 (sort keys %hashAllExpectedConditionNames) {
	foreach $Condition2 (sort keys %hashAllExpectedConditionNames) {
		if ($hashAllExpectedConditionNames{$Condition1} =~ /^Y$/i && $hashAllExpectedConditionNames{$Condition2} =~ /^Y$/i) {
			unless ($Condition1 eq $Condition2) {

			$OutFileSif = "$OutDirNetworks/$Condition1.vs.$Condition2.sif";
			open $OutFileSif, ">$OutFileSif"  or die "Cant't open '$OutFileSif'\n";
		
				$van = 0;
				foreach $SignPair (@PairsOfSignsToPlot) {
				$van++;
				($Sign1,$Sign2) = split ("---", $SignPair);
		
				$value = 0;
				
					if ($hashBetweenPairs{$Sign1}{$Sign2}{$Condition1}{$Condition2}{counts}) {
					$value           = $hashBetweenPairs{$Sign1}{$Sign2}{$Condition1}{$Condition2}{counts};
					@UnderlyingPairs = split ("\n", $hashBetweenPairs{$Sign1}{$Sign2}{$Condition1}{$Condition2}{concatenateddata});
					}
		
					if ($value > 0) {
						foreach $underlyingPair (@UnderlyingPairs) {
						($node1,$node2) = split ("\t", $underlyingPair);
						print $OutFileSif "$node1\t$SignPair\t$node2\t$hashColourNamesToHex{$hashColourNumberToNameForComplements{$van}}" . "$width_network_edges" . "\n";
						}
					}
				}
			close $OutFileSif;
			
				unless ($hashParameters{infile_gml} =~ /^NA$/i) {
				system "merge_network_SIF_to_GML_template.pl $opt_width_network_edges -infile_edge_types_order $hashParameters{infile_edge_types_order} -sif_contains_edge_colours Y -directed n -edges_union_intersec n2 -infile_network_sif $OutFileSif -infile_template_gml $hashParameters{infile_gml} -nodes_union_intersec u -path_outfiles $OutDirNetworks -prefix_outfiles $Condition1.vs.$Condition2";
				$OutFileGml = "$OutDirNetworks/$Condition1.vs.$Condition2.gml";
		
				### Note these commands are for Cytoscape with -S capabilities (command line tool)
				### Copy infile *gml to the root directory with simple names because Cytoscape's command line tool can't handle spaces, low dashes, etc
		
				$countNetworks++;
				$Conditions    = "$Condition1.vs.$Condition2";
				$ConditionsInv = "$Condition2.vs.$Condition1";
				$hashNetworkNumberToNames{$countNetworks} = $Conditions;
				$hashNetworkNamesToNumber{$Conditions} = $countNetworks;
				
				$infileTempRoot = "/$Users_home/$DefaultUserName/tempnet$countNetworks";
				system "cp $OutFileGml $infileTempRoot.gml";
				
					if ($CytoscapeSh =~ /Cytoscape_v2/) {
					$CommandsForCytoscape .= "
					network import file=$infileTempRoot.gml
					network view fit
					network view export type=png file=$infileTempRoot.png
					network destroy name=$infileTempRoot\n";
					
					}elsif ($CytoscapeSh =~ /Cytoscape_v3/) {
					
					$CommandsForCytoscape .= "
					network load file file=\"$infileTempRoot.gml\"
					view fit content
					$CommandsToSetNodes
					view export options=PNG OutputFile=\"$infileTempRoot.png\"
					view destroy\n";
				
					}else{
					die "\n\nERROR!!! couldn't determine the Cytoscape version to use. Only versions 2.X.Y and 3.X.Y are allowed\n";
					}
				}
			}
		}
	}
}

#####################################
#### Commands to generate 'WITHIN' networks
#####################################

foreach $Condition (sort keys %hashAllExpectedConditionNames) {
	if ($hashAllExpectedConditionNames{$Condition} =~ /^Y$/i) {

	$OutFileSif = "$OutDirNetworks/$Condition.sif";
	open $OutFileSif, ">$OutFileSif"  or die "Cant't open '$OutFileSif'\n";
	
		$van = 0;
		foreach $Sign (@SingleSignsToPlot) {
		$van++;
			if ($hashWithinPairs{$Sign}{$Condition}{concatenateddata}) {
			@pairMyCodes = split ("\n", $hashWithinPairs{$Sign}{$Condition}{concatenateddata});
				foreach $pairMyCodes (@pairMyCodes) {
				($node1,$node2) = split ("\t", $pairMyCodes);
				print $OutFileSif "$node1\t$Sign\t$node2\t$hashColourNamesToHex{$hashColourNumberToNameForEachcolumn{$van}}" . "$width_network_edges" . "\n";
				}
			}
		}
	close $OutFileSif;
	
		unless ($hashParameters{infile_gml} =~ /^NA$/i) {
		system "merge_network_SIF_to_GML_template.pl $opt_width_network_edges -infile_edge_types_order $hashParameters{infile_edge_types_order} -sif_contains_edge_colours Y -directed n -edges_union_intersec n2 -infile_network_sif $OutFileSif -infile_template_gml $hashParameters{infile_gml} -nodes_union_intersec u -path_outfiles $OutDirNetworks -prefix_outfiles $Condition";
		$OutFileGml = "$OutDirNetworks/$Condition.gml";
	
		### Note these commands are for Cytoscape with -S capabilities (command line tool)
		### Copy infile *gml to the root directory with simple names because Cytoscape's command line tool can't handle spaces, low dashes, etc
	
		$countNetworks++;
		$hashNetworkNumberToNames{$countNetworks} = $Condition;
		$hashNetworkNamesToNumber{$Condition}  = $countNetworks;
		
		$infileTempRoot = "/$Users_home/$DefaultUserName/tempnet$countNetworks";
		system "cp $OutFileGml $infileTempRoot.gml";
			
			if ($CytoscapeSh =~ /Cytoscape_v2/) {
			$CommandsForCytoscape .= "
			network import file=$infileTempRoot.gml
			network view fit
			network view export type=png file=$infileTempRoot.png
			network destroy name=$infileTempRoot\n";
	
			$CommandQuitCytoscape = "quit\n";
			
			}elsif ($CytoscapeSh =~ /Cytoscape_v3/) {
			$CommandsForCytoscape .= "
			network load file file=\"$infileTempRoot.gml\"
			view fit content
			$CommandsToSetNodes
			view export options=PNG OutputFile=\"$infileTempRoot.png\"
			view destroy\n";
	
			$CommandQuitCytoscape = "command quit\n";
	
			}else{
			die "\n\nERROR!!! couldn't determine the Cytoscape version to use. Only versions 2.X.Y and 3.X.Y are allowed\n";
			}
		}
	}
}


unless ($hashParameters{infile_gml} =~ /^NA$/i) {
$OutFileInsForCytoscape = "$OutDirNetworks/InstructionsForCytoscape.ins";
open  INSTRUCTIONSFORCYTOSCAPE, ">$OutFileInsForCytoscape"  or die "Cant't open '$OutFileInsForCytoscape'\n";
print INSTRUCTIONSFORCYTOSCAPE "$CommandsForCytoscape\n$CommandQuitCytoscape\n";
close INSTRUCTIONSFORCYTOSCAPE;
system "$PathsToPrograms_Files{cytoscape_executable} -S $OutDirNetworks/InstructionsForCytoscape.ins";

	### Trim white background from network images
	foreach $c (1..$countNetworks) {
	system "convert /$Users_home/$DefaultUserName/tempnet$c.png -trim /$Users_home/$DefaultUserName/tempnet$c.trimmed.png";
	system "mv /$Users_home/$DefaultUserName/tempnet$c.trimmed.png /$Users_home/$DefaultUserName/tempnet$c.png";
	}
}

#####################################
#### Print and run instructions for R to generate barplots
#####################################

open BARPLOTSANDNETWORKSINSFORR, ">$hashParameters{path_outfiles}/$outfileWOpath.BarplotsAndNetworks.insFor.R"  or die "Can't open '$hashParameters{path_outfiles}/$outfileWOpath.BarplotsAndNetworks.insFor.R'\n";

print BARPLOTSANDNETWORKSINSFORR "
library(gplots)
mat<-read.table(\"$hashParameters{path_outfiles}/$outfileWOpath.complements.full.tab\",header=T,row.names=1)
PlotsFigureWidth<-($NumberOfConditionsToPlot*$FactorSizeForBarPlot)+($FactorSizeForBarPlot*$FactorSizeOveralHeaders)
PlotsFigureLenght<-($NumberOfConditionsToPlot*$FactorSizeForBarPlot)+($FactorSizeForBarPlot*$FactorSizeOveralHeaders)
pdf(\"~/$outfileWOpath.BarplotsAndNetworks.diagonal_$hashParameters{diagonal_up_or_down}.pdf\",PlotsFigureWidth,PlotsFigureLenght)
par($LayoutForPlot,
xpd=F)
\n";

unless ($hashParameters{infile_gml} =~ /^NA$/i) {
print BARPLOTSANDNETWORKSINSFORR "library(png)\n";
}

$NumberOfPoolPairsPlotted = 0;

#### Printout barplots and networks

if ($hashParameters{diagonal_up_or_down} =~ /^down$/i) {

	foreach  $p (1..$NumberOfConditionsToPlot) {
	$Condition1 = $hashOrderNumberOfConditionToName{$p};
	$NumberOfColumn = 0;
		foreach  $q (1..$NumberOfConditionsToPlot) {
		$Condition2 = $hashOrderNumberOfConditionToName{$q};
		$NumberOfPoolPairsPlotted++;
		$NumberOfColumn++;
		
		$Conditions    = "$Condition1" . ".vs." . "$Condition2";
		$ConditionsInv = "$Condition2" . ".vs." . "$Condition1";
	
			if ($Condition1 eq $Condition2) {
			## Actually will be empty
			## We could program here to import condition-specific netwotks
			$PlotType = "SAME_POOL";
			}elsif ($hashPoolPairsOccurring{$ConditionsInv}) {
				if ($NumberOfColumn == 1) {
				$PlotType = "BARPLOT_FIRST_IN_COLUMN";
				}elsif ($NumberOfColumn == $NumberOfConditionsToPlot) {
				$PlotType = "BARPLOT_LAST_IN_COLUMN";
				}else{
				$PlotType = "BARPLOT";
				}
	
			}else{
				if ($hashParameters{infile_gml} =~ /^NA$/i) {
					if ($NumberOfColumn == 1) {
					$PlotType = "BARPLOT_FIRST_IN_COLUMN";
					}elsif ($NumberOfColumn == $NumberOfConditionsToPlot) {
					$PlotType = "BARPLOT_LAST_IN_COLUMN";
					}else{
					$PlotType = "BARPLOT";
					}
				}else{
				$PlotType = "COMPLEMENT_NETWORK";
				}
			$hashPoolPairsOccurring{$Conditions} = 1;
			}
	
			if ($PlotType =~ /SAME_POOL/) {
			$NumberOfPoolPlotted = $hashNetworkNamesToNumber{$Condition1};
			print BARPLOTSANDNETWORKSINSFORR "par(mar = c(0.6, 2, 0.5, 0))
			network<-readPNG(\"/$Users_home/$DefaultUserName/tempnet$NumberOfPoolPlotted.png\")
			plot($Rcommands{empty_plot})
			rasterImage(network,0,0,1,1)\n";
			
			}elsif ($PlotType =~ /^BARPLOT_FIRST_IN_COLUMN$/) {
			print BARPLOTSANDNETWORKSINSFORR "par(mar = c(0.6, 2, 0.5, 0))
			vec<-unname(unlist(mat\[\"$ConditionsInv\",\]))
			barplot(vec,col=c($ColorsHexadecimal),border=NA,ylim=c(0,$maxYValueAll+1),xaxt=\"n\",yaxt=\"n\",bty=\"l\",xlab=\"\",ylab=\"\",)
			axis(side=2,at=c(0,$maxYValueAll),col=\"$ColourNameforBarPlotsAxes\",lwd=2,las=2,cex.axis=1.5)
			axis(side=1,col=\"$ColourNameforBarPlotsAxes\",lwd=2,tick=T,labels=F,lwd.ticks=-1)\n";
	
			}elsif ($PlotType =~ /^BARPLOT$/) {
			print BARPLOTSANDNETWORKSINSFORR "par(mar = c(0.6, 2, 0.5, 0))
			vec<-unname(unlist(mat\[\"$ConditionsInv\",\]))
			barplot(vec,col=c($ColorsHexadecimal),border=NA,ylim=c(0,$maxYValueAll+1),xaxt=\"n\",yaxt=\"n\",bty=\"l\",xlab=\"\",ylab=\"\",)
			axis(side=1,col=\"$ColourNameforBarPlotsAxes\",lwd=2,tick=T,labels=F,lwd.ticks=-1)\n";
			
			}elsif ($PlotType =~ /COMPLEMENT_NETWORK/) {
			$NumberOfPoolPairsPlottedInv = $hashNetworkNamesToNumber{$Conditions};
			print BARPLOTSANDNETWORKSINSFORR "par(mar = c(0.6, 2, 0.5, 0))
			network<-readPNG(\"/$Users_home/$DefaultUserName/tempnet$NumberOfPoolPairsPlottedInv.png\")
			plot($Rcommands{empty_plot})
			rasterImage(network,0,0,1,1)\n";
			
			}else{
			die "\nERROR!!! unexpected option for PlotType '$PlotType'\n\n";
			}
		}
	}
}else{
	foreach  $p (1..$NumberOfConditionsToPlot) {
	$Condition1 = $hashOrderNumberOfConditionToName{$p};
	$NumberOfColumn = 0;
		foreach  $q (reverse 1..$NumberOfConditionsToPlot) {
		$Condition2 = $hashOrderNumberOfConditionToName{$q};
		$NumberOfPoolPairsPlotted++;
		$NumberOfColumn++;
		
		$Conditions    = "$Condition1" . ".vs." . "$Condition2";
		$ConditionsInv = "$Condition2" . ".vs." . "$Condition1";
	
			if ($Condition1 eq $Condition2) {
			## Actually will be empty
			## We could program here to import condition-specific netwotks
			$PlotType = "SAME_POOL";
			}elsif ($hashPoolPairsOccurring{$ConditionsInv}) {
				if ($NumberOfColumn == 1) {
				$PlotType = "BARPLOT_FIRST_IN_COLUMN";
				}elsif ($NumberOfColumn == $NumberOfConditionsToPlot) {
				$PlotType = "BARPLOT_LAST_IN_COLUMN";
				}else{
				$PlotType = "BARPLOT";
				}
	
			}else{
				if ($hashParameters{infile_gml} =~ /^NA$/i) {
					if ($NumberOfColumn == 1) {
					$PlotType = "BARPLOT_FIRST_IN_COLUMN";
					}elsif ($NumberOfColumn == $NumberOfConditionsToPlot) {
					$PlotType = "BARPLOT_LAST_IN_COLUMN";
					}else{
					$PlotType = "BARPLOT";
					}
				}else{
				$PlotType = "COMPLEMENT_NETWORK";
				}
			$hashPoolPairsOccurring{$Conditions} = 1;
			}
			
			if ($PlotType =~ /SAME_POOL/) {
			$NumberOfPoolPlotted = $hashNetworkNamesToNumber{$Condition1};
			print BARPLOTSANDNETWORKSINSFORR "par(mar = c(0.6, 2, 0.5, 0))
			network<-readPNG(\"/$Users_home/$DefaultUserName/tempnet$NumberOfPoolPlotted.png\")
			plot($Rcommands{empty_plot})
			rasterImage(network,0,0,1,1)\n";
			
			}elsif ($PlotType =~ /^BARPLOT_LAST_IN_COLUMN$/) {
			print BARPLOTSANDNETWORKSINSFORR "par(mar = c(0.6, 0, 0.5, 2.5))
			vec<-unname(unlist(mat\[\"$ConditionsInv\",\]))
			barplot(vec,col=c($ColorsHexadecimal),border=NA,ylim=c(0,$maxYValueAll+1),xaxt=\"n\",yaxt=\"n\",bty=\"l\",xlab=\"\",ylab=\"\",)
			axis(side=4,at=c(0,$maxYValueAll),col=\"$ColourNameforBarPlotsAxes\",lwd=2,las=2,cex.axis=1.5)
			axis(side=1,col=\"$ColourNameforBarPlotsAxes\",lwd=2,tick=T,labels=F,lwd.ticks=-1)\n";
	
			}elsif ($PlotType =~ /^BARPLOT$/) {
			print BARPLOTSANDNETWORKSINSFORR "par(mar = c(0.6, 2, 0.5, 0))
			vec<-unname(unlist(mat\[\"$ConditionsInv\",\]))
			barplot(vec,col=c($ColorsHexadecimal),border=NA,ylim=c(0,$maxYValueAll+1),xaxt=\"n\",yaxt=\"n\",bty=\"l\",xlab=\"\",ylab=\"\",)
			axis(side=1,col=\"$ColourNameforBarPlotsAxes\",lwd=2,tick=T,labels=F,lwd.ticks=-1)\n";
			
			}elsif ($PlotType =~ /COMPLEMENT_NETWORK/) {
			$NumberOfPoolPairsPlottedInv = $hashNetworkNamesToNumber{$Conditions};
			print BARPLOTSANDNETWORKSINSFORR "par(mar = c(0.6, 2, 0.5, 0))
			network<-readPNG(\"/$Users_home/$DefaultUserName/tempnet$NumberOfPoolPairsPlottedInv.png\")
			plot($Rcommands{empty_plot})
			rasterImage(network,0,0,1,1)\n";
			
			}else{
			die "\nERROR!!! unexpected option for PlotType '$PlotType'\n\n";
			}
		}
	}
}

#### Printout column and row headers

if ($hashParameters{diagonal_up_or_down} =~ /^down$/i) {
	foreach  $c (1..$NumberOfConditionsToPlot) {
	$Condition1 = $hashOrderNumberOfConditionToName{$c};
	print BARPLOTSANDNETWORKSINSFORR "par(mar = c(0.1, 0.1, 0.1, 0.1))
	plot($Rcommands{empty_plot})
	text(x=0.5,y=0.5,\"$Condition1\",cex=3,col=\"grey20\")\n";
	}
}elsif ($hashParameters{diagonal_up_or_down} =~ /^up$/i) {
	foreach  $c (reverse 1..$NumberOfConditionsToPlot) {
	$Condition1 = $hashOrderNumberOfConditionToName{$c};
	print BARPLOTSANDNETWORKSINSFORR "par(mar = c(0.1, 0.1, 0.1, 0.1))
	plot($Rcommands{empty_plot})
	text(x=0.5,y=0.5,\"$Condition1\",cex=3,col=\"grey20\")\n";
	}
}

foreach  $r (1..$NumberOfConditionsToPlot) {
$Condition1 = $hashOrderNumberOfConditionToName{$r};
print BARPLOTSANDNETWORKSINSFORR "par(mar = c(0.1, 0.1, 0.1, 0.1),las=3)
plot($Rcommands{empty_plot})
text(x=0.5,y=0.5,\"$Condition1\",cex=3,col=\"grey20\",srt=90)\n";
}


### Printout legend

print BARPLOTSANDNETWORKSINSFORR "
dev.off()
pdf(\"~/$outfileWOpath.BarplotsAndNetworks.legend.pdf\")
plot($Rcommands{empty_plot})
legend(\"topleft\",legend=c($LabelsForLegend),ncol=1,border=F,bty=\"n\",col=c($ColorsHexadecimal),pch=15,pt.cex=2,cex=2)
dev.off()\n";

close BARPLOTSANDNETWORKSINSFORR;

system "R --no-save < $hashParameters{path_outfiles}/$outfileWOpath.BarplotsAndNetworks.insFor.R";

#####################################
#### Move files to their final destination
#####################################

system "mv ~/$outfileWOpath.BarplotsAndNetworks.diagonal_$hashParameters{diagonal_up_or_down}.pdf $hashParameters{path_outfiles}";
system "mv ~/$outfileWOpath.BarplotsAndNetworks.legend.pdf $hashParameters{path_outfiles}";

unless ($hashParameters{infile_gml} =~ /^NA$/i) {
	foreach $c (1..$countNetworks) {
	system "mv /$Users_home/$DefaultUserName/tempnet$c.png $OutDirNetworks/$hashNetworkNumberToNames{$c}.png";
	system "mv /$Users_home/$DefaultUserName/tempnet$c.gml $OutDirNetworks/$hashNetworkNumberToNames{$c}.gml";
	}
}

&PrintParameters;

print "\n\n  Done!!!\n  Check '$hashParameters{path_outfiles}/$outfileWOpath.*' for outfiles\n\n";

exit;

########################################################
################ END OF PROGRAM ########################
########################################################


########################################################
################ START SUBROUTINES #####################
########################################################


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
'infile_table_between' => 1,
'infile_table_within' => 1,
'infile_order_conditions' => 1,
'infile_gene_alias' => 1,
'infile_gml'    => 1,
'infile_edge_types_order' => 1,
'width_network_edges' => 1,
'string_separating_pairs' => 1,
'diagonal_up_or_down' => 1,
'cutoff_fdr_between' => 1,
'cutoff_fdr_within' => 1,
'prefix_for_outfile' => 1,
'represent_nodes' => 1,
);

#######################
#### Starts -- Evaluate parameters

&LoadParameters::Parameters::MainSubParameters(\%hashParametersTolookFor,\@arrayInputtedOneLineCommands);
$Parameters .= "$MoreParameters";

## Defining prefix string for OUTFILE
$outfileWOpath = $hashParameters{prefix_for_outfile};

#### Ends -- Evaluate parameters
#######################

}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub PrintParameters {

### Printing out parameters. Need to be concatenated at sub(Parameters)
open PARAMETERS, ">$hashParameters{path_outfiles}/$outfileWOpath.Complement.Parameters" or die "Can't open '$hashParameters{path_outfiles}/$outfileWOpath.Complement.Parameters'\n";
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
sub GetMatrixFieldsForPlot {

my ($NumberOfConditionsToPlot) = @_;

print "Gettin matrix for plots for '$NumberOfConditionsToPlot' vs. '$NumberOfConditionsToPlot'  pools\n\n";

$NumberOfRows    = $NumberOfConditionsToPlot + 1;
$NumberOfColumns = $NumberOfConditionsToPlot + 1;

$NumberOfConditionsToPlotIndexed = 0;
foreach $row (1..$NumberOfRows) {
	if ($row == 1) {
		foreach $col (1..$NumberOfColumns) {
			if ($col == 1) {
			$MatrixOrder = 0;
			}else{ 
			$i = ($NumberOfConditionsToPlot*$NumberOfConditionsToPlot) + $col - 1;
			$MatrixOrder .= ",$i";
			}
		}
	}else{
		foreach $col (1..$NumberOfColumns) {
			if ($col == 1) {
			$j = ($NumberOfConditionsToPlot*$NumberOfConditionsToPlot) + $NumberOfConditionsToPlot + $row - 1;
			$MatrixOrder .= ",$j";
			}else{
			$NumberOfConditionsToPlotIndexed++;
			$MatrixOrder .= ",$NumberOfConditionsToPlotIndexed";
			}
		}
	}
}

### Note in widths and heights we are declarin only the size for the first row and column (overall headers), the remaining will be '1' by default
$LayoutForPlot = "layout(matrix(c($MatrixOrder), $NumberOfRows, $NumberOfColumns, byrow=T,), widths=($FactorSizeOveralHeaders), heights=($FactorSizeOveralHeaders), respect=TRUE)";

}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

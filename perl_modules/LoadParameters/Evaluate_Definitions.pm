### This module evaluates that one-command-line parameters provided by the User
### meet the expected format (numeric, integer, strings, <comma> separated options, etc)

### If you are a R or Python programmer these two modules LoadParameters::Evaluate_Definitions and LoadParameters::Parameters
### are my equivalents to using 'argparse'

package LoadParameters::Evaluate_Definitions;
require Exporter;
require AutoLoader;

@ISA = qw( Exporter AutoLoader );
@EXPORT = qw(
Evaluate_parameter_values_series_of_digits
Evaluate_numb_cols
Evaluate_numb_rows
Evaluate_cutoffs_negative
Evaluate_cutoffs_positive
Evaluate_restrict_classes
Evaluate_value
Evaluate_file_exist
Evaluate_inflation
Evaluate_type_of_tips
Evaluate_horizontal_offset
%hashColumnKeyToColumnNumber
%hash_parameter_values_to_include
%hash_numb_cols
%hash_numb_rows
%hash_outfile_options
%hash_step_numbers_to_run
%hash_numb_rounds
%hash_rank_classes_to_include
%hash_cutoffs_numeric
%hash_cutoffs_negative
%hash_cutoffs_positive
%hash_cutoffs_negative_or_positive
%hashInflations
%hash_distance_measures
%hash_clustering_methods
$TypeOfTipForRobot_Label
$Horizontal_Offset
);

######################################################
### If you ADD MORE subroutines to this module you'll need to pass input via LoadParameters::Parameters.pm
### Also make sure to add their main output (for external code) to @EXPORT
######################################################

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Evaluate_parameter_values_series_of_digits {
my($parameterKey,$parameterValues) = @_;

	if ($parameterKey =~ /plate_numbers_to_include/) {
	$optionForOutputToScreens = "plate_numbers_to_include";
	}

	if ($parameterValues =~ /(\d+)/) {
	chomp $parameterValues;
		
	@ParameterValues = split (",", $parameterValues);
		foreach $pn (@ParameterValues) {
			if ($pn =~ /^\d+$/) {
			$hash_parameter_values_to_include{$pn} = 1;
			}elsif ($pn =~ /^(\d+)(-)(\d+)$/) {
			$start = $1;
			$end = $3;
				foreach $c ($start..$end) {
				$hash_parameter_values_to_include{$c} = 1;
				}
			}else{
			die "ERROR!!! Reading parameter '$parameterKey' couldn't determine $optionForOutputToScreens to process from '$pn'\n";
			}
		}

	print "The following $optionForOutputToScreens will be processed:\n";

		foreach $c (sort { $a <=> $b } keys %hash_parameter_values_to_include) {
		print "$c\n";
		}

	}elsif ($parameterValues =~ /^(ALL)$/i) {
	print "All $optionForOutputToScreens will be processed\n";
	}else{
	die "ERROR!!! Reading parameter '$parameterKey' couldn't determine $optionForOutputToScreens to process from '$parameterValues'\n";
	}
}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Evaluate_numb_cols {
my($parameterKey,$numb_cols) = @_;

	if ($parameterKey =~ /cols|column/) {
	$optionForOutputToScreens = "columns";
	}else{
	$optionForOutputToScreens = "options";
	}

	if ($numb_cols =~ /(\d+)/) {
	chomp $numb_cols;
		
	### here indexing by $parameterKey in case multiple calls of 'column_*' are made
		if ($parameterKey =~ /^column_/) {
		$hashColumnKeyToColumnNumber{$parameterKey} = $numb_cols;
		}

	@Cols = split (",", $numb_cols);
		foreach $cc (@Cols) {
			if ($cc =~ /^\d+$/) {
			$hash_numb_cols{$cc} = 1;
			}elsif ($cc =~ /^(\d+)(-)(\d+)$/) {
			$start = $1;
			$end = $3;
				foreach $c ($start..$end) {
				$hash_numb_cols{$c} = 1;
				}
			}else{
			die "ERROR!!! Reading parameter '$parameterKey'  couldn't determine $optionForOutputToScreens to process from '$cc'\n";
			}
		}

	print "The following $optionForOutputToScreens will be processed:\n";

		foreach $c (sort { $a <=> $b } keys %hash_numb_cols) {
		print "$c\n";
		}

	}elsif ($numb_cols =~ /^(ALL)$/i) {
	print "All $optionForOutputToScreens will be processed\n";
	}elsif ($numb_cols =~ /^(NA)$/i) {
	}else{
	die "ERROR!!! Reading parameter '$parameterKey' couldn't determine $optionForOutputToScreens to process from '$numb_cols'\n";
	}
}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Evaluate_numb_rows {
my($parameterKey,$numb_rows) = @_;

	if ($parameterKey =~ /row/) {
	$optionForOutputToScreens = "rows";
	}else{
	$optionForOutputToScreens = "options";
	}

	if ($numb_rows =~ /(\d+)/) {
	chomp $numb_rows;
	@rows = split (",", $numb_rows);
		foreach $cc (@rows) {
			if ($cc =~ /^\d+$/) {
			$hash_numb_rows{$cc} = 1;
			}elsif ($cc =~ /^(\d+)(-)(\d+)$/) {
			$start = $1;
			$end = $3;
				foreach $c ($start..$end) {
				$hash_numb_rows{$c} = 1;
				}
			}else{
			die "ERROR!!! Reading parameter '$parameterKey'  couldn't determine $optionForOutputToScreens to process from '$cc'\n";
			}
		}

	print "The following $optionForOutputToScreens will be processed:\n";

		foreach $c (sort { $a <=> $b } keys %hash_numb_rows) {
		print "$c\n";
		}

	}elsif ($numb_rows =~ /^(ALL)$/i) {
	print "All $optionForOutputToScreens will be processed\n";
	}elsif ($numb_rows =~ /^(NA)$/i) {
	print "You selected not to use option '$parameterKey'\n";
	}else{
	die "ERROR!!! Reading parameter '$parameterKey' couldn't determine $optionForOutputToScreens to process from '$numb_rows'\n";
	}
}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Evaluate_outfile_options {
my($parameterKey,$filtered_outfiles) = @_;

	if ($parameterKey =~ /outfile/) {
	$optionForOutputToScreens = "outfile_options";
	}else{
	$optionForOutputToScreens = "options";
	}

	if ($filtered_outfiles =~ /(\d+)/) {
	chomp $filtered_outfiles;
	@Filtered_outfiles = split (",", $filtered_outfiles);
		foreach $cc (@Filtered_outfiles) {
			if ($cc =~ /^\d+$/) {
			$hash_outfile_options{$cc} = 1;
			}elsif ($cc =~ /^(\d+)(-)(\d+)$/) {
			$start = $1;
			$end = $3;
				foreach $c ($start..$end) {
				$hash_outfile_options{$c} = 1;
				}
			}else{
			die "ERROR!!! Reading parameter '$parameterKey'  couldn't determine $optionForOutputToScreens to process from '$cc'\n";
			}
		}

	print "The following $optionForOutputToScreens will be processed:\n";

		foreach $c (sort { $a <=> $b } keys %hash_outfile_options) {
		print "$c\n";
		}

	}elsif ($filtered_outfiles =~ /^(ALL)$/i) {
	print "All $optionForOutputToScreens will be processed\n";
	}elsif ($filtered_outfiles =~ /^(NA)$/i) {
	print "You selected not to use option '$parameterKey'\n";
	}else{
	die "ERROR!!! Reading parameter '$parameterKey' couldn't determine $optionForOutputToScreens to process from '$filtered_outfiles'\n";
	}
}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Evaluate_step_numbers_to_run {
my($parameterKey,$steps_numb) = @_;

	if ($steps_numb =~ /(\d+)/) {
	chomp $steps_numb;
	@steps = split (",", $steps_numb);
		foreach $cc (@steps) {
			if ($cc =~ /^\d+$/) {
			$hash_step_numbers_to_run{$cc} = 1;
			}elsif ($cc =~ /^(\d+)(-)(\d+)$/) {
			$start = $1;
			$end = $3;
				foreach $c ($start..$end) {
				$hash_step_numbers_to_run{$c} = 1;
				}
			}else{
			die "ERROR!!! Reading parameter '$parameterKey'  couldn't determine $optionForOutputToScreens to process from '$cc'\n";
			}
		}

	print "The following step_numbers will be processed:\n";

		foreach $c (sort { $a <=> $b } keys %hash_step_numbers_to_run) {
		print "$c\n";
		}

	}else{
	die "ERROR!!! Reading parameter '$parameterKey' couldn't determine $optionForOutputToScreens to process from '$numb_rows'\n";
	}
}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Evaluate_rank_classes_to_include {
my($parameterKey,$rank_classes_to_include) = @_;

	if ($rank_classes_to_include =~ /(\d+)/) {
	chomp $rank_classes_to_include;
	@rows = split (",", $rank_classes_to_include);
		foreach $cc (@rows) {
			if ($cc =~ /^\d+$/) {
			$hash_rank_classes_to_include{$cc} = 1;
			}elsif ($cc =~ /^(\d+)(-)(\d+)$/) {
			$start = $1;
			$end = $3;
				foreach $c ($start..$end) {
				$hash_rank_classes_to_include{$c} = 1;
				}
			}else{
			die "ERROR!!! Reading parameter '$parameterKey'  couldn't determine rank_classes_to_include to process from '$cc'\n";
			}
		}

	print "The following rank_classes_to_include will be processed:\n";

		foreach $c (sort { $a <=> $b } keys %hash_rank_classes_to_include) {
		print "$c\n";
		}

	}elsif ($rank_classes_to_include =~ /^(ALL)$/i) {
	print "All rank_classes_to_include will be processed\n";
	}else{
	die "ERROR!!! Reading parameter '$parameterKey' couldn't determine rank_classes_to_include to process from '$rank_classes_to_include'\n";
	}
}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Evaluate_inflation {
my($parameterKey,$inflation) = @_;

	if ($inflation =~ /(\d+)/) {
	chomp $inflation;
	@Inflations = split (",", $inflation);
		foreach $cc (@Inflations) {
			if ($cc =~ /^(\d+\.\d+|\d+)$/) {
			$hashInflations{$1} = 1;
			}else{
			die "ERROR!!! Reading parameter '$parameterKey' couldn't determine inflation to process from '$cc'\n";
			}
		}

	}elsif ($inflation =~ /^(default)$/i) {
	%hashInflations = (
	'1.5' => 1,
	'1.6' => 1,
	'1.7' => 1,
	'1.8' => 1,
	'1.9' => 1,
	'2' => 1,
	'2.1' => 1,
	'2.2' => 1,
	'2.3' => 1,
	'2.4' => 1,
	'2.5' => 1,
	'3' => 1,
	'3.5' => 1,
	'4' => 1,
	'4.5' => 1,
	'5' => 1,
	);

	}else{
	die "ERROR!!! Reading parameter '$parameterKey' couldn't determine inflations to process from '$inflation'\n";
	}

print "The following inflations will be processed:\n";
	foreach $c (sort { $a <=> $b } keys %hashInflations) {
	print "$c\n";
	}
}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Evaluate_type_of_tips {
my($parameterKey,$type_of_tip_in_robot) = @_;

%hashTypeOfTips = (
'1' => "Fisher50_GreenBx", ## handles up to 50 microliters in Biotek Precision robot
'2' => "Fisher200BlueBx",  ## handles up to 200 microliters in Biotek Precision robot
);

	if ($type_of_tip_in_robot =~ /(^\d+$)/) {
	chomp $type_of_tip_in_robot;
		if ($hashTypeOfTips{$type_of_tip_in_robot}) {
		$TypeOfTipForRobot_Label = $hashTypeOfTips{$type_of_tip_in_robot};
		}else{
		die "ERROR!!! Reading parameter '$parameterKey' couldn't type of tip from '$type_of_tip_in_robot'\n";
		}

	}else{
	die "ERROR!!! Reading parameter '$parameterKey' couldn't determine type of tip from '$type_of_tip_in_robot'\n";
	}
}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Evaluate_horizontal_offset {
my($parameterKey,$horizontal_offset) = @_;

%hashHorizontalOffset = (
'1' => "DP0481040.center",
'2' => "DP0481040.off5",
'3' => "DP0481040.off10", ## -10 is used by Joe Mellor for PCR plates, but with liquid culture 96-well plates the 200 uL tips may hit the well walls
);

	if ($horizontal_offset =~ /(^\d+$)/) {
	chomp $horizontal_offset;
		if ($hashHorizontalOffset{$horizontal_offset}) {
		$Horizontal_Offset = $hashHorizontalOffset{$horizontal_offset};
		}else{
		die "ERROR!!! Reading parameter '$parameterKey' couldn't determine the horizontal offset from '$horizontal_offset'\n";
		}

	}else{
	die "ERROR!!! Reading parameter '$parameterKey' couldn't determine the horizontal offset from '$horizontal_offset'\n";
	}
}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Evaluate_numb_rounds {
my($parameterKey,$numb_rounds) = @_;
	if ($numb_rounds =~ /(\d+)/) {
	chomp $numb_rounds;
	@rounds = split (",", $numb_rounds);
		foreach $rr (@rounds) {
			if ($rr =~ /^\d+$/) {
			$hash_numb_rounds{$rr} = 1;
			}elsif ($rr =~ /^(\d+)(-)(\d+)$/) {
			$start = $1;
			$end = $3;
				foreach $r ($start..$end) {
				$hash_numb_rounds{$r} = 1;
				}
			}else{
			die "ERROR!!! Reading parameter '$parameterKey'  couldn't determine round to process from '$rr'\n";
			}
		}
		
		print "The following rounds will be processed:\n";
		foreach $r (sort { $a <=> $b } keys %hash_numb_rounds) {
		print "$r\n";
		}
	}else{
	die "ERROR!!! Reading parameter '$parameterKey' couldn't determine rounds to process from '$numb_rounds'\n";
	}
}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Evaluate_cutoffs_numeric {
my($parameterKey,$cutoffs_numeric) = @_;
	if ($cutoffs_numeric =~ /(\d)/) {
	chomp $cutoffs_numeric;
	@Cutoffs_numeric = split (",", $cutoffs_numeric);
		foreach $cc (@Cutoffs_numeric) {
			if ($cc =~ /(^-*\d+$)|(^-*\d+\.\d+$)|(^-*\d+\.\d+e-*\d+$)|(^-*\d+e-*\d+$)/i) {
			$hash_cutoffs_numeric{$cc} = 1;
			}else{
			die "ERROR!!! Reading parameter '$parameterKey' couldn't determine negative cutoff from '$cc'\n";
			}
		}
	}elsif ($cutoffs_numeric =~ /(^na$)|(^none$)/i) {
	print "WARNING!!! no cutoff for '$parameterKey' was provided\n";
	}else{
	die "ERROR!!! Reading parameter '$parameterKey' couldn't determine values to be processed from '$cutoffs_numeric'\n";
	}

print "The following values of $parameterKey will be processed:\n";
	foreach $c (sort { $a <=> $b } keys %hash_cutoffs_numeric) {
	print "$c\n"; 
	}
}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Evaluate_cutoffs_negative_or_positive {
my($parameterKey,$cutoffs_negative_or_positive) = @_;
	if ($cutoffs_negative_or_positive =~ /(\d)/) {
	chomp $cutoffs_negative_or_positive;
	@Cutoffs_negative_or_positive = split (",", $cutoffs_negative_or_positive);
		foreach $cc (@Cutoffs_negative_or_positive) {
		$cc =~ s/^\\//;
			if ($cc =~ /(^-*\d+$)|(^-*\d+\.\d+$)/) {
			$hash_cutoffs_negative_or_positive{$cc} = 1;
			}else{
			die "ERROR!!! Reading parameter '$parameterKey' couldn't determine negative cutoff from '$cc'\n";
			}
		}
	}elsif ($cutoffs_negative_or_positive =~ /^(ALL)$/i) {
	print "All $cutoffs_negative_or_positive will be processed\n";
	}elsif ($cutoffs_negative_or_positive =~ /(^na$)|(^none$)/i) {
	print "WARNING!!! no values for '$parameterKey' were provided\n";
	}else{
	die "ERROR!!! Reading parameter '$parameterKey' couldn't determine values to be processed from '$cutoffs_negative_or_positive'\n";
	}

print "The following values of $parameterKey will be processed:\n";
	foreach $c (sort { $a <=> $b } keys %hash_cutoffs_negative_or_positive) {
	print "$c\n";
	}
}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Evaluate_cutoffs_positive {
my($parameterKey,$cutoffs_positive) = @_;
	if ($cutoffs_positive =~ /(\d)/) {
	chomp $cutoffs_positive;
	@Cutoffs_positive = split (",", $cutoffs_positive);
		foreach $cc (@Cutoffs_positive) {
			if ($cc =~ /(^\d+$)|(^\d+\.\d+$)/) {
			$hash_cutoffs_positive{$cc} = 1;
			}else{
			die "ERROR!!! Couldn't determine positive cutoff from '$cc'\n";
			}
		}
	}else{
	die "ERROR!!! Reading parameter '$parameterKey' couldn't determine values to be processed from '$cutoffs_positive'\n";
	}
	
print "The following values of $parameterKey will be processed:\n";
	foreach $c (sort { $a <=> $b } keys %hash_cutoffs_positive) {
	print "$c\n";
	}
}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Evaluate_restrict_classes {
my($parameterKey,$file_or_all) = @_;
	if ($file_or_all =~ /^all$/i) {
	}elsif (-f $file_or_all) {
	}else{
	die "ERROR!!! Reading parameter '$parameterKey' couldn't find file '$file_or_all' to restrict classes and no 'ALL' command was readed\n";
	}
}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Evaluate_generate_fuzzy_ea {
my($parameterKey,$file_or_no) = @_;
	if ($file_or_no =~ /^n$/i) {
	}elsif (-f $file_or_no) {
	}else{
	die "ERROR!!! Reading parameter '$parameterKey' couldn't find file '$file_or_no' with edge attributes (*.ea file)\n";
	}
}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Evaluate_distance_measure {
my($parameterKey,$distance_measure,$suffix) = @_;

	if ($distance_measure =~ /^(ALL)$/i) {
		foreach $i (0..8) {
		$hash_distance_measures{$i} = 1;
		}

	}elsif ($distance_measure =~ /(\d+)/) {
	chomp $distance_measure;
	@Distances = split (",", $distance_measure);
		foreach $cc (@Distances) {
			if ($cc =~ /(^\d+$)|(^0\.0$)/) {
				if ($suffix =~ /\S/) {
				$hash_distance_measures{$suffix}{$cc} = 1;
				}else{
				$hash_distance_measures{$cc} = 1;
				}
			}elsif ($cc =~ /^(\d+)(-)(\d+)$/) {
			$start = $1;
			$end = $3;
				foreach $c ($start..$end) {
					if ($suffix =~ /\S/) {
					$hash_distance_measures{$suffix}{$c} = 1;
					}else{
					$hash_distance_measures{$c} = 1;
					}
				}
			}else{
			die "ERROR!!! Reading parameter '$parameterKey'  couldn't determine distance_measures to process from '$cc'\n";
			}
		}
	}else{
	die "ERROR!!! Reading parameter '$parameterKey' couldn't determine distance_measure to process from '$distance_measure'\n";
	}

	print "The following distance_measures will be processed:\n";
	if ($suffix =~ /\S/) {
		foreach $c (sort keys %{$hash_distance_measures{$suffix}}) {
		print "$suffix\t$c\n";
		}
	}else{
		foreach $c (sort keys %hash_distance_measures) {
		print "$c\n";
		}
	}
}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Evaluate_clustering_method {
my($parameterKey,$clustering_method) = @_;

	if ($clustering_method =~ /^(ALL)$/i) {
	@all_clustering_methods = ("m", "s", "c", "a");
		foreach $i (@all_clustering_methods) {
		$hash_clustering_methods{$i} = 1;
		}
	}elsif ($clustering_method =~ /[a-z]/i) {
	chomp $clustering_method;
	$clustering_method =~ tr/[A-Z]/[a-z]/;
	@ClusteringMethods = split (",", $clustering_method);
		foreach $cc (@ClusteringMethods) {
		$hash_clustering_methods{$cc} = 1;
		}
	}else{
	die "ERROR!!! Reading parameter '$parameterKey' couldn't determine clustering_method to process from '$clustering_method'\n";
	}

	print "The following clustering_methods will be processed:\n";
	foreach $c (sort keys %hash_clustering_methods) {
	print "$c\n";
	}

}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


######################################################
### This subroutine is for parameters whose format needs to be checked for specifit formats
######################################################

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Evaluate_value {
my($parameterKey,$value) = @_;

	### Negative values or NA or DEFAULT

	if ($parameterKey =~ /(^negative_number$)|(^cutoff_neg$)|(^cutoff_aggrv$)/) {
		unless ($value =~ /(^-\d+$)|(^-\d+\.\d+$)|(^NA$)|(^default$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	
	### Positive values or NA or DEFAULT
	
	}elsif ($parameterKey =~ /(^divide_by)|(^width_network_edges$)|(^max_abs_ratio_exp_obs)|(^factor_scale_up)|(^number_of_empty_spots_per_plate$)|(^number_of_wt_sets_per_plate$)|(^margin_)|(^cex)|(^percent_of_dots_for_labels$)|(^linkage_window$)|(^cutoff_colony_size)|(^cutoff_circularity)|(^size_axes_labels$)|(^cutoff_fixation$)|(^maximum_mismatches)|(^number_of_parts)|(^log_base)|(^top_unmapped_to_display$)|(^top_mapped_to_display$)|(^trim_sequence)|(^cutoff_ratio_three_way$)|(^cutoff_evalue)|(^cutoff_readcounts$)|(^cutoff_abs_zscore$)|(^cutoff_pos$)|(^cutoff_allev$)|(^cutoff_hyper$)|(^cutoff_matrix)|(^cutoff_print_p$)|(^cutoff_print_q$)|(^cutoff_zscore$)|(^cutoff_for_blanks$)|(^null_models$)|(^fuzzy_cutoff$)|(^extra_percentage$)|(^density_bw$)|(^volume_in_target$)|(^sample_volume$)|(^final_od$)|(^disolvent_volume$)|(^change_tip_in_robot$)|(^horizontal_offset$)|(^window_size$)|(^is_a$)|(^part_of$)|(^max_volume_per_well$)|(^max_volume_per_tip$)|(^cutoff_corrected_pvalue$)|(^cutoff_pvalue$)|(^min_length_restriction_site$)|(^max_hits_in_barcodes_to_list$)|(^min_reads$)|(^nbins_)|(^opacity_for_rgb$)|(^spike_reads$)|(^cd_hit_cutoff$)|(^barcode_size$)|(^maximum_barcode_size_mismatch$)|(^minimum_blast_identity)|(^upstream_size$)|(^downstream_size$)|(^minimum_coverage)/) {
		unless ($value =~ /(^\d+$)|(^\d+\.\d+$)|(^NA$)|(^default$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}

	### Negative or Positive values or NA or DEFAULT
	
	}elsif ($parameterKey =~ /(^abline$)|(^constant_a$)|(^cutoff$)/) {
		unless ($value =~ /(^-*\d+$)|(^-*\d+\.\d+$)|(^-*\d+\.\d+e-*\d+$)|(^-*\d+e-*\d+$)|(^default$)|(^NA$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}

	### Negative or Positive values. Don't allow 'NA'

	}elsif ($parameterKey =~ /(^database_fixed_size$)|(^value_to_filter_pairs$)/) {
		unless ($value =~ /(^-*\d+$)|(^-*\d+\.\d+$)|(^-*\d+\.\d+e-*\d+$)|(^-*\d+e-*\d+$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}

	### Positive values. Don't allow 'NA'

	}elsif ($parameterKey =~ /(^min_reporter_intensity$)|(^cutoff_probability$)|(^seed_size_for_stringdistmat$)|(^number_of_plates)|(^lwd)|(^device_size$)|(^adjust_bw$)|(^min_percentage)|(^min_marginal$)|(^ng_per_ul$)|(^molecular_weight$)|(^set_min$)|(^set_max$)|(^top_interactors_cutoff$)|(^cols_in_row_names$)|(^min_number_beta_strands$)|(^min_bits$)|(^nbins$)|(^nperm$)|(^numb_samples$)|(^numb_pairs$)|(^minimum_numb_reads$)|(^numb_letters)|(^format_infile_matrix$)|(^min_nucleotides$)|(^min_letters)|(^min_letters)/) {
		unless ($value =~ /(^\d+$)|(^\d+\.\d+$)/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}

	### Negative or Positive values	comma separated
	
	}elsif ($parameterKey =~ /(^percentiles_to_replace$)|(^ablines$)/) {
		unless ($value =~ /(^-*\d+,*)|(^-*\d+\.\d+,*)|(^-*\d+\.\d+e-*\d+,*)|(^-*\d+e-*\d+,*)|(^default$)|(^NA$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	
	### Integer. Don't allow 'NA'
	
	}elsif ($parameterKey =~ /(^max_attendance$)|(^colors_palette$)|(^position_for_pseudo_single_mutant_)/) {
		unless ($value =~ /(^-*\d+$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}

	### <comma> separated list of integers. Don't allow 'NA'
	
	}elsif ($parameterKey =~ /(^linkage_windows$)/) {
	@values = split(",", $value);
		foreach $v (@values) {
			unless ($v =~ /(^-*\d+$)/i) {
			die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
			}
		}
		
	### Integer or 'NA'
	
	}elsif ($parameterKey =~ /(^list_most_frequent_untrimmed$)|(^max_number_of_cycles$)|(^min_number_of_cycles$)/) {
		unless ($value =~ /(^-*\d+$)|(^NA$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}

	### Integer positive or 'NA'
		
	}elsif ($parameterKey =~ /(^cutoff_combined$)|(^min_ratio_exp_obs_same_gene_pairs$)|(^rescale_pairs_in_list_factor$)|(^display_top_hits$)|(^correspondence_)/) {
		unless ($value =~ /(^\d+$)|(^NA$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}

	### Integer positive or 'ALL'
		
	}elsif ($parameterKey =~ /(^max_replicates)/) {
		unless ($value =~ /(^\d+$)|(^ALL$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}

	### Integer positive. Don't allow 'NA'
		
	}elsif ($parameterKey =~ /(^number_columns)|(^columns_with_row_headers$)|(^max_random_fluctuation)|(^number_of_rows_for_data_type$)|(^expected_number_of_reads_infiles_layouts$)|(^expected_colony_sizes_infiles_layouts$)|(^number_of_threads$)|(^legend_columns$)|(^cutoff_number_of_reads$)/) {
		unless ($value =~ /(^\d+$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}

	### Other values

	}elsif ($parameterKey =~ /(^blast_filter_settings$)/) {
		unless ($value =~ /(^1$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^sequence_to_mask$)/) {
		unless ($value =~ /(^1$)|(^2$)|(^NA$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^bowtie2_parameters$)/) {
		unless ($value =~ /(^1$)|(^2$)|(^NA$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^razers3_parameters$)/) {
		unless ($value =~ /(^[1-8]$)|(^NA$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^segemehl_parameters$)/) {
		unless ($value =~ /(^1$)|(^2$)|(^NA$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^skip_cols$)|(^skip_rows$)/) {
		unless ($value =~ /(^\d+$)|(^ALL$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^p_correction_test$)/) {
		unless ($value =~ /(^BY$)|(^BH$)|(^bonferroni$)/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^up_or_dn_barcode)/) {
		unless ($value =~ /(^up$)|(^dn$)|(^na$)/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^use_hyper$)/) {
		unless ($value =~ /(^p$)|(^pc$)/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^cutoff_column_positives$)|(^cutoffs_colony_sizes$)/) {
		unless ($value =~ /(^\d+,\d+$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^xlim)|(^ylim)/) {
		unless ($value =~ /(((^-*\d+)|(^-*\d+\.\d+)),((-*\d+$)|(-*\d+\.\d+$)))|(^default$)|(^NA$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^linkage$)|(^memory_per_process$)|(^hours_per_process$)/) {
		unless ($value =~ /(^\d+$)|(^\d+\.0$)/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^network_format$)|(^out_pairs_or_matrix$)|(^in_pairs_or_matrix$)/) {
		unless ($value =~ /(^pairs$)|(^matrix$)/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^pairs_or_singles$)/) {
		unless ($value =~ /(^pairs$)|(^singles$)/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^network_pairs_format$)/) {
		unless ($value =~ /(^txt$)|(^sif$)|(^ea$)|(^table_paired$)|(^table_r$)/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^save_only_enrichment$)/) {
		unless ($value =~ /(^all$)|(^batch$)/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^format_table$)/) {
		unless ($value =~ /(^ready$)|(^merge$)|(^filter$)/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^autolinks$)/) {
		unless ($value =~ /(^ready$)|(^merge$)|(^filter$)/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^scores_in_diagonal$)/) {
		unless ($value =~ /(^aggrv$)|(^allev$)/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^nodes_union_intersec$)|(^edges_union_intersec$)/) {
		unless ($value =~ /(^u$)|(^i$)|(^n1$)|(^n2$)/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^axis$)/) {
		unless ($value =~ /(^cols$)|(^rows$)|(^both$)/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^venn_position$)/) {
		unless ($value =~ /(^L$)|(^R$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^colors_or_gray$)/) {
		unless ($value =~ /(^C$)|(^G$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^add_class_name$)|(^depurate_or_merge$)/) {
		unless ($value =~ /(^1$)|(^2$)/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^ontology_root$)/) {
		unless ($value =~ /((^bp)(,mf|,cc)*$)|((^mf)(,bp|,cc)*$)|((^cc)(,bp|,mf)*$)|(^all$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^species_taxonomy$)/) {
		unless ($value =~ /(^ngo$)|(^sce$)|(^eco$)|(^hsa$)|(^all$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^cols_or_rows$)/) {
		unless ($value =~ /^(c|r|b)$/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^ids_col_1_as_rows_or_cols$)/) {
		unless ($value =~ /^(c|r)$/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^sort_by_marginals$)/) {
		unless ($value =~ /^(c|r|b|na)$/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^psk$)/) {
		unless ($value =~ /(p|s|k)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^legend_position)/) {
		unless ($value =~ /(^bottomright$)|(^bottom$)|(^bottomleft$)|(^left$)|(^topright$)|(^top$)|(^topleft$)|(^right$)|(^center$)|(^NA$)/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^abs_send_gsea$)/) {
		unless ($value =~ /(^y$)|(^n$)|(^na$)|(^none$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^more_or_less$)/) {
		unless ($value =~ /(^more$)|(^less$)|(^na$)|(^none$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^more_less_abs$)/) {
		unless ($value =~ /(^more$)|(^less$)|(^abs$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^wells_per_plate$)/) {
		unless ($value =~ /(^96$)|(^384$)|(^1536$)|(^NA$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^wells_per_plate_source)/) {
		unless ($value =~ /(^96$)|(^384$)|(^1536$)|(^NA$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^wells_per_plate_destination)/) {
		unless ($value =~ /(^24$)|(^96$)|(^384$)|(^1536$)|(^NA$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^mutant_collection$)/) {
		unless ($value =~ /(^ura3mm$)|(^kanmx$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^inside_or_outside$)/) {
		unless ($value =~ /^([1-4])$/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^percentiles_for_cutoff$)/) {
		unless ($value =~ /\d/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^starting_tip$)/) {
		unless ($value =~ /(^(\d+|[A-Z])(,)(\d+)$)|(^\d+$)|(^default$)/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^log_axis$)/) {
		unless ($value =~ /^(x|y|xy|na)$/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^input_format$)/) {
		unless ($value =~ /^(m|w|l|guess)$/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
		
	}elsif ($parameterKey =~ /(^input_format_barcodes$)/) {
		unless ($value =~ /^(full|medium|short)$/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^output_format$)/) {
		unless ($value =~ /^(m|w|l)$/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^use_graphics_device$)/) {
		unless ($value =~ /^(pdf|png)$/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^order_colors$)|(^order_lists$)/) {
		unless ($value =~ /(^NA$)|(^alphanumeric$)|(^\S+,\S+$)/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^blank_well$)/) {
		unless ($value =~ /^([A-Z]+\d+)$/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^collections_used$)/) {
		unless ($value =~ /(^1$)|(^3$)|(^4$)/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^priming_sequences$)/) {
		unless ($value =~ /(^1$)|(^3$)|(^5$)|(^7$)/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^pro_strains_version$)/) {
		unless ($value =~ /(^1$)/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^blast_output_format$)/) {
		unless ($value =~ /(^[0-9]$)|(^0\.0$)/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^control_coordinate$)/) {
		unless ($value =~ /(^[A-Z][0-9]+$)/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^rows_format$)/) {
		unless ($value =~ /(^letters$)|(^numbers$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^protein_or_nucleotide$)/) {
		unless ($value =~ /(^p$)|(^n$)|(^NA$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^program_to_map_barcodes$)/) {
		unless ($value =~ /(^grep$)|(^agrep$)|(^bowtie2$)|(^segemehl$)|(^razers3$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^program_to_compare_sequences$)/) {
		unless ($value =~ /(^agrep$)|(^bowtie2$)|(^blastp$)|(^blastn$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^donors_or_recipients$)|(^along_donors_or_recipients$)/) {
		unless ($value =~ /(^donors$)|(^recipients$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^subject_adapters$)/) {
		unless ($value =~ /^[1-3]$/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^replace_or_retain_outliers$)/) {
		unless ($value =~ /(^replace$)|(^retain$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^global_or_first$)/) {
		unless ($value =~ /(^global$)|(^first$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^oligo_before_or_after$)/) {
		unless ($value =~ /(^before$)|(^after$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^print_all_or_matched$)/) {
		unless ($value =~ /(^all$)|(^matched$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^bins_equal_size_or_lenght$)/) {
		unless ($value =~ /(^size$)|(^lenght$)|(^NA$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^labels_by_minmax_or_outliers$)/) {
		unless ($value =~ /(^min_max$)|(^outliers$)|(^both$)|(^NA$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^min_max_mean)/) {
		unless ($value =~ /(^min$)|(^max$)|(^mean$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^first_row_cols$)/) {
		unless ($value =~ /(^all$)|(^none$)|(^rest$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^sort_alphanum_mat1_mat2$)/) {
		unless ($value =~ /(^alphanumeric$)|(^mat1$)|(^mat2$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^sort_alphanum_or_numberofreads$)/) {
		unless ($value =~ /(^alphanumeric$)|(^numberofreads$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^highlight_with_labels_or_frames$)/) {
		unless ($value =~ /(^labels$)|(^frames$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^table_or_matrix$)/) {
		unless ($value =~ /(^table$)|(^matrix$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^single_mutant_1_donor_or_recipient$)|(^single_mutant_2_donor_or_recipient$)/) {
		unless ($value =~ /(^donor$)|(^recipient$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^print_only_same_or_all$)/) {
		unless ($value =~ /(^same$)|(^all$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^print_only_matched_or_all$)/) {
		unless ($value =~ /(^matched$)|(^all$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^label_format$)/) {
		unless ($value =~ /(^1$)|(^2$)|(^3$)/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^outformat_full_or_reduced$)/) {
		unless ($value =~ /(^full$)|(^reduced$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^add_stonge_or_costanzo$)/) {
		unless ($value =~ /(^stonge$)|(^costanzo$)|(^both$)/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^color_same_gene_pairs$)|(^color_histograms$)|(^color_plot_line$)/) {
		unless ($value =~ /(^\d+$)|([a-z])/i) { ### expected to be color names
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^performance_metrics$)/) {
		unless ($value =~ /^(sens|spec|prec|fpr|roc|prec_rec|sens_spec|mcc|mcc_sens_prec|mcc_sens_spec|sens_1mspec|interpolprec_rec)$/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^replace_or_add$)/) {
		unless ($value =~ /^(replace|add)$/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^rows_columns_for_pseudo_strains$)/) {
		unless ($value =~ /^(all_rows_or_columns_vs_neutrals|all_rows_and_columns_vs_neutrals)$/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^colour_by_first_or_second_gene$)/) {
		unless ($value =~ /^(first|second)$/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^stringdist_metric$)/) {
		unless ($value =~ /^(osa|lv|dl|hamming|lcs|qgram|cosine|jaccard|jw|soundex|NA)$/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^diagonal_up_or_down$)/) {
		unless ($value =~ /^(up|down)$/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^mode_epic$)/) {
		unless ($value =~ /^(FA|EXP|COMB|BR)$/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^features_epic$)/) {
		unless ($value =~ /^(0|1)(0|1)(0|1)(0|1)(0|1)(0|1)(0|1)(0|1)$/) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^classifier_epic$)/) {
		unless ($value =~ /^(svm|rf)$/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}elsif ($parameterKey =~ /(^represent_nodes$)/) {
		unless ($value =~ /^(abbreviated_id|node_as_a_dot|both|none)$/i) {
		die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
		}
	}else{
	die "ERROR!!! Reading parameter '$parameterKey' couldn't find evaluation parameters in LoadParameters::Evaluate_Definitions\n";
	}
}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

######################################################
### This subroutine is for parameters in an array <comma> delimited whose format needs to be checked for specifit formats
######################################################

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Evaluate_array_values {
my($parameterKey,$value) = @_;

	if ($parameterKey =~ /(^label_colors$)/) {
	@LabelsForColors = split (",", $value);
		foreach $code (@LabelsForColors) {
			unless ($code =~ /^(\S+)(---)(\S+)$/ or $code =~ /^NA$/i) {
			die "\nERROR!!! unexpected format in color code '$code'\n";
			}
		}
	}else{
	die "ERROR!!! Reading parameter '$parameterKey' couldn't find evaluation parameters in LoadParameters::Evaluate_array_values\n";
	}
}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Evaluate_array_values_or_na {
my($parameterKey,$value) = @_;

	### Digits or NA
	
	if ($parameterKey =~ /(^color_plates$)|(^color_rows$)|(^color_columns$)/) {
	@ValuesForColors = split (",", $value);
		foreach $code (@ValuesForColors) {
			unless ($code =~ /^(\d+)$/ or $value =~ /^NA$/i) {
			die "\nERROR!!! unexpected format in $parameterKey number '$code'\n";
			}
		}
	}else{
	die "ERROR!!! Reading parameter '$parameterKey' couldn't find evaluation parameters in LoadParameters::Evaluate_array_values\n";
	}
}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Evaluate_array_values_or_default_or_whole_na {
my($parameterKey,$value) = @_;


	### Numeric or NA

	if ($parameterKey =~ /(^min_max_limits)|(^rescale_min_max$)/) {
	@ValuesForColors = split (",", $value);
		foreach $code (@ValuesForColors) {
			if ($code =~ /(^-*\d+$)|(^-*\d+\.\d+$)|(^-*\d+\.\d+e-*\d+$)|(^-*\d+e-*\d+$)/i or $code =~ /^DEFAULT$/i) {
			}elsif ($value =~ /^NA$/i) {
			}else{
			die "\nERROR!!! unexpected format in $parameterKey number '$value'\n";
			}
		}
	}else{
	die "ERROR!!! Reading parameter '$parameterKey' couldn't find evaluation parameters in LoadParameters::Evaluate_array_values\n";
	}
}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


######################################################
### This subroutine is for parameters whose format must be [y/Y] or [n/N]
######################################################

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Evaluate_YN {
my($parameterKey,$value) = @_;
	unless ($value =~ /(^y$)|(^n$)|(^NA$)/i) {
	die "ERROR!!! Reading parameter '$parameterKey' value '$value' don't match expected format\n";
	}
}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

######################################################
### These subroutines are for parameters which only need specified path/files do exist
### or if it is defined as 'none'
######################################################

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Evaluate_file_exist {
my($parameterKey,$file) = @_;
	if ($file =~ /(^none$)|(^na$)/i) {
	}elsif (-f $file) {
	}else{
	die "ERROR!!! Reading parameter '$parameterKey' couldn't find file '$file'\n";
	}
}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Evaluate_directory_exist {
my($parameterKey,$directory) = @_;
	if ($directory =~ /^none$/) {
	}elsif (-d $directory) {
	}elsif ($parameterKey =~ /(^path_outfiles)/) { ### these are directories for outputs, thus if don't exist will be created
	`mkdir -p $directory`;
	print "WARNING!!! created directory\n'$directory'\n";
	}elsif ($parameterKey =~ /(^hyperG_directory$)/) { ### this is an intermediate directory, thus just look that there is a defined string
		if ($directory =~ /\S/) {
		}else{
		die "ERROR!!! directory '$directory' was recognized as a string\n";
		}
	}else{
	die "ERROR!!! directory '$directory' was not found\n";
	}
}
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


######################################################
### These subroutines are for parameters which only need to check they were defined
######################################################

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub Evaluate_were_defined {
my($parameterKey,$value) = @_;

	unless ($value =~ /\S/) {
	die "ERROR!!! Reading parameter '$parameterKey' string '$value' is not valid\n";
	}
}

sub Evaluate_were_defined_with_comma {
my($parameterKey,$value) = @_;
	unless ($value =~ /\S,\S/) {
	die "ERROR!!! Reading parameter '$parameterKey' string '$value' is not valid\n";
	}
}


##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

1;

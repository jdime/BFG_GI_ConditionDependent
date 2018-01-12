### This module gets one-command-line parameters provided by the User
### to populates subroutines in LoadParameters::Evaluate_Definitions to run Perl programs or use Perl as a wrapper of other programs

### If you are a R or Python programmer these two modules LoadParameters::Evaluate_Definitions and LoadParameters::Parameters
### are my equivalents to using 'argparse'

### Latest update - Javier Diaz - Jan 12, 2018

package LoadParameters::Parameters;
require Exporter;
require AutoLoader;

use LoadParameters::Evaluate_Definitions;
use PathsDefinition::PathsToInputs;

### NOTE: hashes generated in LoadParameters::Evaluate_Definitions need to be #EXPORT'ed here too to be used by calling programs

@ISA = qw( Exporter AutoLoader );
@EXPORT = qw(
MainSubParameters
%hashParameters
$MoreParameters
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

sub MainSubParameters {

#### Loading inputted parameters

my($In_hashParametersTolookFor,$In_arrayInputtedOneLineCommands) = @_;
%hashParametersTolookFor = %{$In_hashParametersTolookFor};   ## here assigning the incoming hash (element 0 from @_);
@InputtedOneLineCommands = @{$In_arrayInputtedOneLineCommands}; ## here assigning the incoming array (element 1 from @_);

#### Indexing parameters
	
	$c = 0;
	$CountMissingParamaters = 0;
	foreach $parameter (@InputtedOneLineCommands) {
	$c++;
	
		if ($parameter =~ /^-/) {
			if ($parameter =~ /^-\d+/) { ## this is because a parameter values like '-aggrv_cutoff -2' might be considered as two parameters because the '-'
			$MoreParameters .= "$parameter\n";
			}else{
			$MoreParameters .= "$parameter \t";
			}
		}else{
		$MoreParameters .= "$parameter\n";
		}
	
		if ($parameter =~ /^(-)(\S+)$/) {
		$parameterKey = $2;
		$parameterValue = @InputtedOneLineCommands[$c];
			if ($parameterValue =~ /(^-*0+$)/) {
			$parameterValue = "0.0";
			}
		$hashParameters{$parameterKey} = "$parameterValue";
		}
	}
	
#### Checking parameters for further details
	
	foreach $parameterKey (sort keys %hashParametersTolookFor) {
		if ($hashParameters{$parameterKey}) {
		$parameterValue = $hashParameters{$parameterKey};
	
		### these are parameters which need further processing
		#### Also you need to define such details in module LoadParameters::EvaluateDefinitions
		#### Also you need to return any useful hash, array, etc from such other modules by @EXPORT
		

			if ($parameterKey =~ /(^plate_numbers_to_include$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_parameter_values_series_of_digits($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^numb_cols)|(^column)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_numb_cols($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^numb_rows$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_numb_rows($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^step_numbers_to_run$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_step_numbers_to_run($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^filtered_outfile$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_outfile_options($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^filtered_outfile$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_outfile_options($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^rank_classes_to_include$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_rank_classes_to_include($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^type_of_tip_in_robot$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_type_of_tips($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^horizontal_offset$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_horizontal_offset($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^numb_rounds$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_numb_rounds($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^cutoff_send_gsea$)|(^cutoff_fdr)|(^cutoff_correl_plot_same_gene$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_cutoffs_numeric($parameterKey,$parameterValue);

			}elsif ($parameterKey =~ /(^cutoffs_aggrv$)|(^cutoffs_negative$)|(^cutoffs_negative_gold_standards$)|(^cutoffs_positive_gold_standards$)|(^cutoff_probability$)|(^cutoff_column_positives$)|(^cutoffs_colony_sizes$)|(^cutoff_number_of_reads$)|(^cutoff_colony_size)|(^cutoff_circularity)|(^cutoffs_allev$)|(^cutoffs_positive$)|(^cutoffs_network_\d+$)|(^cutoff_occurrences$)|(^cutoffs_readcounts$)|(^constants_a$)|(^constants_a$)|(^number_of_generations$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_cutoffs_negative_or_positive($parameterKey,$parameterValue);
			
			}elsif ($parameterKey =~ /(^restrict_classes$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_restrict_classes($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^inflation$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_inflation($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^generate_fuzzy_ea$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_generate_fuzzy_ea($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^clustering_method$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_clustering_method($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^ng_per_ul$)|(^molecular_weight$)|(^percentiles_to_replace$)|(^cutoff_neg$)|(^cutoff_pos$)|(^cutoff_aggrv$)|(^cutoff_allev$)|(^cutoff_hyper$)|(^cutoff_matrix)|(^cutoff_for_blanks$)|(^top_interactors_cutoff$)|(^cutoff_zscore$)|(^fuzzy_cutoff$)|(^cutoff_corrected_pvalue$)|(^cutoff_pvalue$)|(^constant_a$)|(^cutoff$)|(^database_fixed_size$)|(^value_to_filter_pairs$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
	
		### these are parameters whose values format needs to be checked and make sure Min <= Max value

			}elsif ($parameterKey =~ /(^set_min$)|(^set_max$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
				if ($parameterKey =~ /(^set_min$)/) {
					if ($hashParameters{set_max}) {
					$parameterKey_set_max = "set_max";
					$parameterValue_set_max = $hashParameters{set_max};
					LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey_set_max,$parameterValue_set_max);
						unless ($parameterValue <= $parameterValue_set_max) {
						die "ERROR!!! unexpected comparison '$parameterKey' = '$parameterValue' and '$parameterKey_set_max' = '$parameterValue_set_max', but they are expected '$parameterKey' <= '$parameterKey_set_max'\n";
						}
					}
				}elsif ($parameterKey =~ /(^set_max$)/) {
					if ($hashParameters{set_min}) {
					$parameterKey_set_min = "set_min";
					$parameterValue_set_min = $hashParameters{set_min};
					LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey_set_min,$parameterValue_set_min);
						unless ($parameterValue >= $parameterValue_set_min) {
						die "ERROR!!! unexpected comparison '$parameterKey' = '$parameterValue' and '$parameterKey_set_min' = '$parameterValue_set_min', but they are expected '$parameterKey' >= '$parameterKey_set_min'\n";
						}
					}
				}
				
		### these are parameters whose values format needs to be checked
			}elsif ($parameterKey =~ /(^distance_measure)(_\S+)*/) {
			$Suffix = $2;
			$Suffix =~ s/^_//;
				if ($Suffix =~ /\S/) {
				LoadParameters::Evaluate_Definitions::Evaluate_distance_measure($parameterKey,$parameterValue,$Suffix);
				}else{
				LoadParameters::Evaluate_Definitions::Evaluate_distance_measure($parameterKey,$parameterValue);
				}
			}elsif ($parameterKey =~ /(^ablines$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^cutoff_combined$)|(^width_network_edges$)|(^number_columns)|(^columns_with_row_headers$)|(^seed_size_for_stringdistmat$)|(^number_of_plates)|(^lwd)|(^min_max_mean)|(^max_attendance$)|(^max_random_fluctuation)|(^adjust_bw$)|(^number_of_rows_for_data_type$)|(^device_size$)|(^min_percentage)|(^min_marginal$)|(^min_reporter_intensity$)|(^expected_number_of_reads_infiles_layouts$)|(^expected_colony_sizes_infiles_layouts$)|(^number_of_threads$)|(^legend_columns$)|(^max_replicates)|(^razers3_parameters$)|(^segemehl_parameters$)|(^bowtie2_parameters$)|(^density_bw$)|(^abline$)|(^window_size$)|(^number_of_parts$)|(^top_unmapped_to_display$)|(^top_mapped_to_display$)|(^log_base$)|(^trim_sequence)|(^cutoff_ratio_three_way$)|(^null_models$)|(^extra_percentage$)|(^cols_in_row_names$)|(^min_number_beta_strands$)|(^min_bits$)|(^is_a$)|(^part_of$)|(^nbins$)|(^nperm$)|(^numb_samples$)|(^numb_pairs$)|(^minimum_numb_reads$)|(^numb_letters)|(^maximum_mismatches)|(^format_infile_matrix$)|(^max_volume_per_well$)|(^max_volume_per_tip$)|(^min_nucleotides$)|(^min_letters)|(^min_letters)|(^min_length_restriction_site$)|(^max_hits_in_barcodes_to_list$)|(^min_reads$)|(^skip_cols$)|(^skip_rows$)|(^memory_per_process$)|(^hours_per_process$)|(^nbins_)|(^nbins_)|(^nbins_)|(^opacity_for_rgb$)|(^spike_reads$)|(^cutoff_readcounts$)|(^cd_hit_cutoff$)|(^barcode_size$)|(^maximum_barcode_size_mismatch$)|(^minimum_blast_identity)|(^cutoff_evalue)|(^sequence_to_mask$)|(^upstream_size$)|(^downstream_size$)|(^minimum_coverage)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^size_axes_labels$)|(^cutoff_print_p$)|(^cutoff_print_q$)|(^cutoff_fixation$)|(^cutoff_evalue$)|(^volume_in_target$)|(^sample_volume$)|(^final_od$)|(^disolvent_volume$)|(^change_tip_in_robot$)|(^horizontal_offset$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^p_correction_test$)|(^use_hyper$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^up_or_dn_barcode)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^divide_by)|(^min_ratio_exp_obs_same_gene_pairs$)|(^rescale_pairs_in_list_factor$)|(^display_top_hits$)|(^correspondence_)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^xlim)|(^ylim)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^linkage$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^max_abs_ratio_exp_obs)|(^factor_scale_up)|(^number_of_empty_spots_per_plate$)|(^number_of_wt_sets_per_plate$)|(^max_number_of_cycles$)|(^min_number_of_cycles$)|(^list_most_frequent_untrimmed$)|(^percent_of_dots_for_labels$)|(^cex)|(^margin_)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^network_format$)|(^network_pairs_format$)|(^out_pairs_or_matrix$)|(^in_pairs_or_matrix$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^pairs_or_singles$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^save_only_enrichment$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^format_table$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^scores_in_diagonal$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^nodes_union_intersec$)|(^edges_union_intersec$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^axis$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^venn_position$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^colors_or_gray$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^add_class_name$)|(^depurate_or_merge$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^ontology_root$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^species_taxonomy$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^cols_or_rows$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^ids_col_1_as_rows_or_cols$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^sort_by_marginals$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^psk$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^legend_position)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^abs_send_gsea$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^more_or_less$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^more_less_abs$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^mutant_collection$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^inside_or_outside$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^percentiles_for_cutoff$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^starting_tip$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^log_axis$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^input_format$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^output_format$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^use_graphics_device$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^order_colors$)|(^order_lists$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^blank_well$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^pro_strains_version$)|(^collections_used$)|(^priming_sequences$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^blast_output_format$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^control_coordinate$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^colors_palette$)|(^position_for_pseudo_single_mutant_)|(^linkage_windows$)|(^linkage_window$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^wells_per_plate)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^rows_format)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^protein_or_nucleotide)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^blast_filter_settings$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^program_to)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^donors_or_recipients$)|(^along_donors_or_recipients$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^subject_adapters$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^replace_or_retain_outliers$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^global_or_first$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^oligo_before_or_after$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^print_all_or_matched$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^bins_equal_size_or_lenght$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^labels_by_minmax_or_outliers$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^first_row_cols$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^sort_alphanum_mat1_mat2$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^sort_alphanum_or_numberofreads$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^highlight_with_labels_or_frames$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^table_or_matrix$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^single_mutant_1_donor_or_recipient$)|(^single_mutant_2_donor_or_recipient$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^print_only_matched_or_all$)|(^print_only_same_or_all$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^label_format)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^outformat_full_or_reduced)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^add_stonge_or_costanzo)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^color_same_gene_pairs$)|(^color_histograms$)|(^color_plot_line$)/) { ### These are color names
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^performance_metrics$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^replace_or_add$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^rows_columns_for_pseudo_strains$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^colour_by_first_or_second_gene$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^stringdist_metric$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^input_format_barcodes$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^diagonal_up_or_down$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^classifier_epic$)|(^mode_epic$)|(^features_epic$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);
			}elsif ($parameterKey =~ /(^represent_nodes$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_value($parameterKey,$parameterValue);

		### these are parameters in an array <comma> delimited where each value format needs to be checked

			}elsif ($parameterKey =~ /(^label_colors$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_array_values($parameterKey,$parameterValue);

			}elsif ($parameterKey =~ /(^color_plates$)|(^color_rows$)|(^color_columns$)/) { ### These are color numbers
			LoadParameters::Evaluate_Definitions::Evaluate_array_values_or_na($parameterKey,$parameterValue);

			}elsif ($parameterKey =~ /(^rescale_min_max$)|(^min_max_limits)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_array_values_or_default_or_whole_na($parameterKey,$parameterValue);

		### these are parameters whose values must be [y/Y] or [n/N]

			}elsif ($parameterKey =~ /(^print_only)|(^print_flag_datasets$)|(^produce_files_for_cytoscape$)|(^sort_by_class_size$)|(^keep_outfiles)|(^submitting_in_cluster_nodes)|(^include_)|(^plot_zeros$)|(^always_use_headers_flag$)|(^produce_percent_outfile$)|(^sif_contains)|(^network_txt_contains_headers$)|(^calculate_stringdist$)|(^calculate_agrep$)|(^allows_same_gene_to_stay$)|(^dash_hundred_barcodes$)|(^rescale_zero_up$)|(^reformat_deletion_strain_ids$)|(^remove_pseudo_strain_ids$)|(^use_suffix$)|(^calculate_max_slope$)|(^remove_barcode_number$)|(^calculate_max_slope$)|(^allows_same_gene$)|(^generate_growth_curves$)|(^generate_spot_assays$)|(^obtain_infiles)|(^transform_to_lowercase$)|(^show_)|(^abbreviate_)|(^normalize_by_t1_population$)|(^normalize_by_total_matrix$)|(^legend_outside_plot$)|(^contains_plate_ids$)|(^multiple_matrices_condition1$)|(^multiple_matrices_template$)|(^obtain_frequency$)|(^merge_replicates$)|(^exclude_no_donor_and_no_recipient$)|(^highlight_same_gene$)|(^highlight_linked_genes$)|(^leave_not_found_as_empty$)|(^leave_not_found_as_empty$)|(^add_inverted_pairs_flag$)|(^use_abs$)|(^overlap_plots$)|(^add_sum$)|(^allow_reverse_complement$)|(^produce_newly_mapped$)|(^produce_gridded_images$)|(^produce_heatmaps$)|(^allows_query_multiple_times$)|(^allows_source_multiple_times$)|(^add_sequence_lenght$)|(^use_formatdb$)|(^generate_excel_files$)|(^print_barcode_variants$)|(^ignore_read_identifier$)|(^contains_header$)|(^mask_low_complexity$)|(^mask_same_strain$)|(^autolinks$)|(^directed$)|(^isolated$)|(^fuzzy$)|(^diag$)|(^duplicates)|(^contains_class_name$)|(^invert_same_strain$)|(^invert_same_gene$)|(^abs_cutoff$)|(^ignore_same_strain$)|(^ignore_same_position$)|(^na_as_zero$)|(^zero_as_na$)|(^depurate_contents$)|(^remove_nas$)|(^log_dot_size$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_YN($parameterKey,$parameterValue);

		### these are parameters which only need specified path/files do exist
			
			}elsif ($parameterKey =~ /(^infile)/) {
			
				### This is to allow Evaluate_Definitions::Evaluate_file_exist use '-f' when the input starts with '~/' instead the root/home/Users path
				if ($parameterValue =~ /^~\//) {
				$PathPrefix = "/$Users_home/$DefaultUserName/";
				$parameterValue =~ s/^~\//$PathPrefix/;
				$hashParameters{$parameterKey} = $parameterValue;
				}
				
			LoadParameters::Evaluate_Definitions::Evaluate_file_exist($parameterKey,$parameterValue);

		### these are parameters which only need specified path/directories do exist
			
			}elsif ($parameterKey =~ /(^indir)|(^path_indir$)|(^path_outfiles)|(^hyperG_directory$)/) {
			$hashParameters{$parameterKey} =~ s/\/$//;
			LoadParameters::Evaluate_Definitions::Evaluate_directory_exist($parameterKey,$parameterValue);
			
		### these are parameters which only need to check that are defined 
			}elsif ($parameterKey =~ /(^colour_plots$)|(^headers_columns_complement$)|(^restrict_to_pool_labels$)|(^labels_pseudo_strains$)|(^list_exclude_abbreviated_barcodes$)|(^metric_to_filter_pairs$)|(^pool_labels_to_rescale$)|(^pair_delimiter$)|(^color_hist_x$)|(^color_hist_y$)|(^headers_rows)|(^headers_columns)|(^neutrals_for_pseudo_single_donors$)|(^neutrals_for_pseudo_single_recipients$)|(^neutral_barcode_ids$)|(^header_column)|(^attribute_labels$)|(^collection_expected_read1$)|(^collection_expected_read2$)|(^collection1_to_sort_counts$)|(^collection2_to_sort_counts$)|(^expected_groups$)|(^prefix)|(^flag_outfiles)|(^suffix)|(^string)|(^label_Template$)|(^label_ToDepurate$)|(^xlab$)|(^min_observations$)|(^networks_prefix$)|(^handle_ones$)|(^handle_negatives$)|(^handle_zeros$)|(^pch$)|(^col_header_for_colors$)|(^attribute_layer_1$)/) {
			LoadParameters::Evaluate_Definitions::Evaluate_were_defined($parameterKey,$parameterValue);

			}else{
			die "\nERROR!!! parameter '$parameterKey' is not definied in module LoadParameters::Parameters\n";
			}
			
		}else{
		$hashMissingParameters{$parameterKey} = 1;
		$CountMissingParamaters++;
		}
	}
	
#### Checking if all requested parameters were defined
	
	if ($CountMissingParamaters > 0) {
	print "\nThe following one-line-command parameters are needed, please provide them and try again:\n";
		foreach $parameter (sort keys %hashMissingParameters) {
		print "-$parameter\n";
		}
	die "\nThis program is exiting now by module LoadParameters::Parameters\n\n";
	}else{
	print "\nAll parameters needed were succesfully loaded\n";
	}

};

1;

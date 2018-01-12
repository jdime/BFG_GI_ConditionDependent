package PathsDefinition::PathsToPrograms;
require Exporter;
require AutoLoader;
@ISA = qw( Exporter AutoLoader );
@EXPORT = qw( %PathsToPrograms_Directories %PathsToPrograms_Files );


use PathsDefinition::PathsToInputs;

### Here Defining DIRECTORIES
%PathsToPrograms_Directories = (
'blast_executables'   => "/$Users_home/$DefaultUserName/PROGRAMS/BLAST/blast-2.2.25/bin",
);

### Here Defining FILES
%PathsToPrograms_Files = (
'cytoscape_executable'        => "/$Users_home/$DefaultUserName/PROGRAMS/CYTOSCAPE/Cytoscape_v3.6.0/cytoscape.sh",
'javatreeview_executable'     => "/$Users_home/$DefaultUserName/PROGRAMS/JAVATREEVIEW/TreeView-1.1.5r2-bin/TreeView.jar",
'cluster_one_executable'      => "/$Users_home/$DefaultUserName/PROGRAMS/EPIC/src/cluster_one-1.0.jar",

#'gsea_executable'             => "/$Users_home/$DefaultUserName/PROGRAMS/GSEA/gsea2-2.07.jar",
#'cd-hit_executable'           => "/usr/local/bin/cd-hit",
#'ssconvert_executable'        => "/opt/local/bin/ssconvert",
#'xls2txt_executable'          => "/usr/local/bin/xls2txt",
#'xlsx2csv_executable'         => "/usr/local/bin/xlsx2csv",
#'tab2xls_executable'         =>  "/$Users_home/$DefaultUserName/perl_programs/tab2xls.pl", ### Needs module(Spreadsheet::WriteExcel) which can be installed with CPAN
#'ht_colony_imager_executable' => "/$Users_home/$DefaultUserName/PROGRAMS/HT_COLONY_GRID_ANALYZER/ht-colony-grid-analyzer-1.1.7/ht-col-measurer-1.1.7.jar",
);

1;

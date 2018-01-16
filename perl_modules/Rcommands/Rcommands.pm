### This module populates hash %Rcommands which contains commands for R
### mainly used to generate plots

### Last update: Sep 09, 2010

### Other command that need to be implemented:
### paste (..., sep = " ", collapse = NULL)

package Rcommands::Rcommands;
require Exporter;
require AutoLoader;

@ISA = qw( Exporter AutoLoader );
@EXPORT = qw( %Rcommands );

%Rcommands = (
'suppress_box_and_axes'                                     => "axes=FALSE,bty=\"n\"",
'suppress_axes_descriptions'                                => "xlab=\"\",ylab\"\"",
'suppress_all_around'                                       => "axes=FALSE,bty=\"n\",xlab=\"\",ylab=\"\",main=\"\"",
'put_legend_outside'                                        => "inset=-0.11,xpd=TRUE,bty=\"n\",horiz=FALSE", ### Gives some room for header
'put_legend_veryoutside'                                    => "inset=-0.18,xpd=TRUE,bty=\"n\",horiz=FALSE", ### Doesn't give roon for header
'empty_plot'                                                => "x=NA,y=NA,xlim=c(0,1),ylim=c(0,1),axes=FALSE,bty=\"n\",xlab=\"\",ylab=\"\"",
'empty_plot_to_define_axes_limits'                          => "x=NA,y=NA,axes=FALSE,bty=\"n\",xlab=\"\",ylab=\"\"",
'empty_plot_to_define_axes_limits_and_axes_labels'          => "x=NA,y=NA,axes=FALSE,bty=\"n\"",
'empty_plot_to_define_axes_limits_with_box'                 => "x=NA,y=NA,xlab=\"\",ylab=\"\"",
'empty_plot_to_define_axes_limits_and_axes_labels'          => "x=NA,y=NA,axes=FALSE,bty=\"n\"",
'empty_plot_to_define_axes_limits_and_axes_labels_with_box' => "x=NA,y=NA,",
);

1;

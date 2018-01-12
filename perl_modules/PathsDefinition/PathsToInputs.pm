### Latest modification 12Jan2018 - by Javier Diaz - javier.diazmejia@gmail.com

### This module determines the HOME path and USER_NAME

### if running in a Linux the HOME will be '/home', in a Mac it will be '/Users'
### if running on the BC Linux cluster at Donnelly Centre it may be '/home1/rothlab' or '/home/rothlab'

### The resulting path to Users HOME is passed by $Users_home
### The resulting User name is passed by $DefaultUserName

### It also used to populate hashes %PathsToInputs_Files and %PathsToInputs_Directories with commonly used databases and programs
### But now they are called by ~/perl_modules/PathsDefinition/PathsToPrograms.pm
### and species-specific modules in ~/perl_modules/PathsDefinition/PathsToInfiles_*_.pm

package PathsDefinition::PathsToInputs;
require Exporter;
require AutoLoader;
@ISA = qw( Exporter AutoLoader );
@EXPORT = qw( $Users_home $DefaultUserName );

$User_home_path = `echo ~`;
chomp $User_home_path;
if ($User_home_path =~ /^(\/)(\S+)(\/)(\S+)/) {
$Users_home = $2;
$DefaultUserName = $4;
}

1;

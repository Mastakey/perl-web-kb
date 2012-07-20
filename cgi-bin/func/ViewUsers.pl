use strict;
use warnings;

#PREPROCESS LIB DIRECTORY
use vars qw/$libDir/;
use vars qw/$configDir/;

BEGIN { 
open my $fh, "<PREPROCESS.txt" or die "Can not open PREPROCESS.txt\n";
my @lines = <$fh>;
$libDir = $lines[0];
$configDir = $lines[1];
$libDir =~ s/\n//; #REMOVE new line
$configDir =~ s/\n//;
}

use FindBin;
use Data::Dumper;
use lib $libDir;
use WEBDB;
use CONFIG;
use UTIL;


#CONFIG SUTFF
my $cfg = new CONFIG($configDir);
my $logDir = $cfg->{CONFIG}->{logDir};
my $db_odbc = $cfg->{CONFIG}->{db_odbc};

my $db = new WEBDB($db_odbc, "", "", $logDir.'/db_viewEntry.log');
my $util = new UTIL();

#FUNCTIONAL STUFF
#QUERY

#CONNECT TO DB
$db->connect();

#INPUT
my $userId = 1;

#GET Entry
my $users = $util->getUsers($db);

print Dumper($users);

#DISCONNECT DB
$db->disconnect();

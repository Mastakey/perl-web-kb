use strict;
use warnings;

use FindBin;
use Data::Dumper;
use lib "$FindBin::Bin/../lib";
use WEBDB;
use CONFIG;
use UTIL;


#CONFIG SUTFF
my $cfg = new CONFIG();
my $logDir = $cfg->{CONFIG}->{logDir};

my $db = new WEBDB($cfg->{DBCON}, "", "", $logDir.'/db_viewEntry.log');
my $util = new UTIL();

#FUNCTIONAL STUFF

#CONNECT TO DB
$db->connect();

#INPUT
my $sectionId = 1;

#GET Entries
my $entries = $util->getSectionEntries($db, $sectionId);

print Dumper($entries);

#DISCONNECT DB
$db->disconnect();
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
my $entryId = 1;

#GET Entry
my $entry = $util->getEntry($db, $entryId);

print Dumper($entry);

#DISCONNECT DB
$db->disconnect();
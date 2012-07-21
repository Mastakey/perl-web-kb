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

use strict;
use warnings;

use FindBin;
use Data::Dumper;
use lib "$FindBin::Bin/../lib";
use WEBDB;
use DBCFG;
use CONFIG;
use UTIL;

#CONFIG SUTFF
my $cfg = new CONFIG();
my $dbcfg = new DBCFG($cfg->{ROOTDIR}.'/config/db.cfg');
$dbcfg->getConfig();
my $db_con = $dbcfg->getConnection("KB");
my $db = new WEBDB($db_con->{DRIVER}.$db_con->{TNS}, "", "", $cfg->{ROOTDIR}.'log/db_addsection.log');
my $util = new UTIL();

#FUNCTIONAL STUFF
#QUERY

#CONNECT TO DB
$db->connect();

#INPUT
my $entryId = 1;

#GET Entry
my $entry = $util->getEntry($db, $entryId);

print Dumper($entry);

#DISCONNECT DB
$db->disconnect();
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
my $tagId = 1;

#GET Entries
my $entries = $util->getTagEntries($db, $tagId);

print Dumper($entries);

#DISCONNECT DB
$db->disconnect();
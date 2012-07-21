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
my $insert_query = qq~
	INSERT INTO table_section (name, parent_id, active) VALUES ('Perl', NULL, 1);
~;

#CONNECT TO DB
$db->connect();
#INSERT TO DB
my $id = $db->insertSQLGetLast($insert_query, "table_section", "id");
#VALIDATE INSERT
print "Inserted Section with id:$id\n";;
#DISCONNECT DB
$db->disconnect();
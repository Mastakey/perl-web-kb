use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use WEBDB;
use DBCFG;
use CONFIG;

#CONFIG SUTFF
my $cfg = new CONFIG();
my $dbcfg = new DBCFG($cfg->{ROOTDIR}.'/config/db.cfg');
$dbcfg->getConfig();
my $db_con = $dbcfg->getConnection("KB");
my $db = new WEBDB($db_con->{DRIVER}.$db_con->{TNS}, "", "", $cfg->{ROOTDIR}.'log/db_add_user.log');

#FUNCTIONAL STUFF
#QUERY
my $insert_query = qq~
	INSERT INTO table_user (name, username, email, active) VALUES ('Natalie Hong', '', '', 1);
~;

#CONNECT TO DB
$db->connect();
#INSERT TO DB
my $id = $db->insertSQLGetLast($insert_query, "table_user", "id");
#VALIDATE INSERT
print "Inserted User with id:$id\n";;
#DISCONNECT DB
$db->disconnect();
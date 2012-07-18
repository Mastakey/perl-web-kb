use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Template;
use WEBDB;
use DBCFG;

    my $tmpl_file = 'dbcon.tmpl';
	my $output_file = 'dbcon.html';
    my $vars = {
       perlmessage  => "This is a perl variable",
	   DBVALUES => [],
    };
	my $query = "SELECT ID, NAME FROM SKELETON";

my $dbcfg = new DBCFG('../../config/db.cfg');
#my $dbcfg = new DBCFG('../../../skeleton/config/db.cfg');

$dbcfg->getConfig();
my $db_con = $dbcfg->getConnection("SKELETONDB");
my $db = new WEBDB($db_con->{DRIVER}.$db_con->{TNS}, "", "");

$db->connect();
my $results = $db->executeSQLHash($query);
$db->disconnect();

$vars->{DBVALUES} = $results;

    my $template = Template->new( 
		{
			RELATIVE => 1,
			INCLUDE_PATH => '../../tmpl:../../tmpl/includes',
			OUTPUT_PATH => '../../html',
			PRE_PROCESS => '../../config/tmpl.cfg',
			#IF cgi-bin is shared:
			#INCLUDE_PATH => '../../../skeleton/tmpl:../../../skeleton/tmpl/includes',
			#OUTPUT_PATH => '../../../skeleton/html',
			#PRE_PROCESS => '../../../skeleton/config/tmpl.cfg',
		}
	);
    
    $template->process($tmpl_file, $vars, $output_file)
        || die "Template process failed: ", $template->error(), "\n";
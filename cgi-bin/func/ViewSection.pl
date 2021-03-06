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
my $select_query_roots = qq~
	SELECT id, name, parent_id, active  FROM table_section WHERE parent_id IS NULL AND active=1;
~;

=item
TREE Structure
HTML
Perl
	Notes
	CPAN
C++
Microsoft
	Windows
		2003 Server
		2008 Server
			IIS
	Word
	
@array = 
(
	{id=>1, name=>'HTML', children=>[]},
	{id=>2, name=>'Perl', children=>[{id=>3,name=>'Notes', children=>[]},{id=>4,name=>'CPAN', children=>[]}],
)
=cut

#CONNECT TO DB
$db->connect();
#Query all roots
#my $sectionRootArray = $db->executeSQLHash($select_query_roots);

#Query all children
	my $sections = $util->getAllSections($db, undef, \&printSection);
	print Dumper($sections);

#DISCONNECT DB
$db->disconnect();

sub printSection
{
	my $section = shift;
	#print Dumper($section);
}
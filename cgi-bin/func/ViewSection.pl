use strict;
use warnings;

use FindBin;
use Data::Dumper;
use lib "$FindBin::Bin/../lib";
use WEBDB;
use DBCFG;
use CONFIG;

#CONFIG SUTFF
my $cfg = new CONFIG();
my $dbcfg = new DBCFG($cfg->{ROOTDIR}.'/config/db.cfg');
$dbcfg->getConfig();
my $db_con = $dbcfg->getConnection("KB");
my $db = new WEBDB($db_con->{DRIVER}.$db_con->{TNS}, "", "", $cfg->{ROOTDIR}.'log/db_addsection.log');

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
my $sectionRootArray = $db->executeSQLHash($select_query_roots);

#Query all children
	my $sections = getAllSections($db, undef, \&printSection);
	print Dumper($sections);

#DISCONNECT DB
$db->disconnect();


sub getAllSections
{
#RECURSIVELY Find Children
	my $db = shift;
	my $parentId = shift;
	my $codeRef = shift;
	
	my @sections = ();
	
	my $whereClause = "parent_id=$parentId";
	if ($parentId == 0 || (!(defined($parentId))))
	{
		$whereClause = "parent_id is NULL";
	}
	

	
	#GET children
	my $select_query_children = qq~
		SELECT id, name, parent_id, active  FROM table_section WHERE $whereClause AND active=1;
	~;
	my $sectionArray = $db->executeSQLHash($select_query_children);
	foreach my $section (@$sectionArray)
	{
		#Do something
		$codeRef->($section);	
		my $sub_sections = getAllSections($db, $section->{id}, $codeRef);
		$section->{children} = $sub_sections;
		push(@sections, $section);
	}
	return \@sections;
}

sub printSection
{
	my $section = shift;
	#print Dumper($section);
}
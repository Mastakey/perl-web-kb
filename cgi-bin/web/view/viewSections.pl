#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use Data::Dumper;
use lib "$FindBin::Bin/../../lib";
use WEBDB;
use CONFIG;
use UTIL;

#WEB INIT
print "Content-type: text/html\n\n";

#CONFIG SUTFF

my $cfg = new CONFIG('../');
my $logDir = $cfg->{CONFIG}->{logDir};
my $configDir = $cfg->{CONFIG}->{configDir};
my $db = new WEBDB($cfg->{DBCON}, "", "", $logDir.'/db_viewSections.log');
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
	#print Dumper($sections);

#DISCONNECT DB


$db->disconnect();

sub printSection
{
	my $section = shift;
	#print Dumper($section);
}

#TEMPLATE STUFF
use Template;

my $tmplDir = $cfg->{CONFIG}->{tmplDir};
my $htmlDir = $cfg->{CONFIG}->{htmlDir};
my $htmlcgi = $cfg->{CONFIG}->{htmlcgi};

    my $tmpl_file = 'viewSections.tmpl';
	my $output_file = 'viewSections.html';
    my $vars = {
       sections  => $sections,
	   htmlcgi => $htmlcgi,
	   cssdir => '../css',
    };
	
    my $template = Template->new( 
		{
			RELATIVE => 1,
			RECURSION => 1,
			DELIMITER => ';',
			INCLUDE_PATH => $tmplDir.'/web;'.$tmplDir.'/includes',
			OUTPUT_PATH => $htmlDir.'/web',
			PRE_PROCESS => $configDir.'/tmpl.cfg',
		}
	);
    
print $template->process($tmpl_file, $vars, $output_file)
        || die "Template process failed: ", $template->error(), "\n";

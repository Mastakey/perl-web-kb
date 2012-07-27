#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use Data::Dumper;
use lib "$FindBin::Bin/../../lib";
use WEBDB;
use CONFIG;
use UTIL;
use CGI qw(:standard);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use Cwd;

#WEB INIT
print "Content-type: text/html\n\n";

#CONFIG SUTFF
my $currentDir = getcwd();

my $cfg = new CONFIG('../');
my $logDir = $cfg->{CONFIG}->{logDir};
my $configDir = $cfg->{CONFIG}->{configDir};
my $db = new WEBDB($cfg->{DBCON}, "", "", $logDir.'/db_updateLeftNav.log');
my $util = new UTIL();


#FUNCTIONAL STUFF

#CONNECT TO DB
$db->connect();

#Query all children
	my $sections = $util->getAllSections($db, undef, \&printSection);

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
my $cssDir = $cfg->{CONFIG}->{cssDir};

    my $tmpl_file = 'updateLeftNav.tmpl';
	my $output_file = 'web_left_section.tmpl';
    my $vars = {
       sections  => $sections,
	   htmlcgi => $htmlcgi,
	   cssdir => $cssDir,
    };
	
    my $template = Template->new( 
		{
			RELATIVE => 1,
			RECURSION => 1,
			DELIMITER => ';',
			INCLUDE_PATH => $tmplDir.'/admin/auto;'.$tmplDir.'/includes',
			OUTPUT_PATH => $tmplDir.'/includes',
			PRE_PROCESS => $configDir.'/tmpl.cfg',
		}
	);
    
print $template->process($tmpl_file, $vars, $output_file)
        || die "Template process failed: ", $template->error(), "\n Current dir: $currentDir";

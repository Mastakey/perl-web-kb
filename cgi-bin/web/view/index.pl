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
#my $db = new WEBDB($cfg->{DBCON}, "", "", $logDir.'/db_viewSections.log');
#my $util = new UTIL();


#FUNCTIONAL STUFF
my $breadcrumbs = [
];

#TEMPLATE STUFF
use Template;

my $tmplDir = $cfg->{CONFIG}->{tmplDir};
my $htmlDir = $cfg->{CONFIG}->{htmlDir};
my $htmlcgi = $cfg->{CONFIG}->{htmlcgi};
my $cssDir = $cfg->{CONFIG}->{cssDir};

    my $tmpl_file = 'index.tmpl';
	my $output_file = 'index.html';
    my $vars = {
	   breadcrumbs => $breadcrumbs,
	   htmlcgi => $htmlcgi,
	   cssdir => $cssDir,
    };
	
    my $template = Template->new( 
		{
			RELATIVE => 1,
			RECURSION => 1,
			DELIMITER => ';',
			INCLUDE_PATH => $tmplDir.'/web/view;'.$tmplDir.'/includes',
			OUTPUT_PATH => $htmlDir.'/web/view',
			PRE_PROCESS => $configDir.'/tmpl.cfg',
		}
	);
    
$template->process($tmpl_file, $vars)
        || die "Template process failed: ", $template->error(), "\n Current dir: $currentDir";

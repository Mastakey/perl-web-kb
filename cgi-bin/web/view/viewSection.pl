#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use Data::Dumper;
use lib "$FindBin::Bin/../../lib";
use WEBDB;
use CONFIG;
use UTIL;

#DYANMIC CONTENT {print HTML}:
print "Content-type: text/html\n\n";

#CONFIG SUTFF
my $cfg = new CONFIG('../');
my $logDir = $cfg->{CONFIG}->{logDir};
my $configDir = $cfg->{CONFIG}->{configDir};
my $db = new WEBDB($cfg->{DBCON}, "", "", $logDir.'/db_viewSection.log');
my $util = new UTIL();

#FUNCTIONAL STUFF

#CONNECT TO DB
$db->connect();

#INPUT
my $sectionId = 1;
#my $sectionId = param("sectionId");

#GET Entry
my $section = $util->getSection($db, $sectionId);

#BREADCRUMBS
#TODO

#print Dumper($section);

#DISCONNECT DB
$db->disconnect();

#TEMPLATE STUFF
use Template;

my $tmplDir = $cfg->{CONFIG}->{tmplDir};
my $htmlDir = $cfg->{CONFIG}->{htmlDir};
my $htmlcgi = $cfg->{CONFIG}->{htmlcgi};

    my $tmpl_file = 'viewSection.tmpl';
	my $output_file = 'viewSection.html';
    my $vars = {
       section  => $section->[0],
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
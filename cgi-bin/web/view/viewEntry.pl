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

#WEB INIT
print "Content-type: text/html\n\n";

#CONFIG SUTFF

my $cfg = new CONFIG('../');
my $logDir = $cfg->{CONFIG}->{logDir};
my $configDir = $cfg->{CONFIG}->{configDir};
my $db = new WEBDB($cfg->{DBCON}, "", "", $logDir.'/db_viewEntry.log');
my $util = new UTIL();

#INPUT
my $entry_id = param("entry_id");

#VALIDATION
#TODO

#FUNCTIONAL STUFF

#CONNECT TO DB
$db->connect();

#GET Entry
my $entry = $util->getEntry($db, $entry_id);

#GET ENTRY TAGS
my $tags = $util->getAllTagsByEntry($db, $entry_id);

#DISCONNECT DB
$db->disconnect();

#TEMPLATE STUFF
use Template;

my $tmplDir = $cfg->{CONFIG}->{tmplDir};
my $htmlDir = $cfg->{CONFIG}->{htmlDir};
my $htmlcgi = $cfg->{CONFIG}->{htmlcgi};
my $cssDir = $cfg->{CONFIG}->{cssDir};

    my $tmpl_file = 'viewEntry.tmpl';
	my $output_file = 'viewEntry.html';
    my $vars = {
       entry => $entry->[0],
	   tags => $tags,
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
        || die "Template process failed: ", $template->error(), "\n";

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
my $db = new WEBDB($cfg->{DBCON}, "", "", $logDir.'/db_deleteEntry.log');
my $util = new UTIL();

#INPUTS
my $entry_id = param("entry_id");

#FUNCTIONAL STUFF

#CONNECT TO DB
$db->connect();

#DELETE ENTRY
my $id = $util->deleteEntry($db, $entry_id);

#TODO
my $msg = "Successfully deleted Entry with ID: $id";

#DISCONNECT DB
$db->disconnect();

#TEMPLATE STUFF
use Template;

my $tmplDir = $cfg->{CONFIG}->{tmplDir};
my $htmlDir = $cfg->{CONFIG}->{htmlDir};
my $htmlcgi = $cfg->{CONFIG}->{htmlcgi};
my $cssDir = $cfg->{CONFIG}->{cssDir};

    my $tmpl_file = 'deleteEntry.tmpl';
	my $output_file = 'deleteEntry.html';
    my $vars = {
       msg => $msg,
	   htmlcgi => $htmlcgi,
	   cssdir => $cssDir,
    };
	
    my $template = Template->new( 
		{
			RELATIVE => 1,
			RECURSION => 1,
			DELIMITER => ';',
			INCLUDE_PATH => $tmplDir.'/web/delete;'.$tmplDir.'/includes',
			OUTPUT_PATH => $htmlDir.'/web/delete',
			PRE_PROCESS => $configDir.'/tmpl.cfg',
		}
	);
    
$template->process($tmpl_file, $vars)
        || die "Template process failed: ", $template->error(), "\n";

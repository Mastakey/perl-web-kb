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
my $db = new WEBDB($cfg->{DBCON}, "", "", $logDir.'/db_deleteAttachment.log');
my $util = new UTIL();

#INPUTS
my $attach_id = param("attach_id");

#VALIDATION
#TODO

#FUNCTIONAL STUFF

#CONNECT TO DB
$db->connect();

#INSERT TO DB
$attach_id = $util->deleteAttachment($db, $attach_id);

#DISCONNECT DB
$db->disconnect();

#TEMPLATE STUFF
use Template;

my $tmplDir = $cfg->{CONFIG}->{tmplDir};
my $htmlDir = $cfg->{CONFIG}->{htmlDir};
my $htmlcgi = $cfg->{CONFIG}->{htmlcgi};
my $cssDir = $cfg->{CONFIG}->{cssDir};

    my $tmpl_file = 'deleteAttachment.tmpl';
	#my $output_file = 'addSection.html';
    my $vars = {
	   attach_id => $attach_id,
	   htmlcgi => $htmlcgi,
	   cssdir => $cssDir, #used by header.tmpl
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
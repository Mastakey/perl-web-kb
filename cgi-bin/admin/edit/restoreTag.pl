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
my $db = new WEBDB($cfg->{DBCON}, "", "", $logDir.'/db_restoreTag.log');
my $util = new UTIL();

#INPUT
my $tag_id = param("tag_id");

#VALIDATION
#TODO

#FUNCTIONAL STUFF


#CONNECT TO DB
$db->connect();
#INSERT TO DB
	my $id = $util->restoreItem($db, "table_tag", $tag_id);
#VALIDATE UPDATE
#TODO
my $msg = "TODO";

#DISCONNECT DB
$db->disconnect();

#TEMPLATE STUFF
use Template;

my $tmplDir = $cfg->{CONFIG}->{tmplDir};
my $htmlDir = $cfg->{CONFIG}->{htmlDir};
my $htmlcgi = $cfg->{CONFIG}->{htmlcgi};
my $cssDir = $cfg->{CONFIG}->{cssDir};

    my $tmpl_file = 'editTag.tmpl';
	#my $output_file = 'updateSection.html';
    my $vars = {
		msg => $msg,
	   htmlcgi => $htmlcgi,
	   cssdir => $cssDir, #used by header.tmpl
    };
	
    my $template = Template->new( 
		{
			RELATIVE => 1,
			RECURSION => 1,
			DELIMITER => ';',
			INCLUDE_PATH => $tmplDir.'/admin/edit;'.$tmplDir.'/includes',
			OUTPUT_PATH => $htmlDir.'/admin/edit',
			PRE_PROCESS => $configDir.'/tmpl.cfg',
		}
	);
    
    print $template->process($tmpl_file, $vars)
        || die "Template process failed: ", $template->error(), "\n";
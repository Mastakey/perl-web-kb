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
my $db = new WEBDB($cfg->{DBCON}, "", "", $logDir.'/db_viewTagEntries.log');
my $util = new UTIL();

#INPUT
my $tag_id = param("tag_id");

#FUNCTIONAL STUFF

#CONNECT TO DB
$db->connect();

#GET Tag
my $tag = $util->getTag($db, $tag_id);
#GET Entries
my $entries = $util->getTagEntries($db, $tag_id);

#DISCONNECT DB
$db->disconnect();

#TEMPLATE STUFF

use Template;

my $tmplDir = $cfg->{CONFIG}->{tmplDir};
my $htmlDir = $cfg->{CONFIG}->{htmlDir};
my $htmlcgi = $cfg->{CONFIG}->{htmlcgi};
my $cssDir = $cfg->{CONFIG}->{cssDir};

    my $tmpl_file = 'viewTagEntries.tmpl';
	my $output_file = 'viewTagEntries.html';
    my $vars = {
	   tag => $tag->[0],
	   entries => $entries,
	   htmlcgi => $htmlcgi,
	   cssdir => $cssDir,
    };
	
    my $template = Template->new( 
		{
			RELATIVE => 1,
			RECURSION => 1,
			DELIMITER => ';',
			INCLUDE_PATH => $tmplDir.'/web/view;'.$tmplDir.'/includes;'.$configDir,
			OUTPUT_PATH => $htmlDir.'/web/view',
			PRE_PROCESS => 'tmpl.cfg',
		}
	);
    
$template->process($tmpl_file, $vars)
        || die "Template process failed: ", $template->error(), "\n";

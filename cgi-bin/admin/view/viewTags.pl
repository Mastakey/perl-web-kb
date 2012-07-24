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
my $db = new WEBDB($cfg->{DBCON}, "", "", $logDir.'/db_viewTags.log');
my $util = new UTIL();


#FUNCTIONAL STUFF

#CONNECT TO DB
$db->connect();
#Query
	my $tags = $util->getAllTags($db);

#DISCONNECT DB
$db->disconnect();

#TEMPLATE STUFF
use Template;

my $tmplDir = $cfg->{CONFIG}->{tmplDir};
my $htmlDir = $cfg->{CONFIG}->{htmlDir};
my $htmlcgi = $cfg->{CONFIG}->{htmlcgi};
my $cssDir = $cfg->{CONFIG}->{cssDir};

    my $tmpl_file = 'viewTags.tmpl';
	my $output_file = 'viewTags.html';
    my $vars = {
       tags => $tags,
	   htmlcgi => $htmlcgi,
	   cssdir => $cssDir,
    };
	
    my $template = Template->new( 
		{
			RELATIVE => 1,
			RECURSION => 1,
			DELIMITER => ';',
			INCLUDE_PATH => $tmplDir.'/admin/view;'.$tmplDir.'/includes',
			OUTPUT_PATH => $htmlDir.'/admin/view',
			PRE_PROCESS => $configDir.'/tmpl.cfg',
		}
	);
    
print $template->process($tmpl_file, $vars)
        || die "Template process failed: ", $template->error(), "\n";

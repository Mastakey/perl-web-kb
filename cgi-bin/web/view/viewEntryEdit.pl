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
my $db = new WEBDB($cfg->{DBCON}, "", "", $logDir.'/db_viewEntryEdit.log');
my $util = new UTIL();

#INPUT
my $section_id = param("section_id");
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
my $tagStr = "";
#GET Tag string
foreach my $tag (@$tags)
{
	$tagStr.=$tag->{name}.",";
}

#Breadcrumbs
my $breadcrumbs = $util->getBreadcrumbSections($db, $section_id);

#DISCONNECT DB
$db->disconnect();

#TEMPLATE STUFF
use Template;

my $tmplDir = $cfg->{CONFIG}->{tmplDir};
my $htmlDir = $cfg->{CONFIG}->{htmlDir};
my $htmlcgi = $cfg->{CONFIG}->{htmlcgi};
my $cssDir = $cfg->{CONFIG}->{cssDir};

    my $tmpl_file = 'viewEntryEdit.tmpl';
	my $output_file = 'viewEntryEdit.html';
    my $vars = {
	   breadcrumbs => $breadcrumbs,
       entry => $entry->[0],
	   tagStr => $tagStr, 
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

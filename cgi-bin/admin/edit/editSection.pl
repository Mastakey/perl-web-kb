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
my $db = new WEBDB($cfg->{DBCON}, "", "", $logDir.'/db_editSection.log');
my $util = new UTIL();

#INPUT
#my $name = "SectionName";
my $section_id = param("section_id");
my $section_name = param("section_name");

#VALIDATION
#TODO

#FUNCTIONAL STUFF
#QUERY
my $update_query = qq~
	UPDATE table_section SET name='$section_name' WHERE id=$section_id
~;

#CONNECT TO DB
$db->connect();
#INSERT TO DB
$db->updateSQL($update_query);
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

    my $tmpl_file = 'editSection.tmpl';
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
			INCLUDE_PATH => $tmplDir.'/admin/edit;'.$tmplDir.'/includes;'.$configDir,
			OUTPUT_PATH => $htmlDir.'/admin/edit',
			PRE_PROCESS => 'tmpl.cfg',
		}
	);
    
    print $template->process($tmpl_file, $vars)
        || die "Template process failed: ", $template->error(), "\n";
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
my $db = new WEBDB($cfg->{DBCON}, "", "", $logDir.'/db_addSection.log');
my $util = new UTIL();

#INPUT
#my $name = "SectionName";
my $name = param("section_name");
my $parent_id = param("parent_id");

if ($parent_id <= 0)
{
	$parent_id = "NULL";
}

#VALIDATION
#TODO

#FUNCTIONAL STUFF
#QUERY
my $insert_query = qq~
	INSERT INTO table_section (name, parent_id, active) VALUES ('$name', $parent_id, 1);
~;

#CONNECT TO DB
$db->connect();
#INSERT TO DB
my $id = $db->insertSQLGetLast($insert_query, "table_section", "id");
#VALIDATE INSERT
my $msg = "";
if ($id > 0)
{
	$msg = "Successfully added Section with ID: $id";
}
else
{
	$msg = "Something went wrong: check the log for more details";
}
#DISCONNECT DB
$db->disconnect();

#TEMPLATE STUFF
use Template;

my $tmplDir = $cfg->{CONFIG}->{tmplDir};
my $htmlDir = $cfg->{CONFIG}->{htmlDir};
my $htmlcgi = $cfg->{CONFIG}->{htmlcgi};
my $cssDir = $cfg->{CONFIG}->{cssDir};

    my $tmpl_file = 'addSection.tmpl';
	#my $output_file = 'addSection.html';
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
			INCLUDE_PATH => $tmplDir.'/admin/add;'.$tmplDir.'/includes',
			OUTPUT_PATH => $htmlDir.'/admin/add',
			PRE_PROCESS => $configDir.'/tmpl.cfg',
		}
	);
    
    print $template->process($tmpl_file, $vars)
        || die "Template process failed: ", $template->error(), "\n";
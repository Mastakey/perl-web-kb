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
my $db = new WEBDB($cfg->{DBCON}, "", "", $logDir.'/db_addUser.log');
my $util = new UTIL();

#INPUT
my $name = param("user_name");
my $username = param("user_username");
my $email = param("user_email");

#VALIDATION
#TODO

#FUNCTIONAL STUFF

#CONNECT TO DB
$db->connect();
#INSERT USER
	my $id = $util->insertUser($db, $name, $username, $email);
#VALIDATE INSERT
my $msg = "";
if ($id > 0)
{
	$msg = "Successfully added User with ID: $id";
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

    my $tmpl_file = 'addUser.tmpl';
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
			INCLUDE_PATH => $tmplDir.'/admin/add;'.$tmplDir.'/includes;'.$configDir,
			OUTPUT_PATH => $htmlDir.'/admin/add',
			PRE_PROCESS => 'tmpl.cfg',
		}
	);
    
    print $template->process($tmpl_file, $vars)
        || die "Template process failed: ", $template->error(), "\n";
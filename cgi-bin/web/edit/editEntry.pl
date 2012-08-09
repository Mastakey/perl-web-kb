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
my $db = new WEBDB($cfg->{DBCON}, "", "", $logDir.'/db_editEntry.log');
my $util = new UTIL();

#INPUTS
my $section_id = param("section_id");
my $entry_id = param("entry_id");
my $name = param("entry_name");
my $username = param("entry_user");
my $content = param("entry_content");
my $tagsStr = param("entry_tags");


#VALIDATION
#TODO
#Make sure title is not empty
#Make sure content is not empty
#Make sure user exists
#Make sure section exists

#FUNCTIONAL STUFF

#CONNECT TO DB
$db->connect();
#INPUT TRANSFORM if any
my $tags = $util->parseTags($tagsStr);

#Reads from DB if any
my $userId = $util->getUserId($db, $username);

#INSERT TAGS if neccessary
#GET TAG IDs
my $tagIds = $util->getAndCreateTags($db, $tags);

#GET CONTENT ID
my $content_id = $util->getContentId($db, $entry_id);
#UPDATE CONTENT
$util->updateContent($db, $content_id, $content);

#UPDATE ENTRY
my $id = $util->updateEntry($db, $entry_id, $name, $userId);

#UPDATE TAGS
$util->updateEntryTags($db, $id, $tagIds);
#VALIDATE INSERT
my $msg = "";
if ($id > 0)
{
	$msg = "Successfully edited Entry with ID: $id";
}
else
{
	$msg = "Something went wrong: check the log for more details";
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

    my $tmpl_file = 'editEntry.tmpl';
	my $output_file = 'editwEntry.html';
    my $vars = {
	   breadcrumbs => $breadcrumbs,
       msg => $msg,
	   entry_id => $id,
	   htmlcgi => $htmlcgi,
	   cssdir => $cssDir,
    };
	
    my $template = Template->new( 
		{
			RELATIVE => 1,
			RECURSION => 1,
			DELIMITER => ';',
			INCLUDE_PATH => $tmplDir.'/web/edit;'.$tmplDir.'/includes;'.$configDir,
			OUTPUT_PATH => $htmlDir.'/web/edit',
			PRE_PROCESS => 'tmpl.cfg',
		}
	);
    
$template->process($tmpl_file, $vars)
        || die "Template process failed: ", $template->error(), "\n";

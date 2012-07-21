use strict;
use warnings;

use FindBin;
use Data::Dumper;
use lib "$FindBin::Bin/../lib";
use WEBDB;
use CONFIG;
use UTIL;

#CONFIG SUTFF
my $cfg = new CONFIG();
my $logDir = $cfg->{CONFIG}->{logDir};

my $db = new WEBDB($cfg->{DBCON}, "", "", $logDir.'/db_viewEntry.log');
my $util = new UTIL();

#INPUTS
#tags : str [to array]
#name(title) : str
#content: str
#username: str [to id]  
#sectionid: int

#CONNECT TO DB
$db->connect();

#INPUTS
my $tagsStr = "Database, Sqlite, WEBDB";
my $name = "Database Entry";
my $content = qq~
	This is a test entry.
	Oolong Cha - Pure Brown <p> Blah </p>
~;
my $username = "mastakey";
my $sectionId = 1;

#INPUT TRANSFORM if any
my $tags = $util->parseTags($tagsStr);

#Reads from DB if any
my $userId = $util->getUserId($db, $username);

#VALIDATION
#Make sure title is not empty
#Make sure content is not empty
#Make sure user exists
#Make sure section exists


#FUNCTIONAL STUFF

#INSERT TO DB

#INSERT TAGS if neccessary
#GET TAG IDs
my $tagIds = $util->getAndCreateTags($db, $tags);

#INSERT CONTENT and GET ID
my $contentId = $util->insertContent($db, $content);

#INSERT ENTRY and GET ID
my $entryId = $util->insertEntry($db, $name, $contentId, $userId, $sectionId);

#INSERT ENTRY_TAGs
$util->insertEntryTags($db, $entryId, $tagIds);

#VALIDATE INSERT


#DISCONNECT DB
$db->disconnect();


package UTIL;
use WEBDB;
use Data::Dumper;

use strict;

#test();

sub new
{
    my $class = shift;
    my $self = 
    {
    	
    };    
    bless $self, $class;
    return $self;
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Gernal Functions

#tags
sub parseTags
{
	my $self = shift;
	my $tags = shift;
	my @tagArray = split(',', $tags);
	my @parsedTagArray = ();
	foreach my $tag (@tagArray)
	{
		$tag =~ s/\s//; #remove spaces
		push(@parsedTagArray, $tag);
	}
	return \@parsedTagArray;
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#DB Functions

#Reads
sub getUserId
{
	my $self = shift;
	my $db = shift;
	my $username = shift;
	my $id = 0;
	#assume that db is connected already
	my $queryArray = $db->executeSQLHash("SELECT id FROM table_user WHERE username='".$username."' AND active=1");
	$id = $queryArray->[0]->{id};
	return $id;
}

sub getTagId
{
	my $self = shift;
	my $db = shift;
	my $tag = shift;
	my $uc_function = "upper";
	my $id = 0;
	my $query = qq~
		SELECT id FROM table_tag WHERE $uc_function(name)='$tag' AND active=1 
	~;
	my $array = $db->executeSQLHash($query);
	$id = $array->[0]->{id};
	return $id;
}

#Writes
sub insertTag
{
	my $self = shift;
	my $db = shift;
	my $tag = shift;
	my $id = 0;
	my $query = qq~
		INSERT INTO table_tag (name, active) VALUES ('$tag', 1)
	~;
	$id = $db->insertSQLGetLast($query, 'table_tag', 'id');
	return $id;
}

sub insertContent
{
	my $self = shift;
	my $db = shift;
	my $content = shift;
	my $id = 0;
	my $query = qq~
		INSERT INTO table_content (content_blob) VALUES (?);
	~;
	$id = $db->insertSQLClobGetLast($query, $content, 'table_content', 'id');
	return $id;
}

sub insertEntry
{
	my $self = shift;
	my $db = shift;
	my $name = shift;
	my $contentId = shift;
	my $userId = shift;
	my $sectionId = shift;
	my $id = 0;
	my $query = qq~
		INSERT INTO table_entry (name, content_id, user_id, createdate, lastdate, section_id, active) VALUES ('$name', $contentId, $userId, datetime('now'), datetime('now'), $sectionId, 1)
	~;
	$id = $db->insertSQLGetLast($query, 'table_entry', 'id');
	return $id;	
}

sub insertEntryTags
{
	my $self = shift;
	my $db = shift;
	my $entryId = shift;
	my $tagIds = shift;
	my @ids = ();
	foreach my $tagId (@$tagIds)
	{
		my $query = qq~
			INSERT INTO table_entry_tag (entry_id, tag_id, active) VALUES ($entryId, $tagId, 1);
		~;
		my $id = $db->insertSQLGetLast($query, 'table_entry_tag', 'id');
		push(@ids, $id);
	}
	return \@ids;	
}


#Read and Writes
sub getAndCreateTags
{
	my $self = shift;
	my $db = shift;
	my $tags = shift;
	my @tagIds = ();
	foreach my $tag (@$tags)
	{
		my $tag_uc = uc($tag);
		my $tagId = $self->getTagId($db, $tag_uc);
		if ($tagId <= 0 || !defined($tagId))
		{
			$tagId = $self->insertTag($db, $tag);
		}
		push(@tagIds, $tagId);
	}
	return \@tagIds;
}

#=====================================================================

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Tests

sub test_parseTags
{
	my $util = new UTIL();
	my @tags = $util->parseTags("database, sqlite");
	print Dumper(@tags);
}
#=====================================================================


#test_parseTags();

1;

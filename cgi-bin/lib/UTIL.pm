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
#General Functions

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

sub getAllTags
{
	my $self = shift;
	my $db = shift;
	my $query = qq~
		SELECT id, name, active FROM table_tag WHERE active=1
	~;
	return $db->executeSQLHash($query);
}

sub getTag
{
	my $self = shift;
	my $db = shift;
	my $id = shift;
	my $query = qq~
		SELECT id, name, active FROM table_tag WHERE id=$id
	~;
	return $db->executeSQLHash($query);
}

sub getAllSections
{
#RECURSIVELY Find Children
	my $self = shift;
	my $db = shift;
	my $parentId = shift;
	my $codeRef = shift;
	
	my @sections = ();
	
	my $whereClause = "parent_id=$parentId";
	if ($parentId == 0 || (!(defined($parentId))))
	{
		$whereClause = "parent_id is NULL";
	}

	#GET children
	my $select_query_children = qq~
		SELECT id, name, parent_id, active  FROM table_section WHERE $whereClause AND active=1
	~;
	my $sectionArray = $db->executeSQLHash($select_query_children);
	foreach my $section (@$sectionArray)
	{
		#Do something
		$codeRef->($section);	
		my $sub_sections = $self->getAllSections($db, $section->{id}, $codeRef);
		$section->{children} = $sub_sections;
		push(@sections, $section);
	}
	return \@sections;
}

sub getSection
{
	my $self = shift;
	my $db = shift;
	my $sectionId = shift;
	my $query = qq~
		SELECT id, name, parent_id, active FROM table_section where id =$sectionId
	~;
	return $db->executeSQLHash($query);
}

sub getSectionEntries
{
	my $self = shift;
	my $db = shift;
	my $sectionId = shift;
	my $query = qq~
		SELECT id, name, user_id, createdate, lastdate FROM table_entry WHERE section_id=$sectionId AND active=1 
	~;
	return $db->executeSQLHash($query);
}

sub getTagEntries
{
	my $self = shift;
	my $db = shift;
	my $tagId = shift;
	my $query = qq~
		SELECT entry.id, entry.name, user.name, entry.createdate, entry.lastdate 
		FROM table_entry entry, table_user user, table_entry_tag entry_tag, table_tag tag 
		WHERE 
		entry.user_id = user.id 
		AND
		entry.id = entry_tag.entry_id
		AND
		entry_tag.tag_id = tag.id
		AND
		tag.id = $tagId
	~;
	return $db->executeSQLHash($query);
}

sub getEntry
{
	my $self = shift;
	my $db = shift;
	my $entryId = shift;
	my $query = qq~
		SELECT 
		entry.id,
		entry.name, 
		content.content_blob,
		user.name,
		entry.createdate,
		entry.lastdate,
		section.name,
		entry.active	
		FROM 
		table_entry entry,
		table_content content,
		table_section section,
		table_user user
		WHERE
		entry.content_id = content.id and
		entry.user_id = user.id and
		entry.section_id = section.id and
		entry.id = $entryId
	~;
	return $db->executeSQLHash($query);
}

sub getUsers
{
	my $self = shift;
	my $db = shift;
	my $query = qq~
		SELECT id, name, username, email, active FROM table_user WHERE active=1
	~;
	return $db->executeSQLHash($query);
}

sub getUser
{
	my $self = shift;
	my $db = shift;
	my $userId = shift;
	my $query = qq~
		SELECT id, name, username, email, active FROM table_user WHERE id = $userId
	~;
	return $db->executeSQLHash($query);
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

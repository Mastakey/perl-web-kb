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
#General Functions #

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

#make html
sub makePrettyHTML
{
	my $self = shift;
	my $str = shift;
	$str =~ s/\</&lt/g;
	$str =~ s/\>/&gt/g;
	return $str;
}

sub sanitizeLink
{
	my $self = shift;
	my $str = shift;
	$str =~ s/\+/\&#43;/g;
	$str =~ s/\&/\&amp;/g;
	return $str;
}

sub unTaint
{
	my $self = shift;
	my $str = shift;
	my $safe_filename_characters = "a-zA-Z0-9_.-";
	my $old_str = $str;
	$str =~ tr/ /_/;
	$str =~ s/[^$safe_filename_characters]//g;
	if ($str =~ /^([$safe_filename_characters]+)$/ ) 
	{
		$str = $1;
	}
	else
	{
		die "$old_str contains invalid characters";
	}
	return $str;
}

sub _reverse
{
	my $arrayRef = shift;
	my @bc = @$arrayRef;
	@bc = reverse(@bc);
	return \@bc
}

#End General Functions #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#DB Functions #

#Generic Reads

sub getBreadcrumbSections
{
	my $self = shift;
	my $db = shift;
	my $sectionId = shift;
	my $breadcrumbs = $self->getBreadcrumbSectionsRec($db, $sectionId);
	my $crumbs = _reverse($breadcrumbs);
	return $crumbs;
}


sub getBreadcrumbSectionsRec
{
	my $self = shift;
	my $db = shift;
	my $sectionId = shift;
	my @breadcrumbs = ();
	my $query = qq~
		SELECT id, parent_id, name FROM table_section WHERE id=$sectionId
	~;
	my $section = $db->executeSQLHash($query);
	if (@$section)
	{
		push(@breadcrumbs, @$section);
		my $parent_id = $section->[0]->{parent_id};
		if ($parent_id > 0 && defined($parent_id) && $parent_id ne "" && $parent_id ne "NULL")
		{
			my $crumbs = $self->getBreadcrumbSections($db, $parent_id);
			my $bcs = _reverse($crumbs);
			push(@breadcrumbs, @$bcs);
		}
	}
	return \@breadcrumbs; 
}

sub getDeleted
{
	my $self = shift;
	my $db = shift;
	my $table = shift;
	my $query = qq~
		SELECT id, name FROM $table WHERE active=0
	~;
	return $db->executeSQLHash($query);
}

#Search
sub searchContent
{
	my $self = shift;
	my $db = shift;
	my $search_str = shift;
	my $query = qq~
		SELECT id FROM table_content WHERE content_blob like '%$search_str%'
	~;
	return $db->executeSQLHash($query);
}

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

sub getAllUsers
{
	my $self = shift;
	my $db = shift;
	my $query = qq~
		SELECT id, name, username, email, active FROM table_user WHERE active=1
	~;
	return $db->executeSQLHash($query);
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

sub getAllTagsByEntry
{
	#returns an array of tags for a given entry
	my $self = shift;
	my $db = shift;
	my $entryId = shift;
	my $query = qq~
		SELECT 
		tag.id, tag.name
		FROM 
		table_entry entry, table_entry_tag entry_tag, table_tag tag
		WHERE
		entry.id = entry_tag.entry_id AND
		tag.id = entry_tag.tag_id AND
		tag.active = 1 AND
		entry_tag.active = 1 AND
		entry.id = $entryId
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
		SELECT entry.id, entry.name, entry.user_id, user.username, entry.createdate, entry.lastdate 
		FROM table_entry entry, table_user user 
		WHERE entry.section_id=$sectionId 
		AND entry.user_id = user.id
		AND entry.active=1
	~;
	return $db->executeSQLHash($query);
}

sub getTagEntries
{
	my $self = shift;
	my $db = shift;
	my $tagId = shift;
	my $query = qq~
		SELECT entry.id, entry.name, entry.user_id, user.username, entry.createdate, entry.lastdate 
		FROM table_entry entry, table_user user, table_entry_tag entry_tag, table_tag tag 
		WHERE entry.user_id = user.id 
		AND entry.id = entry_tag.entry_id
		AND entry_tag.tag_id = tag.id
		AND tag.id = $tagId
		AND entry_tag.active=1
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
		entry.name AS entry_name, 
		content.content_blob,
		user.username AS user_username,
		entry.createdate,
		entry.lastdate,
		section.id AS section_id,
		section.name AS section_name,
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

sub getContentId
{
	my $self = shift;
	my $db = shift;
	my $entryId = shift;
	my $query = qq~
		SELECT content_id FROM table_entry WHERE id=$entryId
	~;
	my $array = $db->executeSQLHash($query);
	return $array->[0]->{content_id};
}

sub getAllAttachmentsByEntry
{
	my $self = shift;
	my $db = shift;
	my $entryId = shift;
	my $query = qq~
		SELECT attach.id, attach.name, attach.filename 
		FROM table_attachment attach, 
		table_entry entry, 
		table_entry_attachment entry_attach
		WHERE 
		entry.id = $entryId AND
		entry_attach.entry_id = entry.id AND
		entry_attach.attachment_id = attach.id AND
		attach.active = 1
	~;
	return $db->executeSQLHash($query);
}

#Writes
sub restoreItem
{
	my $self = shift;
	my $db = shift;
	my $table = shift;
	my $id = shift;

	my $query = qq~
		UPDATE $table SET active=1 WHERE id=$id
	~;
	$db->updateSQL($query);
	return $id;
}

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

sub insertUser
{
	my $self = shift;
	my $db = shift;
	my $name = shift;
	my $username = shift;
	my $email = shift;
	my $id = 0;
	my $query = qq~
		INSERT INTO table_user (name, username, email, active) VALUES ('$name', '$username', '$email', 1)
	~;
	$id = $db->insertSQLGetLast($query, 'table_user', 'id');
	return $id;
}

sub editUser
{
	my $self = shift;
	my $db = shift;
	my $id = shift;
	my $name = shift;
	my $username = shift;
	my $email = shift;

	my $query = qq~
		UPDATE table_user SET name='$name', username='$username', email='$email' WHERE id=$id
	~;
	$db->updateSQL($query);
	return $id;
}

sub deleteUser
{
	my $self = shift;
	my $db = shift;
	my $id = shift;

	my $query = qq~
		UPDATE table_user SET active=0 WHERE id=$id
	~;
	$db->updateSQL($query);
	return $id;
}

sub insertContent
{
	my $self = shift;
	my $db = shift;
	my $content = shift;
	my $id = 0;
	my $query = qq~
		INSERT INTO table_content (content_blob) VALUES (?)
	~;
	$id = $db->insertSQLClobGetLast($query, $content, 'table_content', 'id');
	return $id;
}

sub updateContent
{
	my $self = shift;
	my $db = shift;
	my $contentId = shift;
	my $content = shift;
	my $query = qq~
		UPDATE table_content SET content_blob=? WHERE id=$contentId
	~;
	$db->updateSQLClob($query, $content);
	return $contentId;
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

sub updateEntry
{
	my $self = shift;
	my $db = shift;
	my $entryId = shift;
	my $name = shift;
	my $userId = shift;
	my $query = qq~
		UPDATE table_entry SET name='$name', user_id=$userId, lastdate=datetime('now') WHERE id=$entryId
	~;
	$db->updateSQL($query);
	return $entryId;
}

sub deleteEntry
{
	my $self = shift;
	my $db = shift;
	my $id = shift;

	my $query = qq~
		UPDATE table_entry SET active=0 WHERE id=$id
	~;
	$db->updateSQL($query);
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

sub insertAttachment
{
	my $self = shift;
	my $db = shift;
	my $name = shift;
	my $filename = shift;
	my $id = 0;
	my $query = qq~
		INSERT INTO table_attachment (name, filename, createdate, lastdate, active) VALUES ('$name', '$filename', datetime('now'), datetime('now'), 1)
	~;
	$id = $db->insertSQLGetLast($query, 'table_attachment', 'id');
	return $id;	
}

sub insertEntryAttachment
{
	my $self = shift;
	my $db = shift;
	my $entry_id = shift;
	my $attach_id = shift;
	my $id = 0;
	my $query = qq~
		INSERT INTO table_entry_attachment (entry_id, attachment_id, active) VALUES ($entry_id, $attach_id, 1)
	~;
	$id = $db->insertSQLGetLast($query, 'table_entry_attachment', 'id');
	return $id;	
}

sub deleteAttachment
{
	my $self = shift;
	my $db = shift;
	my $id = shift;
	my $query = qq~
		UPDATE table_attachment SET active=0 WHERE id=$id
	~;
	$db->updateSQL($query);
	return $id;	
}

#Read and Writes

sub updateEntryTags
{
	my $self = shift;
	my $db = shift;
	my $entryId = shift;
	my $tagIds = shift;
	
	my $select_query = qq~
		SELECT entry_id, tag_id FROM table_entry_tag WHERE entry_id = $entryId AND active=1
	~;
	
	my $tagArray = $db->executeSQLHash($select_query);
	
	#ADDING TAGS
	foreach my $tagId (@$tagIds)
	{
		if (!_isInArrayHash($tagId, $tagArray, 'tag_id'))
		{
			my $query = qq~
				INSERT INTO table_entry_tag (entry_id, tag_id, active) VALUES ($entryId, $tagId, 1);
			~;
			my $id = $db->insertSQLGetLast($query, 'table_entry_tag', 'id');
		}
	}
	
	#DELETING TAGS
	foreach my $tag (@$tagArray)
	{
		if (!_isInArray($tag->{tag_id}, $tagIds))
		{
			my $query = qq~
				UPDATE table_entry_tag SET active=0 where tag_id=$tag->{tag_id} AND entry_id=$entryId;
			~;
			$db->updateSQL($query);
		}
	}	
}

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

#END DB Functions #
#=====================================================================

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#INTERNAL Functions #
sub _isInArray
{
	my $item = shift;
	my $array = shift;
	foreach my $a (@$array)
	{
		if ($item eq $a)
		{
			return 1;
		}
	}
	return 0;
}


sub _isInArrayHash
{
	my $item = shift;
	my $array = shift;
	my $key = shift;
	foreach my $a (@$array)
	{
		if ($item eq $a->{$key})
		{
			return 1;
		}
	}
	return 0;
}

#END INTERNAL Functions #
#=====================================================================

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Tests

sub test_parseTags
{
	my $util = new UTIL();
	my @tags = $util->parseTags("database, sqlite");
	print Dumper(@tags);
}

sub test_updateContent
{
	my $util = new UTIL();
	my $logDir = '../../log';
	my $dbCon = "dbi:SQLite:dbname=../../db/data/kb_1.db";
	my $db = new WEBDB($dbCon, "", "", $logDir.'/db_UTIL_updateContent.log');
	my $str = qq~
	Testing 13
	fdsa
	~;
	$db->connect();
	#$util->getAllUsers($db);
	$util->updateContent($db, 1, $str);
	$db->disconnect();
}

sub test_getAndCreateTags
{
	my $util = new UTIL();
	my $logDir = '../../log';
	my $dbCon = "dbi:SQLite:dbname=../../db/data/kb_1.db";
	my $db = new WEBDB($dbCon, "", "", $logDir.'/db_UTIL_getAndCreateTags.log');
	$db->connect();
	my $tagStr = "Database,Test3,Test4";
	my $tags = $util->parseTags($tagStr);
	my $tagIds = $util->getAndCreateTags($db, $tags);
	$util->updateEntryTags($db, 1, $tagIds);
	$db->disconnect();
	#print Dumper($array);
}

sub test_breadCrumbSections
{
	my $util = new UTIL();
	my $logDir = '../../log';
	my $dbCon = "dbi:SQLite:dbname=../../db/data/kb_1.db";
	my $db = new WEBDB($dbCon, "", "", $logDir.'/db_UTIL_getAndCreateTags.log');
	$db->connect();
	my $section_id = 8;
	my $breadcrumbs = $util->getBreadcrumbSectionsRec($db, $section_id);
	#my $bc = $util->_reverse($breadcrumbs);
	#print Dumper($breadcrumbs);
	#my $breadcrumbs = $util->getBreadcrumbSections($db, $section_id);
	print Dumper($breadcrumbs);
	$db->disconnect();
	#print Dumper($array);
}

#=====================================================================

#test_breadCrumbSections();

#test_getAndCreateTags();

#test_updateContent();

#test_parseTags();

1;

All Entry:
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
entry.section_id = section.id;

Tag Entry:
SELECT entry.id, entry.name, user.name, entry.createdate, entry.lastdate 
FROM table_entry entry, table_user user, table_entry_tag entry_tag, table_tag tag 
WHERE 
entry.user_id = user.id 
AND
entry.id = entry_tag.entry_id
AND
entry_tag.tag_id = tag.id
AND
tag.id = 1;
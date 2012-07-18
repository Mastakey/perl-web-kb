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
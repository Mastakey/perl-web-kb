INSERT INTO table_user (name, username, email, active) VALUES ('Kioh Han', 'mastakey', 'kioh.han@gmail.com', 1);
INSERT INTO table_section (name, parent_id, active) VALUES ('Database', NULL, 1);
INSERT INTO table_section (name, parent_id, active) VALUES ('SQLite', (SELECT id FROM table_section WHERE name ='Database'), 1);
INSERT INTO table_tag (name, active) VALUES ('Database', 1);
INSERT INTO table_tag (name, active) VALUES ('SQLite', 1);
INSERT INTO table_content (content_blob) VALUES ('SQLite is good.');
INSERT INTO table_entry (name, content_id, user_id, createdate, lastdate, section_id, active) VALUES ('SQLite notes', 1, 1, datetime('now'), datetime('now'), 2, 1);
INSERT INTO table_entry_tag (entry_id, tag_id, active) VALUES (1, 1, 1);
INSERT INTO table_entry_tag (entry_id, tag_id, active) VALUES (1, 2, 1);

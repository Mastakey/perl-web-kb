CREATE TABLE table_user 
(
id INTEGER PRIMARY KEY ASC AUTOINCREMENT,
name TEXT NOT NULL,
username TEXT,
email TEXT,
active INTEGER NOT NULL
);
CREATE TABLE table_section
(
id INTEGER PRIMARY KEY ASC AUTOINCREMENT,
name TEXT NOT NULL,
parent_id INTEGER,
active INTEGER NOT NULL,
FOREIGN KEY(parent_id) REFERENCES table_section(id)
);
CREATE TABLE table_tag
(
id INTEGER PRIMARY KEY ASC AUTOINCREMENT,
name TEXT NOT NULL,
active INTEGER NOT NULL
);
CREATE TABLE table_content
(
id INTEGER PRIMARY KEY ASC AUTOINCREMENT,
content_blob NOT NULL
);
CREATE TABLE table_entry
(
id INTEGER PRIMARY KEY ASC AUTOINCREMENT,
name TEXT NOT NULL,
content_id INTEGER NOT NULL,
user_id INTEGER NOT NULL,
createdate TEXT,
lastdate TEXT,
section_id INTEGER NOT NULL,
active INTEGER NOT NULL,
FOREIGN KEY(content_id) REFERENCES table_content(id),
FOREIGN KEY(user_id) REFERENCES table_user(id),
FOREIGN KEY(section_id) REFERENCES table_section(id)
);
CREATE TABLE table_entry_tag
(
id INTEGER PRIMARY KEY ASC AUTOINCREMENT,
entry_id INTEGER NOT NULL,
tag_id INTEGER NOT NULL,
active INTEGER NOT NULL,
FOREIGN KEY(entry_id) REFERENCES table_entry(id),
FOREIGN KEY(tag_id) REFERENCES table_tag(id)
);
CREATE TABLE table_attachment
(
id INTEGER PRIMARY KEY ASC AUTOINCREMENT,
name TEXT NOT NULL,
filename TEXT NOT NULL,
description TEXT,
createdate TEXT,
lastdate TEXT,
active INTEGER NOT NULL
);
CREATE TABLE table_entry_attachment
(
id INTEGER PRIMARY KEY ASC AUTOINCREMENT,
entry_id INTEGER NOT NULL,
attachment_id INTEGER NOT NULL,
active INTEGER NOT NULL,
FOREIGN KEY(entry_id) REFERENCES table_entry(id),
FOREIGN KEY(attachment_id) REFERENCES table_attachment(id)
);

CREATE TABLE artist (
  first_name  NOT NULL,
  last_name  NOT NULL,
  id INTEGER PRIMARY KEY NOT NULL,
  created_on DATETIME NOT NULL,
  updated_on DATETIME NOT NULL,
  access_read TEXT NOT NULL,
  access_write TEXT NOT NULL,
  status INTEGER NOT NULL DEFAULT 0,
  data VARCHAR NOT NULL
);
CREATE TABLE cd (
  name  NOT NULL,
  release_date  NOT NULL,
  artist_id  NOT NULL,
  id INTEGER PRIMARY KEY NOT NULL,
  created_on DATETIME NOT NULL,
  updated_on DATETIME NOT NULL,
  access_read TEXT NOT NULL,
  access_write TEXT NOT NULL,
  status INTEGER NOT NULL DEFAULT 0,
  data VARCHAR NOT NULL
);
CREATE UNIQUE INDEX artist_first_name ON artist (first_name);
CREATE INDEX cd_idx_artist_id ON cd (artist_id);
CREATE UNIQUE INDEX cd_name ON cd (name);

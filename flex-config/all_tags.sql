COMMENT ON TABLE osm.tags IS 'OpenStreetMap tag data for all objects in source file.  Key/value data stored in tags column in JSONB format.';
COMMENT ON COLUMN osm.tags.tags IS 'Stores unaltered key/value pairs from OpenStreetMap.  A few tags are dropped by Lua script though most are preserved.';

ALTER TABLE osm.tags
    ADD CONSTRAINT pk_osm_tags_osm_id_type
    PRIMARY KEY (osm_id, geom_type)
;